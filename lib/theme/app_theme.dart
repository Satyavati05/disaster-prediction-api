import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFE85C1C);
  static const Color backgroundLight = Color(0xFFDDECE8);
  static const Color darkText = Color(0xFF162339);
  static const Color darkBlueBg = Color(0xFF161F2E);
  static const Color surfaceWhite = Colors.white;
  static const Color grayText = Color(0xFF757A8B);
  static const Color lightGrayBg = Color(0xFFF4F6F5);
  static const Color inputBg = Color(0xFFEBF2F0);
  
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: 'Roboto', // Using standard Roboto, recommend integrating google_fonts if needed
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryOrange,
        unselectedItemColor: grayText,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceWhite,
        elevation: 10,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
