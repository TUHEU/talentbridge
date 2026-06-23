// test/test_helper.dart
//
// Shared fixtures, mock repository, and widget pump helper
// used across all test files.
//
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';           // ← fixes WidgetTester
import 'package:provider/provider.dart';
import 'package:talent_bridge/core/theme/app_theme.dart';
import 'package:talent_bridge/core/theme/theme_controller.dart';
import 'package:talent_bridge/features/auth/data/models/user_model.dart';
import 'package:talent_bridge/features/auth/data/repositories/auth_repository.dart';
import 'package:talent_bridge/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talent_bridge/core/network/api_client.dart';

// ─────────────────────────────────────────────────────────────
// Standard test user fixtures
// ─────────────────────────────────────────────────────────────
final testUser = UserModel(
  id: 1,
  fullName: 'Fahdil Mochtar',
  email: 'fahdil@example.com',
  phone: '+237698765432',
  isEmailVerified: true,
  jobTitle: 'Flutter Developer',
  company: 'TechCorp Africa',
  xpPoints: 350,
);

final unverifiedUser = UserModel(
  id: 2,
  fullName: 'Unverified User',
  email: 'unverified@example.com',
  isEmailVerified: false,
);

// ─────────────────────────────────────────────────────────────
// Base mock repository — safe defaults, no real network calls
// ─────────────────────────────────────────────────────────────
class BaseMockRepo implements AuthRepository {
  @override
  Future<ApiResult<UserModel>> login(String e, String p) async =>
      const ApiError('BaseMockRepo: login not configured');

  @override
  Future<ApiResult<UserModel>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? dateOfBirth,
    String? gender,          // ← must match AuthRepository exactly
    File?   profileImage,
  }) async =>
      const ApiError('BaseMockRepo: register not configured');

  @override
  Future<ApiResult<bool>> verifyEmail(String e, String o) async =>
      const ApiSuccess(true);

  @override
  Future<ApiResult<bool>> resendOtp(String e) async => const ApiSuccess(true);

  @override
  Future<ApiResult<bool>> forgotPassword(String e) async =>
      const ApiSuccess(true);

  @override
  Future<ApiResult<bool>> resetPassword(String e, String o, String p) async =>
      const ApiSuccess(true);

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel?> getCachedUser() async => null;
}

// ─────────────────────────────────────────────────────────────
// Widget pump helper
// Wraps any widget with required providers + MaterialApp.
// ─────────────────────────────────────────────────────────────
Widget wrapWithProviders(
  Widget child, {
  AuthRepository? repo,
  bool darkMode = false,
}) {
  final authRepo = repo ?? BaseMockRepo();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider(
        // Fixed: named param is 'repo', NOT 'repository'
        create: (_) => AuthController(repo: authRepo),
      ),
    ],
    child: MaterialApp(
      // Fixed: AppTheme.dark / AppTheme.light (not darkTheme / lightTheme)
      theme: darkMode ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: child),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// Convenience settle helper
// ─────────────────────────────────────────────────────────────
Future<void> tbSettle(WidgetTester tester) =>
    tester.pumpAndSettle(const Duration(milliseconds: 100));
