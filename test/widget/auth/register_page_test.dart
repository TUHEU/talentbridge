// test/widget/auth/register_page_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talent_bridge/core/theme/app_theme.dart';
import 'package:talent_bridge/core/theme/theme_controller.dart';
import 'package:talent_bridge/features/auth/data/models/user_model.dart';
import 'package:talent_bridge/features/auth/data/repositories/auth_repository.dart';
import 'package:talent_bridge/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talent_bridge/features/auth/presentation/pages/register_page.dart';
import 'package:talent_bridge/core/network/api_client.dart';

// ── Mock repo ─────────────────────────────────────────────────
class _MockRepo implements AuthRepository {
  ApiResult<UserModel>? registerResult;

  @override
  Future<ApiResult<UserModel>> login(String e, String p) async =>
      const ApiError('n/a');

  @override
  Future<ApiResult<UserModel>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? dateOfBirth,
    String? gender,         // ← required by AuthRepository
    File?   profileImage,
  }) async =>
      registerResult ?? const ApiError('n/a');

  @override
  Future<ApiResult<bool>> verifyEmail(String e, String o) async =>
      const ApiSuccess(true);

  @override
  Future<ApiResult<bool>> resendOtp(String e) async => const ApiSuccess(true);

  @override
  Future<ApiResult<bool>> forgotPassword(String e) async => const ApiSuccess(true);

  @override
  Future<ApiResult<bool>> resetPassword(String e, String o, String p) async =>
      const ApiSuccess(true);

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel?> getCachedUser() async => null;
}

// ── Widget pump helper ────────────────────────────────────────
Widget _pump({_MockRepo? repo}) {
  final r = repo ?? _MockRepo();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider(
        // Fixed: 'repo' not 'repository'
        create: (_) => AuthController(repo: r),
      ),
    ],
    child: MaterialApp(
      // Fixed: AppTheme.light not AppTheme.lightTheme
      theme: AppTheme.light,
      home: const RegisterPage(),
    ),
  );
}

void main() {
  // ═══════════════════════════════════════════════════════
  // Structure
  // ═══════════════════════════════════════════════════════
  group('RegisterPage — Structure', () {
    testWidgets('shows Create Account title in app bar', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('renders full name field', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.textContaining('Full name'), findsOneWidget);
    });

    testWidgets('renders email field', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.textContaining('Email'), findsOneWidget);
    });

    testWidgets('renders phone field', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.textContaining('Phone'), findsOneWidget);
    });

    testWidgets('renders password field', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.textContaining('Password'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders confirm password field', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.textContaining('Confirm'), findsOneWidget);
    });

    testWidgets('renders Create Account button', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Create Account'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders sign in link', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('renders add photo section', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Add Profile Photo'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════
  // Validation
  // ═══════════════════════════════════════════════════════
  group('RegisterPage — Validation', () {
    testWidgets('shows validation errors when submitting empty form', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();

      // Scroll to and tap Create Account button
      await t.ensureVisible(find.text('Create Account').last);
      await t.tap(find.text('Create Account').last);
      await t.pumpAndSettle();

      // At least one validation error should show
      expect(find.textContaining('required'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows error for invalid email format', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'Fahdil Mochtar');
      await t.enterText(fields.at(1), 'notanemail');

      await t.ensureVisible(find.text('Create Account').last);
      await t.tap(find.text('Create Account').last);
      await t.pumpAndSettle();

      expect(find.textContaining('valid email'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'Fahdil Mochtar');
      await t.enterText(fields.at(1), 'fahdil@example.com');
      await t.enterText(fields.at(2), '+237698765432');
      // Password and confirm don't match
      await t.enterText(fields.at(3), 'Password1');
      await t.enterText(fields.at(4), 'Different1');

      await t.ensureVisible(find.text('Create Account').last);
      await t.tap(find.text('Create Account').last);
      await t.pumpAndSettle();

      expect(find.textContaining('match'), findsOneWidget);
    });

    testWidgets('shows error for weak password', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'Fahdil Mochtar');
      await t.enterText(fields.at(1), 'fahdil@example.com');
      await t.enterText(fields.at(2), '+237698765432');
      await t.enterText(fields.at(3), 'weak');

      await t.ensureVisible(find.text('Create Account').last);
      await t.tap(find.text('Create Account').last);
      await t.pumpAndSettle();

      expect(find.textContaining('8'), findsAtLeastNWidgets(1));
    });
  });

  // ═══════════════════════════════════════════════════════
  // Server error
  // ═══════════════════════════════════════════════════════
  group('RegisterPage — Server Error', () {
    testWidgets('shows SnackBar with server error message', (t) async {
      final repo = _MockRepo();
      repo.registerResult =
          const ApiError('An account with this email already exists');
      await t.pumpWidget(_pump(repo: repo));
      await t.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'Fahdil Mochtar');
      await t.enterText(fields.at(1), 'fahdil@example.com');
      await t.enterText(fields.at(2), '+237698765432');
      await t.enterText(fields.at(3), 'Password1');
      await t.enterText(fields.at(4), 'Password1');

      await t.ensureVisible(find.text('Create Account').last);
      await t.tap(find.text('Create Account').last);
      await t.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('already exists'), findsOneWidget);
    });
  });
}
