// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Chef Kit';

  @override
  String get discoverRecipes => 'Découvrir des recettes';

  @override
  String get findYourNextFavoriteMeal => 'Trouvez votre prochain repas préféré';

  @override
  String get searchRecipesOrChefs => 'Rechercher des recettes ou des chefs';

  @override
  String get chefs => 'Chefs';

  @override
  String get hotRecipes => 'Recettes populaires';

  @override
  String get seasonalDelights => 'Délices de saison';

  @override
  String get seeAll => 'Tout voir';

  @override
  String servings(String count) {
    return '$count portions';
  }

  @override
  String calories(String count) {
    return '$count Kcal';
  }

  @override
  String recipeDetailsFor(String name) {
    return 'Détails de la recette pour $name';
  }

  @override
  String minutes(String count) {
    return '$count min';
  }

  @override
  String error(String message) {
    return 'Erreur : $message';
  }

  @override
  String get allChefs => 'Tous les chefs';

  @override
  String get superHot => 'Super Tendance';

  @override
  String get total => 'Total';

  @override
  String get superHotChefs => 'Chefs Super Tendance';

  @override
  String get trendingChefsSubtitle => 'Les chefs les plus tendances du moment';

  @override
  String paginationInfo(int currentPage, int totalPages, int chefCount) {
    return 'Page $currentPage sur $totalPages • $chefCount chefs';
  }

  @override
  String get recipesStat => 'recettes';

  @override
  String get trendingStat => 'tendances';

  @override
  String get favoritesStat => 'favoris';

  @override
  String get filterAll => 'Tout';

  @override
  String get filterTrending => 'Tendances';

  @override
  String get filterTraditional => 'Traditionnel';

  @override
  String get filterSoup => 'Soupe';

  @override
  String get filterQuick => 'Rapide';

  @override
  String get hotBadge => 'CHAUD';

  @override
  String get seasonalDelightsTitle => 'Délices de saison';

  @override
  String get freshThisSeason => 'Frais cette saison';

  @override
  String get seasonalDescription =>
      'Découvrez des recettes parfaites pour la saison actuelle';

  @override
  String get seasonSpring => 'Printemps';

  @override
  String get seasonSummer => 'Été';

  @override
  String get seasonAutumn => 'Automne';

  @override
  String get seasonWinter => 'Hiver';

  @override
  String seasonalRecipesCount(int count, String season) {
    return '$count recettes $season';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get noNotifications => 'Pas encore de notifications';

  @override
  String get notificationNewRecipeTitle => 'Nouvelle recette publiée !';

  @override
  String get notificationNewRecipeMessage =>
      'Chef Gordon a publié une nouvelle recette de Bœuf Wellington';

  @override
  String get notificationRecipeLikedTitle => 'Recette aimée';

  @override
  String get notificationRecipeLikedMessage =>
      'Sarah a aimé votre recette de Mahjouba';

  @override
  String get notificationNewFollowerTitle => 'Nouvel abonné';

  @override
  String get notificationNewFollowerMessage =>
      'Chef Jamie a commencé à vous suivre';

  @override
  String get notificationCommentTitle => 'Commentaire sur la recette';

  @override
  String get notificationCommentMessage =>
      'Mike a commenté votre recette de Couscous : \"Ça a l\'air délicieux !\"';

  @override
  String get notificationChallengeTitle => 'Défi hebdomadaire';

  @override
  String get notificationChallengeMessage =>
      'Le nouveau défi culinaire hebdomadaire est maintenant disponible !';

  @override
  String get notificationSavedTitle => 'Recette enregistrée';

  @override
  String get notificationSavedMessage =>
      'Votre recette de Tajine a été enregistrée par 15 personnes cette semaine';

  @override
  String get notificationTrendingTitle => 'Recette tendance';

  @override
  String get notificationTrendingMessage =>
      'Votre recette de Chorba est tendance ! 🔥';

  @override
  String get notificationAchievementTitle => 'Nouvelle réussite';

  @override
  String get notificationAchievementMessage =>
      'Félicitations ! Vous avez débloqué le badge \"Master Chef\"';

  @override
  String get notificationRecipeDayTitle => 'Recette du jour';

  @override
  String get notificationRecipeDayMessage =>
      'Votre Barkoukes a été présenté comme Recette du jour !';

  @override
  String get notificationIngredientTitle => 'Alerte ingrédient';

  @override
  String get notificationIngredientMessage =>
      'Le paprika est presque épuisé dans votre inventaire';

  @override
  String timeMinAgo(int count) {
    return 'il y a $count min';
  }

  @override
  String timeHourAgo(int count) {
    return 'il y a $count heure';
  }

  @override
  String timeHoursAgo(int count) {
    return 'il y a $count heures';
  }

  @override
  String timeDayAgo(int count) {
    return 'il y a $count jour';
  }

  @override
  String timeDaysAgo(int count) {
    return 'il y a $count jours';
  }

  @override
  String get inventoryTitle => 'Mon inventaire de cuisine';

  @override
  String get inventorySubtitle => 'Gérez vos ingrédients';

  @override
  String get availableIngredientsTitle => 'Ingrédients disponibles';

  @override
  String get availableIngredientsSubtitle => 'Vos articles actuels';

  @override
  String availableCount(int count) {
    return '$count Disponibles';
  }

  @override
  String totalItemsCount(int count) {
    return '$count Articles au total';
  }

  @override
  String get showLess => 'Voir moins';

  @override
  String get showMore => 'Voir plus';

  @override
  String get browseIngredientsTitle => 'Parcourir tous les ingrédients';

  @override
  String get browseIngredientsSubtitle => 'Trouvez ce dont vous avez besoin ?';

  @override
  String get ingredientTypeAll => 'Tout';

  @override
  String get ingredientTypeProtein => 'Protéines';

  @override
  String get ingredientTypeVegetables => 'Légumes';

  @override
  String get ingredientTypeSpices => 'Épices';

  @override
  String get ingredientTypeFruits => 'Fruits';

  @override
  String get favouritesTitle => 'Favoris';

  @override
  String get favouritesSubtitle => 'Retrouvez vos recettes enregistrées';

  @override
  String get noFavouritesYet => 'Pas encore de favoris';

  @override
  String get noFavouritesMessage =>
      'Explorez l\'application et enregistrez vos recettes préférées !';

  @override
  String get searchYourRecipes => 'Recherchez vos recettes...';

  @override
  String get categoriesTitle => 'Catégories';

  @override
  String get searchIngredient => 'Rechercher un ingrédient...';

  @override
  String get profileTitle => 'Profil';

  @override
  String get notLoggedIn => 'Non connecté';

  @override
  String get goToLogin => 'Aller à la connexion';

  @override
  String get errorLoadingProfile => 'Erreur lors du chargement du profil';

  @override
  String get retry => 'Réessayer';

  @override
  String get noProfileData => 'Aucune donnée de profil';

  @override
  String get recipesCount => 'Recettes';

  @override
  String get followingCount => 'Abonnements';

  @override
  String get followersCount => 'Abonnés';

  @override
  String get chefsCorner => 'Coin du Chef';

  @override
  String get myRecipes => 'Mes Recettes';

  @override
  String get general => 'Général';

  @override
  String get personalInfo => 'Informations Personnelles';

  @override
  String get security => 'Sécurité';

  @override
  String get preferences => 'Préférences';

  @override
  String get language => 'Langue';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get logOut => 'Se Déconnecter';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'Arabe';

  @override
  String get securityTitle => 'Sécurité';

  @override
  String get accountSecurity => 'Sécurité du compte';

  @override
  String get accountSecuritySubtitle =>
      'Gérez votre connexion et protégez votre compte.';

  @override
  String get changeEmail => 'Changer d\'email';

  @override
  String get changeEmailSubtitle =>
      'Nous enverrons un code à six chiffres à votre nouvelle adresse pour confirmer le changement.';

  @override
  String get newEmailAddress => 'Nouvelle adresse email';

  @override
  String get enterOtp => 'Entrer le code OTP';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get confirmChange => 'Confirmer le changement';

  @override
  String get editEmailInput => 'Modifier l\'email';

  @override
  String get updatePassword => 'Mettre à jour le mot de passe';

  @override
  String get updatePasswordSubtitle =>
      'Votre mot de passe doit contenir au moins huit caractères. Nous confirmerons avec un code envoyé dans votre boîte de réception.';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get passwordHelperText => 'Utilisez au moins 8 caractères';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get editPasswordInputs => 'Modifier le mot de passe';

  @override
  String get noEmailOnFile => 'Aucun email enregistré';

  @override
  String get enterNewEmail => 'Veuillez entrer une nouvelle adresse email.';

  @override
  String get enterValidEmail => 'Entrez une adresse email valide.';

  @override
  String get emailMatchesCurrent =>
      'Le nouvel email correspond à votre email actuel.';

  @override
  String otpSentTo(String email) {
    return 'OTP envoyé à $email. Vérifiez votre boîte de réception pour continuer.';
  }

  @override
  String get enterOtpSent => 'Entrez le code OTP envoyé à votre nouvel email.';

  @override
  String get otpLengthError => 'Les codes OTP sont composés de 6 chiffres.';

  @override
  String get emailUpdatedSuccess => 'Email mis à jour avec succès.';

  @override
  String get completePasswordFields =>
      'Remplissez tous les champs de mot de passe.';

  @override
  String get passwordLengthError =>
      'Utilisez au moins 8 caractères pour votre nouveau mot de passe.';

  @override
  String get passwordsDoNotMatch =>
      'Le nouveau mot de passe et la confirmation ne correspondent pas.';

  @override
  String get passwordMustDiffer =>
      'Le nouveau mot de passe doit être différent du mot de passe actuel.';

  @override
  String get otpSentEmail =>
      'OTP envoyé à votre email. Entrez-le pour confirmer la mise à jour du mot de passe.';

  @override
  String get provideOtpAndPassword =>
      'Fournissez à la fois le code OTP et le nouveau mot de passe.';

  @override
  String get passwordUpdatedSuccess =>
      'Mot de passe mis à jour avec succès. Utilisez votre nouveau mot de passe lors de votre prochaine connexion.';

  @override
  String get somethingWentWrong => 'Une erreur s\'est produite.';

  @override
  String get navDiscovery => 'Découverte';

  @override
  String get navInventory => 'Inventaire';

  @override
  String get navFavorite => 'Favoris';

  @override
  String get navProfile => 'Profil';

  @override
  String get allSaved => 'Tous enregistrés';

  @override
  String get recipeSingular => 'recette';

  @override
  String get recipePlural => 'recettes';

  @override
  String get loadingAnalyzing => 'Analyse de vos ingrédients...';

  @override
  String get loadingSearching => 'Recherche de recettes...';

  @override
  String get loadingMatching => 'Correspondance...';

  @override
  String get loadingFinding => 'Recherche des recettes parfaites...';

  @override
  String get findingRecipes => 'Recherche de recettes';

  @override
  String get recipeResultsTitle => 'Résultats de recettes';

  @override
  String recipesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes trouvées',
      one: '1 recette trouvée',
      zero: 'Aucune recette trouvée',
    );
    return '$_temp0';
  }

  @override
  String get yourIngredients => 'Vos ingrédients :';

  @override
  String get recipesYouCanMake => 'Recettes que vous pouvez faire';

  @override
  String get sortedByMatch => 'Trié par correspondance d\'ingrédients';

  @override
  String get caloriesLabel => 'Calories';

  @override
  String get servingsLabel => 'Portions';

  @override
  String get ingredients => 'Ingrédients';

  @override
  String itemsCount(int count) {
    return '$count articles';
  }

  @override
  String get instructions => 'Instructions';

  @override
  String stepsCount(int count) {
    return '$count étapes';
  }

  @override
  String get personalInfoTitle => 'Informations personnelles';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get bioLabel => 'Bio';

  @override
  String get storyLabel => 'Histoire';

  @override
  String get specialtiesLabel => 'Spécialités';

  @override
  String get addSpecialtyHint => 'Ajouter une spécialité';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get fullNameEmptyError => 'Le nom complet ne peut pas être vide';

  @override
  String profileUpdateError(String error) {
    return 'Échec de la mise à jour du profil : $error';
  }

  @override
  String get profileUpdateSuccess => 'Informations personnelles mises à jour';

  @override
  String get noRecipesFound => 'Aucune recette trouvée';

  @override
  String get connectionIssue => 'Problème de connexion';

  @override
  String get connectionIssueMessage =>
      'Veuillez vérifier votre connexion et réessayer';
}
