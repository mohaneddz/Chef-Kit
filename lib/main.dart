import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;
import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/domain/repositories/ingredients/ingredient_repo.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import 'package:chefkit/common/config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import 'package:chefkit/blocs/locale/locale_cubit.dart';
import 'package:chefkit/blocs/notifications/notifications_bloc.dart';
import 'package:chefkit/blocs/notifications/notifications_event.dart';
import 'package:chefkit/blocs/theme/theme_cubit.dart';
import 'package:chefkit/common/constants.dart';

import 'package:chefkit/views/screens/home_page.dart';
import 'package:chefkit/domain/offline_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chefkit/views/screens/onboarding/onboarding_screen.dart';
import 'package:chefkit/common/navigation_service.dart';

bool get isFirebaseSupported {
  if (kIsWeb) return true;
  if (Platform.isAndroid || Platform.isIOS) return true;
  return false;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // .env not loaded
  }

  if (isFirebaseSupported) {
    try {
      await Firebase.initializeApp();

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Pass all uncaught async errors from the current Isolate to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Firebase Crashlytics initialized successfully

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize Firebase Messaging Service
      await FirebaseMessagingService().initialize();
    } catch (e) {
      // Firebase initialization failed
    }
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
                FavouritesBloc(recipeRepository: recipeRepository),
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
                  navigatorKey: NavigationService.navigatorKey,
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

    // Login is optional - always go to HomePage after onboarding
    // BlocBuilder still runs restoreSessionOnStart() in initState to auto-login returning users
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Always show HomePage - login is optional
        return const HomePage();
      },
    );
  }
}
