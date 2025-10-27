import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  brightness: Brightness.light,
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF2A9849))),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2A9849),
    secondary: Color(0xFF1ED7AA),
    surface: Colors.white,
    onSurface: Colors.black87,
    onSurfaceVariant: Color(0xFF9F9F9F),
  ).copyWith(error: const Color(0xFFE84D4F)),
  popupMenuTheme: const PopupMenuThemeData(
      color: Colors.white, surfaceTintColor: Colors.white),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarThemeData(
      color: Colors.white,
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 5)),
  dividerTheme:
      const DividerThemeData(thickness: 0.2, color: Color(0xFFA0A4A8)),
);
