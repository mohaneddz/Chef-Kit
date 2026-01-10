import 'package:bloc_test/bloc_test.dart';
import 'package:chefkit/blocs/inventory/inventory_bloc.dart';
import 'package:chefkit/blocs/inventory/inventory_event.dart';
import 'package:chefkit/blocs/inventory/inventory_state.dart';
import 'package:chefkit/database/db_helper.dart';
import 'package:chefkit/domain/repositories/ingredients/ingredient_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late InventoryBloc inventoryBloc;

  final Map<String, String> mockIngredient = {
    "key": "tomato",
    "name_en": "Tomato",
    "type_en": "Vegetable",
    "imageUrl": "path/to/tomato"
  };

  setUpAll(() async {
    // Use FFI to avoid platform channels during tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    registerFallbackValue(LoadInventoryEvent('en'));
    registerFallbackValue(SearchInventoryEvent(''));
    registerFallbackValue(AddIngredientEvent(<String, String>{}));
    registerFallbackValue(RemoveIngredientEvent(<String, String>{}));
    registerFallbackValue(ToggleShowMoreEvent());
  });

  setUp(() {
    inventoryBloc = InventoryBloc();
  });

  tearDown(() async {
    await inventoryBloc.close();
  });

  group('InventoryBloc Tests', () {
    test('initial state is correct', () {
      expect(inventoryBloc.state.available, isEmpty);
      expect(inventoryBloc.state.browse, isEmpty);
      expect(inventoryBloc.state.showMore, false);
      expect(inventoryBloc.state.searchTerm, '');
      expect(inventoryBloc.state.currentLang, 'en');
    });

    blocTest<InventoryBloc, InventoryState>(
      'emits updated searchTerm when SearchInventoryEvent is added',
      build: () => InventoryBloc(),
      act: (bloc) => bloc.add(SearchInventoryEvent('Onion')),
      expect: () => [
        isA<InventoryState>().having((s) => s.searchTerm, 'searchTerm', 'Onion'),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'toggles showMore when ToggleShowMoreEvent is added',
      build: () => InventoryBloc(),
      act: (bloc) => bloc.add(ToggleShowMoreEvent()),
      expect: () => [
        isA<InventoryState>().having((s) => s.showMore, 'showMore', true),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'adds ingredient to available and removes from browse',
      build: () => InventoryBloc(),
      seed: () => InventoryState(
        available: [],
        browse: [mockIngredient],
        showMore: false,
      ),
      act: (bloc) => bloc.add(AddIngredientEvent(mockIngredient)),
      expect: () => [
        isA<InventoryState>()
            .having((s) => s.available, 'available', [mockIngredient])
            .having((s) => s.browse, 'browse', isEmpty),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'removes ingredient from available and adds back to browse',
      build: () => InventoryBloc(),
      seed: () => InventoryState(
        available: [mockIngredient],
        browse: [],
        showMore: false,
      ),
      act: (bloc) => bloc.add(RemoveIngredientEvent(mockIngredient)),
      expect: () => [
        isA<InventoryState>()
            .having((s) => s.available, 'available', isEmpty)
            .having((s) => s.browse, 'browse', [mockIngredient]),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'loads ingredients from repository and sets language',
      setUp: () async {
        final repo = IngredientsRepo.getInstance();
        // Ensure table exists and is empty
        final db = await DBHelper.database;
        await db.delete('ingredients');
        await repo.insertIngredient({
          "name_en": "Tomato",
          "name_fr": "Tomate",
          "name_ar": "طماطم",
          "type_en": "Vegetables",
          "type_fr": "Légumes",
          "type_ar": "خضروات",
          "image_path": "assets/images/ingredients/tomato.png",
        });
        await repo.insertIngredient({
          "name_en": "Onion",
          "name_fr": "Oignon",
          "name_ar": "بصل",
          "type_en": "Vegetables",
          "type_fr": "Légumes",
          "type_ar": "خضروات",
          "image_path": "assets/images/ingredients/onion.png",
        });
      },
      build: () => InventoryBloc(),
      act: (bloc) => bloc.add(LoadInventoryEvent('fr')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<InventoryState>()
            .having((s) => s.browse.length, 'browse length', 2)
            .having((s) => s.currentLang, 'lang', 'fr')
            .having((s) => s.available, 'available', isEmpty),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'LoadInventoryEvent excludes already available ingredients from browse list',
      setUp: () async {
        final repo = IngredientsRepo.getInstance();
        final db = await DBHelper.database;
        await db.delete('ingredients');
        await repo.insertIngredient({
          "name_en": "Tomato",
          "name_fr": "Tomate",
          "name_ar": "طماطم",
          "type_en": "Vegetables",
          "type_fr": "Légumes",
          "type_ar": "خضروات",
          "image_path": "assets/images/ingredients/tomato.png",
        });
        await repo.insertIngredient({
          "name_en": "Onion",
          "name_fr": "Oignon",
          "name_ar": "بصل",
          "type_en": "Vegetables",
          "type_fr": "Légumes",
          "type_ar": "خضروات",
          "image_path": "assets/images/ingredients/onion.png",
        });
      },
      build: () => InventoryBloc(),
      seed: () => InventoryState(
        available: [
          {
            "key": "Tomato",
            "name_en": "Tomato",
            "type_en": "Vegetables",
            "imageUrl": "assets/images/ingredients/tomato.png",
          },
        ],
        browse: const [],
        showMore: false,
      ),
      act: (bloc) => bloc.add(LoadInventoryEvent('en')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<InventoryState>()
            .having((s) => s.available.length, 'available length', 1)
            .having(
              (s) => s.browse.map((i) => i["key"]).toList(),
              'browse keys',
              ['Onion'],
            )
            .having((s) => s.currentLang, 'lang', 'en'),
      ],
    );
  });
}