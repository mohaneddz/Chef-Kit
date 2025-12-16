import 'dart:io' show Platform;
import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/domain/repositories/ingredients/ingredient_repo.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import 'package:chefkit/common/config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chefkit/common/firebase_messaging_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Repositories
import 'package:chefkit/domain/repositories/chef_repository.dart';
import 'package:chefkit/domain/repositories/recipe_repository.dart';
// unused profile repo removed

// Blocs & events
import 'package:chefkit/blocs/discovery/discovery_bloc.dart';
import 'package:chefkit/blocs/discovery/discovery_events.dart';
// unused profile blocs removed
import 'package:chefkit/blocs/chef_profile/chef_profile_bloc.dart';
import 'package:chefkit/blocs/chefs/chefs_bloc.dart';
import 'package:chefkit/blocs/chefs/chefs_events.dart';
import 'package:chefkit/blocs/inventory/inventory_bloc.dart';
import 'package:chefkit/blocs/favourites/favourites_bloc.dart';
import 'package:chefkit/blocs/favourites/favourites_events.dart';
import 'package:chefkit/blocs/locale/locale_cubit.dart';
import 'package:chefkit/blocs/notifications/notifications_bloc.dart';
import 'package:chefkit/blocs/notifications/notifications_event.dart';
import 'package:chefkit/blocs/theme/theme_cubit.dart';
import 'package:chefkit/common/constants.dart';

import 'package:chefkit/views/screens/authentication/singup_page.dart';
import 'package:chefkit/views/screens/home_page.dart';
import 'package:chefkit/domain/offline_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chefkit/views/screens/onboarding/onboarding_screen.dart';

/// Check if Firebase is supported on current platform
bool get isFirebaseSupported {
  if (kIsWeb) return true; // Web is supported
  if (Platform.isAndroid || Platform.isIOS) return true;
  // Windows, Linux, macOS desktop are NOT supported
  return false;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load local .env (gitignored) so runtime config like BASE_URL works in dev.
  // For CI/production you can still prefer `--dart-define=BASE_URL=...`.
  try {
    await dotenv.load(fileName: '.env');
    print('[Main] .env loaded');
  } catch (e) {
    // Don't crash if missing; AppConfig will throw a clear error if BASE_URL is required.
    print('[Main] .env not loaded: $e');
  }

  // Initialize Firebase only on supported platforms (Android, iOS, Web)
  if (isFirebaseSupported) {
    try {
      await Firebase.initializeApp();

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize Firebase Messaging Service
      await FirebaseMessagingService().initialize();

      print('[Main] Firebase initialized successfully');
    } catch (e) {
      print('[Main] Firebase initialization failed: $e');
      // Continue without Firebase - notifications won't work but app will run
    }
  } else {
    print(
      '[Main] Firebase not supported on this platform (${Platform.operatingSystem})',
    );
  }

  final repo = IngredientsRepo.getInstance();
  await repo.seedIngredients();

  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final String? savedLanguageCode = await storage.read(key: 'selected_locale');
  final initialLocale = savedLanguageCode != null
      ? Locale(savedLanguageCode)
      : null;

  // Load saved theme
  final savedTheme = await ThemeCubit.loadSavedTheme();

  runApp(MainApp(initialLocale: initialLocale, initialTheme: savedTheme));
}

class MainApp extends StatelessWidget {
  final Locale? initialLocale;
  final ThemeMode? initialTheme;

  const MainApp({super.key, this.initialLocale, this.initialTheme});

  @override
  Widget build(BuildContext context) {
    final chefRepository = ChefRepository();
    final recipeRepository = RecipeRepository();

    final String baseUrl = AppConfig.baseUrl;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: chefRepository),
        RepositoryProvider.value(value: recipeRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => DiscoveryBloc(
              chefRepository: chefRepository,
              recipeRepository: recipeRepository,
            )..add(LoadDiscovery()),
          ),
          BlocProvider(
            create: (_) => ChefProfileBloc(
              chefRepository: chefRepository,
              recipeRepository: recipeRepository,
            ),
          ),
          BlocProvider(
            create: (_) =>
                ChefsBloc(repository: chefRepository)..add(LoadChefs()),
          ),
          BlocProvider(create: (_) => InventoryBloc()),
          BlocProvider(
            create: (_) =>
                AuthCubit(baseUrl: baseUrl, offline: OfflineProvider()),
          ),
          BlocProvider(
            create: (_) =>
                FavouritesBloc(recipeRepository: recipeRepository)
                  ..add(LoadFavourites()),
          ),
          BlocProvider(
            create: (_) => NotificationsBloc()..add(const LoadNotifications()),
          ),
          BlocProvider(create: (_) => LocaleCubit(initialLocale)),
          BlocProvider(create: (_) => ThemeCubit(initialTheme)),
        ],
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeMode,
                  locale: locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: const AuthInitializer(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AuthInitializer extends StatefulWidget {
  const AuthInitializer({super.key});

  @override
  State<AuthInitializer> createState() => _AuthInitializerState();
}

class _AuthInitializerState extends State<AuthInitializer> {
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    context.read<AuthCubit>().restoreSessionOnStart();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wait for onboarding check
    if (_hasSeenOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show onboarding for first-time users
    if (!_hasSeenOnboarding!) {
      return const OnboardingScreen();
    }

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.userId != null && state.accessToken != null) {
          return const HomePage();
        }

        return const SingupPage();
      },
    );
  }
}
