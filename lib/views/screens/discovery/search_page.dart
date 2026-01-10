import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chefkit/blocs/search/search_bloc.dart';
import 'package:chefkit/blocs/search/search_events.dart';
import 'package:chefkit/blocs/search/search_state.dart';
import 'package:chefkit/domain/repositories/chef_repository.dart';
import 'package:chefkit/domain/repositories/recipe_repository.dart';
import 'package:chefkit/views/screens/profile/chef_profile_public_page.dart';
import 'package:chefkit/views/screens/recipe/recipe_details_page.dart';
import 'package:chefkit/views/widgets/profile/chef_card_widget.dart';
import 'package:chefkit/views/widgets/recipe/recipe_card_widget.dart';
import 'package:chefkit/l10n/app_localizations.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(
        chefRepository: context.read<ChefRepository>(),
        recipeRepository: context.read<RecipeRepository>(),
      ),
      child: const _SearchPageContent(),
    );
  }
}

class _SearchPageContent extends StatefulWidget {
  const _SearchPageContent();

  @override
  State<_SearchPageContent> createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<_SearchPageContent> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (value) {
            context.read<SearchBloc>().add(SearchQueryChanged(value));
          },
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: l10n.searchRecipesOrChefs,
            hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear, color: theme.iconTheme.color),
            onPressed: () {
              _searchController.clear();
              context.read<SearchBloc>().add(ClearSearch());
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state.query.isEmpty) {
            return _buildEmptyPrompt(context, l10n);
          }

          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Text(
                state.error!,
                style: TextStyle(color: Colors.red[400]),
              ),
            );
          }

          if (state.isEmpty) {
            return _buildNoResults(context, l10n, state.query);
          }

          return _buildResults(context, state, isDark);
        },
      ),
    );
  }

  Widget _buildEmptyPrompt(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: theme.textTheme.bodySmall?.color),
          const SizedBox(height: 16),
          Text(
            l10n.searchRecipesOrChefs,
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(
    BuildContext context,
    AppLocalizations l10n,
    String query,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 16),
          Text(
            'No results for "$query"',
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, SearchState state, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chefs section
          if (state.chefs.isNotEmpty) ...[
            Text(
              l10n.chefs,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.chefs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final chef = state.chefs[index];
                  return ChefCardWidget(
                    name: chef.name,
                    imageUrl: chef.imageUrl,
                    isOnFire: chef.isOnFire,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChefProfilePublicPage(chefId: chef.id),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Recipes section
          if (state.recipes.isNotEmpty) ...[
            Text(
              l10n.hotRecipes,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.recipes.length,
              itemBuilder: (context, index) {
                final recipe = state.recipes[index];
                return RecipeCardWidget(
                  title: recipe.name,
                  subtitle: recipe.description,
                  imageUrl: recipe.imageUrl,
                  isFavorite: recipe.isFavorite,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailsPage(recipe: recipe),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
