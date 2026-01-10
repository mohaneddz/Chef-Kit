import 'package:bloc_test/bloc_test.dart';
import 'package:chefkit/blocs/favourites/favourites_bloc.dart';
import 'package:chefkit/blocs/favourites/favourites_events.dart';
import 'package:chefkit/blocs/favourites/favourites_state.dart';
import 'package:chefkit/domain/models/recipe.dart';
import 'package:chefkit/domain/repositories/recipe_repository.dart';
import 'package:chefkit/common/favorites_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockFavoritesCacheService extends Mock implements FavoritesCacheService {}

void main() {
  late FavouritesBloc favouritesBloc;
  late MockRecipeRepository mockRecipeRepository;
  late MockFavoritesCacheService mockFavoritesCacheService;

  final Recipe mockRecipe1 = Recipe(
    id: '1',
    name: 'Spaghetti Carbonara',
    description: 'Delicious Italian pasta',
    imageUrl: 'https://example.com/carbonara.jpg',
    ownerId: 'user1',
    prepTime: 15,
    cookTime: 20,
    tags: ['Italian', 'Pasta'],
    tagsFr: ['Italien', 'Pâtes'],
    tagsAr: ['إيطالي', 'معكرونة'],
    ingredients: [],
    instructions: [],
  );

  final Recipe mockRecipe2 = Recipe(
    id: '2',
    name: 'Chicken Curry',
    description: 'Spicy Indian chicken',
    imageUrl: 'https://example.com/curry.jpg',
    ownerId: 'user1',
    prepTime: 20,
    cookTime: 30,
    tags: ['Indian', 'Curry'],
    tagsFr: ['Indien', 'Curry'],
    tagsAr: ['هندي', 'كاري'],
    ingredients: [],
    instructions: [],
  );

  final Recipe mockRecipe3 = Recipe(
    id: '3',
    name: 'Caesar Salad',
    description: 'Fresh salad',
    imageUrl: 'https://example.com/salad.jpg',
    ownerId: 'user2',
    prepTime: 10,
    cookTime: 0,
    tags: ['Salad', 'Healthy'],
    tagsFr: ['Salade', 'Sain'],
    tagsAr: ['سلطة', 'صحي'],
    ingredients: [],
    instructions: [],
  );

  setUpAll(() {
    registerFallbackValue(LoadFavourites(locale: 'en'));
    registerFallbackValue(SelectCategory(0));
    registerFallbackValue(ToggleFavoriteRecipe(''));
    registerFallbackValue(SearchFavourites(''));
    registerFallbackValue(RefreshFavourites(locale: 'en'));
  });

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    mockFavoritesCacheService = MockFavoritesCacheService();

    // Default stubs
    when(
      () => mockFavoritesCacheService.toggleFavorite(any()),
    ).thenAnswer((_) async => true);

    favouritesBloc = FavouritesBloc(
      recipeRepository: mockRecipeRepository,
      cacheService: mockFavoritesCacheService,
    );
  });

  tearDown(() async {
    await favouritesBloc.close();
  });

  group('FavouritesBloc Tests', () {
    test('initial state is correct', () {
      expect(favouritesBloc.state.loading, false);
      expect(favouritesBloc.state.categories, isEmpty);
      expect(favouritesBloc.state.displayRecipes, isEmpty);
      expect(favouritesBloc.state.selectedCategoryIndex, 0);
      expect(favouritesBloc.state.searchQuery, '');
      expect(favouritesBloc.state.error, isNull);
      expect(favouritesBloc.state.syncError, isNull);
    });

    blocTest<FavouritesBloc, FavouritesState>(
      'emits loading then success when LoadFavourites is added',
      setUp: () {
        when(
          () => mockRecipeRepository.fetchFavoriteRecipes(),
        ).thenAnswer((_) async => [mockRecipe1, mockRecipe2]);
      },
      build: () => FavouritesBloc(
        recipeRepository: mockRecipeRepository,
        cacheService: mockFavoritesCacheService,
      ),
      act: (bloc) => bloc.add(
        LoadFavourites(
          allSavedText: 'All Saved',
          recipeText: 'recipe',
          recipesText: 'recipes',
          locale: 'en',
          otherText: 'Other',
        ),
      ),
      expect: () => [
        isA<FavouritesState>().having((s) => s.loading, 'loading', true),
        isA<FavouritesState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.categories.isNotEmpty, 'has categories', true)
            .having((s) => s.displayRecipes.isNotEmpty, 'has recipes', true),
      ],
      verify: (_) {
        verify(() => mockRecipeRepository.fetchFavoriteRecipes()).called(1);
      },
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'groups recipes by tags correctly',
      setUp: () {
        when(
          () => mockRecipeRepository.fetchFavoriteRecipes(),
        ).thenAnswer((_) async => [mockRecipe1, mockRecipe2, mockRecipe3]);
      },
      build: () => FavouritesBloc(
        recipeRepository: mockRecipeRepository,
        cacheService: mockFavoritesCacheService,
      ),
      act: (bloc) => bloc.add(
        LoadFavourites(
          allSavedText: 'All Saved',
          recipeText: 'recipe',
          recipesText: 'recipes',
          locale: 'en',
        ),
      ),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.categories.isNotEmpty, true);

        // Check that "All Saved" category is last and contains all recipes
        final allSavedCategory = state.categories.last;
        expect(allSavedCategory['title'], 'All Saved');
        expect((allSavedCategory['recipes'] as List).length, 3);

        // Verify categories are created for tags
        final categoryTitles = state.categories
            .map((c) => c['title'] as String)
            .toList();
        expect(
          categoryTitles.contains('Italian') ||
              categoryTitles.contains('Pasta'),
          true,
        );
      },
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'uses localized tags when locale is fr',
      setUp: () {
        when(
          () => mockRecipeRepository.fetchFavoriteRecipes(),
        ).thenAnswer((_) async => [mockRecipe1]);
      },
      build: () => FavouritesBloc(
        recipeRepository: mockRecipeRepository,
        cacheService: mockFavoritesCacheService,
      ),
      act: (bloc) => bloc.add(
        LoadFavourites(
          allSavedText: 'Tous enregistrés',
          recipeText: 'recette',
          recipesText: 'recettes',
          locale: 'fr',
        ),
      ),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final categoryTitles = bloc.state.categories
            .map((c) => c['title'] as String)
            .toList();
        expect(
          categoryTitles.contains('Italien') ||
              categoryTitles.contains('Pâtes'),
          true,
        );
      },
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'SelectCategory updates selected index and display recipes',
      setUp: () {
        when(
          () => mockRecipeRepository.fetchFavoriteRecipes(),
        ).thenAnswer((_) async => [mockRecipe1, mockRecipe2]);
      },
      build: () => FavouritesBloc(
        recipeRepository: mockRecipeRepository,
        cacheService: mockFavoritesCacheService,
      ),
      seed: () {
        final categories = [
          {
            'title': 'Italian',
            'subtitle': '1 recipe',
            'imagePaths': [mockRecipe1.imageUrl],
            'recipes': [mockRecipe1],
          },
          {
            'title': 'Indian',
            'subtitle': '1 recipe',
            'imagePaths': [mockRecipe2.imageUrl],
            'recipes': [mockRecipe2],
          },
        ];
        return FavouritesState(
          loading: false,
          categories: categories,
          displayRecipes: [mockRecipe1],
          selectedCategoryIndex: 0,
        );
      },
      act: (bloc) => bloc.add(SelectCategory(1)),
      expect: () => [
        isA<FavouritesState>()
            .having((s) => s.selectedCategoryIndex, 'index', 1)
            .having((s) => s.displayRecipes.first.id, 'recipe', '2'),
      ],
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'SearchFavourites filters display recipes by query',
      build: () => FavouritesBloc(
        recipeRepository: mockRecipeRepository,
        cacheService: mockFavoritesCacheService,
      ),
      seed: () {
        final categories = [
          {
            'title': 'All',
            'subtitle': '2 recipes',
            'imagePaths': [],
            'recipes': [mockRecipe1, mockRecipe2],
          },
        ];
        return FavouritesState(
          loading: false,
          categories: categories,
          displayRecipes: [mockRecipe1, mockRecipe2],
          selectedCategoryIndex: 0,
        );
      },
      act: (bloc) => bloc.add(SearchFavourites('curry')),
      expect: () => [
        isA<FavouritesState>()
            .having((s) => s.searchQuery, 'query', 'curry')
            .having((s) => s.displayRecipes.length, 'count', 1)
            .having(
              (s) => s.displayRecipes.first.name,
              'name',
              'Chicken Curry',
            ),
      ],
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'SearchFavourites returns all when query is empty',
      build: () => FavouritesBloc(
        recipeRepository: mockRecipeRepository,
        cacheService: mockFavoritesCacheService,
      ),
      seed: () {
        final categories = [
          {
            'title': 'All',
            'subtitle': '2 recipes',
            'imagePaths': [],
            'recipes': [mockRecipe1, mockRecipe2],
          },
        ];
        return FavouritesState(
          loading: false,
          categories: categories,
          displayRecipes: [mockRecipe1],
          selectedCategoryIndex: 0,
          searchQuery: 'old',
        );
      },
      act: (bloc) => bloc.add(SearchFavourites('')),
      expect: () => [
        isA<FavouritesState>()
            .having((s) => s.searchQuery, 'query', '')
            .having((s) => s.displayRecipes.length, 'count', 2),
      ],
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'ToggleFavoriteRecipe removes recipe optimistically and syncs',
      setUp: () {
        when(
          () => mockRecipeRepository.toggleFavorite(any()),
        ).thenAnswer((_) async => mockRecipe1);
        when(
          () => mockFavoritesCacheService.toggleFavorite(any()),
        ).thenAnswer((_) async => true);
      },
      build: () => FavouritesBloc(
        recipeRepository: mockRecipeRepository,
        cacheService: mockFavoritesCacheService,
      ),
      seed: () {
        final categories = [
          {
            'title': 'All',
            'subtitle': '2 recipes',
            'imagePaths': [mockRecipe1.imageUrl, mockRecipe2.imageUrl],
            'recipes': [mockRecipe1, mockRecipe2],
          },
        ];
        return FavouritesState(
          loading: false,
          categories: categories,
          displayRecipes: [mockRecipe1, mockRecipe2],
          selectedCategoryIndex: 0,
        );
      },
      act: (bloc) => bloc.add(ToggleFavoriteRecipe('1')),
      expect: () => [
        isA<FavouritesState>()
            .having((s) => s.displayRecipes.length, 'count', 1)
            .having((s) => s.displayRecipes.first.id, 'remaining id', '2'),
      ],
      verify: (_) {
        verify(() => mockFavoritesCacheService.toggleFavorite('1')).called(1);
        verify(() => mockRecipeRepository.toggleFavorite('1')).called(1);
      },
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'ToggleFavoriteRecipe shows syncError when repository fails',
      setUp: () {
        when(
          () => mockRecipeRepository.toggleFavorite(any()),
        ).thenThrow(Exception('Network error'));
        when(
          () => mockFavoritesCacheService.toggleFavorite(any()),
        ).thenAnswer((_) async => true);
      },
      build: () => FavouritesBloc(
        recipeRepository: mockRecipeRepository,
        cacheService: mockFavoritesCacheService,
      ),
      seed: () {
        final categories = [
          {
            'title': 'All',
            'subtitle': '1 recipe',
            'imagePaths': [mockRecipe1.imageUrl],
            'recipes': [mockRecipe1],
          },
        ];
        return FavouritesState(
          loading: false,
          categories: categories,
          displayRecipes: [mockRecipe1],
          selectedCategoryIndex: 0,
        );
      },
      act: (bloc) => bloc.add(ToggleFavoriteRecipe('1')),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.syncError, isNotNull);
        expect(bloc.state.syncError!.contains('Failed to sync'), true);
        // Recipe should still be removed optimistically
        expect(bloc.state.displayRecipes.length, 0);

        verify(() => mockFavoritesCacheService.toggleFavorite('1')).called(1);
      },
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'RefreshFavourites loads data without showing loading state',
      setUp: () {
        when(
          () => mockRecipeRepository.fetchFavoriteRecipes(),
        ).thenAnswer((_) async => [mockRecipe1]);
      },
      build: () => FavouritesBloc(
        recipeRepository: mockRecipeRepository,
        cacheService: mockFavoritesCacheService,
      ),
      act: (bloc) => bloc.add(
        RefreshFavourites(
          allSavedText: 'All Saved',
          recipeText: 'recipe',
          recipesText: 'recipes',
          locale: 'en',
        ),
      ),
      expect: () => [
        isA<FavouritesState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.categories.isNotEmpty, 'has categories', true),
      ],
      verify: (_) {
        verify(() => mockRecipeRepository.fetchFavoriteRecipes()).called(1);
      },
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'emits error state when repository throws',
      setUp: () {
        when(
          () => mockRecipeRepository.fetchFavoriteRecipes(),
        ).thenThrow(Exception('Failed to load'));
      },
      build: () => FavouritesBloc(
        recipeRepository: mockRecipeRepository,
        cacheService: mockFavoritesCacheService,
      ),
      act: (bloc) => bloc.add(
        LoadFavourites(
          allSavedText: 'All Saved',
          recipeText: 'recipe',
          recipesText: 'recipes',
          locale: 'en',
        ),
      ),
      expect: () => [
        isA<FavouritesState>().having((s) => s.loading, 'loading', true),
        isA<FavouritesState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'SelectCategory ignores invalid index',
      build: () => FavouritesBloc(
        recipeRepository: mockRecipeRepository,
        cacheService: mockFavoritesCacheService,
      ),
      seed: () {
        final categories = [
          {
            'title': 'All',
            'subtitle': '1 recipe',
            'imagePaths': [],
            'recipes': [mockRecipe1],
          },
        ];
        return FavouritesState(
          loading: false,
          categories: categories,
          displayRecipes: [mockRecipe1],
          selectedCategoryIndex: 0,
        );
      },
      act: (bloc) => bloc.add(SelectCategory(5)),
      expect: () => [],
    );

    blocTest<FavouritesBloc, FavouritesState>(
      'SearchFavourites respects selected category',
      build: () => FavouritesBloc(
        recipeRepository: mockRecipeRepository,
        cacheService: mockFavoritesCacheService,
      ),
      seed: () {
        final categories = [
          {
            'title': 'Italian',
            'subtitle': '1 recipe',
            'imagePaths': [],
            'recipes': [mockRecipe1],
          },
          {
            'title': 'All',
            'subtitle': '2 recipes',
            'imagePaths': [],
            'recipes': [mockRecipe1, mockRecipe2],
          },
        ];
        return FavouritesState(
          loading: false,
          categories: categories,
          displayRecipes: [mockRecipe1],
          selectedCategoryIndex: 0, // Italian category selected
        );
      },
      act: (bloc) => bloc.add(SearchFavourites('chicken')),
      expect: () => [
        isA<FavouritesState>()
            .having((s) => s.searchQuery, 'query', 'chicken')
            .having(
              (s) => s.displayRecipes.length,
              'count',
              0,
            ), // No chicken in Italian
      ],
    );
  });
}
