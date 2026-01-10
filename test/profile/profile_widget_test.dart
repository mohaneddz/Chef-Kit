import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:chefkit/blocs/profile/profile_bloc.dart';
import 'package:chefkit/blocs/profile/profile_state.dart';
import 'package:chefkit/blocs/profile/profile_events.dart';
import 'package:chefkit/blocs/locale/locale_cubit.dart';
import 'package:chefkit/blocs/theme/theme_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chefkit/l10n/app_localizations.dart';

import '../helpers/mocks.dart';

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class MockLocaleCubit extends MockCubit<Locale> implements LocaleCubit {}

class MockThemeCubit extends MockCubit<ThemeMode> implements ThemeCubit {}

void main() {
  late MockProfileBloc mockProfileBloc;
  late MockLocaleCubit mockLocaleCubit;
  late MockThemeCubit mockThemeCubit;

  setUp(() {
    mockProfileBloc = MockProfileBloc();
    mockLocaleCubit = MockLocaleCubit();
    mockThemeCubit = MockThemeCubit();
    when(() => mockLocaleCubit.state).thenReturn(const Locale('en'));
    when(() => mockThemeCubit.state).thenReturn(ThemeMode.light);
  });

  Widget buildWidget(ProfileState state) {
    when(() => mockProfileBloc.state).thenReturn(state);
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
          BlocProvider<LocaleCubit>.value(value: mockLocaleCubit),
          BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
        ],
        child: Scaffold(
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state.loading)
                return const Center(child: CircularProgressIndicator());
              if (state.error != null)
                return Center(child: Text('Error: ${state.error}'));
              if (state.profile == null)
                return const Center(child: Text('No data'));
              return Center(child: Text(state.profile!.name));
            },
          ),
        ),
      ),
    );
  }

  group('ProfilePage', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(buildWidget(ProfileState(loading: true)));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays profile name when loaded', (tester) async {
      final profile = createTestUserProfile(
        name: 'John Doe',
        email: 'john@example.com',
      );
      await tester.pumpWidget(buildWidget(ProfileState(profile: profile)));
      await tester.pump();
      expect(find.text('John Doe'), findsOneWidget);
    });
  });
}
