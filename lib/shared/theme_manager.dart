import 'package:ymapper/main.dart';
import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;

  ThemeManager() {
    _isDark = prefs.getBool('isDark') ?? true;
  }

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
    prefs.setBool('isDark', _isDark);
  }

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;
}
