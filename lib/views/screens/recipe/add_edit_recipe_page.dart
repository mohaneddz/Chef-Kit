import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../common/constants.dart';
import '../../../blocs/auth/auth_cubit.dart';
import '../../../blocs/my_recipes/my_recipes_bloc.dart';
import '../../../blocs/my_recipes/my_recipes_events.dart';
import '../../../blocs/my_recipes/my_recipes_state.dart';
import '../../../domain/models/recipe.dart';

class AddEditRecipePage extends StatefulWidget {
  final Recipe? recipe; // null = add mode, non-null = edit mode

  const AddEditRecipePage({Key? key, this.recipe}) : super(key: key);

  @override
  State<AddEditRecipePage> createState() => _AddEditRecipePageState();
}

class _AddEditRecipePageState extends State<AddEditRecipePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _servingsController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  late TextEditingController _caloriesController;

  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _instructionControllers = [];
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  bool _isUploadingImage = false;

  bool get isEditMode => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.recipe?.description ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.recipe?.imageUrl ?? '',
    );
    _servingsController = TextEditingController(
      text: widget.recipe != null
          ? widget.recipe!.servingsCount.toString()
          : '4',
    );

    // Parse time
    _prepTimeController = TextEditingController(
      text: widget.recipe?.prepTime.toString() ?? '15',
    );
    _cookTimeController = TextEditingController(
      text: widget.recipe?.cookTime.toString() ?? '30',
    );

    _caloriesController = TextEditingController(
      text: widget.recipe != null ? widget.recipe!.calories.toString() : '500',
    );

    // Load existing ingredients and instructions
    if (widget.recipe != null) {
      for (var ingredient in widget.recipe!.ingredients) {
        _ingredientControllers.add(TextEditingController(text: ingredient));
      }
      for (var instruction in widget.recipe!.instructions) {
        _instructionControllers.add(TextEditingController(text: instruction));
      }
      _tags.addAll(widget.recipe!.tags);
      print(
        '[initState] Edit mode - loaded tags from recipe: ${widget.recipe!.tags}',
      );
      print('[initState] _tags after loading: $_tags');
    } else {
      // Start with one ingredient and instruction field
      _ingredientControllers.add(TextEditingController());
      _instructionControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _caloriesController.dispose();
    _tagController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _instructionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  void _addInstructionField() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstructionField(int index) {
    setState(() {
      _instructionControllers[index].dispose();
      _instructionControllers.removeAt(index);
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    print('[addTag] Attempting to add tag: "$tag"');
    print('[addTag] Current tags before: $_tags');
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
      print('[addTag] Tag added! Current tags after: $_tags');
    } else {
      print('[addTag] Tag NOT added (empty or duplicate)');
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      print('[recipe-image] Opening image picker...');
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked == null) {
        print('[recipe-image] User cancelled image selection');
        return;
      }

      setState(() {
        _isUploadingImage = true;
      });

      print('[recipe-image] Reading image bytes...');
      final bytes = await picked.readAsBytes();
      print('[recipe-image] Image size: ${bytes.length} bytes');

      print('[recipe-image] Encoding to base64...');
      final b64 = base64Encode(bytes);

      final authState = context.read<AuthCubit>().state;
      final accessToken = authState.accessToken;
      if (accessToken == null) {
        throw Exception('Not authenticated');
      }

      final String baseUrl;
      if (kIsWeb) {
        baseUrl = 'http://localhost:5000';
      } else if (Platform.isAndroid) {
        baseUrl = 'http://10.0.2.2:5000';
      } else {
        baseUrl = 'http://localhost:5000';
      }

      print('[recipe-image] Uploading to backend...');
      final resp = await http.post(
        Uri.parse('$baseUrl/api/recipes/upload-image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'image_base64': b64}),
      );

      if (resp.statusCode != 200) {
        print('[recipe-image] Upload failed: ${resp.statusCode} ${resp.body}');
        throw Exception('Upload failed: ${resp.body}');
      }

      final data = jsonDecode(resp.body);
      final imageUrl = data['image_url'];
      print('[recipe-image] Upload succeeded: $imageUrl');

      setState(() {
        _imageUrlController.text = imageUrl;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('[recipe-image] Error: $e');
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveRecipe() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    print('[save-recipe] === SAVE RECIPE START ===');
    print('[save-recipe] Is edit mode: $isEditMode');
    print(
      '[save-recipe] Image URL controller text: "${_imageUrlController.text}"',
    );
    print(
      '[save-recipe] Image URL controller isEmpty: ${_imageUrlController.text.isEmpty}',
    );

    // Collect ingredients and instructions
    final ingredients = _ingredientControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final instructions = _instructionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    if (instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one instruction')),
      );
      return;
    }

    final imageUrl = _imageUrlController.text.trim().isEmpty
        ? null
        : _imageUrlController.text.trim();

    print('[save-recipe] Image URL being saved: $imageUrl');
    print('[save-recipe] Image URL is null: ${imageUrl == null}');
    print('[save-recipe] Tags being saved: $_tags');
    print('[save-recipe] Tags count: ${_tags.length}');

    final event = isEditMode
        ? UpdateRecipeEvent(
            recipeId: widget.recipe!.id,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            imageUrl: imageUrl,
            servingsCount: int.tryParse(_servingsController.text) ?? 4,
            prepTime: int.tryParse(_prepTimeController.text) ?? 0,
            cookTime: int.tryParse(_cookTimeController.text) ?? 0,
            calories: int.tryParse(_caloriesController.text) ?? 0,
            ingredients: ingredients,
            instructions: instructions,
            tags: _tags,
          )
        : AddRecipeEvent(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            imageUrl: imageUrl,
            servingsCount: int.tryParse(_servingsController.text) ?? 4,
            prepTime: int.tryParse(_prepTimeController.text) ?? 0,
            cookTime: int.tryParse(_cookTimeController.text) ?? 0,
            calories: int.tryParse(_caloriesController.text) ?? 0,
            ingredients: ingredients,
            instructions: instructions,
            tags: _tags,
          );

    context.read<MyRecipesBloc>().add(event);
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
        title: Text(
          isEditMode ? "Edit Recipe" : "Add New Recipe",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: "Poppins",
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<MyRecipesBloc, MyRecipesState>(
        listener: (context, state) {
          if (state.isAdding == false &&
              state.isUpdating == false &&
              state.error == null) {
            // Successfully added/updated
            if (!state.loading) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEditMode ? 'Recipe updated!' : 'Recipe added!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            }
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<MyRecipesBloc, MyRecipesState>(
          builder: (context, state) {
            final isLoading = state.isAdding || state.isUpdating;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Recipe Name',
                      hint: 'e.g., Classic Margherita Pizza',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Brief description of your recipe',
                      maxLines: 3,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter a description'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildImageSection(),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Details'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _servingsController,
                            label: 'Servings',
                            hint: '4',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _prepTimeController,
                            label: 'Prep Time (min)',
                            hint: '15',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cookTimeController,
                            label: 'Cook Time (min)',
                            hint: '30',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _caloriesController,
                            label: 'Calories',
                            hint: '500',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Ingredients'),
                    const SizedBox(height: 16),
                    ..._buildIngredientFields(),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addIngredientField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Ingredient'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red600,
                        side: BorderSide(color: AppColors.red600),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Instructions'),
                    const SizedBox(height: 16),
                    ..._buildInstructionFields(),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addInstructionField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Instruction'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red600,
                        side: BorderSide(color: AppColors.red600),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Tags'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Italian, Vegetarian',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addTag,
                          icon: const Icon(Icons.add_circle),
                          color: AppColors.red600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) => _buildTagChip(tag)).toList(),
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: isLoading ? null : _saveRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isEditMode ? 'Update Recipe' : 'Create Recipe',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final hasImage = _imageUrlController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recipe Image',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            const Text(
              ' (optional)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (hasImage) ...[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _imageUrlController.text,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                icon: _isUploadingImage
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(
                  _isUploadingImage ? 'Uploading...' : 'Upload Image',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red600,
                  side: BorderSide(color: AppColors.red600),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _imageUrlController.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
                child: const Icon(Icons.delete),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  List<Widget> _buildIngredientFields() {
    return List.generate(_ingredientControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ingredientControllers[index],
                decoration: InputDecoration(
                  hintText: 'e.g., 2 cups flour',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            if (_ingredientControllers.length > 1) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeIngredientField(index),
                icon: const Icon(Icons.remove_circle),
                color: Colors.red,
              ),
            ],
          ],
        ),
      );
    });
  }

  List<Widget> _buildInstructionFields() {
    return List.generate(_instructionControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, right: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.red600,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _instructionControllers[index],
                decoration: InputDecoration(
                  hintText: 'Describe this step',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 2,
              ),
            ),
            if (_instructionControllers.length > 1) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeInstructionField(index),
                icon: const Icon(Icons.remove_circle),
                color: Colors.red,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag, style: const TextStyle(fontFamily: 'Poppins')),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _removeTag(tag),
      backgroundColor: AppColors.red600.withOpacity(0.1),
      deleteIconColor: AppColors.red600,
    );
  }
}
