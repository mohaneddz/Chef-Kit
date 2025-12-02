import '../../common/constants.dart';
import 'package:flutter/material.dart';
import 'notifications_page.dart';
import 'edit_profile_page.dart';
import 'about_page.dart';
import '../../blocs/profile/popups/theme_popup.dart';
import '../../blocs/profile/popups/language_popup.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 72,
        leading: Align(
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.person,
            size: 52,
            color: AppColors.red600,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Profile",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
              ),
            ),
            const Text(
              "Manage your account",
              style: TextStyle(
                color: Color(0xFF4A5565),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Profile Header Card
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.red600.withOpacity(0.1),
                                AppColors.red600.withOpacity(0.05),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.red600.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.red600,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.red600, AppColors.red600.withOpacity(0.8)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.red600.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Chef Ramsay",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "chef.ramsay@chefkit.com",
                      style: TextStyle(
                        color: const Color(0xFF6A7282),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.restaurant_menu,
                      value: "24",
                      label: "Recipes",
                      color1: AppColors.red600,
                      color2: AppColors.red600.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.favorite,
                      value: "48",
                      label: "Favorites",
                      color1: AppColors.orange,
                      color2: AppColors.orange.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.bookmark,
                      value: "12",
                      label: "Saved",
                      color1: AppColors.red600,
                      color2: AppColors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Account Settings Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.red600, AppColors.red600.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Account Settings",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsTile(
                    icon: Icons.person_outline,
                    title: "Edit Profile",
                    subtitle: "Update your personal information",
                    gradient: LinearGradient(
                      colors: [AppColors.red600, AppColors.red600.withOpacity(0.8)],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfilePage()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: Icons.notifications_outlined,
                    title: "Notifications",
                    subtitle: "Manage notification preferences",
                    gradient: LinearGradient(
                      colors: [AppColors.red600, AppColors.red600.withOpacity(0.8)],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: Icons.lock_outline,
                    title: "Privacy & Security",
                    subtitle: "Password and security settings",
                    gradient: LinearGradient(
                      colors: [AppColors.red600, AppColors.red600.withOpacity(0.8)],
                    ),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Preferences Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.red600,
                              AppColors.red600.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.tune,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Preferences",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsTile(
                    icon: Icons.language,
                    title: "Language",
                    subtitle: "English (US)",
                    gradient: LinearGradient(
                      colors: [AppColors.red600, AppColors.red600.withOpacity(0.8)],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const LanguagePopup(),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: Icons.restaurant,
                    title: "Dietary Preferences",
                    subtitle: "Manage your dietary restrictions",
                    gradient: LinearGradient(
                      colors: [AppColors.red600, AppColors.red600.withOpacity(0.8)],
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: Icons.palette_outlined,
                    title: "Theme",
                    subtitle: "Light mode",
                    gradient: LinearGradient(
                      colors: [AppColors.red600, AppColors.red600.withOpacity(0.8)],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ThemePopup(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Support Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.red600, AppColors.red600.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Support",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: "Help & Support",
                    subtitle: "Get help with the app",
                    gradient: LinearGradient(
                      colors: [AppColors.red600, AppColors.red600.withOpacity(0.8)],
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: "About",
                    subtitle: "App version & information",
                    gradient: LinearGradient(
                      colors: [AppColors.red600, AppColors.red600.withOpacity(0.8)],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutPage()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Logout Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [AppColors.red600, AppColors.red600.withOpacity(0.8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.red600.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement logout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1.withOpacity(0.15), color2.withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color1.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color1, color2]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color1.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color1,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color1,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red600.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: AppColors.red600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF6A7282),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
