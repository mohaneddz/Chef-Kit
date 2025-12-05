import 'dart:io';
import 'dart:convert';
import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/blocs/profile/profile_bloc.dart';
import 'package:chefkit/blocs/profile/profile_events.dart';
import 'package:chefkit/blocs/profile/profile_state.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/domain/repositories/profile_repository.dart';
import 'package:chefkit/views/screens/authentication/login_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../notifications_page.dart';
import 'edit_profile_page.dart';
import '../recipe/my_recipes_page.dart';
import '../../../blocs/profile/popups/language_popup.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final userId = authState.userId;
    final accessToken = authState.accessToken;

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Not logged in'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    // Resolve backend baseUrl depending on platform
    final String baseUrl;
    if (kIsWeb) {
      baseUrl = 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:5000';
    } else {
      baseUrl = 'http://localhost:5000';
    }

    return BlocProvider(
      create: (context) => ProfileBloc(
        repository: ProfileRepository(
          baseUrl: baseUrl,
          accessToken: accessToken,
        ),
      )..add(LoadProfile(userId: userId)),
      child: const _ProfilePageContent(),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

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
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading profile',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final userId = context.read<AuthCubit>().state.userId;
                      if (userId != null) {
                        context.read<ProfileBloc>().add(LoadProfile(userId: userId));
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = state.profile;
          if (profile == null) {
            return const Center(child: Text('No profile data'));
          }

          return SingleChildScrollView(
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
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: profile.avatarUrl.isNotEmpty && profile.avatarUrl.startsWith('http')
                                  ? NetworkImage(profile.avatarUrl)
                                  : null,
                              child: (profile.avatarUrl.isEmpty || !profile.avatarUrl.startsWith('http'))
                                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              print('=== Edit Avatar Button Tapped ===');
                              final userId = context.read<AuthCubit>().state.userId;
                              print('User ID: $userId');
                              if (userId != null) {
                                _onEditAvatarPressed(context, userId);
                              } else {
                                print('ERROR: userId is null');
                              }
                            },
                            child: Container(
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
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
                
                // Stats Row - Different for Chef vs Regular User
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: profile.isChef
                      ? Row(
                          children: [
                            Expanded(child: _buildStatItem("Recipes", profile.recipesCount.toString())),
                            Container(width: 1, height: 40, color: Colors.grey[200]),
                            Expanded(child: _buildStatItem("Following", profile.followingCount.toString())),
                            Container(width: 1, height: 40, color: Colors.grey[200]),
                            Expanded(child: _buildStatItem("Followers", _formatCount(profile.followersCount))),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem("Following", profile.followingCount.toString()),
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
                      // Chef's Corner - Only for chefs
                      if (profile.isChef) ...[
                        _buildSectionTitle("Chef's Corner"),
                        const SizedBox(height: 16),
                        _buildMenuItem(
                          context,
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
                        context,
                        icon: Icons.person_outline_rounded,
                        title: "Personal Info",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfilePage()),
                        ),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.notifications_outlined,
                        title: "Notifications",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationsPage()),
                        ),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.security_outlined,
                        title: "Security",
                        onTap: () {},
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle("Preferences"),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        context,
                        icon: Icons.language_rounded,
                        title: "Language",
                        trailing: "English (US)",
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => const LanguagePopup(),
                        ),
                      ),
                      _buildMenuItem(
                        context,
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
                          onPressed: () {
                            context.read<AuthCubit>().logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                              (route) => false,
                            );
                          },
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
          );
        },
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}k';
    }
    return count.toString();
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

  Widget _buildMenuItem(
    BuildContext context, {
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

Future<void> _onEditAvatarPressed(BuildContext context, String userId) async {
  try {
    print('=== _onEditAvatarPressed called ===');
    print('Opening image picker...');
    
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery, 
      maxWidth: 600, 
      maxHeight: 600, 
      imageQuality: 85
    );
    
    print('Picked result: ${picked?.path ?? "null - user cancelled"}');
    if (picked == null) {
      print('User cancelled image selection');
      return;
    }

    print('Reading image bytes...');
    final bytes = await picked.readAsBytes();
    print('Image size: ${bytes.length} bytes');
    
    print('Encoding to base64...');
    final b64 = base64Encode(bytes);
    print('Base64 length: ${b64.length} characters');

    final authState = context.read<AuthCubit>().state;
    final accessToken = authState.accessToken;
    print('Access token present: ${accessToken != null}');
    if (accessToken != null) {
      final preview = accessToken.length > 16
          ? '${accessToken.substring(0, 16)}...'
          : accessToken;
      print('Access token preview: $preview');
    }

    // Match baseUrl logic from ProfilePage
    final String baseUrl;
    if (kIsWeb) {
      baseUrl = 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:5000';
    } else {
      baseUrl = 'http://localhost:5000';
    }
    print('Upload URL: $baseUrl/api/users/$userId/avatar');

    print('Uploading to backend...');
    final resp = await http.post(
      Uri.parse('$baseUrl/api/users/$userId/avatar'),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'image_base64': b64}),
    );

    print('Upload response: ${resp.statusCode}');
    print('Response body: ${resp.body}');
    print('Response headers: ${resp.headers}');

    if (resp.statusCode == 200) {
      print('✅ Upload successful! Reloading profile...');
      // Reload profile to pick up new avatar URL
      context.read<ProfileBloc>().add(LoadProfile(userId: userId));
    } else {
      print('❌ Upload failed: ${resp.statusCode} ${resp.body}');
      debugPrint('Avatar upload failed: ${resp.statusCode} ${resp.body}');
    }
  } catch (e) {
    print('❌ Error in _onEditAvatarPressed: $e');
    debugPrint('Avatar upload error: $e');
  }
}