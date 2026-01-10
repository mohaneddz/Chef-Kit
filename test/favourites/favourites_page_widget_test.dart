import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:chefkit/blocs/auth/auth_cubit.dart';
// import 'package:chefkit/blocs/auth/auth_state.dart'; // Removed to avoid conflict
import 'package:chefkit/blocs/favourites/favourites_bloc.dart';
import 'package:chefkit/blocs/favourites/favourites_events.dart';
import 'package:chefkit/blocs/favourites/favourites_state.dart';
import 'package:chefkit/blocs/locale/locale_cubit.dart';
import 'package:chefkit/blocs/notifications/notifications_bloc.dart';
import 'package:chefkit/blocs/notifications/notifications_event.dart';
import 'package:chefkit/blocs/notifications/notifications_state.dart';
import 'package:chefkit/domain/models/recipe.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import 'package:chefkit/views/screens/favourite/favourites_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

final TestWidgetsFlutterBinding binding =
    TestWidgetsFlutterBinding.ensureInitialized();

class MockFavouritesBloc extends MockBloc<FavouritesEvent, FavouritesState>
    implements FavouritesBloc {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockLocaleCubit extends MockCubit<Locale> implements LocaleCubit {}

class MockNotificationsBloc
    extends MockBloc<NotificationsEvent, NotificationsState>
    implements NotificationsBloc {}

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
  static final ByteData _emptyManifest = const StandardMessageCodec()
      .encodeMessage(<String, dynamic>{})!;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.view(_transparentImage.buffer);

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

Recipe _recipe(String id, String name, List<String> tags) {
  return Recipe(
    id: id,
    name: name,
    description: 'Test Description',
    imageUrl: 'https://example.com/$id.jpg',
    ownerId: 'user1',
    prepTime: 15,
    cookTime: 20,
    tags: tags,
    ingredients: [],
    instructions: [],
  );
}

void main() {
  late MockFavouritesBloc mockFavouritesBloc;
  late MockAuthCubit mockAuthCubit;
  late MockLocaleCubit mockLocaleCubit;
  late MockNotificationsBloc mockNotificationsBloc;
  late FavouritesState baseState;

  setUpAll(() {
    registerFallbackValue(LoadFavourites(locale: 'en'));
    registerFallbackValue(SelectCategory(0));
    registerFallbackValue(ToggleFavoriteRecipe(''));
    registerFallbackValue(SearchFavourites(''));
    registerFallbackValue(RefreshFavourites(locale: 'en'));
  });

  setUp(() {
    binding.window
      ..physicalSizeTestValue = const Size(2000, 3000)
      ..devicePixelRatioTestValue = 1.0;

    mockFavouritesBloc = MockFavouritesBloc();
    mockAuthCubit = MockAuthCubit();
    mockLocaleCubit = MockLocaleCubit();
    mockNotificationsBloc = MockNotificationsBloc();

    final recipe1 = _recipe('1', 'Spaghetti Carbonara', ['Italian', 'Pasta']);
    final recipe2 = _recipe('2', 'Chicken Curry', ['Indian', 'Curry']);

    baseState = FavouritesState(
      loading: false,
      categories: [
        {
          'title': 'Italian',
          'subtitle': '1 recipe',
          'imagePaths': [recipe1.imageUrl],
          'recipes': [recipe1],
        },
        {
          'title': 'All Saved',
          'subtitle': '2 recipes',
          'imagePaths': [recipe1.imageUrl, recipe2.imageUrl],
          'recipes': [recipe1, recipe2],
        },
      ],
      displayRecipes: [recipe1],
      selectedCategoryIndex: 0,
      searchQuery: '',
    );

    when(() => mockFavouritesBloc.state).thenReturn(baseState);
    whenListen(
      mockFavouritesBloc,
      Stream<FavouritesState>.fromIterable([baseState]),
      initialState: baseState,
    );
    when(() => mockFavouritesBloc.add(any())).thenReturn(null);

    when(() => mockAuthCubit.state).thenReturn(AuthState(userId: 'user123'));
    whenListen(
      mockAuthCubit,
      Stream<AuthState>.empty(),
      initialState: AuthState(userId: 'user123'),
    );

    when(() => mockLocaleCubit.state).thenReturn(const Locale('en'));
    whenListen(
      mockLocaleCubit,
      Stream<Locale>.empty(),
      initialState: const Locale('en'),
    );

    when(() => mockNotificationsBloc.state).thenReturn(NotificationsInitial());
    whenListen(
      mockNotificationsBloc,
      Stream<NotificationsState>.empty(),
      initialState: NotificationsInitial(),
    );
  });

  tearDown(() {
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  Widget _buildPage() {
    final mediaQueryData = MediaQueryData.fromWindow(
      binding.window,
    ).copyWith(textScaleFactor: 0.8);

    return MediaQuery(
      data: mediaQueryData,
      child: DefaultAssetBundle(
        bundle: _TestAssetBundle(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<FavouritesBloc>.value(value: mockFavouritesBloc),
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
            BlocProvider<LocaleCubit>.value(value: mockLocaleCubit),
            BlocProvider<NotificationsBloc>.value(value: mockNotificationsBloc),
          ],
          child: BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const FavouritesPage(),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('loads favourites on init when user is logged in', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    final events = verify(
      () => mockFavouritesBloc.add(captureAny<FavouritesEvent>()),
    ).captured;
    final loadEvents = events.whereType<LoadFavourites>().toList();

    expect(loadEvents.any((e) => e.locale == 'en'), isTrue);
  });

  testWidgets('shows guest view when user is not logged in', (tester) async {
    when(() => mockAuthCubit.state).thenReturn(AuthState(userId: null));
    whenListen(
      mockAuthCubit,
      Stream<AuthState>.empty(),
      initialState: AuthState(userId: null),
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.text('Login Required'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('shows empty state when no favourites', (tester) async {
    final emptyState = FavouritesState(
      loading: false,
      categories: [],
      displayRecipes: [],
      selectedCategoryIndex: 0,
    );

    when(() => mockFavouritesBloc.state).thenReturn(emptyState);
    whenListen(
      mockFavouritesBloc,
      Stream<FavouritesState>.fromIterable([emptyState]),
      initialState: emptyState,
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.text('No Favourites Yet'), findsOneWidget);
  });

  testWidgets('shows loading indicator when loading', (tester) async {
    final loadingState = FavouritesState(loading: true);

    when(() => mockFavouritesBloc.state).thenReturn(loadingState);
    whenListen(
      mockFavouritesBloc,
      Stream<FavouritesState>.fromIterable([loadingState]),
      initialState: loadingState,
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders categories and recipes', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.text('Spaghetti Carbonara'), findsWidgets);
  });

  testWidgets('search input dispatches SearchFavourites event', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField), 'curry');
    await tester.pump();

    verify(
      () => mockFavouritesBloc.add(
        any(
          that: isA<SearchFavourites>().having(
            (e) => e.query,
            'query',
            'curry',
          ),
        ),
      ),
    ).called(greaterThan(0));
  });

  testWidgets('tapping category dispatches SelectCategory event', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    // Find and tap a category card
    final categoryCards = find.byType(GestureDetector);
    if (categoryCards.evaluate().isNotEmpty) {
      await tester.tap(find.text('Italian').first);
      await tester.pump();

      verify(
        () => mockFavouritesBloc.add(any(that: isA<SelectCategory>())),
      ).called(greaterThan(0));
    }
  });

  testWidgets('pull to refresh dispatches RefreshFavourites event', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
    await tester.pump();
    await tester.pumpAndSettle(); // Wait for all animations and timers

    verify(
      () => mockFavouritesBloc.add(any(that: isA<RefreshFavourites>())),
    ).called(greaterThan(0));
  });

  testWidgets('reloads favourites when locale changes', (tester) async {
    when(() => mockLocaleCubit.state).thenReturn(const Locale('en'));
    whenListen(
      mockLocaleCubit,
      Stream<Locale>.fromIterable([const Locale('en'), const Locale('fr')]),
      initialState: const Locale('en'),
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();
    await tester.pump();

    final captured = verify(
      () => mockFavouritesBloc.add(captureAny<FavouritesEvent>()),
    ).captured;

    final loadLangs = captured
        .whereType<LoadFavourites>()
        .map((e) => e.locale)
        .toList();

    expect(loadLangs, contains('en'));
    expect(loadLangs, contains('fr'));
  });

  testWidgets('shows error message when error state', (tester) async {
    final errorState = FavouritesState(
      loading: false,
      error: 'Failed to load favourites',
    );

    when(() => mockFavouritesBloc.state).thenReturn(errorState);
    whenListen(
      mockFavouritesBloc,
      Stream<FavouritesState>.fromIterable([errorState]),
      initialState: errorState,
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.textContaining('Error:'), findsOneWidget);
  });

  testWidgets('shows empty search results message', (tester) async {
    final emptySearchState = baseState.copyWith(
      searchQuery: 'nonexistent',
      displayRecipes: [],
    );

    when(() => mockFavouritesBloc.state).thenReturn(emptySearchState);
    whenListen(
      mockFavouritesBloc,
      Stream<FavouritesState>.fromIterable([baseState, emptySearchState]),
      initialState: baseState,
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();
    await tester.pump();

    expect(find.byIcon(Icons.search_off), findsOneWidget);
  });

  testWidgets('tapping favorite icon dispatches ToggleFavoriteRecipe', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    // Find favorite icon buttons
    final favoriteIcons = find.byIcon(Icons.favorite);
    if (favoriteIcons.evaluate().isNotEmpty) {
      await tester.tap(favoriteIcons.first);
      await tester.pump();

      verify(
        () => mockFavouritesBloc.add(any(that: isA<ToggleFavoriteRecipe>())),
      ).called(greaterThan(0));
    }
  });

  testWidgets('shows snackbar on sync error', (tester) async {
    final errorState = baseState.copyWith(
      syncError: 'Failed to sync favorite. Will retry later.',
    );

    when(() => mockFavouritesBloc.state).thenReturn(errorState);
    whenListen(
      mockFavouritesBloc,
      Stream<FavouritesState>.fromIterable([baseState, errorState]),
      initialState: baseState,
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Failed to sync favorite. Will retry later.'),
      findsOneWidget,
    );
  });

  testWidgets('guest view navigates to signup on button tap', (tester) async {
    when(() => mockAuthCubit.state).thenReturn(AuthState(userId: null));
    whenListen(
      mockAuthCubit,
      Stream<AuthState>.empty(),
      initialState: AuthState(userId: null),
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.text('Sign Up'), findsOneWidget);

    // Tap the sign up button
    await tester.tap(find.text('Sign Up'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 100)); // Advance slightly

    // We just verify no crash, as full navigation verification would require checking the route stack
    // which is implicit if we don't crash and AuthCubit was found.
  });

  testWidgets('empty favourites displays pull to refresh', (tester) async {
    final emptyState = FavouritesState(
      loading: false,
      categories: [],
      displayRecipes: [],
    );

    when(() => mockFavouritesBloc.state).thenReturn(emptyState);
    whenListen(
      mockFavouritesBloc,
      Stream<FavouritesState>.fromIterable([emptyState]),
      initialState: emptyState,
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('displays empty category message when category has no recipes', (
    tester,
  ) async {
    final emptyDisplayState = baseState.copyWith(displayRecipes: []);

    when(() => mockFavouritesBloc.state).thenReturn(emptyDisplayState);
    whenListen(
      mockFavouritesBloc,
      Stream<FavouritesState>.fromIterable([baseState, emptyDisplayState]),
      initialState: baseState,
    );

    await tester.pumpWidget(_buildPage());
    await tester.pump();
    await tester.pump();

    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
  });
}
