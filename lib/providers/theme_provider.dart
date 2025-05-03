import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDark = false;

  ThemeMode get themeMode => isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool enabled) {
    isDark = enabled;
    notifyListeners();
  }
}