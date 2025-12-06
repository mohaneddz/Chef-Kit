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
            final List<String> availableIngredients = inventoryState.available
                .map((e) => e['name'] ?? '')
                .where((name) => name.isNotEmpty)
                .toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeLoadingPage(
                  selectedIngredients: availableIngredients,
                ),
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
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.white),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              '$title Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming soon...',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
