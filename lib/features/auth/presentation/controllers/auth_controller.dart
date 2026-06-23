// lib/features/auth/presentation/controllers/auth_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailUnverified,
}

class AuthController extends ChangeNotifier {
  final AuthRepository _repo;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String?    _error;
  String?    _pendingEmail;

  AuthStatus get status        => _status;
  UserModel? get user          => _user;
  String?    get error         => _error;
  // Alias so old code using auth.errorMessage still compiles
  String?    get errorMessage  => _error;
  String?    get pendingEmail  => _pendingEmail;
  bool get isLoading           => _status == AuthStatus.loading;
  bool get isAuthenticated     => _status == AuthStatus.authenticated;

  /// Named parameter is [repo] — used in tests and widget trees.
  AuthController({AuthRepository? repo})
      : _repo = repo ?? AuthRepositoryImpl() {
    _init();
  }

  Future<void> _init() async {
    final cached = await _repo.getCachedUser();
    if (cached != null) {
      _user   = cached;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── login ─────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _loading();
    final r = await _repo.login(email, password);
    return switch (r) {
      ApiSuccess(:final data) => _ok(data, AuthStatus.authenticated),
      ApiError(:final message, :final code) => _fail(
          message,
          code == 403 ? AuthStatus.emailUnverified : AuthStatus.unauthenticated,
        ),
    };
  }

  // ── register ──────────────────────────────────────────────
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? dateOfBirth,
    String? gender,
    File?   profileImage,
  }) async {
    _loading();
    final r = await _repo.register(
      fullName:    fullName,
      email:       email,
      phone:       phone,
      password:    password,
      dateOfBirth: dateOfBirth,
      gender:      gender,
      profileImage: profileImage,
    );
    return switch (r) {
      ApiSuccess(:final data) => _ok(data, AuthStatus.emailUnverified,
          pending: email),
      ApiError(:final message) => _fail(message, AuthStatus.unauthenticated),
    };
  }

  // ── verifyEmail ───────────────────────────────────────────
  Future<bool> verifyEmail(String email, String otp) async {
    _loading();
    final r = await _repo.verifyEmail(email, otp);
    return switch (r) {
      ApiSuccess() => _boolOk(AuthStatus.authenticated),
      ApiError(:final message) => _fail(message, AuthStatus.emailUnverified),
    };
  }

  // ── resendOtp ─────────────────────────────────────────────
  Future<bool> resendOtp(String email) async {
    final r = await _repo.resendOtp(email);
    return switch (r) {
      ApiSuccess() => true,
      ApiError(:final message) => () {
          _error = message;
          notifyListeners();
          return false;
        }(),
    };
  }

  // ── forgotPassword ────────────────────────────────────────
  Future<bool> forgotPassword(String email) async {
    _loading();
    final r = await _repo.forgotPassword(email);
    return switch (r) {
      ApiSuccess() => () {
          _pendingEmail = email;
          _status = AuthStatus.unauthenticated;
          _error  = null;
          notifyListeners();
          return true;
        }(),
      ApiError(:final message) => _fail(message, AuthStatus.unauthenticated),
    };
  }

  // ── resetPassword ─────────────────────────────────────────
  Future<bool> resetPassword(String email, String otp, String newPass) async {
    _loading();
    final r = await _repo.resetPassword(email, otp, newPass);
    return switch (r) {
      ApiSuccess() => _boolOk(AuthStatus.unauthenticated),
      ApiError(:final message) => _fail(message, AuthStatus.unauthenticated),
    };
  }

  // ── logout ────────────────────────────────────────────────
  Future<void> logout() async {
    await _repo.logout();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    _error  = null;
    notifyListeners();
  }

  // ── helpers ───────────────────────────────────────────────
  void updateUser(UserModel u) {
    _user = u;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _loading() {
    _status = AuthStatus.loading;
    _error  = null;
    notifyListeners();
  }

  bool _ok(UserModel u, AuthStatus s, {String? pending}) {
    _user         = u;
    _status       = s;
    _error        = null;
    _pendingEmail = pending;
    notifyListeners();
    return true;
  }

  bool _boolOk(AuthStatus s) {
    _status = s;
    _error  = null;
    notifyListeners();
    return true;
  }

  bool _fail(String msg, AuthStatus s) {
    _status = s;
    _error  = msg;
    notifyListeners();
    return false;
  }
}
