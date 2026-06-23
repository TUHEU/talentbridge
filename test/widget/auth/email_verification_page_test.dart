// test/widget/auth/email_verification_page_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talent_bridge/core/theme/app_theme.dart';
import 'package:talent_bridge/core/theme/theme_controller.dart';
import 'package:talent_bridge/features/auth/data/models/user_model.dart';
import 'package:talent_bridge/features/auth/data/repositories/auth_repository.dart';
import 'package:talent_bridge/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talent_bridge/features/auth/presentation/pages/email_verification_page.dart';
import 'package:talent_bridge/core/network/api_client.dart';

// ── Mock repo ─────────────────────────────────────────────────
class _MockRepo implements AuthRepository {
  ApiResult<bool>? verifyResult;
  int resendCallCount = 0;

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
  }) async => const ApiError('n/a');

  @override
  Future<ApiResult<bool>> verifyEmail(String e, String o) async =>
      verifyResult ?? const ApiSuccess(true);

  @override
  Future<ApiResult<bool>> resendOtp(String e) async {
    resendCallCount++;
    return const ApiSuccess(true);
  }

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
Widget _pump({_MockRepo? repo, String email = 'test@example.com'}) {
  final mockRepo = repo ?? _MockRepo();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider(
        // Fixed: 'repo' not 'repository'
        create: (_) => AuthController(repo: mockRepo),
      ),
    ],
    child: MaterialApp(
      // Fixed: AppTheme.light not AppTheme.lightTheme
      theme: AppTheme.light,
      home: EmailVerificationPage(email: email),
    ),
  );
}

void main() {
  // ═══════════════════════════════════════════════════════
  // Structure
  // ═══════════════════════════════════════════════════════
  group('EmailVerificationPage — Structure', () {
    testWidgets('renders the heading "Check your email"', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Check your email'), findsOneWidget);
    });

    testWidgets('shows the email address passed in', (t) async {
      await t.pumpWidget(_pump(email: 'fahdil@example.com'));
      await t.pumpAndSettle();
      expect(find.textContaining('fahdil@example.com'), findsOneWidget);
    });

    testWidgets('renders 6 OTP input cells', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.byType(TextFormField), findsNWidgets(6));
    });

    testWidgets('renders Verify Email button', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Verify Email'), findsOneWidget);
    });

    testWidgets('shows countdown timer initially', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.textContaining('Resend in'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════
  // OTP Input
  // ═══════════════════════════════════════════════════════
  group('EmailVerificationPage — OTP Input', () {
    testWidgets('Verify button is disabled with incomplete OTP', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      // Only enter 3 digits — button should stay disabled
      final cells = find.byType(TextFormField);
      await t.enterText(cells.at(0), '1');
      await t.enterText(cells.at(1), '2');
      await t.enterText(cells.at(2), '3');
      await t.pump();
      // Button present but no error SnackBar (form not submitted)
      expect(find.text('Verify Email'), findsOneWidget);
    });

    testWidgets('shows error SnackBar when OTP is invalid', (t) async {
      final repo = _MockRepo();
      repo.verifyResult = const ApiError('Invalid or expired code');
      await t.pumpWidget(_pump(repo: repo));
      await t.pumpAndSettle();

      // Enter all 6 digits
      final cells = find.byType(TextFormField);
      for (int i = 0; i < 6; i++) {
        await t.enterText(cells.at(i), '0');
        await t.pump();
      }

      await t.tap(find.text('Verify Email'));
      await t.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════
  // Resend
  // ═══════════════════════════════════════════════════════
  group('EmailVerificationPage — Resend', () {
    testWidgets('Resend button appears after countdown expires', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();

      // Initially shows countdown
      expect(find.textContaining('Resend in'), findsOneWidget);

      // Fast-forward 61 seconds
      await t.pump(const Duration(seconds: 61));
      await t.pumpAndSettle();

      expect(find.text('Resend code'), findsOneWidget);
    });
  });
}
