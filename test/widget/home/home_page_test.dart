// test/widget/home/home_page_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talent_bridge/core/theme/app_theme.dart';
import 'package:talent_bridge/core/theme/theme_controller.dart';
import 'package:talent_bridge/features/auth/data/models/user_model.dart';
import 'package:talent_bridge/features/auth/data/repositories/auth_repository.dart';
import 'package:talent_bridge/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talent_bridge/features/home/presentation/pages/home_page.dart';
import 'package:talent_bridge/core/network/api_client.dart';

// ── Mock repo that provides a logged-in user ──────────────────
class _MockRepo implements AuthRepository {
  final UserModel user;
  _MockRepo(this.user);

  @override
  Future<UserModel?> getCachedUser() async => user;

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
}

// ── Test user fixture ─────────────────────────────────────────
final _testUser = UserModel(
  id: 1,
  fullName: 'Fahdil Mochtar',
  email: 'fahdil@example.com',
  isEmailVerified: true,
  xpPoints: 350,
);

// ── Widget pump helper ────────────────────────────────────────
Widget _pump() => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeController()),
    ChangeNotifierProvider(
      // Fixed: 'repo' not 'repository'
      create: (_) => AuthController(repo: _MockRepo(_testUser)),
    ),
  ],
  child: MaterialApp(
    // Fixed: AppTheme.light not AppTheme.lightTheme
    theme: AppTheme.light,
    home: const HomePage(),
  ),
);

void main() {
  // ═══════════════════════════════════════════════════════
  // Bottom navigation bar
  // ═══════════════════════════════════════════════════════
  group('HomePage — Bottom Navigation Bar', () {
    testWidgets('renders the bottom navigation bar', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.byType(BottomNavigationBar), findsNothing);
      // Our custom nav is not BottomNavigationBar — verify tabs by icons
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('shows Home tab selected by default', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      // Home label visible in the animated pill when selected
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('all 5 tab icons are present', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.home_rounded),         findsOneWidget);
      expect(find.byIcon(Icons.psychology_outlined),  findsOneWidget);
      expect(find.byIcon(Icons.work_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });

    testWidgets('tapping AI Advisor tab switches to AI page', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.psychology_outlined));
      await t.pumpAndSettle();
      expect(find.text('AI Advisor'), findsOneWidget);
    });

    testWidgets('tapping Jobs tab switches to Opportunities page', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.work_outline_rounded));
      await t.pumpAndSettle();
      expect(find.text('Opportunities'), findsOneWidget);
    });

    testWidgets('tapping back to Home restores dashboard', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();

      // Navigate away
      await t.tap(find.byIcon(Icons.psychology_outlined));
      await t.pumpAndSettle();

      // Navigate back to Home
      await t.tap(find.byIcon(Icons.home_outlined));
      await t.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════
  // IndexedStack state persistence
  // ═══════════════════════════════════════════════════════
  group('HomePage — IndexedStack', () {
    testWidgets('uses IndexedStack to keep pages alive', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('IndexedStack has 5 children', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      final stack = t.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.children.length, 5);
    });
  });

  // ═══════════════════════════════════════════════════════
  // Dashboard content (from first tab)
  // ═══════════════════════════════════════════════════════
  group('HomePage — Dashboard Content', () {
    testWidgets('shows user greeting on home tab', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Fahdil'), findsOneWidget);
    });

    testWidgets('shows XP badge on home tab', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.textContaining('350 XP'), findsOneWidget);
    });
  });
}
