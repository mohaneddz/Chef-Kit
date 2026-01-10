import 'package:chefkit/views/screens/notifications_page.dart';
import 'package:chefkit/domain/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import '../../../blocs/discovery/discovery_bloc.dart';
import '../../../blocs/discovery/discovery_state.dart';
import '../../../blocs/discovery/discovery_events.dart';
import '../../../blocs/notifications/notifications_bloc.dart';
import '../../../blocs/notifications/notifications_state.dart';
import '../../../blocs/auth/auth_cubit.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/login_required_modal.dart';
import '../../widgets/section_header_widget.dart';
import '../../widgets/profile/chef_card_widget.dart';
import '../../widgets/recipe/recipe_card_widget.dart';
import '../../widgets/recipe/seasonal_item_widget.dart';
import 'all_chefs_page.dart';
import '../profile/chef_profile_public_page.dart';
import 'all_hot_recipes_page.dart';
import '../recipe/recipe_details_page.dart';
import 'search_page.dart';
import '../../../common/constants.dart';

class RecipeDiscoveryScreen extends StatefulWidget {
  const RecipeDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<RecipeDiscoveryScreen> createState() => _RecipeDiscoveryScreenState();
}

class _RecipeDiscoveryScreenState extends State<RecipeDiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(LoadDiscovery());
  }

  String _getLocalizedTitle(Recipe recipe) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'ar' &&
            recipe.titleAr != null &&
            recipe.titleAr!.isNotEmpty
        ? recipe.titleAr!
        : (locale == 'fr' &&
                  recipe.titleFr != null &&
                  recipe.titleFr!.isNotEmpty
              ? recipe.titleFr!
              : recipe.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.discoverRecipes,
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.findYourNextFavoriteMeal,
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'LeagueSpartan',
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0, top: 10),
            child: Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsPage(),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF2A2A2A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Color(0xFF3A3A3A)
                            : Colors.grey.withOpacity(0.1),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          size: 24,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        BlocBuilder<NotificationsBloc, NotificationsState>(
                          builder: (context, state) {
                            if (state is NotificationsLoaded &&
                                state.unreadCount > 0) {
                              return Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.connectionIssue,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.connectionIssueMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<DiscoveryBloc>().add(LoadDiscovery());
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(AppLocalizations.of(context)!.retry),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // Force refresh all discovery data
              context.read<DiscoveryBloc>().add(RefreshDiscovery());
              // Wait for the state to finish loading
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.red600,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    SearchBarWidget(
                      hintText: AppLocalizations.of(
                        context,
                      )!.searchRecipesOrChefs,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchPage()),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SectionHeaderWidget(
                      title: AppLocalizations.of(context)!.chefs,
                      onSeeAllPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AllChefsPage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final chef in state.chefsOnFire) ...[
                            ChefCardWidget(
                              name: chef.name,
                              imageUrl: chef.imageUrl,
                              isOnFire: chef.isOnFire,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChefProfilePublicPage(chefId: chef.id),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SectionHeaderWidget(
                      title: AppLocalizations.of(context)!.hotRecipes,
                      onSeeAllPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllHotRecipesPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        // Decrease aspect ratio to increase tile height and prevent overflow
                        childAspectRatio: 0.82,
                      ),
                      itemCount: state.hotRecipes.length.clamp(0, 4),
                      itemBuilder: (context, index) {
                        final recipe = state.hotRecipes[index];
                        final title = _getLocalizedTitle(recipe);
                        return RecipeCardWidget(
                          title: title,
                          subtitle: title,
                          imageUrl: recipe.imageUrl,
                          isFavorite: recipe.isFavorite,
                          heroTag: 'recipe_${recipe.id}',
                          onFavoritePressed: () {
                            final userId = context
                                .read<AuthCubit>()
                                .state
                                .userId;
                            if (userId == null) {
                              showLoginRequiredModal(
                                context,
                                customMessage: AppLocalizations.of(
                                  context,
                                )!.loginRequiredFavorites,
                              );
                              return;
                            }
                            context.read<DiscoveryBloc>().add(
                              ToggleDiscoveryRecipeFavorite(recipe.id),
                            );
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        RecipeDetailsPage(recipe: recipe),
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
                                reverseTransitionDuration: const Duration(
                                  milliseconds: 300,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    SectionHeaderWidget(
                      title: AppLocalizations.of(context)!.seasonalDelights,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        for (final recipe in state.seasonalRecipes) ...[
                          SeasonalItemWidget(
                            title: _getLocalizedTitle(recipe),
                            subtitle: _getLocalizedTitle(recipe),
                            imageUrl: recipe.imageUrl,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RecipeDetailsPage(recipe: recipe),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
