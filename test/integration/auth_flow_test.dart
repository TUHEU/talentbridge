// test/integration/auth_flow_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talent_bridge/core/theme/app_theme.dart';
import 'package:talent_bridge/core/theme/theme_controller.dart';
import 'package:talent_bridge/features/auth/data/models/user_model.dart';
import 'package:talent_bridge/features/auth/data/repositories/auth_repository.dart';
import 'package:talent_bridge/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talent_bridge/features/auth/presentation/pages/login_page.dart';
import 'package:talent_bridge/core/network/api_client.dart';

// ─── Configurable scenario repository ─────────────────────────
class _Repo implements AuthRepository {
  final UserModel? onLogin;
  final String?    loginErr;
  final int?       loginErrCode;
  final bool verifyOk;
  final bool forgotOk;
  final bool resetOk;

  const _Repo({
    this.onLogin,
    this.loginErr,
    this.loginErrCode,
    this.verifyOk = true,
    this.forgotOk = true,
    this.resetOk  = true,
  });

  @override
  Future<ApiResult<UserModel>> login(String e, String p) async {
    if (loginErr != null) return ApiError(loginErr!, code: loginErrCode);
    if (onLogin  != null) return ApiSuccess(onLogin!);
    return const ApiError('Not configured');
  }

  @override
  Future<ApiResult<UserModel>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? dateOfBirth,
    String? gender,
    File?   profileImage,
  }) async =>
      ApiSuccess(UserModel(
          id: 99, fullName: fullName, email: email, isEmailVerified: false));

  @override
  Future<ApiResult<bool>> verifyEmail(String e, String o) async =>
      verifyOk ? const ApiSuccess(true) : const ApiError('Wrong code');

  @override
  Future<ApiResult<bool>> resendOtp(String e) async => const ApiSuccess(true);

  @override
  Future<ApiResult<bool>> forgotPassword(String e) async =>
      forgotOk ? const ApiSuccess(true) : const ApiError('Not found');

  @override
  Future<ApiResult<bool>> resetPassword(String e, String o, String p) async =>
      resetOk ? const ApiSuccess(true) : const ApiError('Wrong code');

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel?> getCachedUser() async => null;
}

// ─── App builder ───────────────────────────────────────────────
Widget _app(_Repo repo) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        // Fixed: named param is 'repo'
        ChangeNotifierProvider(create: (_) => AuthController(repo: repo)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const LoginPage(),
      ),
    );

// ─── Helper user ──────────────────────────────────────────────
UserModel _verifiedUser() => UserModel(
    id: 1,
    fullName: 'Fahdil Mochtar',
    email: 'fahdil@example.com',
    isEmailVerified: true);

void main() {
  // ═══════════════════════════════════════════════════════
  // SCENARIO 1 — Successful login
  // ═══════════════════════════════════════════════════════
  group('Scenario: Successful Login', () {
    testWidgets('fills valid credentials — no error SnackBar appears', (t) async {
      await t.pumpWidget(_app(_Repo(onLogin: _verifiedUser())));
      await t.pumpAndSettle();

      await t.enterText(find.byType(TextFormField).first, 'fahdil@example.com');
      await t.enterText(find.byType(TextFormField).last,  'Password1');
      await t.tap(find.text('Sign In'));
      await t.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('controller is authenticated after success', (t) async {
      await t.pumpWidget(_app(_Repo(onLogin: _verifiedUser())));
      await t.pumpAndSettle();

      final ctrl = t.element(find.byType(LoginPage))
          .read<AuthController>();

      await t.enterText(find.byType(TextFormField).first, 'fahdil@example.com');
      await t.enterText(find.byType(TextFormField).last,  'Password1');
      await t.tap(find.text('Sign In'));
      await t.pumpAndSettle();

      expect(ctrl.status,      AuthStatus.authenticated);
      expect(ctrl.user?.email, 'fahdil@example.com');
    });
  });

  // ═══════════════════════════════════════════════════════
  // SCENARIO 2 — Failed login
  // ═══════════════════════════════════════════════════════
  group('Scenario: Failed Login', () {
    testWidgets('shows error SnackBar with server message', (t) async {
      await t.pumpWidget(
          _app(const _Repo(loginErr: 'Invalid email or password')));
      await t.pumpAndSettle();

      await t.enterText(find.byType(TextFormField).first, 'bad@example.com');
      await t.enterText(find.byType(TextFormField).last,  'WrongPass1');
      await t.tap(find.text('Sign In'));
      await t.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Invalid email or password'), findsOneWidget);
    });

    testWidgets('controller stays unauthenticated after failure', (t) async {
      await t.pumpWidget(
          _app(const _Repo(loginErr: 'Invalid email or password')));
      await t.pumpAndSettle();

      final ctrl = t.element(find.byType(LoginPage))
          .read<AuthController>();

      await t.enterText(find.byType(TextFormField).first, 'bad@example.com');
      await t.enterText(find.byType(TextFormField).last,  'WrongPass1');
      await t.tap(find.text('Sign In'));
      await t.pumpAndSettle();

      expect(ctrl.status, AuthStatus.unauthenticated);
      expect(ctrl.user,   isNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  // SCENARIO 3 — Form validation blocks submission
  // ═══════════════════════════════════════════════════════
  group('Scenario: Form Validation Gate', () {
    testWidgets('empty form does not reach the repository', (t) async {
      await t.pumpWidget(_app(const _Repo()));
      await t.pumpAndSettle();

      await t.tap(find.text('Sign In'));
      await t.pumpAndSettle();

      final ctrl = t.element(find.byType(LoginPage))
          .read<AuthController>();
      expect(ctrl.status,       AuthStatus.unauthenticated);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('invalid email shows inline error, no SnackBar', (t) async {
      await t.pumpWidget(_app(const _Repo()));
      await t.pumpAndSettle();

      await t.enterText(find.byType(TextFormField).first, 'notanemail');
      await t.enterText(find.byType(TextFormField).last,  'Password1');
      await t.tap(find.text('Sign In'));
      await t.pumpAndSettle();

      expect(find.textContaining('valid email'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  // ═══════════════════════════════════════════════════════
  // SCENARIO 4 — Navigation from login
  // ═══════════════════════════════════════════════════════
  group('Scenario: Navigation', () {
    testWidgets('tapping Create account opens register page', (t) async {
      await t.pumpWidget(_app(const _Repo()));
      await t.pumpAndSettle();

      await t.tap(find.text('Create account'));
      await t.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('tapping Forgot password opens forgot page', (t) async {
      await t.pumpWidget(_app(const _Repo()));
      await t.pumpAndSettle();

      await t.tap(find.text('Forgot password?'));
      await t.pumpAndSettle();

      expect(find.textContaining('Forgot Password'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════
  // SCENARIO 5 — Unverified email redirect
  // ═══════════════════════════════════════════════════════
  group('Scenario: Unverified Email', () {
    testWidgets('controller status is emailUnverified on 403', (t) async {
      await t.pumpWidget(_app(
          const _Repo(loginErr: 'Email not verified', loginErrCode: 403)));
      await t.pumpAndSettle();

      final ctrl = t.element(find.byType(LoginPage))
          .read<AuthController>();

      await t.enterText(
          find.byType(TextFormField).first, 'unverified@example.com');
      await t.enterText(find.byType(TextFormField).last, 'Password1');
      await t.tap(find.text('Sign In'));
      await t.pumpAndSettle();

      expect(ctrl.status, AuthStatus.emailUnverified);
    });
  });

  // ═══════════════════════════════════════════════════════
  // SCENARIO 6 — Remember me
  // ═══════════════════════════════════════════════════════
  group('Scenario: Remember Me', () {
    testWidgets('checkbox starts unchecked and can be toggled', (t) async {
      await t.pumpWidget(_app(const _Repo()));
      await t.pumpAndSettle();

      Checkbox cb = t.widget<Checkbox>(find.byType(Checkbox));
      expect(cb.value, isFalse);

      await t.tap(find.byType(Checkbox));
      await t.pumpAndSettle();

      cb = t.widget<Checkbox>(find.byType(Checkbox));
      expect(cb.value, isTrue);
    });
  });
}
