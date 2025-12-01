import 'package:chefkit/data/examples/recipe_data.dart';

String formatSubtitle(int count) {
  return "$count ${count == 1 ? 'recipe' : 'recipes'}";
}

List<String> getPreviewImagePaths(List<Recipe> recipeList) { // up to 3 image paths for previews
  return recipeList.map((recipe) => recipe.imagePath).take(3).toList();
}

// MODIFIED: 'recipes' list is now named 'dummyRecipes'
final List<Recipe> traditionalRecipes = [
  dummyRecipes[0],
  dummyRecipes[1],
  dummyRecipes[2],
  dummyRecipes[3]
];
final List<Recipe> quickRecipes = [dummyRecipes[4]];
final List<Recipe> allSavedRecipes = dummyRecipes; // MODIFIED

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