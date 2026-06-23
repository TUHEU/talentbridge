// lib/core/theme/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ThemeController extends ChangeNotifier {
  bool _dark = false;
  bool get isDark => _dark;
  ThemeMode get mode => _dark ? ThemeMode.dark : ThemeMode.light;

  ThemeController() { _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _dark = p.getBool(AppConstants.keyTheme) ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _dark = !_dark;
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConstants.keyTheme, _dark);
    notifyListeners();
  }
}
