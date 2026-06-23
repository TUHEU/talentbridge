// test/widget/home/home_dashboard_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talent_bridge/core/theme/app_theme.dart';
import 'package:talent_bridge/core/theme/theme_controller.dart';
import 'package:talent_bridge/features/auth/data/models/user_model.dart';
import 'package:talent_bridge/features/auth/data/repositories/auth_repository.dart';
import 'package:talent_bridge/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talent_bridge/features/home/presentation/widgets/home_dashboard.dart';
import 'package:talent_bridge/core/network/api_client.dart';

class _MockRepo implements AuthRepository {
  final UserModel? user;
  _MockRepo({this.user});
  @override Future<UserModel?> getCachedUser() async => user;
  @override Future<ApiResult<UserModel>> login(String e, String p) async =>
      const ApiError('n/a');
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
}

final _testUser = UserModel(
  id: 1,
  fullName: 'Fahdil Mochtar',
  email: 'fahdil@example.com',
  isEmailVerified: true,
  xpPoints: 350,
);

Widget _pump({UserModel? user, bool dark = false}) => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeController()),
    // Fixed: named param is 'repo'
    ChangeNotifierProvider(
      create: (_) =>
          AuthController(repo: _MockRepo(user: user ?? _testUser)),
    ),
  ],
  child: MaterialApp(
    theme: dark ? AppTheme.dark : AppTheme.light,
    home: const Scaffold(body: HomeDashboard()),
  ),
);

void main() {
  group('HomeDashboard — Structure', () {
    testWidgets('shows user first name in greeting', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Fahdil'), findsOneWidget);
    });

    testWidgets('shows XP points and level badge', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.textContaining('350 XP'), findsOneWidget);
      expect(find.textContaining('Achiever'), findsOneWidget);
    });

    testWidgets('shows search bar hint text', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.textContaining('Search jobs'), findsOneWidget);
    });

    testWidgets('shows Quick Access section', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Quick Access'), findsOneWidget);
    });

    testWidgets('shows all 4 feature cards', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('AI Advisor'),  findsOneWidget);
      expect(find.text('Job Board'),   findsOneWidget);
      expect(find.text('Community'),   findsOneWidget);
      expect(find.text('Startups'),    findsOneWidget);
    });

    testWidgets('shows stat cards', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Applications'), findsOneWidget);
      expect(find.text('Saved Jobs'),   findsOneWidget);
      expect(find.text('AI Chats'),     findsOneWidget);
    });

    testWidgets('shows Featured Jobs section', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Featured Jobs'), findsOneWidget);
    });

    testWidgets('shows Tip of the day card', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      expect(find.text('Tip of the day'), findsOneWidget);
    });

    testWidgets('shows Explorer fallback when user is null', (t) async {
      await t.pumpWidget(_pump(user: null));
      await t.pumpAndSettle();
      expect(find.text('Explorer'), findsOneWidget);
    });
  });

  group('HomeDashboard — Greeting', () {
    testWidgets('shows a time-appropriate greeting', (t) async {
      await t.pumpWidget(_pump());
      await t.pumpAndSettle();
      final greetings = ['Good morning', 'Good afternoon', 'Good evening'];
      final found = greetings.any((g) => t.any(find.textContaining(g)));
      expect(found, isTrue,
          reason: 'Expected morning/afternoon/evening greeting');
    });
  });

  group('HomeDashboard — Dark Mode', () {
    testWidgets('renders without error in dark mode', (t) async {
      await t.pumpWidget(_pump(dark: true));
      await t.pumpAndSettle();
      expect(find.text('Fahdil'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });
}
