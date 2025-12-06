import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../l10n/app_localizations.dart';
import '../../../blocs/recipe_details/recipe_details_cubit.dart';
import '../../../blocs/recipe_details/recipe_details_state.dart';
import '../../../common/constants.dart';

class RecipeDetailsPage extends StatelessWidget {
  final String recipeId;
  final String recipeName;
  final String? recipeDescription;
  final String recipeImageUrl;
  final int recipePrepTime;
  final int recipeCookTime;
  final int recipeCalories;
  final int recipeServingsCount;
  final List<String> recipeIngredients;
  final List<String> recipeInstructions;
  final List<String> recipeTags;
  final bool initialFavorite;
  final String? recipeOwner;

  const RecipeDetailsPage({
    Key? key,
    required this.recipeId,
    required this.recipeName,
    this.recipeDescription,
    required this.recipeImageUrl,
    this.recipePrepTime = 0,
    this.recipeCookTime = 0,
    this.recipeCalories = 0,
    this.recipeServingsCount = 4,
    required this.recipeIngredients,
    required this.recipeInstructions,
    this.recipeTags = const [],
    this.initialFavorite = false,
    this.recipeOwner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecipeDetailsCubit(
        initialFavorite: initialFavorite,
        initialServings: recipeServingsCount,
      ),
      child: _RecipeDetailsContent(
        recipeId: recipeId,
        recipeName: recipeName,
        recipeDescription: recipeDescription,
        recipeImageUrl: recipeImageUrl,
        recipePrepTime: recipePrepTime,
        recipeCookTime: recipeCookTime,
        recipeCalories: recipeCalories,
        recipeServingsCount: recipeServingsCount,
        recipeIngredients: recipeIngredients,
        recipeInstructions: recipeInstructions,
        recipeTags: recipeTags,
        recipeOwner: recipeOwner,
      ),
    );
  }
}

class _RecipeDetailsContent extends StatelessWidget {
  final String recipeId;
  final String recipeName;
  final String? recipeDescription;
  final String recipeImageUrl;
  final int recipePrepTime;
  final int recipeCookTime;
  final int recipeCalories;
  final int recipeServingsCount;
  final List<String> recipeIngredients;
  final List<String> recipeInstructions;
  final List<String> recipeTags;
  final String? recipeOwner;

  const _RecipeDetailsContent({
    required this.recipeId,
    required this.recipeName,
    this.recipeDescription,
    required this.recipeImageUrl,
    required this.recipePrepTime,
    required this.recipeCookTime,
    required this.recipeCalories,
    required this.recipeServingsCount,
    required this.recipeIngredients,
    required this.recipeInstructions,
    required this.recipeTags,
    this.recipeOwner,
  });

  int get totalTime => recipePrepTime + recipeCookTime;

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
                _buildHeaderSection(),

                // Quick Info Cards
                _buildQuickInfoSection(),

                // Servings shown in Quick Info (no adjuster)

                // Tags Section
                if (recipeTags.isNotEmpty) _buildTagsSection(),

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
            Hero(tag: 'recipe_$recipeId', child: _buildHeaderImage()),
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
    if (recipeImageUrl.startsWith('assets/')) {
      return Image.asset(
        recipeImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    }

    // Handle network images
    if (recipeImageUrl.startsWith('http')) {
      return Image.network(
        recipeImageUrl,
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

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipeName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
              color: Color(0xFF1D1617),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          if (recipeDescription != null && recipeDescription!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              recipeDescription!,
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
                  value: '$recipeCalories',
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

  Widget _buildTagsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: recipeTags.map((tag) {
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
        final servingMultiplier = state.servings / recipeServingsCount;

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
                    )!.itemsCount(recipeIngredients.length),
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
              ...recipeIngredients.asMap().entries.map((entry) {
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
                          _scaleIngredient(entry.value, servingMultiplier),
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

  String _scaleIngredient(String ingredient, double multiplier) {
    if (multiplier == 1.0) return ingredient;

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

      return '$formattedAmount $rest';
    }

    return ingredient;
  }

  Widget _buildInstructionsSection(BuildContext context) {
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
                AppLocalizations.of(
                  context,
                )!.stepsCount(recipeInstructions.length),
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
          ...recipeInstructions.asMap().entries.map((entry) {
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
