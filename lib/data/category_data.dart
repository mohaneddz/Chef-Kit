import 'package:chefkit/data/recipe_data.dart';

String formatSubtitle(int count) {
  return "$count ${count == 1 ? 'recipe' : 'recipes'}";
}
List<String> getPreviewImagePaths(List<Recipe> recipeList) { // up to 3 image paths for previews
  return recipeList.map((recipe) => recipe.imagePath).take(3).toList();
}

// manually defined placeholder data
final List<Recipe> traditionalRecipes = [recipes[0], recipes[1], recipes[2], recipes[3]];
final List<Recipe> quickRecipes = [recipes[4]];
final List<Recipe> allSavedRecipes = recipes;

final List<Map<String, dynamic>> categories = [
  {
    'title': "Traditional",
    'subtitle': formatSubtitle(traditionalRecipes.length),
    'imagePaths': getPreviewImagePaths(traditionalRecipes),
    'recipes': traditionalRecipes,
  },
  {
    'title': "Quick & Easy",
    'subtitle': formatSubtitle(quickRecipes.length),
    'imagePaths': getPreviewImagePaths(quickRecipes),
    'recipes': quickRecipes,
  },
  {
    'title': "All Saved",
    'subtitle': formatSubtitle(allSavedRecipes.length),
    'imagePaths': getPreviewImagePaths(allSavedRecipes),
    'recipes': allSavedRecipes,
  },
];
