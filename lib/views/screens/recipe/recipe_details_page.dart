import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/models/recipe.dart';
import '../../../l10n/app_localizations.dart';
import '../../../blocs/recipe_details/recipe_details_cubit.dart';
import '../../../blocs/recipe_details/recipe_details_state.dart';
import '../../../common/constants.dart';
import '../../../database/repositories/ingredients/ingredients_repository.dart';

class RecipeDetailsPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RecipeDetailsCubit(
            initialFavorite: recipe.isFavorite,
            initialServings: recipe.servingsCount,
          )..loadIngredientTranslations(
            recipe.basicIngredients.isNotEmpty
                ? recipe.basicIngredients
                : recipe.ingredients,
            Localizations.localeOf(context).languageCode,
          ),
      child: _RecipeDetailsContent(recipe: recipe),
    );
  }
}

class _RecipeDetailsContent extends StatelessWidget {
  final Recipe recipe;

  const _RecipeDetailsContent({required this.recipe});

  int get totalTime => recipe.prepTime + recipe.cookTime;

  String _getLocalizedName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar' && recipe.titleAr != null && recipe.titleAr!.isNotEmpty)
      return recipe.titleAr!;
    if (locale == 'fr' && recipe.titleFr != null && recipe.titleFr!.isNotEmpty)
      return recipe.titleFr!;
    return recipe.name;
  }

  String? _getLocalizedDescription(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar' || locale == 'fr') {
      return _getLocalizedName(context);
    }
    return recipe.description;
  }

  List<String> _getLocalizedTags(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar' && recipe.tagsAr != null && recipe.tagsAr!.isNotEmpty)
      return recipe.tagsAr!;
    if (locale == 'fr' && recipe.tagsFr != null && recipe.tagsFr!.isNotEmpty)
      return recipe.tagsFr!;
    return recipe.tags;
  }

  List<String> _getLocalizedInstructions(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar' &&
        recipe.instructionsAr != null &&
        recipe.instructionsAr!.isNotEmpty)
      return recipe.instructionsAr!;
    if (locale == 'fr' &&
        recipe.instructionsFr != null &&
        recipe.instructionsFr!.isNotEmpty)
      return recipe.instructionsFr!;
    return recipe.instructions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Image App Bar
          _buildSliverAppBar(context),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Description Section
                _buildHeaderSection(context),

                // Quick Info Cards
                _buildQuickInfoSection(),

                // Servings shown in Quick Info (no adjuster)

                // Tags Section
                if (_getLocalizedTags(context).isNotEmpty)
                  _buildTagsSection(context),

                // Ingredients Section
                _buildIngredientsSection(),

                // Instructions Section
                _buildInstructionsSection(context),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            customBorder: const CircleBorder(),
            child: const Icon(
              LucideIcons.arrowLeft,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<RecipeDetailsCubit, RecipeDetailsState>(
            builder: (context, state) {
              return Material(
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.15),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () =>
                      context.read<RecipeDetailsCubit>().toggleFavorite(),
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      state.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: state.isFavorite
                          ? AppColors.primary
                          : Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(tag: 'recipe_${recipe.id}', child: _buildHeaderImage()),
            // Gradient overlays
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    // Handle asset images
    if (recipe.imageUrl.startsWith('assets/')) {
      return Image.asset(
        recipe.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    }

    // Handle network images
    if (recipe.imageUrl.startsWith('http')) {
      return Image.network(
        recipe.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImagePlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(LucideIcons.chefHat, size: 80, color: Colors.grey),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final localizedName = _getLocalizedName(context);
    final localizedDescription = _getLocalizedDescription(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizedName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
              color: Color(0xFF1D1617),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          if (localizedDescription != null &&
              localizedDescription.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              localizedDescription,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                fontFamily: 'LeagueSpartan',
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: BlocBuilder<RecipeDetailsCubit, RecipeDetailsState>(
        builder: (context, state) {
          return Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: LucideIcons.clock,
                  label: AppLocalizations.of(context)!.total,
                  value: '${totalTime}m',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: LucideIcons.flame,
                  label: AppLocalizations.of(context)!.caloriesLabel,
                  value: '${recipe.calories}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: LucideIcons.users,
                  label: AppLocalizations.of(context)!.servingsLabel,
                  value: '${state.servings}',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Removed servings adjuster per design: servings is a property only

  Widget _buildTagsSection(BuildContext context) {
    final tags = _getLocalizedTags(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: tags.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.tag, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  tag,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'LeagueSpartan',
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return BlocBuilder<RecipeDetailsCubit, RecipeDetailsState>(
      builder: (context, state) {
        final servingMultiplier = state.servings / recipe.servingsCount;

        // Use basicIngredients if available, otherwise fallback to ingredients list
        List<String> ingredientsList = [];
        if (recipe.basicIngredients.isNotEmpty) {
          ingredientsList = recipe.basicIngredients;
        } else {
          ingredientsList = recipe.ingredients;
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.shoppingCart,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.ingredients,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Color(0xFF1D1617),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.itemsCount(ingredientsList.length),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'LeagueSpartan',
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...ingredientsList.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _scaleIngredient(
                            entry.value,
                            servingMultiplier,
                            state.ingredientTranslations,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontFamily: 'LeagueSpartan',
                            color: Color(0xFF1D1617),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _scaleIngredient(
    String ingredient,
    double multiplier, [
    Map<String, IngredientTranslation>? translations,
  ]) {
    String result = ingredient;

    if (multiplier != 1.0) {
      // Match numbers (including fractions like 1/2, 1/4, decimals)
      final numberPattern = RegExp(r'^(\d+\.?\d*|\d+/\d+)\s*');
      final match = numberPattern.firstMatch(ingredient);

      if (match != null) {
        final originalAmount = match.group(1)!;
        final rest = ingredient.substring(match.end);

        // Parse the amount
        double amount;
        if (originalAmount.contains('/')) {
          final parts = originalAmount.split('/');
          amount = double.parse(parts[0]) / double.parse(parts[1]);
        } else {
          amount = double.parse(originalAmount);
        }

        // Scale it
        final scaledAmount = amount * multiplier;

        // Format nicely
        String formattedAmount;
        if (scaledAmount == scaledAmount.roundToDouble()) {
          formattedAmount = scaledAmount.toInt().toString();
        } else if ((scaledAmount * 2).roundToDouble() == scaledAmount * 2) {
          // Handle common fractions
          formattedAmount = '${(scaledAmount * 2).toInt()}/2';
        } else if ((scaledAmount * 4).roundToDouble() == scaledAmount * 4) {
          formattedAmount = '${(scaledAmount * 4).toInt()}/4';
        } else {
          formattedAmount = scaledAmount.toStringAsFixed(1);
        }

        result = '$formattedAmount $rest';
      }
    }

    if (translations != null && translations.containsKey(ingredient)) {
      final translation = translations[ingredient]!;
      final pattern = RegExp(
        RegExp.escape(translation.matchedEnglishName),
        caseSensitive: false,
      );
      result = result.replaceAll(pattern, translation.translatedName);
    }

    return result;
  }

  Widget _buildInstructionsSection(BuildContext context) {
    final instructions = _getLocalizedInstructions(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF92A3FD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.chefHat,
                  size: 20,
                  color: Color(0xFF92A3FD),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.instructions,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: Color(0xFF1D1617),
                ),
              ),
              const Spacer(),
              Text(
                AppLocalizations.of(context)!.stepsCount(instructions.length),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'LeagueSpartan',
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...instructions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF92A3FD),
                          const Color(0xFF9DCEFF),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          fontFamily: 'LeagueSpartan',
                          color: Color(0xFF1D1617),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF7B6F72)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'LeagueSpartan',
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: Color(0xFF1D1617),
            ),
          ),
        ],
      ),
    );
  }
}

// Servings controls removed
