import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../blocs/hot_recipes/hot_recipes_bloc.dart';
import '../../../blocs/hot_recipes/hot_recipes_state.dart';
import '../../../blocs/hot_recipes/hot_recipes_events.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../../widgets/recipe/recipe_card_widget.dart';
import '../recipe/recipe_details_page.dart';

class AllHotRecipesPage extends StatelessWidget {
  const AllHotRecipesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HotRecipesBloc(recipeRepository: context.read<RecipeRepository>())
            ..add(LoadHotRecipes()),
      child: const _AllHotRecipesView(),
    );
  }
}

class _AllHotRecipesView extends StatelessWidget {
  const _AllHotRecipesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.hotRecipes,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<HotRecipesBloc, HotRecipesState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.error(state.error!),
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<HotRecipesBloc>().add(LoadHotRecipes()),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row
                    Row(
                      children: [
                        _buildStatBadge(
                          context,
                          Icons.whatshot,
                          '${state.totalCount}',
                          AppLocalizations.of(context)!.recipesStat,
                          const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(width: 12),
                        _buildStatBadge(
                          context,
                          Icons.trending_up,
                          '${state.trendingCount}',
                          AppLocalizations.of(context)!.trendingStat,
                          AppColors.orange,
                        ),
                        const SizedBox(width: 12),
                        _buildStatBadge(
                          context,
                          Icons.favorite,
                          '${state.favoritesCount}',
                          AppLocalizations.of(context)!.favoritesStat,
                          AppColors.red600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            context,
                            'All',
                            AppLocalizations.of(context)!.filterAll,
                            Icons.grid_view,
                            state.selectedTag,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context,
                            'Trending',
                            AppLocalizations.of(context)!.filterTrending,
                            Icons.local_fire_department,
                            state.selectedTag,
                          ),
                          // Dynamic tag filters
                          for (final tag in state.availableTags) ...[
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              context,
                              tag,
                              tag,
                              Icons.tag,
                              state.selectedTag,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Recipes Grid
              Expanded(
                child: state.filteredRecipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.noRecipesFound,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: state.filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = state.filteredRecipes[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 300 + (index * 50),
                              ),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: Stack(
                                children: [
                                  RecipeCardWidget(
                                    title: recipe.name,
                                    subtitle: recipe.description,
                                    imageUrl: recipe.imageUrl,
                                    isFavorite: recipe.isFavorite,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                              ) => RecipeDetailsPage(
                                                recipe: recipe,
                                              ),
                                          transitionsBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                                child,
                                              ) {
                                                const begin = Offset(0.8, 0.0);
                                                const end = Offset.zero;
                                                final curved = CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeOutQuart,
                                                );

                                                return FadeTransition(
                                                  opacity: curved,
                                                  child: SlideTransition(
                                                    position: Tween(
                                                      begin: begin,
                                                      end: end,
                                                    ).animate(curved),
                                                    child: child,
                                                  ),
                                                );
                                              },
                                          transitionDuration: const Duration(
                                            milliseconds: 350,
                                          ),
                                          reverseTransitionDuration:
                                              const Duration(milliseconds: 300),
                                        ),
                                      );
                                    },
                                    onFavoritePressed: () =>
                                        context.read<HotRecipesBloc>().add(
                                          ToggleHotRecipeFavorite(recipe.id),
                                        ),
                                  ),
                                  if (recipe.isTrending)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFF6B6B),
                                              Color(0xFFFFAA6B),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.local_fire_department,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.hotBadge,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontFamily: 'Poppins',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String filterKey,
    String displayLabel,
    IconData icon,
    String selectedTag,
  ) {
    final isSelected = selectedTag == filterKey;
    return GestureDetector(
      onTap: () {
        context.read<HotRecipesBloc>().add(FilterByTag(filterKey));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                )
              : null,
          color: isSelected ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              displayLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
