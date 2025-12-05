import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/domain/repositories/ingredients/ingredient_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Repositories
import 'package:chefkit/domain/repositories/chef_repository.dart';
import 'package:chefkit/domain/repositories/recipe/recipe_repo.dart';
import 'package:chefkit/domain/repositories/profile_repository.dart';

// Blocs & events
import 'package:chefkit/blocs/discovery/discovery_bloc.dart';
import 'package:chefkit/blocs/discovery/discovery_events.dart';
import 'package:chefkit/blocs/profile/profile_bloc.dart';
import 'package:chefkit/blocs/profile/profile_events.dart';
import 'package:chefkit/blocs/chef_profile/chef_profile_bloc.dart';
import 'package:chefkit/blocs/chefs/chefs_bloc.dart';
import 'package:chefkit/blocs/chefs/chefs_events.dart';
import 'package:chefkit/blocs/inventory/inventory_bloc.dart';
import 'package:chefkit/blocs/favourites/favourites_bloc.dart';
import 'package:chefkit/blocs/favourites/favourites_events.dart';

import 'package:chefkit/views/screens/authentication/singup_page.dart';
import 'package:chefkit/views/screens/home_page.dart';
import 'package:chefkit/domain/offline_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = IngredientsRepo.getInstance();
  await repo.seedIngredients(); 
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final chefRepository = ChefRepository();
    final recipeRepository = RecipeRepository();

    final String baseUrl;
    if (kIsWeb) {
      baseUrl = 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:5000';
    } else {
      baseUrl = 'http://localhost:5000';
    }

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
            create: (_) => AuthCubit(
              baseUrl: baseUrl,
              offline: OfflineProvider(),
            ),
          ),
          BlocProvider(
            create: (_) =>
                FavouritesBloc(recipeRepository: recipeRepository)
                  ..add(LoadFavourites()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Poppins'),
          home: const AuthInitializer(),
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
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().restoreSessionOnStart();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (state.userId != null && state.accessToken != null) {
          // User is authenticated, show main app
          return const HomePage();
        }
        
        return const SingupPage();
      },
    );
  }
}
