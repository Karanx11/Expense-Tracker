import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF4F7C82);
  static const Color secondary = Color(0xFF93B1B5);
  static const Color background = Color(0xFF0B2E33);
  static const Color card = Color(0xFFB8E3E9);

  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: background,

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4F7C82),
      centerTitle: true,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF4F7C82),
    ),

    cardTheme: CardThemeData(
      color: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
  );
}
