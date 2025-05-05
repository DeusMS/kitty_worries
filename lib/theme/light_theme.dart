import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: const Color(0xFFF5F5F7),
  cardColor: Colors.white,
  primaryColor: const Color(0xFF2979FF),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF5F5F7),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black87),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFF5F5F7),
    selectedItemColor: Color(0xFF2979FF),
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF2979FF),
    foregroundColor: Colors.white,
  ),
);
