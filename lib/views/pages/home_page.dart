import 'package:chefkit/views/pages/favourites_page.dart';
import 'package:chefkit/views/pages/ingredient_selection_page.dart';
import 'package:chefkit/views/pages/inventory_page.dart';
import './discovery_page.dart';
import 'package:chefkit/views/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Start with Recipe Discovery (index 0)

  // Placeholder screens - you can replace these with actual pages later
  final List<Widget> _screens = [
    RecipeDiscoveryScreen(),
    InventoryPage(), // Your existing inventory page
    _PlaceholderScreen(title: 'Refresh/Recipe', icon: Icons.refresh),
    FavouritesPage(),
    _PlaceholderScreen(title: 'Profile', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          // If fire button (index 2) is tapped, navigate to ingredient selection
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IngredientSelectionPage(),
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

// Temporary placeholder widget for screens that haven't been created yet
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
