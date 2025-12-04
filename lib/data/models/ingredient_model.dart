class LocalIngredientModel {
  final String ingredientId;
  final String ingredientName;
  final String ingredientCategory;
  final String ingredientImageUrl;

  LocalIngredientModel({
    required this.ingredientId,
    required this.ingredientName,
    required this.ingredientCategory,
    required this.ingredientImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'ingredient_id': ingredientId,
      'ingredient_name': ingredientName,
      'ingredient_category': ingredientCategory,
      'ingredient_image_url': ingredientImageUrl,
    };
  }

  factory LocalIngredientModel.fromMap(Map<String, dynamic> map) {
    return LocalIngredientModel(
      ingredientId: map['ingredient_id'],
      ingredientName: map['ingredient_name'],
      ingredientCategory: map['ingredient_category'],
      ingredientImageUrl: map['ingredient_image_url'],
    );
  }
}
