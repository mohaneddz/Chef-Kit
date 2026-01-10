import 'package:chefkit/views/screens/favourite/favourites_page.dart';
import 'package:chefkit/views/screens/recipe/recipe_loading_page.dart';
import 'package:chefkit/views/screens/inventory/inventory_page.dart';
import 'package:chefkit/views/screens/profile/profile_page.dart';
import 'package:chefkit/blocs/inventory/inventory_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'discovery/discovery_page.dart';
import 'package:chefkit/views/layout/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:chefkit/blocs/favourites/favourites_bloc.dart';
import 'package:chefkit/blocs/favourites/favourites_events.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import 'package:chefkit/views/widgets/recipe_generation_modal.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    RecipeDiscoveryScreen(),
    InventoryPage(),
    _PlaceholderScreen(title: 'Refresh/Recipe', icon: Icons.refresh),
    FavouritesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          if (index == 2) {
            final inventoryState = context.read<InventoryBloc>().state;
            final lang = inventoryState.currentLang;

            // Get ingredient maps with all translations
            final availableItems = inventoryState.available;

            // Display names (localized) for UI
            final List<String> displayIngredients = availableItems
                .map((e) => e['name_$lang'] ?? e['name_en'] ?? '')
                .where((name) => name.isNotEmpty)
                .toList();

            // English names for backend API
            final List<String> backendIngredients = availableItems
                .map((e) => e['key'] ?? e['name_en'] ?? '')
                .where((name) => name.isNotEmpty)
                .toList();

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (modalContext) => RecipeGenerationModal(
                availableIngredients: displayIngredients,
                backendIngredients: backendIngredients,
                onProceed: (duration, selectedDisplayIngredients) {
                  // Map selected display names back to English names for backend
                  final selectedBackendIngredients = <String>[];
                  for (int i = 0; i < displayIngredients.length; i++) {
                    if (selectedDisplayIngredients.contains(
                      displayIngredients[i],
                    )) {
                      selectedBackendIngredients.add(backendIngredients[i]);
                    }
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeLoadingPage(
                        selectedIngredients: selectedBackendIngredients,
                        displayIngredients: selectedDisplayIngredients,
                        duration: duration,
                        language: Localizations.localeOf(context).languageCode,
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            if (index == 3) {
              // Refresh favourites when switching to favorites tab
              context.read<FavouritesBloc>().add(
                RefreshFavourites(
                  allSavedText: AppLocalizations.of(context)!.allSaved,
                  recipeText: AppLocalizations.of(context)!.recipeSingular,
                  recipesText: AppLocalizations.of(context)!.recipePlural,
                  locale: Localizations.localeOf(context).languageCode,
                  otherText: "Other",
                ),
              );
            }
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.textTheme.bodySmall?.color),
            const SizedBox(height: 20),
            Text(
              '$title Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming soon...',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
