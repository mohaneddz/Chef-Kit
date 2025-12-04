import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Repositories
import 'package:chefkit/domain/repositories/chef_repository.dart';
import 'package:chefkit/domain/repositories/recipe_repository.dart';
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

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final chefRepository = ChefRepository();
    final recipeRepository = RecipeRepository();
    final profileRepository = ProfileRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: chefRepository),
        RepositoryProvider.value(value: recipeRepository),
        RepositoryProvider.value(value: profileRepository),
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
            create: (_) =>
                ProfileBloc(repository: profileRepository)..add(LoadProfile()),
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
          BlocProvider(create: (_) => AuthCubit()),
          BlocProvider(
            create: (_) =>
                FavouritesBloc(recipeRepository: recipeRepository)
                  ..add(LoadFavourites()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Poppins'),
          home: const SingupPage(),
        ),
      ),
    );
  }
}
