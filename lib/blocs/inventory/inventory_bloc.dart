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
          ),
        ) {

    on<AddIngredientEvent>((event, emit) {
      final ing = event.ingredient;
      emit(
        state.copyWith(
          available: [...state.available, ing],
          browse: state.browse.where((i) => i["name"] != ing["name"]).toList(),
        ),
      );
    });

    on<RemoveIngredientEvent>((event, emit) {
      final ing = event.ingredient;

      emit(
        state.copyWith(
          available: state.available
              .where((i) => i["name"] != ing["name"])
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

      final browseList = results.map((e) => {
        "name": e["name"].toString(),
        "type": e["type"].toString(),
        "imageUrl": e["image_path"].toString(),
      }).toList();

      emit(
        state.copyWith(
          browse: browseList,
          available: [], // empty at first
        ),
      );
    });

  }
}
