// lib/features/auth/data/repositories/auth_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<ApiResult<UserModel>> login(String email, String password);
  Future<ApiResult<UserModel>> register({
    required String fullName, required String email,
    required String phone, required String password,
    String? dateOfBirth, String? gender, File? profileImage,
  });
  Future<ApiResult<bool>> verifyEmail(String email, String otp);
  Future<ApiResult<bool>> resendOtp(String email);
  Future<ApiResult<bool>> forgotPassword(String email);
  Future<ApiResult<bool>> resetPassword(String email, String otp, String newPass);
  Future<void> logout();
  Future<UserModel?> getCachedUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _api;
  AuthRepositoryImpl({ApiClient? api}) : _api = api ?? ApiClient.instance;

  // ── Helpers ──────────────────────────────────────────────
  Future<void> _saveSession(Map data) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConstants.keyAccessToken,  data['access_token']  ?? '');
    await p.setString(AppConstants.keyRefreshToken, data['refresh_token'] ?? '');
    await p.setString(AppConstants.keyUser, jsonEncode(UserModel.fromJson(data['user']).toJson()));
  }

  String _parseErr(DioException e) {
    if (e.response?.data is Map) {
      final d = e.response!.data as Map;
      return (d['message'] ?? d['error'] ?? 'An error occurred').toString();
    }
    return dioErrorMessage(e);
  }

  // ── Login ─────────────────────────────────────────────────
  @override
  Future<ApiResult<UserModel>> login(String email, String password) async {
    try {
      final r = await _api.post('/auth/login',
          data: {'email': email.trim().toLowerCase(), 'password': password});
      await _saveSession(r.data);
      return ApiSuccess(UserModel.fromJson(r.data['user']));
    } on DioException catch (e) {
      return ApiError(_parseErr(e), code: e.response?.statusCode);
    }
  }

  // ── Register ──────────────────────────────────────────────
  @override
  Future<ApiResult<UserModel>> register({
    required String fullName, required String email,
    required String phone, required String password,
    String? dateOfBirth, String? gender, File? profileImage,
  }) async {
    try {
      final form = FormData.fromMap({
        'full_name': fullName.trim(),
        'email':     email.trim().toLowerCase(),
        'phone':     phone.trim(),
        'password':  password,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (gender != null)      'gender':         gender,
        if (profileImage != null)
          'profile_image': await MultipartFile.fromFile(
              profileImage.path, filename: 'profile.jpg'),
      });
      final r = await _api.postForm('/auth/register', form);
      return ApiSuccess(UserModel.fromJson(r.data['user']));
    } on DioException catch (e) {
      return ApiError(_parseErr(e), code: e.response?.statusCode);
    }
  }

  @override
  Future<ApiResult<bool>> verifyEmail(String email, String otp) async {
    try {
      final r = await _api.post('/auth/verify-email',
          data: {'email': email, 'otp': otp});
      await _saveSession(r.data);
      return const ApiSuccess(true);
    } on DioException catch (e) {
      return ApiError(_parseErr(e));
    }
  }

  @override
  Future<ApiResult<bool>> resendOtp(String email) async {
    try {
      await _api.post('/auth/resend-otp', data: {'email': email});
      return const ApiSuccess(true);
    } on DioException catch (e) {
      return ApiError(_parseErr(e));
    }
  }

  @override
  Future<ApiResult<bool>> forgotPassword(String email) async {
    try {
      await _api.post('/auth/forgot-password', data: {'email': email});
      return const ApiSuccess(true);
    } on DioException catch (e) {
      return ApiError(_parseErr(e));
    }
  }

  @override
  Future<ApiResult<bool>> resetPassword(String email, String otp, String newPass) async {
    try {
      await _api.post('/auth/reset-password',
          data: {'email': email, 'otp': otp, 'new_password': newPass});
      return const ApiSuccess(true);
    } on DioException catch (e) {
      return ApiError(_parseErr(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      final p = await SharedPreferences.getInstance();
      final tok = p.getString(AppConstants.keyRefreshToken);
      if (tok != null) await _api.post('/auth/logout', data: {'refresh_token': tok});
    } catch (_) {}
    final p = await SharedPreferences.getInstance();
    await p.remove(AppConstants.keyAccessToken);
    await p.remove(AppConstants.keyRefreshToken);
    await p.remove(AppConstants.keyUser);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(AppConstants.keyUser);
    if (s == null) return null;
    try { return UserModel.fromJson(jsonDecode(s)); } catch (_) { return null; }
  }
}
