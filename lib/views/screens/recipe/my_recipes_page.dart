// unused import removed
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants.dart';
import '../../../common/config.dart';
import '../../../blocs/auth/auth_cubit.dart';
import '../../../blocs/my_recipes/my_recipes_bloc.dart';
import '../../../blocs/my_recipes/my_recipes_events.dart';
import '../../../blocs/my_recipes/my_recipes_state.dart';
import '../../../domain/repositories/my_recipes_repository.dart';
import 'add_edit_recipe_page.dart';
import 'recipe_details_page.dart';

class MyRecipesPage extends StatelessWidget {
  const MyRecipesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final accessToken = authState.accessToken;

    if (accessToken == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Recipes')),
        body: const Center(child: Text('Please log in to manage your recipes')),
      );
    }

    // Determine baseUrl based on platform
    // Determine baseUrl
    final String baseUrl = AppConfig.baseUrl;

    return BlocProvider(
      create: (context) => MyRecipesBloc(
        repository: MyRecipesRepository(
          baseUrl: baseUrl,
          accessToken: accessToken,
        ),
      )..add(const LoadMyRecipesEvent()),
      child: const _MyRecipesContent(),
    );
  }
}

class _MyRecipesContent extends StatelessWidget {
  const _MyRecipesContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Recipes",
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: "Poppins",
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<MyRecipesBloc, MyRecipesState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.recipes.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = state.recipes[index];
                    return _buildRecipeItem(context, recipe, state);
                  },
                ),
              ),
              // Add Recipe Button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: _buildAddRecipeButton(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddRecipeButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.red600, AppColors.red600.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.red600.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToAddRecipe(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  "Add New Recipe",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "No recipes yet",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontFamily: "Poppins",
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Share your culinary creations with the world!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontFamily: "Poppins",
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        // Add Recipe Button
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: _buildAddRecipeButton(context),
        ),
      ],
    );
  }

  Widget _buildRecipeItem(BuildContext context, recipe, MyRecipesState state) {
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
      child: InkWell(
        onTap: () => _navigateToRecipeDetails(context, recipe),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Container(
                width: 100,
                height: 120,
                color: Colors.grey[200],
                child: _buildRecipeImage(recipe.imageUrl),
              ),
            ),
            // Recipe Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontFamily: "Poppins",
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${recipe.prepTime + recipe.cookTime} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: "Poppins",
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.restaurant,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${recipe.servingsCount} servings',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: "Poppins",
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Action Buttons - fixed width to prevent overflow
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: state.isDeleting || state.isUpdating
                        ? null
                        : () => _navigateToEditRecipe(context, recipe),
                    color: AppColors.red600,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: state.isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete, size: 20),
                    onPressed: state.isDeleting || state.isUpdating
                        ? null
                        : () => _confirmDelete(context, recipe.id, recipe.name),
                    color: Colors.red,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.restaurant_menu, size: 40, color: Colors.grey[400]),
      ),
    );
  }

  void _navigateToAddRecipe(BuildContext context) async {
    final bloc = context.read<MyRecipesBloc>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (newContext) =>
            BlocProvider.value(value: bloc, child: const AddEditRecipePage()),
      ),
    );

    if (result == true) {
      bloc.add(const LoadMyRecipesEvent());
    }
  }

  void _navigateToEditRecipe(BuildContext context, recipe) async {
    final bloc = context.read<MyRecipesBloc>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (newContext) => BlocProvider.value(
          value: bloc,
          child: AddEditRecipePage(recipe: recipe),
        ),
      ),
    );

    if (result == true) {
      bloc.add(const LoadMyRecipesEvent());
    }
  }

  void _navigateToRecipeDetails(BuildContext context, recipe) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RecipeDetailsPage(recipe: recipe),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String recipeId,
    String recipeName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Delete Recipe',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "$recipeName"? This action cannot be undone.',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MyRecipesBloc>().add(DeleteRecipeEvent(recipeId));
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
