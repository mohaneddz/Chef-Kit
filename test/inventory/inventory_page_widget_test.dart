import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:chefkit/blocs/inventory/inventory_bloc.dart';
import 'package:chefkit/blocs/inventory/inventory_event.dart';
import 'package:chefkit/blocs/inventory/inventory_state.dart';
import 'package:chefkit/blocs/locale/locale_cubit.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import 'package:chefkit/views/screens/inventory/inventory_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();

class MockInventoryBloc extends MockBloc<InventoryEvent, InventoryState>
    implements InventoryBloc {}

class MockLocaleCubit extends MockCubit<Locale> implements LocaleCubit {}

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

Map<String, String> _ingredient(String key, String name, String type) {
  return {
    "key": key,
    "name_en": name,
    "type_en": type,
    "imageUrl": "assets/images/ingredients/$key.png",
  };
}

void main() {
  late MockInventoryBloc mockInventoryBloc;
  late MockLocaleCubit mockLocaleCubit;
  late InventoryState baseState;

  setUpAll(() {
    registerFallbackValue(LoadInventoryEvent('en'));
    registerFallbackValue(SearchInventoryEvent(''));
    registerFallbackValue(AddIngredientEvent(<String, String>{}));
    registerFallbackValue(RemoveIngredientEvent(<String, String>{}));
    registerFallbackValue(ToggleShowMoreEvent());
  });

  setUp(() {
    binding.window
      ..physicalSizeTestValue = const Size(2000, 3000)
      ..devicePixelRatioTestValue = 1.0;

    mockInventoryBloc = MockInventoryBloc();
    mockLocaleCubit = MockLocaleCubit();

    baseState = InventoryState(
      available: [_ingredient('broccoli', 'Broccoli', 'Vegetables')],
      browse: [
        _ingredient('tomato', 'Tomato', 'Vegetables'),
        _ingredient('onion', 'Onion', 'Vegetables'),
      ],
      showMore: false,
      searchTerm: '',
      currentLang: 'en',
    );

    when(() => mockInventoryBloc.state).thenReturn(baseState);
    whenListen(
      mockInventoryBloc,
      Stream<InventoryState>.fromIterable([baseState]),
      initialState: baseState,
    );
    when(() => mockInventoryBloc.add(any())).thenReturn(null);

    when(() => mockLocaleCubit.state).thenReturn(const Locale('en'));
    whenListen(
      mockLocaleCubit,
      Stream<Locale>.empty(),
      initialState: const Locale('en'),
    );
  });

  tearDown(() {
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  Widget _buildPage() {
    final mediaQueryData = MediaQueryData.fromWindow(binding.window).copyWith(
      textScaleFactor: 0.8,
    );

    return MediaQuery(
      data: mediaQueryData,
      child: DefaultAssetBundle(
        bundle: _TestAssetBundle(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<InventoryBloc>.value(value: mockInventoryBloc),
              BlocProvider<LocaleCubit>.value(value: mockLocaleCubit),
            ],
            child: const InventoryPage(),
          ),
        ),
      ),
    );
  }

  testWidgets('loads inventory on init and renders available/browse items', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    final events = verify(
      () => mockInventoryBloc.add(captureAny<InventoryEvent>()),
    ).captured;
    final loadEvents = events.whereType<LoadInventoryEvent>().toList();

    expect(loadEvents.any((e) => e.langCode == 'en'), isTrue);

    expect(find.text('Broccoli'), findsOneWidget);
    expect(find.text('Tomato'), findsOneWidget);
    expect(find.text('Onion'), findsOneWidget);
  });

  testWidgets('search input dispatches SearchInventoryEvent', (tester) async {
    final searchedState = baseState.copyWith(
      searchTerm: 'tom',
      browse: [
        _ingredient('tomato', 'Tomato', 'Vegetables'),
        _ingredient('onion', 'Onion', 'Vegetables'),
      ],
    );

    when(() => mockInventoryBloc.state).thenReturn(searchedState);
    whenListen(
      mockInventoryBloc,
      Stream<InventoryState>.fromIterable([baseState, searchedState]),
      initialState: baseState,
    );

    await tester.pumpWidget(_buildPage());
    await tester.enterText(find.byType(TextFormField), 'tom');
    await tester.pump();

    verify(
      () => mockInventoryBloc.add(
        any(that: isA<SearchInventoryEvent>().having((e) => e.searchTerm, 'term', 'tom')),
      ),
    ).called(1);

    expect(find.text('Tomato'), findsOneWidget);
    expect(find.text('Onion'), findsNothing);
  });

  testWidgets('tapping Add and Delete triggers bloc events', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.tap(find.text('Add').first);
    await tester.pump();

    verify(
      () => mockInventoryBloc.add(
        any(that: isA<AddIngredientEvent>()),
      ),
    ).called(1);

    await tester.tap(find.text('Delete'));
    await tester.pump();

    verify(
      () => mockInventoryBloc.add(
        any(that: isA<RemoveIngredientEvent>()),
      ),
    ).called(1);
  });

  testWidgets('Show more button dispatches ToggleShowMoreEvent when available > 10', (tester) async {
    final longListState = InventoryState(
      available: List.generate(
        11,
        (i) => _ingredient('item_$i', 'Item $i', 'Vegetables'),
      ),
      browse: baseState.browse,
      showMore: false,
      searchTerm: '',
      currentLang: 'en',
    );

    when(() => mockInventoryBloc.state).thenReturn(longListState);
    whenListen(
      mockInventoryBloc,
      Stream<InventoryState>.fromIterable([longListState]),
      initialState: longListState,
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.tap(find.text('Show more'));
    await tester.pump();

    verify(() => mockInventoryBloc.add(any(that: isA<ToggleShowMoreEvent>()))).called(1);
  });

  testWidgets('hides available section when searching', (tester) async {
    final searchingState = baseState.copyWith(
      searchTerm: 'tom',
    );

    when(() => mockInventoryBloc.state).thenReturn(searchingState);
    whenListen(
      mockInventoryBloc,
      Stream<InventoryState>.fromIterable([baseState, searchingState]),
      initialState: baseState,
    );

    await tester.pumpWidget(_buildPage());
    await tester.enterText(find.byType(TextFormField), 'tom');
    await tester.pump();

    expect(find.text('Available Ingredients'), findsNothing);
    expect(find.text('Broccoli'), findsNothing);
    expect(find.text('Tomato'), findsOneWidget);
    expect(find.text('Onion'), findsNothing);
  });

  testWidgets('filters browse grid by ingredient type selection', (tester) async {
    final typedState = baseState.copyWith(
      browse: [
        _ingredient('tomato', 'Tomato', 'Vegetables'),
        _ingredient('onion', 'Onion', 'Vegetables'),
        _ingredient('chicken', 'Chicken', 'Protein'),
      ],
    );

    when(() => mockInventoryBloc.state).thenReturn(typedState);
    whenListen(
      mockInventoryBloc,
      Stream<InventoryState>.fromIterable([typedState]),
      initialState: typedState,
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.tap(find.text('Protein').first);
    await tester.pump();

    expect(find.text('Chicken'), findsOneWidget);
    expect(find.text('Tomato'), findsNothing);
    expect(find.text('Onion'), findsNothing);
  });

  testWidgets('reloads inventory when locale changes', (tester) async {
    when(() => mockInventoryBloc.state).thenReturn(baseState);
    whenListen(
      mockInventoryBloc,
      Stream<InventoryState>.fromIterable([baseState]),
      initialState: baseState,
    );

    when(() => mockLocaleCubit.state).thenReturn(const Locale('en'));
    whenListen(
      mockLocaleCubit,
      Stream<Locale>.fromIterable([
        const Locale('en'),
        const Locale('fr'),
      ]),
      initialState: const Locale('en'),
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();
    await tester.pump();

    final captured = verify(
      () => mockInventoryBloc.add(captureAny<InventoryEvent>()),
    ).captured;

    final loadLangs = captured
        .whereType<LoadInventoryEvent>()
        .map((e) => e.langCode)
        .toList();

    expect(loadLangs, contains('en'));
    expect(loadLangs, contains('fr'));
  });
}
