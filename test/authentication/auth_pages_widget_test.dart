import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import 'package:chefkit/views/screens/authentication/login_page.dart';
import 'package:chefkit/views/screens/authentication/otp_verify_page.dart';
import 'package:chefkit/views/screens/authentication/singup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class _TestAssetBundle extends CachingAssetBundle {
  static final Uint8List _transparentImage = Uint8List.fromList(const <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, //
    0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, //
    0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, //
    0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]);
  static final ByteData _emptyManifest =
      const StandardMessageCodec().encodeMessage(<String, dynamic>{})!;

  @override
  Future<ByteData> load(String key) async => ByteData.view(_transparentImage.buffer);

  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async {
    if (key == 'AssetManifest.bin') {
      return parser(_emptyManifest);
    }
    return parser(ByteData(0));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => '{}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthCubit mockAuthCubit;

  setUp(() {
    binding.window
      ..physicalSizeTestValue = const Size(1400, 2600)
      ..devicePixelRatioTestValue = 1.0;

    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.clearAuthFieldErrors()).thenReturn(null);
    when(() => mockAuthCubit.login(any(), any())).thenAnswer((_) async {});
    when(() => mockAuthCubit.signup(any(), any(), any(), any())).thenAnswer((_) async {});
  });

  tearDown(() {
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  Widget _wrapWithApp(
    Widget child, {
    AuthState? state,
    Stream<AuthState>? stream,
    NavigatorObserver? observer,
  }) {
    final initialState = state ?? AuthState();
    var currentState = initialState;

    when(() => mockAuthCubit.state).thenAnswer((_) => currentState);
    whenListen(
      mockAuthCubit,
      (stream ?? Stream<AuthState>.empty()).map((s) {
        currentState = s;
        return s;
      }),
      initialState: initialState,
    );

    final mediaQueryData = MediaQueryData.fromWindow(binding.window).copyWith(
      textScaleFactor: 0.7,
    );

    return MediaQuery(
      data: mediaQueryData,
      child: DefaultAssetBundle(
        bundle: _TestAssetBundle(),
        child: BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            navigatorObservers: [
              if (observer != null) observer,
            ],
            home: child,
          ),
        ),
      ),
    );
  }

  group('LoginPage widget', () {
    testWidgets('clears errors when page initializes', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const LoginPage()));
      await tester.pump();

      verify(() => mockAuthCubit.clearAuthFieldErrors()).called(1);
    });

    testWidgets('submits trimmed credentials to cubit', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const LoginPage()));

      await tester.enterText(find.byType(TextFormField).at(0), ' user@test.com ');
      await tester.enterText(find.byType(TextFormField).at(1), ' pass1234 ');

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      verify(() => mockAuthCubit.login('user@test.com', 'pass1234')).called(1);
    });

    testWidgets('renders field error from cubit state', (tester) async {
      final errorState = AuthState(fieldErrors: {'email': 'Invalid email format'});
      await tester.pumpWidget(
        _wrapWithApp(
          const LoginPage(),
          state: errorState,
          stream: Stream<AuthState>.fromIterable([errorState]),
        ),
      );
      await tester.pump();

      expect(find.text('Invalid email format'), findsOneWidget);
    });

    testWidgets('shows snackbar for generic auth error', (tester) async {
      final errorState = AuthState(error: 'Server down');

      await tester.pumpWidget(
        _wrapWithApp(
          const LoginPage(),
          stream: Stream<AuthState>.fromIterable([
            AuthState(),
            errorState,
          ]),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Server down'), findsOneWidget);
    });

    testWidgets('disables sign in button while loading', (tester) async {
      final loadingState = AuthState(loading: true);
      await tester.pumpWidget(
        _wrapWithApp(
          const LoginPage(),
          state: loadingState,
          stream: Stream<AuthState>.fromIterable([loadingState]),
        ),
      );
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('navigates to OTP page when needsOtp is true', (tester) async {
      final otpState = AuthState(needsOtp: true);
      final observer = MockNavigatorObserver();
      when(() => mockAuthCubit.pendingEmail).thenReturn('pending@test.com');

      await tester.pumpWidget(
        _wrapWithApp(
          const LoginPage(),
          stream: Stream<AuthState>.fromIterable([
            AuthState(),
            otpState,
          ]),
          observer: observer,
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(OtpVerifyPage), findsOneWidget);
    });
  });

  group('SingupPage widget', () {
    testWidgets('clears errors when page initializes', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const SingupPage()));
      await tester.pump();

      verify(() => mockAuthCubit.clearAuthFieldErrors()).called(1);
    });

    testWidgets('submits trimmed signup data to cubit', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const SingupPage()));

      await tester.enterText(find.byType(TextFormField).at(0), ' Jane Doe ');
      await tester.enterText(find.byType(TextFormField).at(1), ' jane@test.com ');
      await tester.enterText(find.byType(TextFormField).at(2), ' password123 ');
      await tester.enterText(find.byType(TextFormField).at(3), ' password123 ');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      verify(
        () => mockAuthCubit.signup(
          'Jane Doe',
          'jane@test.com',
          'password123',
          'password123',
        ),
      ).called(1);
    });

    testWidgets('shows confirm password error when provided by cubit', (tester) async {
      final errorState = AuthState(fieldErrors: {'confirm': 'Passwords don’t match'});
      await tester.pumpWidget(
        _wrapWithApp(
          const SingupPage(),
          state: errorState,
          stream: Stream<AuthState>.fromIterable([errorState]),
        ),
      );
      await tester.pump();

      expect(find.text('Passwords don’t match'), findsOneWidget);
    });

    testWidgets('disables signup button while loading', (tester) async {
      final loadingState = AuthState(loading: true);

      await tester.pumpWidget(
        _wrapWithApp(
          const SingupPage(),
          state: loadingState,
          stream: Stream<AuthState>.fromIterable([loadingState]),
        ),
      );
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows snackbar for signup error without field errors', (tester) async {
      final errorState = AuthState(error: 'Signup failed');

      await tester.pumpWidget(
        _wrapWithApp(
          const SingupPage(),
          stream: Stream<AuthState>.fromIterable([
            AuthState(),
            errorState,
          ]),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Signup failed'), findsOneWidget);
    });

    testWidgets('navigates to OTP verify page after successful signup', (tester) async {
      final controller = StreamController<AuthState>();
      final observer = MockNavigatorObserver();
      addTearDown(() => controller.close());

      await tester.pumpWidget(
        _wrapWithApp(
          const SingupPage(),
          stream: controller.stream,
          observer: observer,
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(1), ' user@test.com ');
      await tester.pump();

      controller.add(AuthState(signedUp: true));
      await tester.pump();
      await tester.pump();

      expect(find.byType(OtpVerifyPage), findsOneWidget);
    });
  });
}
