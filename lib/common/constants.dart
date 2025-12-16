import 'package:flutter/material.dart';

class AppColors {
  // Primary brand color
  static const red600 = Color(0xFFFF4C5A);
  static const orange = Color(0xFFFF914D);
  static const white = Color(0xFFFFFDF9);
  static const success1 = Color(0xFF00C950);
  static const success2 = Color(0xFF00BC7D);
  static const green = Color(0xFF008236);
  static const browmpod = Color(0xFF32201C);
  static const black = Color(0xFF1C0F0D);
  static const navcolor = Color(0xFF9DB2CE);

  // Additional colors for recipe details
  static const primary = Color(0xFFFF6B6B);
  static const lightGray = Color(0xFFF7F8F8);
  static const textDark = Color(0xFF1D1617);
  static const textGray = Color(0xFF7B6F72);

  // ============================================
  // DARK THEME COLORS
  // ============================================

  // Dark backgrounds
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkCard = Color(0xFF252525);
  static const darkCardElevated = Color(0xFF2C2C2C);

  // Dark text colors
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFB3B3B3);
  static const darkTextHint = Color(0xFF757575);

  // Dark dividers and borders
  static const darkDivider = Color(0xFF2C2C2C);
  static const darkBorder = Color(0xFF3D3D3D);

  // Dark input fields
  static const darkInputFill = Color(0xFF2A2A2A);
  static const darkInputBorder = Color(0xFF3D3D3D);
}

/// Light Theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Poppins',
  primaryColor: AppColors.red600,
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.white,
  dividerColor: Colors.grey[200],

  colorScheme: ColorScheme.light(
    primary: AppColors.red600,
    secondary: AppColors.red600,
    surface: Colors.white,
    background: Colors.white,
    error: Colors.red[700]!,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black87,
    onBackground: Colors.black87,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
    ),
  ),

  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
    headlineMedium: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
    headlineSmall: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
    titleLarge: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
    titleMedium: TextStyle(color: Colors.black87, fontFamily: 'Poppins'),
    titleSmall: TextStyle(color: Colors.black87, fontFamily: 'Poppins'),
    bodyLarge: TextStyle(color: Colors.black87, fontFamily: 'Poppins'),
    bodyMedium: TextStyle(color: Colors.black87, fontFamily: 'Poppins'),
    bodySmall: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
    labelLarge: TextStyle(color: Colors.black87, fontFamily: 'Poppins'),
  ),

  iconTheme: const IconThemeData(color: Colors.black87),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.grey[100],
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: Colors.grey[500]),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.red600,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.red600,
    unselectedItemColor: Colors.grey,
  ),
);

/// Dark Theme
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Poppins',
  primaryColor: AppColors.red600,
  scaffoldBackgroundColor: AppColors.darkBackground,
  cardColor: AppColors.darkCard,
  dividerColor: AppColors.darkDivider,

  colorScheme: ColorScheme.dark(
    primary: AppColors.red600,
    secondary: AppColors.red600,
    surface: AppColors.darkSurface,
    background: AppColors.darkBackground,
    error: Colors.red[400]!,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.darkTextPrimary,
    onBackground: AppColors.darkTextPrimary,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    foregroundColor: AppColors.darkTextPrimary,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
    titleTextStyle: TextStyle(
      color: AppColors.darkTextPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
    ),
  ),

  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      color: AppColors.darkTextPrimary,
      fontFamily: 'Poppins',
    ),
    headlineMedium: TextStyle(
      color: AppColors.darkTextPrimary,
      fontFamily: 'Poppins',
    ),
    headlineSmall: TextStyle(
      color: AppColors.darkTextPrimary,
      fontFamily: 'Poppins',
    ),
    titleLarge: TextStyle(
      color: AppColors.darkTextPrimary,
      fontFamily: 'Poppins',
    ),
    titleMedium: TextStyle(
      color: AppColors.darkTextSecondary,
      fontFamily: 'Poppins',
    ),
    titleSmall: TextStyle(
      color: AppColors.darkTextSecondary,
      fontFamily: 'Poppins',
    ),
    bodyLarge: TextStyle(
      color: AppColors.darkTextPrimary,
      fontFamily: 'Poppins',
    ),
    bodyMedium: TextStyle(
      color: AppColors.darkTextSecondary,
      fontFamily: 'Poppins',
    ),
    bodySmall: TextStyle(color: AppColors.darkTextHint, fontFamily: 'Poppins'),
    labelLarge: TextStyle(
      color: AppColors.darkTextPrimary,
      fontFamily: 'Poppins',
    ),
  ),

  iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),

  cardTheme: CardThemeData(
    color: AppColors.darkCard,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    fillColor: AppColors.darkInputFill,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: AppColors.darkTextHint),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.red600,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkSurface,
    selectedItemColor: AppColors.red600,
    unselectedItemColor: AppColors.darkTextHint,
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.darkCard,
    titleTextStyle: TextStyle(
      color: AppColors.darkTextPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
    ),
    contentTextStyle: TextStyle(
      color: AppColors.darkTextSecondary,
      fontSize: 14,
      fontFamily: 'Poppins',
    ),
  ),

  snackBarTheme: const SnackBarThemeData(
    backgroundColor: AppColors.darkCardElevated,
    contentTextStyle: TextStyle(color: AppColors.darkTextPrimary),
  ),

  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.red600;
      }
      return Colors.grey;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.red600.withOpacity(0.5);
      }
      return Colors.grey.withOpacity(0.3);
    }),
  ),
);
