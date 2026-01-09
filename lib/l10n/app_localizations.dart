import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Chef Kit'**
  String get appTitle;

  /// No description provided for @discoverRecipes.
  ///
  /// In en, this message translates to:
  /// **'Discover Recipes'**
  String get discoverRecipes;

  /// No description provided for @findYourNextFavoriteMeal.
  ///
  /// In en, this message translates to:
  /// **'Find your next favorite meal'**
  String get findYourNextFavoriteMeal;

  /// No description provided for @searchRecipesOrChefs.
  ///
  /// In en, this message translates to:
  /// **'Search Recipes or Chefs'**
  String get searchRecipesOrChefs;

  /// No description provided for @chefs.
  ///
  /// In en, this message translates to:
  /// **'Chefs'**
  String get chefs;

  /// No description provided for @hotRecipes.
  ///
  /// In en, this message translates to:
  /// **'Hot Recipes'**
  String get hotRecipes;

  /// No description provided for @seasonalDelights.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Delights'**
  String get seasonalDelights;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String servings(String count);

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'{count} Kcal'**
  String calories(String count);

  /// No description provided for @recipeDetailsFor.
  ///
  /// In en, this message translates to:
  /// **'Recipe details for {name}'**
  String recipeDetailsFor(String name);

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutes(String count);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error(String message);

  /// No description provided for @allChefs.
  ///
  /// In en, this message translates to:
  /// **'All Chefs'**
  String get allChefs;

  /// No description provided for @superHot.
  ///
  /// In en, this message translates to:
  /// **'Super Hot'**
  String get superHot;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @superHotChefs.
  ///
  /// In en, this message translates to:
  /// **'Super Hot Chefs'**
  String get superHotChefs;

  /// No description provided for @trendingChefsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The most trending chefs right now'**
  String get trendingChefsSubtitle;

  /// No description provided for @paginationInfo.
  ///
  /// In en, this message translates to:
  /// **'Page {currentPage} of {totalPages} • {chefCount} chefs'**
  String paginationInfo(int currentPage, int totalPages, int chefCount);

  /// No description provided for @recipesStat.
  ///
  /// In en, this message translates to:
  /// **'recipes'**
  String get recipesStat;

  /// No description provided for @trendingStat.
  ///
  /// In en, this message translates to:
  /// **'trending'**
  String get trendingStat;

  /// No description provided for @favoritesStat.
  ///
  /// In en, this message translates to:
  /// **'favorites'**
  String get favoritesStat;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get filterTrending;

  /// No description provided for @filterTraditional.
  ///
  /// In en, this message translates to:
  /// **'Traditional'**
  String get filterTraditional;

  /// No description provided for @filterSoup.
  ///
  /// In en, this message translates to:
  /// **'Soup'**
  String get filterSoup;

  /// No description provided for @filterQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get filterQuick;

  /// No description provided for @hotBadge.
  ///
  /// In en, this message translates to:
  /// **'HOT'**
  String get hotBadge;

  /// No description provided for @seasonalDelightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Delights'**
  String get seasonalDelightsTitle;

  /// No description provided for @freshThisSeason.
  ///
  /// In en, this message translates to:
  /// **'Fresh This Season'**
  String get freshThisSeason;

  /// No description provided for @seasonalDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover recipes perfect for the current season'**
  String get seasonalDescription;

  /// No description provided for @seasonSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get seasonSpring;

  /// No description provided for @seasonSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get seasonSummer;

  /// No description provided for @seasonAutumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get seasonAutumn;

  /// No description provided for @seasonWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get seasonWinter;

  /// No description provided for @seasonalRecipesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {season} recipes'**
  String seasonalRecipesCount(int count, String season);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @notificationNewRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'New Recipe Posted!'**
  String get notificationNewRecipeTitle;

  /// No description provided for @notificationNewRecipeMessage.
  ///
  /// In en, this message translates to:
  /// **'Chef Gordon posted a new Beef Wellington recipe'**
  String get notificationNewRecipeMessage;

  /// No description provided for @notificationRecipeLikedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe Liked'**
  String get notificationRecipeLikedTitle;

  /// No description provided for @notificationRecipeLikedMessage.
  ///
  /// In en, this message translates to:
  /// **'Sarah liked your Mahjouba recipe'**
  String get notificationRecipeLikedMessage;

  /// No description provided for @notificationNewFollowerTitle.
  ///
  /// In en, this message translates to:
  /// **'New Follower'**
  String get notificationNewFollowerTitle;

  /// No description provided for @notificationNewFollowerMessage.
  ///
  /// In en, this message translates to:
  /// **'Chef Jamie started following you'**
  String get notificationNewFollowerMessage;

  /// No description provided for @notificationCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Comment on Recipe'**
  String get notificationCommentTitle;

  /// No description provided for @notificationCommentMessage.
  ///
  /// In en, this message translates to:
  /// **'Mike commented on your Couscous recipe: \"Looks delicious!\"'**
  String get notificationCommentMessage;

  /// No description provided for @notificationChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Challenge'**
  String get notificationChallengeTitle;

  /// No description provided for @notificationChallengeMessage.
  ///
  /// In en, this message translates to:
  /// **'New weekly cooking challenge is now available!'**
  String get notificationChallengeMessage;

  /// No description provided for @notificationSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe Saved'**
  String get notificationSavedTitle;

  /// No description provided for @notificationSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Tajine recipe was saved by 15 people this week'**
  String get notificationSavedMessage;

  /// No description provided for @notificationTrendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Trending Recipe'**
  String get notificationTrendingTitle;

  /// No description provided for @notificationTrendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Chorba recipe is trending! 🔥'**
  String get notificationTrendingMessage;

  /// No description provided for @notificationAchievementTitle.
  ///
  /// In en, this message translates to:
  /// **'New Achievement'**
  String get notificationAchievementTitle;

  /// No description provided for @notificationAchievementMessage.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You unlocked \"Master Chef\" badge'**
  String get notificationAchievementMessage;

  /// No description provided for @notificationRecipeDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe of the Day'**
  String get notificationRecipeDayTitle;

  /// No description provided for @notificationRecipeDayMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Barkoukes was featured as Recipe of the Day!'**
  String get notificationRecipeDayMessage;

  /// No description provided for @notificationIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Alert'**
  String get notificationIngredientTitle;

  /// No description provided for @notificationIngredientMessage.
  ///
  /// In en, this message translates to:
  /// **'Paprika is running low in your inventory'**
  String get notificationIngredientMessage;

  /// No description provided for @timeMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeMinAgo(int count);

  /// No description provided for @timeHourAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hour ago'**
  String timeHourAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDayAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} day ago'**
  String timeDayAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String timeDaysAgo(int count);

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'My Kitchen Inventory'**
  String get inventoryTitle;

  /// No description provided for @inventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your ingredients'**
  String get inventorySubtitle;

  /// No description provided for @availableIngredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Ingredients'**
  String get availableIngredientsTitle;

  /// No description provided for @availableIngredientsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your current pantry items'**
  String get availableIngredientsSubtitle;

  /// No description provided for @availableCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Available'**
  String availableCount(int count);

  /// No description provided for @totalItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Total Items'**
  String totalItemsCount(int count);

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @browseIngredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse all the ingredients'**
  String get browseIngredientsTitle;

  /// No description provided for @browseIngredientsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find what you need?'**
  String get browseIngredientsSubtitle;

  /// No description provided for @ingredientTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ingredientTypeAll;

  /// No description provided for @ingredientTypeProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get ingredientTypeProtein;

  /// No description provided for @ingredientTypeVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get ingredientTypeVegetables;

  /// No description provided for @ingredientTypeSpices.
  ///
  /// In en, this message translates to:
  /// **'Spices'**
  String get ingredientTypeSpices;

  /// No description provided for @ingredientTypeFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get ingredientTypeFruits;

  /// No description provided for @favouritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favouritesTitle;

  /// No description provided for @favouritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find Your Saved Recipes'**
  String get favouritesSubtitle;

  /// No description provided for @noFavouritesYet.
  ///
  /// In en, this message translates to:
  /// **'No Favourites Yet'**
  String get noFavouritesYet;

  /// No description provided for @noFavouritesMessage.
  ///
  /// In en, this message translates to:
  /// **'Explore the app and save your favourite recipes!'**
  String get noFavouritesMessage;

  /// No description provided for @searchYourRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search Your Recipes...'**
  String get searchYourRecipes;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @searchIngredient.
  ///
  /// In en, this message translates to:
  /// **'Search ingredient...'**
  String get searchIngredient;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noProfileData.
  ///
  /// In en, this message translates to:
  /// **'No profile data'**
  String get noProfileData;

  /// No description provided for @recipesCount.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesCount;

  /// No description provided for @followingCount.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingCount;

  /// No description provided for @followersCount.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followersCount;

  /// No description provided for @chefsCorner.
  ///
  /// In en, this message translates to:
  /// **'Chef\'s Corner'**
  String get chefsCorner;

  /// No description provided for @myRecipes.
  ///
  /// In en, this message translates to:
  /// **'My Recipes'**
  String get myRecipes;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityTitle;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @accountSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage how you sign in and keep your account protected.'**
  String get accountSecuritySubtitle;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @changeEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will send a six-digit code to your new address to confirm the switch.'**
  String get changeEmailSubtitle;

  /// No description provided for @newEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'New email address'**
  String get newEmailAddress;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @confirmChange.
  ///
  /// In en, this message translates to:
  /// **'Confirm change'**
  String get confirmChange;

  /// No description provided for @editEmailInput.
  ///
  /// In en, this message translates to:
  /// **'Edit email input'**
  String get editEmailInput;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @updatePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your password must include at least eight characters. We will confirm with a code sent to your inbox.'**
  String get updatePasswordSubtitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @passwordHelperText.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get passwordHelperText;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @editPasswordInputs.
  ///
  /// In en, this message translates to:
  /// **'Edit password inputs'**
  String get editPasswordInputs;

  /// No description provided for @noEmailOnFile.
  ///
  /// In en, this message translates to:
  /// **'No email on file'**
  String get noEmailOnFile;

  /// No description provided for @enterNewEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new email address.'**
  String get enterNewEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get enterValidEmail;

  /// No description provided for @emailMatchesCurrent.
  ///
  /// In en, this message translates to:
  /// **'New email matches your current email.'**
  String get emailMatchesCurrent;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to {email}. Check your inbox to continue.'**
  String otpSentTo(String email);

  /// No description provided for @enterOtpSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP code sent to your new email.'**
  String get enterOtpSent;

  /// No description provided for @otpLengthError.
  ///
  /// In en, this message translates to:
  /// **'OTP codes are 6 digits.'**
  String get otpLengthError;

  /// No description provided for @emailUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email updated successfully.'**
  String get emailUpdatedSuccess;

  /// No description provided for @completePasswordFields.
  ///
  /// In en, this message translates to:
  /// **'Complete all password fields.'**
  String get completePasswordFields;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters for your new password.'**
  String get passwordLengthError;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New password and confirmation do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'New password must differ from the current password.'**
  String get passwordMustDiffer;

  /// No description provided for @otpSentEmail.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your email. Enter it to confirm the password update.'**
  String get otpSentEmail;

  /// No description provided for @provideOtpAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Provide both the OTP code and new password.'**
  String get provideOtpAndPassword;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully. Use your new password next time you sign in.'**
  String get passwordUpdatedSuccess;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @navDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get navDiscovery;

  /// No description provided for @navInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get navInventory;

  /// No description provided for @navFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get navFavorite;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @allSaved.
  ///
  /// In en, this message translates to:
  /// **'All Saved'**
  String get allSaved;

  /// No description provided for @recipeSingular.
  ///
  /// In en, this message translates to:
  /// **'recipe'**
  String get recipeSingular;

  /// No description provided for @recipePlural.
  ///
  /// In en, this message translates to:
  /// **'recipes'**
  String get recipePlural;

  /// No description provided for @loadingAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your ingredients...'**
  String get loadingAnalyzing;

  /// No description provided for @loadingSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching recipes...'**
  String get loadingSearching;

  /// No description provided for @loadingMatching.
  ///
  /// In en, this message translates to:
  /// **'Matching...'**
  String get loadingMatching;

  /// No description provided for @loadingFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding perfect recipes...'**
  String get loadingFinding;

  /// No description provided for @findingRecipes.
  ///
  /// In en, this message translates to:
  /// **'Finding Recipes'**
  String get findingRecipes;

  /// No description provided for @recipeResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe Results'**
  String get recipeResultsTitle;

  /// No description provided for @recipesFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No recipes found} =1{1 recipe found} other{{count} recipes found}}'**
  String recipesFound(int count);

  /// No description provided for @yourIngredients.
  ///
  /// In en, this message translates to:
  /// **'Your Ingredients:'**
  String get yourIngredients;

  /// No description provided for @recipesYouCanMake.
  ///
  /// In en, this message translates to:
  /// **'Recipes You Can Make'**
  String get recipesYouCanMake;

  /// No description provided for @sortedByMatch.
  ///
  /// In en, this message translates to:
  /// **'Sorted by ingredient match'**
  String get sortedByMatch;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get caloriesLabel;

  /// No description provided for @servingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servingsLabel;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @stepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String stepsCount(int count);

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfoTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// No description provided for @storyLabel.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get storyLabel;

  /// No description provided for @specialtiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialities'**
  String get specialtiesLabel;

  /// No description provided for @addSpecialtyHint.
  ///
  /// In en, this message translates to:
  /// **'Add speciality'**
  String get addSpecialtyHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @fullNameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Full Name cannot be empty'**
  String get fullNameEmptyError;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String profileUpdateError(String error);

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Personal info updated'**
  String get profileUpdateSuccess;

  /// No description provided for @noRecipesFound.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get noRecipesFound;

  /// No description provided for @connectionIssue.
  ///
  /// In en, this message translates to:
  /// **'Connection issue'**
  String get connectionIssue;

  /// No description provided for @connectionIssueMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again'**
  String get connectionIssueMessage;

  /// No description provided for @generateRecipe.
  ///
  /// In en, this message translates to:
  /// **'Generate Recipe'**
  String get generateRecipe;

  /// No description provided for @cookingDuration.
  ///
  /// In en, this message translates to:
  /// **'Cooking Duration'**
  String get cookingDuration;

  /// No description provided for @availableIngredients.
  ///
  /// In en, this message translates to:
  /// **'Available Ingredients'**
  String get availableIngredients;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @loginRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequiredTitle;

  /// No description provided for @loginRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign up or log in to use this feature'**
  String get loginRequiredMessage;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @loginRequiredFavorites.
  ///
  /// In en, this message translates to:
  /// **'Sign up to save your favorite recipes'**
  String get loginRequiredFavorites;

  /// No description provided for @loginRequiredFollow.
  ///
  /// In en, this message translates to:
  /// **'Sign up to follow chefs'**
  String get loginRequiredFollow;

  /// No description provided for @guestProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign up to unlock all features'**
  String get guestProfileMessage;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @loginRequiredNotifications.
  ///
  /// In en, this message translates to:
  /// **'Sign up to see your notifications'**
  String get loginRequiredNotifications;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
