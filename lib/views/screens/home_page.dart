import 'package:chefkit/views/screens/favourites_page.dart';
import 'package:chefkit/views/screens/recipe_loading_page.dart';
import 'package:chefkit/views/screens/inventory_page.dart';
import 'package:chefkit/views/screens/profile_page.dart';
import 'discovery_page.dart';
import 'package:chefkit/views/layout/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';

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

  // Placeholder screens - you can replace these with actual pages later
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
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          if (index == 2) {
            final List<String> availableIngredients = [
              "Escalope",
              "Tomato",
              "Potato",
              "Paprika",
              "Chicken",
              "Onion",
              "Carrot",
              "Cumin",
            ];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeLoadingPage(
                  selectedIngredients: availableIngredients,
                ),
              ),
            );
          } else {
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
