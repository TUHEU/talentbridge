// test/unit/controllers/auth_controller_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_bridge/features/auth/data/models/user_model.dart';
import 'package:talent_bridge/features/auth/data/repositories/auth_repository.dart';
import 'package:talent_bridge/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talent_bridge/core/network/api_client.dart';

// ── Full configurable mock ────────────────────────────────────
class MockRepo implements AuthRepository {
  ApiResult<UserModel>? loginResult;
  ApiResult<UserModel>? registerResult;
  ApiResult<bool>?      verifyResult;
  ApiResult<bool>?      resendResult;
  ApiResult<bool>?      forgotResult;
  ApiResult<bool>?      resetResult;
  UserModel?            cachedUser;
  bool logoutCalled = false;

  @override Future<ApiResult<UserModel>> login(String e, String p) async =>
      loginResult    ?? const ApiError('not configured');
  @override Future<ApiResult<UserModel>> register({
    required String fullName, required String email,
    required String phone,    required String password,
    String? dateOfBirth, String? gender, File? profileImage}) async =>
      registerResult ?? const ApiError('not configured');
  @override Future<ApiResult<bool>> verifyEmail(String e, String o) async =>
      verifyResult   ?? const ApiError('not configured');
  @override Future<ApiResult<bool>> resendOtp(String e) async =>
      resendResult   ?? const ApiSuccess(true);
  @override Future<ApiResult<bool>> forgotPassword(String e) async =>
      forgotResult   ?? const ApiSuccess(true);
  @override Future<ApiResult<bool>> resetPassword(String e, String o, String p) async =>
      resetResult    ?? const ApiSuccess(true);
  @override Future<void> logout() async { logoutCalled = true; }
  @override Future<UserModel?> getCachedUser() async => cachedUser;
}

UserModel _user({String email = 'fahdil@example.com', bool verified = true}) =>
    UserModel(id: 1, fullName: 'Fahdil Mochtar', email: email, isEmailVerified: verified);

void main() {
  late MockRepo       repo;
  late AuthController ctrl;

  setUp(() {
    repo = MockRepo();
    // Use named param 'repo'
    ctrl = AuthController(repo: repo);
  });

  Future<void> settle() => Future.delayed(Duration.zero);

  // ═══════════════════════════════════════════════════════
  // Initial state
  // ═══════════════════════════════════════════════════════
  group('Initial state', () {
    test('starts as AuthStatus.initial synchronously', () {
      expect(ctrl.status, AuthStatus.initial);
    });

    test('transitions to unauthenticated when no cached user', () async {
      await settle();
      expect(ctrl.status, AuthStatus.unauthenticated);
      expect(ctrl.user,   isNull);
    });

    test('transitions to authenticated when cached user exists', () async {
      repo.cachedUser = _user();
      final c = AuthController(repo: repo);
      await settle();
      expect(c.status,      AuthStatus.authenticated);
      expect(c.user?.email, 'fahdil@example.com');
    });

    test('isLoading is false initially', () {
      expect(ctrl.isLoading, isFalse);
    });

    test('isAuthenticated is false initially', () {
      expect(ctrl.isAuthenticated, isFalse);
    });

    test('error is null initially', () {
      expect(ctrl.error, isNull);
    });

    test('errorMessage alias is also null initially', () {
      expect(ctrl.errorMessage, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  // login()
  // ═══════════════════════════════════════════════════════
  group('login()', () {
    test('returns true and sets authenticated on success', () async {
      repo.loginResult = ApiSuccess(_user());
      await settle();
      final ok = await ctrl.login('fahdil@example.com', 'Password1');
      expect(ok,               isTrue);
      expect(ctrl.status,      AuthStatus.authenticated);
      expect(ctrl.user?.email, 'fahdil@example.com');
      expect(ctrl.error,       isNull);
    });

    test('returns false and stores error on failure', () async {
      repo.loginResult = const ApiError('Invalid email or password');
      await settle();
      final ok = await ctrl.login('bad@email.com', 'wrong');
      expect(ok,          isFalse);
      expect(ctrl.status, AuthStatus.unauthenticated);
      expect(ctrl.user,   isNull);
      expect(ctrl.error,  'Invalid email or password');
      // errorMessage alias must also work
      expect(ctrl.errorMessage, 'Invalid email or password');
    });

    test('passes through loading state during call', () async {
      repo.loginResult = ApiSuccess(_user());
      await settle();
      bool seenLoading = false;
      ctrl.addListener(() {
        if (ctrl.status == AuthStatus.loading) seenLoading = true;
      });
      await ctrl.login('fahdil@example.com', 'Password1');
      expect(seenLoading,    isTrue);
      expect(ctrl.isLoading, isFalse);
    });

    test('clears previous error before new attempt', () async {
      repo.loginResult = const ApiError('First error');
      await settle();
      await ctrl.login('a@a.com', 'Password1');
      expect(ctrl.error, isNotNull);

      repo.loginResult = ApiSuccess(_user());
      await ctrl.login('fahdil@example.com', 'Password1');
      expect(ctrl.error, isNull);
    });

    test('sets emailUnverified status when code 403 returned', () async {
      repo.loginResult = const ApiError('Email not verified', code: 403);
      await settle();
      await ctrl.login('unverified@example.com', 'Password1');
      expect(ctrl.status, AuthStatus.emailUnverified);
    });
  });

  // ═══════════════════════════════════════════════════════
  // register()
  // ═══════════════════════════════════════════════════════
  group('register()', () {
    test('returns true and sets emailUnverified on success', () async {
      repo.registerResult = ApiSuccess(_user(verified: false));
      await settle();
      final ok = await ctrl.register(
        fullName: 'Fahdil Mochtar', email: 'fahdil@example.com',
        phone: '+237698765432', password: 'Password1',
      );
      expect(ok,             isTrue);
      expect(ctrl.status,    AuthStatus.emailUnverified);
      expect(ctrl.pendingEmail, 'fahdil@example.com');
    });

    test('returns false and stores error on duplicate email', () async {
      repo.registerResult =
          const ApiError('An account with this email already exists', code: 409);
      await settle();
      final ok = await ctrl.register(
        fullName: 'Test', email: 'dup@example.com',
        phone: '+237000000000', password: 'Password1',
      );
      expect(ok,         isFalse);
      expect(ctrl.error, contains('already exists'));
    });
  });

  // ═══════════════════════════════════════════════════════
  // verifyEmail()
  // ═══════════════════════════════════════════════════════
  group('verifyEmail()', () {
    test('returns true and sets authenticated on success', () async {
      repo.verifyResult = const ApiSuccess(true);
      await settle();
      final ok = await ctrl.verifyEmail('fahdil@example.com', '123456');
      expect(ok,          isTrue);
      expect(ctrl.status, AuthStatus.authenticated);
    });

    test('returns false and stores error on wrong OTP', () async {
      repo.verifyResult = const ApiError('Invalid or expired code');
      await settle();
      final ok = await ctrl.verifyEmail('fahdil@example.com', '000000');
      expect(ok,         isFalse);
      expect(ctrl.error, 'Invalid or expired code');
    });
  });

  // ═══════════════════════════════════════════════════════
  // forgotPassword()
  // ═══════════════════════════════════════════════════════
  group('forgotPassword()', () {
    test('returns true and stores pending email', () async {
      repo.forgotResult = const ApiSuccess(true);
      await settle();
      final ok = await ctrl.forgotPassword('fahdil@example.com');
      expect(ok,                isTrue);
      expect(ctrl.pendingEmail, 'fahdil@example.com');
    });

    test('returns false on error', () async {
      repo.forgotResult = const ApiError('Error');
      await settle();
      final ok = await ctrl.forgotPassword('x@x.com');
      expect(ok, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════
  // resetPassword()
  // ═══════════════════════════════════════════════════════
  group('resetPassword()', () {
    test('returns true and sets unauthenticated on success', () async {
      repo.resetResult = const ApiSuccess(true);
      await settle();
      final ok = await ctrl.resetPassword('f@e.com', '123456', 'NewPass1');
      expect(ok,          isTrue);
      expect(ctrl.status, AuthStatus.unauthenticated);
    });

    test('returns false on invalid OTP', () async {
      repo.resetResult = const ApiError('Invalid or expired reset code');
      await settle();
      final ok = await ctrl.resetPassword('f@e.com', '000000', 'NewPass1');
      expect(ok,         isFalse);
      expect(ctrl.error, isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  // logout()
  // ═══════════════════════════════════════════════════════
  group('logout()', () {
    test('clears user, sets unauthenticated, calls repo.logout', () async {
      repo.loginResult = ApiSuccess(_user());
      await settle();
      await ctrl.login('fahdil@example.com', 'Password1');
      expect(ctrl.isAuthenticated, isTrue);

      await ctrl.logout();
      expect(ctrl.user,         isNull);
      expect(ctrl.status,       AuthStatus.unauthenticated);
      expect(repo.logoutCalled, isTrue);
    });

    test('clears error on logout', () async {
      repo.loginResult = const ApiError('Some error');
      await settle();
      await ctrl.login('x@x.com', 'Pass1');
      expect(ctrl.error, isNotNull);
      await ctrl.logout();
      expect(ctrl.error, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  // clearError()
  // ═══════════════════════════════════════════════════════
  group('clearError()', () {
    test('sets error to null', () async {
      repo.loginResult = const ApiError('Test error');
      await settle();
      await ctrl.login('x@x.com', 'Password1');
      expect(ctrl.error, isNotNull);
      ctrl.clearError();
      expect(ctrl.error, isNull);
    });

    test('notifies listeners when called', () {
      bool notified = false;
      ctrl.addListener(() => notified = true);
      ctrl.clearError();
      expect(notified, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════
  // updateUser()
  // ═══════════════════════════════════════════════════════
  group('updateUser()', () {
    test('replaces user and notifies listeners', () async {
      repo.cachedUser = _user();
      final c = AuthController(repo: repo);
      await settle();
      bool notified = false;
      c.addListener(() => notified = true);

      final updated = _user().copyWith(jobTitle: 'Senior Dev', xpPoints: 500);
      c.updateUser(updated);
      expect(c.user?.jobTitle, 'Senior Dev');
      expect(c.user?.xpPoints, 500);
      expect(notified, isTrue);
    });
  });
}
