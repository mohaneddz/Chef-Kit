// unused import removed
import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/blocs/profile/profile_bloc.dart';
import 'package:chefkit/blocs/profile/profile_events.dart';
import 'package:chefkit/blocs/profile/profile_state.dart';
import 'package:chefkit/blocs/locale/locale_cubit.dart';
import 'package:chefkit/blocs/theme/theme_cubit.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/common/config.dart';
import 'package:chefkit/domain/repositories/profile_repository.dart';
import 'package:chefkit/views/screens/authentication/login_page.dart';
import 'package:chefkit/views/widgets/top_navbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chefkit/l10n/app_localizations.dart';
// import '../notifications_page.dart';
import 'personal_info_page.dart';
import 'security_page.dart';
import '../recipe/my_recipes_page.dart';
import '../../../blocs/profile/popups/language_popup.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final userId = authState.userId;
    final accessToken = authState.accessToken;

    // Guest user - show guest-friendly profile with settings
    if (userId == null) {
      return const _GuestProfilePage();
    }

    // Resolve backend baseUrl depending on platform
    // Resolve backend baseUrl
    final String baseUrl = AppConfig.baseUrl;

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

/// Guest profile page showing settings and signup prompt
class _GuestProfilePage extends StatelessWidget {
  const _GuestProfilePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: TopNavBar(title: loc.profileTitle, subtitle: loc.profileSubtitle),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Guest Avatar
            Center(
              child: Column(
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
                      child: Icon(
                        Icons.person_outline,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.notLoggedIn,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.guestProfileMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodySmall?.color,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign Up Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    loc.signUp,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 20),

            // Preferences Section (available to all users)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.preferences,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<LocaleCubit, Locale>(
                    builder: (context, locale) {
                      String languageName = loc.english;
                      switch (locale.languageCode) {
                        case 'fr':
                          languageName = loc.french;
                          break;
                        case 'ar':
                          languageName = loc.arabic;
                          break;
                        default:
                          languageName = loc.english;
                      }
                      return _buildGuestMenuItem(
                        context,
                        icon: Icons.language_rounded,
                        title: loc.language,
                        trailing: languageName,
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => const LanguagePopup(),
                        ),
                      );
                    },
                  ),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      return _buildGuestDarkModeItem(
                        context,
                        isDarkMode: themeMode == ThemeMode.dark,
                        onToggle: () {
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                color: isDark ? AppColors.darkCard : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: theme.iconTheme.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (trailing != null)
              Row(
                children: [
                  Text(
                    trailing,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodySmall?.color,
                      fontFamily: "Poppins",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.textTheme.bodySmall?.color,
                    size: 20,
                  ),
                ],
              )
            else
              Icon(
                Icons.chevron_right,
                color: theme.textTheme.bodySmall?.color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestDarkModeItem(
    BuildContext context, {
    required bool isDarkMode,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkCard : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode : Icons.dark_mode_outlined,
                size: 22,
                color: theme.iconTheme.color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.darkMode,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Switch(
              value: isDarkMode,
              onChanged: (val) => onToggle(),
              activeColor: AppColors.red600,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: TopNavBar(
        title: AppLocalizations.of(context)!.profileTitle,
        subtitle: AppLocalizations.of(context)!.profileSubtitle,
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
                    AppLocalizations.of(context)!.errorLoadingProfile,
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
                        context.read<ProfileBloc>().add(
                          LoadProfile(userId: userId),
                        );
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          final profile = state.profile;
          if (profile == null) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noProfileData),
            );
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
                              backgroundImage:
                                  profile.avatarUrl.isNotEmpty &&
                                      profile.avatarUrl.startsWith('http')
                                  ? NetworkImage(profile.avatarUrl)
                                  : null,
                              child:
                                  (profile.avatarUrl.isEmpty ||
                                      !profile.avatarUrl.startsWith('http'))
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodySmall?.color,
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
                            Expanded(
                              child: _buildStatItem(
                                AppLocalizations.of(context)!.recipesCount,
                                profile.recipesCount.toString(),
                                theme,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.dividerColor,
                            ),
                            Expanded(
                              child: _buildStatItem(
                                AppLocalizations.of(context)!.followingCount,
                                profile.followingCount.toString(),
                                theme,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.dividerColor,
                            ),
                            Expanded(
                              child: _buildStatItem(
                                AppLocalizations.of(context)!.followersCount,
                                _formatCount(profile.followersCount),
                                theme,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem(
                              AppLocalizations.of(context)!.followingCount,
                              profile.followingCount.toString(),
                              theme,
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 30),
                Divider(height: 1, color: theme.dividerColor),
                const SizedBox(height: 20),

                // Menu Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chef's Corner - Only for chefs
                      if (profile.isChef) ...[
                        _buildSectionTitle(
                          AppLocalizations.of(context)!.chefsCorner,
                          theme,
                        ),
                        const SizedBox(height: 16),
                        _buildMenuItem(
                          context,
                          icon: Icons.restaurant_menu_rounded,
                          title: AppLocalizations.of(context)!.myRecipes,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyRecipesPage(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      _buildSectionTitle(
                        AppLocalizations.of(context)!.general,
                        theme,
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        context,
                        icon: Icons.person_outline_rounded,
                        title: AppLocalizations.of(context)!.personalInfo,
                        onTap: () {
                          final profileBloc = context.read<ProfileBloc>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: profileBloc,
                                child: const PersonalInfoPage(),
                              ),
                            ),
                          );
                        },
                      ),
                      // _buildMenuItem(
                      //   context,
                      //   icon: Icons.notifications_outlined,
                      //   title: AppLocalizations.of(context)!.notificationsTitle,
                      //   onTap: () => Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => const NotificationsPage(),
                      //     ),
                      //   ),
                      // ),
                      _buildMenuItem(
                        context,
                        icon: Icons.security_outlined,
                        title: AppLocalizations.of(context)!.security,
                        onTap: () {
                          final profileBloc = context.read<ProfileBloc>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: profileBloc,
                                child: const SecurityPage(),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        AppLocalizations.of(context)!.preferences,
                        theme,
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<LocaleCubit, Locale>(
                        builder: (context, locale) {
                          String languageName = AppLocalizations.of(
                            context,
                          )!.english;
                          switch (locale.languageCode) {
                            case 'fr':
                              languageName = AppLocalizations.of(
                                context,
                              )!.french;
                              break;
                            case 'ar':
                              languageName = AppLocalizations.of(
                                context,
                              )!.arabic;
                              break;
                            default:
                              languageName = AppLocalizations.of(
                                context,
                              )!.english;
                          }
                          return _buildMenuItem(
                            context,
                            icon: Icons.language_rounded,
                            title: AppLocalizations.of(context)!.language,
                            trailing: languageName,
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => const LanguagePopup(),
                            ),
                          );
                        },
                      ),
                      BlocBuilder<ThemeCubit, ThemeMode>(
                        builder: (context, themeMode) {
                          return _buildDarkModeItem(
                            context,
                            isDarkMode: themeMode == ThemeMode.dark,
                            onToggle: () {
                              context.read<ThemeCubit>().toggleTheme();
                            },
                          );
                        },
                      ),

                      // Debug: Crashlytics Test (only in debug mode)
                      if (kDebugMode) ...[
                        const SizedBox(height: 32),
                        _buildSectionTitle('Developer', theme),
                        const SizedBox(height: 16),
                        _buildMenuItem(
                          context,
                          icon: Icons.bug_report_outlined,
                          title: 'Test Crashlytics (Non-Fatal)',
                          onTap: () {
                            FirebaseCrashlytics.instance.recordError(
                              Exception('Test non-fatal error from Chef-Kit'),
                              StackTrace.current,
                              reason: 'Testing Crashlytics integration',
                              fatal: false,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Non-fatal error sent to Crashlytics!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.warning_amber_rounded,
                          title: 'Force Crash (CAUTION!)',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Force Crash?'),
                                content: const Text(
                                  'This will crash the app to test Crashlytics. '
                                  'The app will close immediately. Continue?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      FirebaseCrashlytics.instance.crash();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Crash Now'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 40),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            context.read<AuthCubit>().logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
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
                            AppLocalizations.of(context)!.logOut,
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

  Widget _buildStatItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color,
            fontFamily: "Poppins",
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: "Poppins",
        color: theme.textTheme.titleLarge?.color,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                color: isDark ? AppColors.darkCard : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: theme.iconTheme.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  color: theme.textTheme.bodyLarge?.color,
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
                      color: theme.textTheme.bodySmall?.color,
                      fontFamily: "Poppins",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.textTheme.bodySmall?.color,
                    size: 20,
                  ),
                ],
              )
            else
              Icon(
                Icons.chevron_right,
                color: theme.textTheme.bodySmall?.color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeItem(
    BuildContext context, {
    required bool isDarkMode,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkCard : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode : Icons.dark_mode_outlined,
                size: 22,
                color: theme.iconTheme.color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.darkMode,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Switch(
              value: isDarkMode,
              onChanged: (val) => onToggle(),
              activeColor: AppColors.red600,
            ),
          ],
        ),
      ),
    );
  }
}
