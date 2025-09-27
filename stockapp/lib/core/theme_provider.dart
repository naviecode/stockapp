import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = AppTheme.darkTheme;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData.brightness == Brightness.dark;

  void toggleTheme() {
    _themeData = isDarkMode ? AppTheme.lightTheme : AppTheme.darkTheme;
    notifyListeners();
  }

  void setTheme(bool darkMode) {
    _themeData = darkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
    notifyListeners();
  }
}
