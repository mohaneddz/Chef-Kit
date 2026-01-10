import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:chefkit/blocs/discovery/discovery_bloc.dart';
import 'package:chefkit/blocs/discovery/discovery_events.dart';
import 'package:chefkit/blocs/discovery/discovery_state.dart';

import '../helpers/mocks.dart';

void main() {
  late MockChefRepository mockChefRepository;
  late MockRecipeRepository mockRecipeRepository;

  setUp(() {
    mockChefRepository = MockChefRepository();
    mockRecipeRepository = MockRecipeRepository();
  });

  group('DiscoveryBloc', () {
    final testChefs = [
      createTestChef(id: 'chef-1', name: 'Chef One'),
      createTestChef(id: 'chef-2', name: 'Chef Two'),
    ];

    final testHotRecipes = [
      createTestRecipe(id: 'hot-1', name: 'Hot Recipe 1', isTrending: true),
      createTestRecipe(id: 'hot-2', name: 'Hot Recipe 2', isTrending: true),
    ];

    final testSeasonalRecipes = [
      createTestRecipe(
        id: 'season-1',
        name: 'Seasonal Recipe 1',
        isSeasonal: true,
      ),
    ];

    blocTest<DiscoveryBloc, DiscoveryState>(
      'LoadDiscovery emits loading then loaded state with data on success',
      build: () {
        when(
          () => mockChefRepository.fetchChefsOnFire(),
        ).thenAnswer((_) async => testChefs);
        when(
          () => mockRecipeRepository.fetchHotRecipes(),
        ).thenAnswer((_) async => testHotRecipes);
        when(
          () => mockRecipeRepository.fetchSeasonalRecipes(),
        ).thenAnswer((_) async => testSeasonalRecipes);
        return DiscoveryBloc(
          chefRepository: mockChefRepository,
          recipeRepository: mockRecipeRepository,
        );
      },
      act: (bloc) => bloc.add(LoadDiscovery()),
      expect: () => [
        isA<DiscoveryState>().having((s) => s.loading, 'loading', true),
        isA<DiscoveryState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.chefsOnFire.length, 'chefsOnFire.length', 2)
            .having((s) => s.hotRecipes.length, 'hotRecipes.length', 2),
      ],
    );

    blocTest<DiscoveryBloc, DiscoveryState>(
      'ToggleFavorite reverts state on failure',
      build: () {
        when(
          () => mockRecipeRepository.toggleFavorite('hot-1'),
        ).thenThrow(Exception('Network error'));
        return DiscoveryBloc(
          chefRepository: mockChefRepository,
          recipeRepository: mockRecipeRepository,
        );
      },
      seed: () => DiscoveryState(
        hotRecipes: [createTestRecipe(id: 'hot-1', isFavorite: false)],
      ),
      act: (bloc) => bloc.add(ToggleDiscoveryRecipeFavorite('hot-1')),
      expect: () => [
        isA<DiscoveryState>().having(
          (s) => s.hotRecipes.first.isFavorite,
          'optimistic',
          true,
        ),
        isA<DiscoveryState>().having(
          (s) => s.hotRecipes.first.isFavorite,
          'reverted',
          false,
        ),
      ],
    );
  });
}
