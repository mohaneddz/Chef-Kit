import 'package:chefkit/common/constants.dart';
import 'package:flutter/material.dart';
import '../notifications_page.dart';
import 'edit_profile_page.dart';
import '../recipe/my_recipes_page.dart';
import '../../../blocs/profile/popups/language_popup.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Dummy variable to simulate if the user is a chef
  final bool isChef = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: "Poppins",
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.red600.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 55,
                          backgroundImage:
                              AssetImage('assets/images/chefs/chef_1.png'),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.red600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Chef Ramsay",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "chef.ramsay@chefkit.com",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: _buildStatItem("Recipes", "24")),
                  Container(width: 1, height: 40, color: Colors.grey[200]),
                  Expanded(child: _buildStatItem("Following", "48")),
                  Container(width: 1, height: 40, color: Colors.grey[200]),
                  Expanded(child: _buildStatItem("Followers", "12k")),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Divider(height: 1, color: Colors.grey[100]),
            const SizedBox(height: 20),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isChef) ...[
                    _buildSectionTitle("Chef's Corner"),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      icon: Icons.restaurant_menu_rounded,
                      title: "My Recipes",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyRecipesPage()),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  _buildSectionTitle("General"),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: "Personal Info",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfilePage()),
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: "Notifications",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsPage()),
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.security_outlined,
                    title: "Security",
                    onTap: () {},
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle("Preferences"),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.language_rounded,
                    title: "Language",
                    trailing: "English (US)",
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => const LanguagePopup(),
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.dark_mode_outlined,
                    title: "Dark Mode",
                    isSwitch: true,
                    onTap: () {}, // Toggle logic
                  ),

                  const SizedBox(height: 40),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.red600.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Log Out",
                        style: TextStyle(
                          color: AppColors.red600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontFamily: "Poppins",
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: "Poppins",
        color: Colors.black,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? trailing,
    bool isSwitch = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  color: Colors.black87,
                ),
              ),
            ),
            if (isSwitch)
              Switch(
                value: false, 
                onChanged: (val) {},
                activeColor: AppColors.red600,
              )
            else if (trailing != null)
              Row(
                children: [
                  Text(
                    trailing,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontFamily: "Poppins",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                ],
              )
            else
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}