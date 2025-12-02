import 'package:flutter/material.dart';
import '../../common/constants.dart';

class MyRecipesPage extends StatefulWidget {
  const MyRecipesPage({Key? key}) : super(key: key);

  @override
  State<MyRecipesPage> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  // Dummy data for recipes
  final List<Map<String, dynamic>> _myRecipes = [
    {
      'id': '1',
      'title': 'Spicy Ramen Bowl',
      'image': 'assets/images/recipes/recipe_1.png',
      'time': '45 min',
      'rating': 4.8,
      'ingredients': ['Noodles', 'Broth', 'Egg', 'Green Onion'],
    },
    {
      'id': '2',
      'title': 'Avocado Toast',
      'image': 'assets/images/recipes/recipe_2.png',
      'time': '15 min',
      'rating': 4.5,
      'ingredients': ['Bread', 'Avocado', 'Salt', 'Pepper'],
    },
    {
      'id': '3',
      'title': 'Grilled Salmon',
      'image': 'assets/images/recipes/recipe_3.png',
      'time': '30 min',
      'rating': 4.9,
      'ingredients': ['Salmon', 'Lemon', 'Asparagus'],
    },
  ];

  // In a real app this would come from ImagePicker / backend
  String? _newRecipeImage;

  void _addNewRecipe() {
    // Show dialog or bottom sheet to add recipe
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddRecipeSheet(),
    );
  }

  void _editRecipe(String id) {
    // Logic to edit recipe
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit recipe $id')),
    );
  }

  void _deleteRecipe(String id) {
    setState(() {
      _myRecipes.removeWhere((r) => r['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Recipes",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: "Poppins",
          ),
        ),
        centerTitle: true,
      ),
      body: _myRecipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "No recipes yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[500],
                      fontFamily: "Poppins",
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _addNewRecipe,
                    child: Text(
                      "Create your first recipe",
                      style: TextStyle(
                        color: AppColors.red600,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _myRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _myRecipes[index];
                return _buildRecipeItem(recipe);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewRecipe,
        backgroundColor: AppColors.red600,
        icon: const Icon(Icons.add),
        label: const Text(
          "Add Recipe",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRecipeItem(Map<String, dynamic> recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Recipe Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              image: DecorationImage(
                image: AssetImage(recipe['image']),
                fit: BoxFit.cover,
                onError: (_, __) {}, // Handle error gracefully
              ),
              color: Colors.grey[200],
            ),
            child: recipe['image'] == null 
                ? const Icon(Icons.image_not_supported, color: Colors.grey) 
                : null,
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          recipe['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                        onSelected: (value) {
                          if (value == 'edit') _editRecipe(recipe['id']);
                          if (value == 'delete') _deleteRecipe(recipe['id']);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text("Edit"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text("Delete", style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        recipe['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: "Poppins",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        "${recipe['rating']}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: (recipe['ingredients'] as List<String>).take(3).map((ing) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ing,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontFamily: "Poppins",
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRecipeSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Add New Recipe",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                // Image picker (dummy)
                GestureDetector(
                  onTap: () {
                    // Dummy logic: toggle between null and a sample image
                    setState(() {
                      _newRecipeImage = _newRecipeImage == null
                          ? 'assets/images/recipes/recipe_1.png'
                          : null;
                    });
                  },
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                            image: _newRecipeImage != null
                                ? DecorationImage(
                                    image: AssetImage(_newRecipeImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _newRecipeImage == null
                              ? Icon(Icons.camera_alt,
                                  color: Colors.grey[400], size: 28)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Recipe Cover Image",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Poppins",
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _newRecipeImage == null
                                    ? "Tap to upload from gallery"
                                    : "Tap to change image (dummy)",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField("Recipe Name", "e.g. Spicy Ramen"),
                const SizedBox(height: 16),
                _buildTextField("Description", "Tell us about your recipe...", maxLines: 3),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField("Time", "e.g. 45 min")),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField("Servings", "e.g. 2 people")),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Ingredients",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField("Add Ingredient", "e.g. 2 eggs"),
                const SizedBox(height: 24),
                const Text(
                  "Steps",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField("Step 1", "Describe the first step...", maxLines: 2),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recipe Added (Dummy)')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Post Recipe",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontFamily: "Poppins"),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
