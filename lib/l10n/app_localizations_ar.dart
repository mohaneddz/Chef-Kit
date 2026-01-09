// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'شيف كيت';

  @override
  String get discoverRecipes => 'اكتشف الوصفات';

  @override
  String get findYourNextFavoriteMeal => 'اعثر على وجبتك المفضلة التالية';

  @override
  String get searchRecipesOrChefs => 'ابحث عن وصفات أو طهاة';

  @override
  String get chefs => 'الطهاة';

  @override
  String get hotRecipes => 'وصفات ساخنة';

  @override
  String get seasonalDelights => 'المسرات الموسمية';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String servings(String count) {
    return '$count حصص';
  }

  @override
  String calories(String count) {
    return '$count سعرة حرارية';
  }

  @override
  String recipeDetailsFor(String name) {
    return 'تفاصيل الوصفة لـ $name';
  }

  @override
  String minutes(String count) {
    return '$count دقيقة';
  }

  @override
  String error(String message) {
    return 'خطأ: $message';
  }

  @override
  String get allChefs => 'كل الطهاة';

  @override
  String get superHot => 'رائج جداً';

  @override
  String get total => 'المجموع';

  @override
  String get superHotChefs => 'طهاة رائجون جداً';

  @override
  String get trendingChefsSubtitle => 'أكثر الطهاة رواجاً الآن';

  @override
  String paginationInfo(int currentPage, int totalPages, int chefCount) {
    return 'صفحة $currentPage من $totalPages • $chefCount طهاة';
  }

  @override
  String get recipesStat => 'وصفات';

  @override
  String get trendingStat => 'رائج';

  @override
  String get favoritesStat => 'المفضلة';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterTrending => 'رائج';

  @override
  String get filterTraditional => 'تقليدي';

  @override
  String get filterSoup => 'حساء';

  @override
  String get filterQuick => 'سريع';

  @override
  String get hotBadge => 'ساخن';

  @override
  String get seasonalDelightsTitle => 'المسرات الموسمية';

  @override
  String get freshThisSeason => 'طازج هذا الموسم';

  @override
  String get seasonalDescription => 'اكتشف وصفات مثالية للموسم الحالي';

  @override
  String get seasonSpring => 'الربيع';

  @override
  String get seasonSummer => 'الصيف';

  @override
  String get seasonAutumn => 'الخريف';

  @override
  String get seasonWinter => 'الشتاء';

  @override
  String seasonalRecipesCount(int count, String season) {
    return '$count وصفات $season';
  }

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات بعد';

  @override
  String get notificationNewRecipeTitle => 'تم نشر وصفة جديدة!';

  @override
  String get notificationNewRecipeMessage =>
      'نشر الشيف جوردون وصفة بيف ويلينغتون جديدة';

  @override
  String get notificationRecipeLikedTitle => 'تم الإعجاب بالوصفة';

  @override
  String get notificationRecipeLikedMessage =>
      'أعجبت سارة بوصفة المحجوبة الخاصة بك';

  @override
  String get notificationNewFollowerTitle => 'متابع جديد';

  @override
  String get notificationNewFollowerMessage => 'بدأ الشيف جيمي بمتابعتك';

  @override
  String get notificationCommentTitle => 'تعليق على الوصفة';

  @override
  String get notificationCommentMessage =>
      'علق مايك على وصفة الكسكس الخاصة بك: \"تبدو لذيذة!\"';

  @override
  String get notificationChallengeTitle => 'التحدي الأسبوعي';

  @override
  String get notificationChallengeMessage =>
      'تحدي الطهي الأسبوعي الجديد متاح الآن!';

  @override
  String get notificationSavedTitle => 'تم حفظ الوصفة';

  @override
  String get notificationSavedMessage =>
      'تم حفظ وصفة الطاجين الخاصة بك من قبل 15 شخصًا هذا الأسبوع';

  @override
  String get notificationTrendingTitle => 'وصفة رائجة';

  @override
  String get notificationTrendingMessage => 'وصفة الشوربة الخاصة بك رائجة! 🔥';

  @override
  String get notificationAchievementTitle => 'إنجاز جديد';

  @override
  String get notificationAchievementMessage =>
      'مبروك! لقد فتحت شارة \"ماستر شيف\"';

  @override
  String get notificationRecipeDayTitle => 'وصفة اليوم';

  @override
  String get notificationRecipeDayMessage =>
      'تم عرض البركوكس الخاص بك كوصفة اليوم!';

  @override
  String get notificationIngredientTitle => 'تنبيه المكونات';

  @override
  String get notificationIngredientMessage => 'البابريكا تنفد من مخزونك';

  @override
  String timeMinAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String timeHourAgo(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String timeHoursAgo(int count) {
    return 'منذ $count ساعات';
  }

  @override
  String timeDayAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String timeDaysAgo(int count) {
    return 'منذ $count أيام';
  }

  @override
  String get inventoryTitle => 'مخزون مطبخي';

  @override
  String get inventorySubtitle => 'إدارة المكونات الخاصة بك';

  @override
  String get availableIngredientsTitle => 'المكونات المتاحة';

  @override
  String get availableIngredientsSubtitle => 'عناصر المؤن الحالية الخاصة بك';

  @override
  String availableCount(int count) {
    return '$count متاح';
  }

  @override
  String totalItemsCount(int count) {
    return '$count إجمالي العناصر';
  }

  @override
  String get showLess => 'عرض أقل';

  @override
  String get showMore => 'عرض المزيد';

  @override
  String get browseIngredientsTitle => 'تصفح جميع المكونات';

  @override
  String get browseIngredientsSubtitle => 'هل تجد ما تحتاجه؟';

  @override
  String get ingredientTypeAll => 'الكل';

  @override
  String get ingredientTypeProtein => 'بروتين';

  @override
  String get ingredientTypeVegetables => 'خضروات';

  @override
  String get ingredientTypeSpices => 'توابل';

  @override
  String get ingredientTypeFruits => 'فواكه';

  @override
  String get favouritesTitle => 'المفضلة';

  @override
  String get favouritesSubtitle => 'اعثر على وصفاتك المحفوظة';

  @override
  String get noFavouritesYet => 'لا توجد مفضلات بعد';

  @override
  String get noFavouritesMessage => 'استكشف التطبيق واحفظ وصفاتك المفضلة!';

  @override
  String get searchYourRecipes => 'ابحث في وصفاتك...';

  @override
  String get categoriesTitle => 'الفئات';

  @override
  String get searchIngredient => 'ابحث عن مكون...';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get notLoggedIn => 'غير مسجل الدخول';

  @override
  String get goToLogin => 'الذهاب لتسجيل الدخول';

  @override
  String get errorLoadingProfile => 'خطأ في تحميل الملف الشخصي';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noProfileData => 'لا توجد بيانات للملف الشخصي';

  @override
  String get recipesCount => 'الوصفات';

  @override
  String get followingCount => 'أتابع';

  @override
  String get followersCount => 'المتابعون';

  @override
  String get chefsCorner => 'ركن الشيف';

  @override
  String get myRecipes => 'وصفاتي';

  @override
  String get general => 'عام';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get security => 'الأمان';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get language => 'اللغة';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get english => 'الإنجليزية';

  @override
  String get french => 'الفرنسية';

  @override
  String get arabic => 'العربية';

  @override
  String get securityTitle => 'الأمان';

  @override
  String get accountSecurity => 'أمان الحساب';

  @override
  String get accountSecuritySubtitle =>
      'إدارة كيفية تسجيل الدخول والحفاظ على حماية حسابك.';

  @override
  String get changeEmail => 'تغيير البريد الإلكتروني';

  @override
  String get changeEmailSubtitle =>
      'سنرسل رمزًا مكونًا من ستة أرقام إلى عنوانك الجديد لتأكيد التغيير.';

  @override
  String get newEmailAddress => 'عنوان البريد الإلكتروني الجديد';

  @override
  String get enterOtp => 'أدخل رمز التحقق';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get confirmChange => 'تأكيد التغيير';

  @override
  String get editEmailInput => 'تعديل البريد الإلكتروني';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get updatePasswordSubtitle =>
      'يجب أن تتضمن كلمة المرور الخاصة بك ثمانية أحرف على الأقل. سنؤكد ذلك برمز يتم إرساله إلى صندوق الوارد الخاص بك.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get passwordHelperText => 'استخدم 8 أحرف على الأقل';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get editPasswordInputs => 'تعديل كلمة المرور';

  @override
  String get noEmailOnFile => 'لا يوجد بريد إلكتروني مسجل';

  @override
  String get enterNewEmail => 'الرجاء إدخال عنوان بريد إلكتروني جديد.';

  @override
  String get enterValidEmail => 'أدخل عنوان بريد إلكتروني صالح.';

  @override
  String get emailMatchesCurrent =>
      'البريد الإلكتروني الجديد يطابق بريدك الإلكتروني الحالي.';

  @override
  String otpSentTo(String email) {
    return 'تم إرسال رمز التحقق إلى $email. تحقق من صندوق الوارد للمتابعة.';
  }

  @override
  String get enterOtpSent =>
      'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني الجديد.';

  @override
  String get otpLengthError => 'رموز التحقق تتكون من 6 أرقام.';

  @override
  String get emailUpdatedSuccess => 'تم تحديث البريد الإلكتروني بنجاح.';

  @override
  String get completePasswordFields => 'أكمل جميع حقول كلمة المرور.';

  @override
  String get passwordLengthError =>
      'استخدم 8 أحرف على الأقل لكلمة المرور الجديدة.';

  @override
  String get passwordsDoNotMatch =>
      'كلمة المرور الجديدة والتأكيد غير متطابقين.';

  @override
  String get passwordMustDiffer =>
      'يجب أن تختلف كلمة المرور الجديدة عن كلمة المرور الحالية.';

  @override
  String get otpSentEmail =>
      'تم إرسال رمز التحقق إلى بريدك الإلكتروني. أدخله لتأكيد تحديث كلمة المرور.';

  @override
  String get provideOtpAndPassword =>
      'قدم كلاً من رمز التحقق وكلمة المرور الجديدة.';

  @override
  String get passwordUpdatedSuccess =>
      'تم تحديث كلمة المرور بنجاح. استخدم كلمة المرور الجديدة في المرة القادمة التي تقوم فيها بتسجيل الدخول.';

  @override
  String get somethingWentWrong => 'حدث خطأ ما.';

  @override
  String get navDiscovery => 'اكتشاف';

  @override
  String get navInventory => 'المخزون';

  @override
  String get navFavorite => 'المفضلة';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get allSaved => 'كل المحفوظات';

  @override
  String get recipeSingular => 'وصفة';

  @override
  String get recipePlural => 'وصفات';

  @override
  String get loadingAnalyzing => 'تحليل مكوناتك...';

  @override
  String get loadingSearching => 'البحث عن وصفات...';

  @override
  String get loadingMatching => 'مطابقة...';

  @override
  String get loadingFinding => 'إيجاد الوصفات المثالية...';

  @override
  String get findingRecipes => 'البحث عن وصفات';

  @override
  String get recipeResultsTitle => 'نتائج الوصفات';

  @override
  String recipesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم العثور على $count وصفات',
      two: 'تم العثور على وصفتين',
      one: 'تم العثور على وصفة واحدة',
      zero: 'لم يتم العثور على وصفات',
    );
    return '$_temp0';
  }

  @override
  String get yourIngredients => 'مكوناتك:';

  @override
  String get recipesYouCanMake => 'وصفات يمكنك صنعها';

  @override
  String get sortedByMatch => 'مرتبة حسب تطابق المكونات';

  @override
  String get caloriesLabel => 'سعرات';

  @override
  String get servingsLabel => 'حصص';

  @override
  String get ingredients => 'المكونات';

  @override
  String itemsCount(int count) {
    return '$count عناصر';
  }

  @override
  String get instructions => 'التعليمات';

  @override
  String stepsCount(int count) {
    return '$count خطوات';
  }

  @override
  String get personalInfoTitle => 'المعلومات الشخصية';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get bioLabel => 'نبذة';

  @override
  String get storyLabel => 'قصتي';

  @override
  String get specialtiesLabel => 'التخصصات';

  @override
  String get addSpecialtyHint => 'أضف تخصص';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get fullNameEmptyError => 'الاسم الكامل لا يمكن أن يكون فارغاً';

  @override
  String profileUpdateError(String error) {
    return 'فشل تحديث الملف الشخصي: $error';
  }

  @override
  String get profileUpdateSuccess => 'تم تحديث المعلومات الشخصية';

  @override
  String get noRecipesFound => 'لم يتم العثور على وصفات';

  @override
  String get connectionIssue => 'مشكلة في الاتصال';

  @override
  String get connectionIssueMessage =>
      'يرجى التحقق من اتصالك والمحاولة مرة أخرى';

  @override
  String get generateRecipe => 'إنشاء وصفة';

  @override
  String get cookingDuration => 'مدة الطهي';

  @override
  String get availableIngredients => 'المكونات المتاحة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get proceed => 'متابعة';

  @override
  String get loginRequiredTitle => 'تسجيل الدخول مطلوب';

  @override
  String get loginRequiredMessage => 'سجّل أو ادخل لاستخدام هذه الميزة';

  @override
  String get signUp => 'التسجيل';

  @override
  String get loginRequiredFavorites => 'سجّل لحفظ وصفاتك المفضلة';

  @override
  String get loginRequiredFollow => 'سجّل لمتابعة الطهاة';

  @override
  String get guestProfileMessage => 'سجّل لفتح جميع الميزات';

  @override
  String get continueAsGuest => 'تواصل كضيف';

  @override
  String get loginRequiredNotifications => 'سجّل لرؤية إشعاراتك';
}
