import 'package:chefkit/domain/repositories/ingredients/ingredient_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc()
    : super(
        InventoryState(
          available: [], // list of the user's current available ingredients
          browse: [],
          showMore: false,
          searchTerm: '',
        ),
      ) {
    on<AddIngredientEvent>((event, emit) {
      final ing = event.ingredient;
      emit(
        state.copyWith(
          available: [...state.available, ing],
          browse: state.browse.where((i) => i["key"] != ing["key"]).toList(),
        ),
      );
    });

    on<RemoveIngredientEvent>((event, emit) {
      final ing = event.ingredient;

      emit(
        state.copyWith(
          available: state.available
              .where((i) => i["key"] != ing["key"])
              .toList(),
          browse: [...state.browse, ing],
        ),
      );
    });

    on<ToggleShowMoreEvent>((event, emit) {
      emit(state.copyWith(showMore: !state.showMore));
    });

    on<LoadInventoryEvent>((event, emit) async {
      final repo = IngredientsRepo.getInstance();
      final results = await repo.getAllIngredients();
      final lang = event.langCode; // "en", "fr", "ar"

      // Get keys of already selected ingredients
      final availableKeys = state.available
          .map((e) => e["key"])
          .whereType<String>()
          .toSet();

      // Store all translations for each ingredient, excluding already selected ones
      final browseList = results
          .map(
            (e) => {
              "key": e["name_en"]
                  .toString(), // English name as unique key for backend
              "name_en": e["name_en"].toString(),
              "name_fr": e["name_fr"].toString(),
              "name_ar": e["name_ar"].toString(),
              "type_en": e["type_en"].toString(),
              "type_fr": e["type_fr"].toString(),
              "type_ar": e["type_ar"].toString(),
              "imageUrl": e["image_path"].toString(),
            },
          )
          .where((item) => !availableKeys.contains(item["key"]))
          .toList();

      emit(
        state.copyWith(
          browse: browseList,
          available: state.available,
          currentLang: lang,
        ),
      );
    });

    on<SearchInventoryEvent>((event, emit) {
      emit(state.copyWith(searchTerm: event.searchTerm));
    });
  }
}
