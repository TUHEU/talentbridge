// test/widget/auth/login_page_test.dart
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

class _MockRepo implements AuthRepository {
  ApiResult<UserModel>? loginResult;

  @override Future<ApiResult<UserModel>> login(String e, String p) async =>
      loginResult ?? const ApiError('mock');
  @override Future<ApiResult<UserModel>> register({
    required String fullName, required String email,
    required String phone,    required String password,
    String? dateOfBirth, String? gender, File? profileImage}) async =>
      const ApiError('n/a');
  @override Future<ApiResult<bool>> verifyEmail(String e, String o) async =>
      const ApiSuccess(true);
  @override Future<ApiResult<bool>> resendOtp(String e) async =>
      const ApiSuccess(true);
  @override Future<ApiResult<bool>> forgotPassword(String e) async =>
      const ApiSuccess(true);
  @override Future<ApiResult<bool>> resetPassword(String e, String o, String p)
      async => const ApiSuccess(true);
  @override Future<void> logout() async {}
  @override Future<UserModel?> getCachedUser() async => null;
}

Widget _pump({_MockRepo? repo}) {
  final r = repo ?? _MockRepo();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      // Fixed: named param is 'repo'
      ChangeNotifierProvider(create: (_) => AuthController(repo: r)),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const LoginPage(),
    ),
  );
}

void main() {
  // ═══════════════════════════════════════════════════════
  // Structure
  // ═══════════════════════════════════════════════════════
  group('LoginPage — Structure', () {
    testWidgets('shows app name Talent Bridge', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Talent Bridge'), findsOneWidget);
    });

    testWidgets('shows tagline text', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.textContaining('Connect Talent'), findsOneWidget);
    });

    testWidgets('shows welcome heading', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.textContaining('Welcome back'), findsOneWidget);
    });

    testWidgets('renders at least 2 text fields', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
    });

    testWidgets('renders Sign In button', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('renders Create account link', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Create account'), findsOneWidget);
    });

    testWidgets('renders Forgot password button', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('renders Remember me checkbox', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.byType(Checkbox), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════
  // Validation
  // ═══════════════════════════════════════════════════════
  group('LoginPage — Validation', () {
    testWidgets('shows error for invalid email format', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextFormField).first, 'notanemail');
      await t.tap(find.text('Sign In'));
      await t.pumpAndSettle();
      expect(find.textContaining('valid email'), findsOneWidget);
    });

    testWidgets('shows error for empty password', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextFormField).first, 'user@example.com');
      await t.tap(find.text('Sign In'));
      await t.pumpAndSettle();
      expect(find.textContaining('password'), findsAtLeastNWidgets(1));
    });

    testWidgets('does not call API when form is invalid', (t) async {
      final repo = _MockRepo();
      await t.pumpWidget(_pump(repo: repo));
      await t.pumpAndSettle();
      await t.tap(find.text('Sign In'));
      await t.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  // ═══════════════════════════════════════════════════════
  // Interaction
  // ═══════════════════════════════════════════════════════
  group('LoginPage — Interaction', () {
    testWidgets('password visibility toggle works', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await t.tap(find.byIcon(Icons.visibility_outlined));
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('remember me checkbox toggles', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      Checkbox cb = t.widget<Checkbox>(find.byType(Checkbox));
      expect(cb.value, isFalse);
      await t.tap(find.byType(Checkbox));
      await t.pumpAndSettle();
      cb = t.widget<Checkbox>(find.byType(Checkbox));
      expect(cb.value, isTrue);
    });

    testWidgets('shows SnackBar with error on failed login', (t) async {
      final repo = _MockRepo();
      repo.loginResult = const ApiError('Invalid email or password');
      await t.pumpWidget(_pump(repo: repo));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextFormField).first, 'bad@example.com');
      await t.enterText(find.byType(TextFormField).last, 'WrongPass1');
      await t.tap(find.text('Sign In'));
      await t.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Invalid email or password'), findsOneWidget);
    });
  });
}
