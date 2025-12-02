import 'package:equatable/equatable.dart';

class InventoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadInventoryEvent extends InventoryEvent {}

class AddIngredientEvent extends InventoryEvent {
  final Map<String, String> ingredient;
  AddIngredientEvent(this.ingredient);

  @override
  List<Object?> get props => [ingredient];
}

class RemoveIngredientEvent extends InventoryEvent {
  final Map<String, String> ingredient;
  RemoveIngredientEvent(this.ingredient);

  @override
  List<Object?> get props => [ingredient];
}

class ToggleShowMoreEvent extends InventoryEvent {}
