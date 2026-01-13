# 🍳 Chef-Kit Project Architecture

> A comprehensive guide to understanding the Flutter mobile application structure, state management, and data flow.

---

## 📁 Project Structure Overview

```
lib/
├── main.dart                 # App entry point, sets up BLoC providers
├── blocs/                    # All BLoC state management
│   ├── discovery/           # Discovery page state
│   ├── profile/             # Profile page state
│   ├── favourites/          # Favorites state
│   ├── auth/                # Authentication state
│   ├── chef_profile/        # Chef profile viewing state
│   ├── chefs/               # Chefs list state
│   ├── inventory/           # Ingredient inventory state
│   ├── notifications/       # Notifications state
│   ├── locale/              # Language settings
│   └── theme/               # Dark/Light mode
├── domain/                   # Business logic layer
│   ├── models/              # Data models (Recipe, Chef, UserProfile)
│   └── repositories/        # API calls (RecipeRepository, ChefRepository)
├── views/
│   ├── screens/             # Full pages/screens
│   │   ├── discovery/       # Discovery page + related pages
│   │   ├── profile/         # Profile page + related pages
│   │   ├── recipe/          # Recipe details + creation
│   │   ├── favourite/       # Favorites page
│   │   ├── inventory/       # Inventory management
│   │   └── authentication/  # Login/Signup pages
│   ├── widgets/             # Reusable UI components
│   └── layout/              # Layout components (bottom navbar)
├── common/                   # Shared utilities
│   ├── config.dart          # API configuration
│   ├── constants.dart       # Colors, themes
│   └── token_storage.dart   # JWT token management
└── l10n/                     # Localization (English, French, Arabic)
```

---

## 🧠 Understanding BLoC Pattern (Business Logic Component)

### What is BLoC?

BLoC is a **state management pattern** that separates business logic from UI. It makes your app:

- **Testable** - Logic is separate from widgets
- **Predictable** - Data flows in one direction
- **Scalable** - Easy to add new features

### The Three Components

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    EVENT    │ →  │    BLoC     │ →  │    STATE    │
│ (user action)│    │  (logic)    │    │ (UI data)   │
└─────────────┘    └─────────────┘    └─────────────┘
```

| Component | Description                               | Example                           |
| --------- | ----------------------------------------- | --------------------------------- |
| **Event** | An action triggered by the user or system | `LoadDiscovery`, `ToggleFavorite` |
| **BLoC**  | Processes events and calls repositories   | `DiscoveryBloc`, `ProfileBloc`    |
| **State** | Holds the current data for the UI         | `DiscoveryState`, `ProfileState`  |

### How Data Flows

1. **User taps a button** → UI dispatches an Event
2. **BLoC receives Event** → Calls repository to fetch/update data
3. **Repository makes API call** → Returns data to BLoC
4. **BLoC emits new State** → UI rebuilds with new data

---

## 🔍 Discovery Page Deep Dive

### Overview

The Discovery page (`discovery_page.dart`) is the **main home screen** showing:

- 🔍 Search bar
- 👨‍🍳 Chefs on Fire (horizontal scroll)
- 🔥 Hot Recipes (2-column grid, max 4 items)
- 🍂 Seasonal Recipes (vertical list)

### File Structure

```
lib/
├── views/screens/discovery/
│   ├── discovery_page.dart      # Main discovery screen
│   ├── all_chefs_page.dart      # "See All" chefs page
│   ├── all_hot_recipes_page.dart # "See All" hot recipes
│   └── search_page.dart         # Search functionality
└── blocs/discovery/
    ├── discovery_bloc.dart      # Business logic
    ├── discovery_events.dart    # Available events
    └── discovery_state.dart     # State definition
```

### Discovery Events (`discovery_events.dart`)

```dart
// Base class for all discovery events
abstract class DiscoveryEvent {}

// Event: Load initial data
class LoadDiscovery extends DiscoveryEvent {}

// Event: Pull-to-refresh (force reload)
class RefreshDiscovery extends DiscoveryEvent {}

// Event: Like/unlike a recipe
class ToggleDiscoveryRecipeFavorite extends DiscoveryEvent {
  final String recipeId;
  ToggleDiscoveryRecipeFavorite(this.recipeId);
}
```

### Discovery State (`discovery_state.dart`)

```dart
class DiscoveryState {
  final bool loading;              // Show loading spinner?
  final List<Chef> chefsOnFire;    // List of featured chefs
  final List<Recipe> hotRecipes;   // Trending recipes
  final List<Recipe> seasonalRecipes;  // Seasonal recipes
  final String? error;             // Error message if any
  final String? syncError;         // Non-blocking error for favorites

  // copyWith method allows creating new state with modified fields
  DiscoveryState copyWith({...}) => DiscoveryState(...);
}
```

### Discovery BLoC (`discovery_bloc.dart`)

```dart
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final ChefRepository chefRepository;
  final RecipeRepository recipeRepository;

  DiscoveryBloc({required this.chefRepository, required this.recipeRepository})
    : super(DiscoveryState()) {
    // Register event handlers
    on<LoadDiscovery>(_onLoad);
    on<RefreshDiscovery>(_onRefresh);
    on<ToggleDiscoveryRecipeFavorite>(_onToggleFavorite);
  }

  // Handler: Load initial data
  Future<void> _onLoad(LoadDiscovery event, Emitter<DiscoveryState> emit) async {
    // Skip if already loading or has data
    if (state.loading) return;
    if (state.chefsOnFire.isNotEmpty && state.hotRecipes.isNotEmpty) return;

    emit(state.copyWith(loading: true));  // Show spinner

    // Load each section independently
    final chefs = await chefRepository.fetchChefsOnFire();
    final hot = await recipeRepository.fetchHotRecipes();
    final seasonal = await recipeRepository.fetchSeasonalRecipes();

    emit(state.copyWith(
      loading: false,
      chefsOnFire: chefs,
      hotRecipes: hot,
      seasonalRecipes: seasonal,
    ));
  }

  // Handler: Toggle favorite (with optimistic update)
  Future<void> _onToggleFavorite(ToggleDiscoveryRecipeFavorite event, Emitter emit) async {
    // 1. Immediately update UI (optimistic)
    final updatedRecipes = state.hotRecipes.map((r) {
      if (r.id == event.recipeId) {
        return r.copyWith(isFavorite: !r.isFavorite);
      }
      return r;
    }).toList();
    emit(state.copyWith(hotRecipes: updatedRecipes));

    // 2. Sync with server in background
    try {
      await recipeRepository.toggleFavorite(event.recipeId);
    } catch (e) {
      // Don't revert - show error via snackbar instead
      emit(state.copyWith(syncError: 'Failed to sync favorite'));
    }
  }
}
```

### Discovery Page UI (`discovery_page.dart`)

```dart
class RecipeDiscoveryScreen extends StatefulWidget {
  @override
  State<RecipeDiscoveryScreen> createState() => _RecipeDiscoveryScreenState();
}

class _RecipeDiscoveryScreenState extends State<RecipeDiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger data loading when page initializes
    context.read<DiscoveryBloc>().add(LoadDiscovery());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Discover Recipes')),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, state) {
          // Handle loading state
          if (state.loading) {
            return Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (state.error != null) {
            return Center(
              child: Column(
                children: [
                  Text('Connection Issue'),
                  ElevatedButton(
                    onPressed: () => context.read<DiscoveryBloc>().add(LoadDiscovery()),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Display data
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DiscoveryBloc>().add(RefreshDiscovery());
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Search Bar
                  SearchBarWidget(onTap: () => Navigator.push(...)),

                  // Chefs Section
                  SectionHeaderWidget(title: 'Chefs', onSeeAllPressed: () => ...),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final chef in state.chefsOnFire)
                          ChefCardWidget(
                            name: chef.name,
                            imageUrl: chef.imageUrl,
                            onTap: () => Navigator.push(...),
                          ),
                      ],
                    ),
                  ),

                  // Hot Recipes Section
                  SectionHeaderWidget(title: 'Hot Recipes'),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: state.hotRecipes.length.clamp(0, 4),
                    itemBuilder: (context, index) {
                      final recipe = state.hotRecipes[index];
                      return RecipeCardWidget(
                        title: recipe.name,
                        imageUrl: recipe.imageUrl,
                        isFavorite: recipe.isFavorite,
                        onFavoritePressed: () {
                          context.read<DiscoveryBloc>().add(
                            ToggleDiscoveryRecipeFavorite(recipe.id),
                          );
                        },
                        onTap: () => Navigator.push(...RecipeDetailsPage...),
                      );
                    },
                  ),

                  // Seasonal Recipes Section
                  for (final recipe in state.seasonalRecipes)
                    SeasonalItemWidget(title: recipe.name, ...),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

## 👤 Profile Page Deep Dive

### Overview

The Profile page shows:

- 👤 User avatar and name
- 📊 Stats (recipes count, followers, following)
- ⚙️ Settings menu (Personal Info, Security, Language, Dark Mode)
- 🚪 Logout button

### Key Feature: Guest vs Logged-in User

```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthCubit>().state.userId;

    // Guest user - show limited profile with signup prompt
    if (userId == null) {
      return _GuestProfilePage();
    }

    // Logged-in user - create ProfileBloc and load data
    return BlocProvider(
      create: (context) => ProfileBloc(
        repository: ProfileRepository(...),
      )..add(LoadProfile(userId: userId)),
      child: _ProfilePageContent(),
    );
  }
}
```

### Profile Events (`profile_events.dart`)

```dart
abstract class ProfileEvent {}

// Load user profile data
class LoadProfile extends ProfileEvent {
  final String userId;
  LoadProfile({required this.userId});
}

// Increment recipe count (after creating a recipe)
class IncrementProfileRecipes extends ProfileEvent {}

// Update personal information
class UpdatePersonalInfo extends ProfileEvent {
  final String userId;
  final String fullName;
  final String bio;
  final String story;
  final List<String> specialties;
  UpdatePersonalInfo({...});
}
```

### Profile State (`profile_state.dart`)

```dart
class ProfileState {
  final bool loading;           // Loading profile?
  final bool saving;            // Saving changes?
  final UserProfile? profile;   // User data
  final String? error;          // Error message

  ProfileState copyWith({...}) => ProfileState(...);
}
```

### Profile BLoC (`profile_bloc.dart`)

```dart
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileState()) {
    on<LoadProfile>(_onLoad);
    on<UpdatePersonalInfo>(_onUpdatePersonalInfo);
  }

  Future<void> _onLoad(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final profile = await repository.fetchProfile(event.userId);
      emit(state.copyWith(loading: false, profile: profile));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdatePersonalInfo(UpdatePersonalInfo event, Emitter emit) async {
    emit(state.copyWith(saving: true));
    try {
      final updated = await repository.updatePersonalInfo(
        userId: event.userId,
        fullName: event.fullName,
        bio: event.bio,
        story: event.story,
        specialties: event.specialties,
      );
      emit(state.copyWith(saving: false, profile: updated));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }
}
```

### Profile Sub-pages

| Page          | File                            | Description                 |
| ------------- | ------------------------------- | --------------------------- |
| Personal Info | `personal_info_page.dart`       | Edit name, bio, specialties |
| Security      | `security_page.dart`            | Change password             |
| Chef Profile  | `chef_profile_public_page.dart` | View other chef's profiles  |

---

## 🏠 Home Page (Navigation Hub)

The `HomePage` uses `IndexedStack` to manage tab navigation:

```dart
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // All screens in tab order
  final List<Widget> _screens = [
    RecipeDiscoveryScreen(),  // Tab 0: Discovery
    InventoryPage(),          // Tab 1: Inventory
    _PlaceholderScreen(),     // Tab 2: Recipe generation (modal)
    FavouritesPage(),         // Tab 3: Favorites
    ProfilePage(),            // Tab 4: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all screens alive but only shows selected one
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          if (index == 2) {
            // Special case: show modal for recipe generation
            showModalBottomSheet(...);
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
    );
  }
}
```

---

## 🔗 App Initialization (`main.dart`)

### Entry Point

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase (for notifications, crashlytics)
  if (isFirebaseSupported) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FirebaseMessagingService().initialize();
  }

  // Load saved preferences
  final savedLocale = await storage.read(key: 'selected_locale');
  final savedTheme = await ThemeCubit.loadSavedTheme();

  runApp(MainApp(initialLocale: savedLocale, initialTheme: savedTheme));
}
```

### Global BLoC Providers

```dart
class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: ChefRepository()),
        RepositoryProvider.value(value: RecipeRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          // Discovery - loads immediately
          BlocProvider(
            create: (_) => DiscoveryBloc(...)..add(LoadDiscovery()),
          ),
          // Auth - manages login state
          BlocProvider(create: (_) => AuthCubit(...)),
          // Favorites
          BlocProvider(
            create: (_) => FavouritesBloc(...)..add(LoadFavourites()),
          ),
          // Notifications
          BlocProvider(
            create: (_) => NotificationsBloc()..add(LoadNotifications()),
          ),
          // Settings
          BlocProvider(create: (_) => LocaleCubit(initialLocale)),
          BlocProvider(create: (_) => ThemeCubit(initialTheme)),
        ],
        child: MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          home: AuthInitializer(),  // Checks onboarding + auth
        ),
      ),
    );
  }
}
```

---

## 🎨 Reusable Widgets

### Widget Organization

```
lib/views/widgets/
├── recipe/
│   ├── recipe_card_widget.dart      # Recipe cards in grids
│   ├── seasonal_item_widget.dart    # Seasonal recipe row
│   └── ingredient_chip_widget.dart  # Ingredient tags
├── profile/
│   └── chef_card_widget.dart        # Chef avatar cards
├── favourites/
│   └── favourite_card_widget.dart   # Favorite recipe cards
├── search_bar_widget.dart           # Search bar
├── section_header_widget.dart       # "Title" + "See All" button
├── button_widget.dart               # Custom buttons
├── text_field_widget.dart           # Custom text inputs
├── top_navbar.dart                  # Custom app bar
└── login_required_modal.dart        # "Please login" popup
```

### Example: RecipeCardWidget

```dart
class RecipeCardWidget extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [...],
        ),
        child: Column(
          children: [
            // Image with favorite button overlay
            Stack(
              children: [
                ClipRRect(
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 12, right: 12,
                  child: GestureDetector(
                    onTap: onFavoritePressed,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            // Title and subtitle
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📊 Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP                               │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────────┐    │
│  │  UI (Views) │ ←→  │    BLoC     │ ←→  │   Repository    │    │
│  │             │     │             │     │                 │    │
│  │ - Widgets   │     │ - Events    │     │ - HTTP client   │    │
│  │ - Screens   │     │ - State     │     │ - JSON parsing  │    │
│  │ - Pages     │     │ - Handlers  │     │ - Error handling│    │
│  └─────────────┘     └─────────────┘     └─────────────────┘    │
│         ↑                                        ↓               │
│         │                                        │               │
│    User sees                              HTTP Requests          │
│    UI updates                                    │               │
│                                                  ↓               │
└──────────────────────────────────────────────────┼───────────────┘
                                                   │
                                          ┌────────┴────────┐
                                          │  Flask Backend  │
                                          │   (Render)      │
                                          │                 │
                                          │  - REST API     │
                                          │  - Auth         │
                                          │  - Business     │
                                          │    Logic        │
                                          └────────┬────────┘
                                                   │
                                          ┌────────┴────────┐
                                          │    Supabase     │
                                          │                 │
                                          │  - PostgreSQL   │
                                          │  - Auth         │
                                          │  - Storage      │
                                          └─────────────────┘
```

---

## 🗣️ Presentation Talking Points

### If asked: "Explain your architecture"

> "We use the **BLoC (Business Logic Component) pattern** for state management. Each feature has its own BLoC that handles business logic separately from the UI. When the user performs an action, the UI dispatches an **Event**. The BLoC processes this event, typically calling a **Repository** to fetch or update data via HTTP. Once complete, the BLoC emits a new **State**, and the UI automatically rebuilds using `BlocBuilder`."

### If asked: "Why BLoC instead of setState?"

> "BLoC provides better **separation of concerns** - UI code doesn't contain business logic. It's also more **testable** since we can unit test BLoCs without widgets. Finally, it handles **complex state** better - for example, our Discovery page needs to track loading state, error state, and three different lists of data simultaneously."

### If asked: "How does the Discovery page work?"

> "When the user opens the app, `initState` calls `add(LoadDiscovery())` to dispatch an event. The `DiscoveryBloc` receives this and calls three repository methods in parallel: `fetchChefsOnFire()`, `fetchHotRecipes()`, and `fetchSeasonalRecipes()`. These make HTTP GET requests to our Flask backend. When all data is received, the bloc emits a new state with `loading: false` and the data lists populated. The `BlocBuilder` widget in the UI detects this state change and rebuilds, showing the recipe cards and chef avatars."

### If asked: "How do favorites work?"

> "We use **optimistic updates**. When the user taps the heart icon, we immediately toggle `isFavorite` in the local state so the UI updates instantly. Then we call the backend API in the background. If the API call fails, we show a non-blocking error message but don't revert the UI - the local cache preserves their intent until the next successful sync."

### If asked: "How is the Profile page different for guests?"

> "The Profile page checks `AuthCubit.state.userId`. If it's null (guest user), we show `_GuestProfilePage` which has a 'Sign Up' button and basic settings like language and dark mode. If the user is logged in, we create a `ProfileBloc`, dispatch `LoadProfile(userId)`, and show the full profile with stats, menu items, and logout button."

---

## 📝 Key Files Reference

| File                     | Purpose                                         |
| ------------------------ | ----------------------------------------------- |
| `main.dart`              | App entry, Firebase init, global BLoC providers |
| `home_page.dart`         | Tab navigation with IndexedStack                |
| `discovery_page.dart`    | Main home screen with recipes/chefs             |
| `discovery_bloc.dart`    | Discovery business logic                        |
| `profile_page.dart`      | User profile with guest handling                |
| `profile_bloc.dart`      | Profile business logic                          |
| `recipe_repository.dart` | All recipe API calls                            |
| `chef_repository.dart`   | All chef API calls                              |
| `recipe.dart`            | Recipe data model                               |
| `user_profile.dart`      | User profile data model                         |

---

## 🚀 Good Luck with Your Presentation!

Remember:

- BLoC = Events → BLoC → State
- Repositories handle API calls
- Widgets are reusable UI components
- Screens are full pages that use widgets

You've got this! 💪
