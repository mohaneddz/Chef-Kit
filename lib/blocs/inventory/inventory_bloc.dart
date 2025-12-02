import 'package:flutter_bloc/flutter_bloc.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc()
      : super(
          InventoryState(
            available: [],        
            browse: [              
              {
                "imageUrl": "assets/images/escalope.png",
                "name": "Escalope",
                "type": "Protein",
              },
              {
                "imageUrl": "assets/images/tomato.png",
                "name": "Tomato",
                "type": "Vegetables",
              },
              {
                "imageUrl": "assets/images/potato.png",
                "name": "Potato",
                "type": "Vegetables",
              },
              {
                "imageUrl": "assets/images/paprika.png",
                "name": "Paprika",
                "type": "Spices",
              },
              {
                "imageUrl": "assets/images/escalope.png",
                "name": "Escalope 2",
                "type": "Protein",
              },
              {
                "imageUrl": "assets/images/escalope.png",
                "name": "Escalope 3",
                "type": "Protein",
              },
              {
                "imageUrl": "assets/images/escalope.png",
                "name": "Escalope 4",
                "type": "Protein",
              },
              {
                "imageUrl": "assets/images/escalope.png",
                "name": "Escalope 5",
                "type": "Protein",
              },
            ],
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
  }
}
