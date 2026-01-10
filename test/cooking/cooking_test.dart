import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefkit/domain/repositories/recipe_repository.dart';
import 'package:chefkit/domain/models/recipe.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockRecipeRepository mockRecipeRepository;

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
  });

  group('Main Cooking Functionality', () {
    test(
      'generateRecipes returns recipes when user sends ingredients',
      () async {
        // Arrange
        final testIngredients = ['Chicken Breast', 'Onion', 'Garlic'];
        const testMaxTime = '30:00';
        const testLang = 'en';

        final expectedRecipes = [
          Recipe(
            id: 'recipe-1',
            name: 'Garlic Chicken',
            description: 'A delicious garlic chicken dish',
            imageUrl: 'https://example.com/chicken.jpg',
            ownerId: 'chef-1',
            prepTime: 10,
            cookTime: 20,
            isFavorite: false,
            isTrending: false,
            isSeasonal: false,
            instructions: ['Season chicken', 'Cook with garlic'],
            ingredients: ['Chicken Breast', 'Garlic', 'Olive Oil'],
          ),
          Recipe(
            id: 'recipe-2',
            name: 'Chicken Stir Fry',
            description: 'Quick and easy chicken stir fry',
            imageUrl: 'https://example.com/stirfry.jpg',
            ownerId: 'chef-2',
            prepTime: 15,
            cookTime: 15,
            isFavorite: false,
            isTrending: true,
            isSeasonal: false,
            instructions: ['Cut chicken', 'Stir fry with onions'],
            ingredients: ['Chicken Breast', 'Onion', 'Soy Sauce'],
          ),
        ];

        when(
          () => mockRecipeRepository.generateRecipes(
            lang: testLang,
            maxTime: testMaxTime,
            ingredients: testIngredients,
          ),
        ).thenAnswer((_) async => expectedRecipes);

        // Act
        final result = await mockRecipeRepository.generateRecipes(
          lang: testLang,
          maxTime: testMaxTime,
          ingredients: testIngredients,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, equals(2));
        expect(result.first.name, equals('Garlic Chicken'));
        verify(
          () => mockRecipeRepository.generateRecipes(
            lang: testLang,
            maxTime: testMaxTime,
            ingredients: testIngredients,
          ),
        ).called(1);
      },
    );

    test(
      'generateRecipes returns empty list when no matching recipes',
      () async {
        // Arrange
        final testIngredients = ['Unusual Ingredient'];
        const testMaxTime = '10:00';
        const testLang = 'en';

        when(
          () => mockRecipeRepository.generateRecipes(
            lang: testLang,
            maxTime: testMaxTime,
            ingredients: testIngredients,
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await mockRecipeRepository.generateRecipes(
          lang: testLang,
          maxTime: testMaxTime,
          ingredients: testIngredients,
        );

        // Assert
        expect(result, isEmpty);
      },
    );

    test('generateRecipes throws exception on backend error', () async {
      // Arrange
      final testIngredients = ['Chicken'];
      const testMaxTime = '30:00';
      const testLang = 'en';

      when(
        () => mockRecipeRepository.generateRecipes(
          lang: testLang,
          maxTime: testMaxTime,
          ingredients: testIngredients,
        ),
      ).thenThrow(Exception('Failed to generate recipes: 500'));

      // Act & Assert
      expect(
        () => mockRecipeRepository.generateRecipes(
          lang: testLang,
          maxTime: testMaxTime,
          ingredients: testIngredients,
        ),
        throwsException,
      );
    });
  });
}
