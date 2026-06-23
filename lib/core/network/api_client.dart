// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

// ── Result type ───────────────────────────────────────────────
sealed class ApiResult<T> {
  const ApiResult();
}
class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}
class ApiError<T> extends ApiResult<T> {
  final String message;
  final int? code;
  const ApiError(this.message, {this.code});
}

// ── Singleton Dio client ──────────────────────────────────────
class ApiClient {
  static ApiClient? _i;
  late final Dio dio;

  ApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(seconds: AppConstants.connectTimeout),
      receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    dio.interceptors.addAll([
      _AuthInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true, logPrint: (_) {}),
    ]);
  }

  static ApiClient get instance => _i ??= ApiClient._();

  Future<Response> get(String path, {Map<String, dynamic>? query}) =>
      dio.get(path, queryParameters: query);
  Future<Response> post(String path, {dynamic data}) =>
      dio.post(path, data: data);
  Future<Response> put(String path, {dynamic data}) =>
      dio.put(path, data: data);
  Future<Response> patch(String path, {dynamic data}) =>
      dio.patch(path, data: data);
  Future<Response> delete(String path, {dynamic data}) =>
      dio.delete(path, data: data);
  Future<Response> postForm(String path, FormData data) =>
      dio.post(path, data: data,
          options: Options(contentType: 'multipart/form-data'));
  Future<Response> putForm(String path, FormData data) =>
      dio.put(path, data: data,
          options: Options(contentType: 'multipart/form-data'));
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions opts, RequestInterceptorHandler h) async {
    final p = await SharedPreferences.getInstance();
    final t = p.getString(AppConstants.keyAccessToken);
    if (t != null) opts.headers['Authorization'] = 'Bearer $t';
    h.next(opts);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) async {
    if (e.response?.statusCode == 401) {
      final p = await SharedPreferences.getInstance();
      await p.remove(AppConstants.keyAccessToken);
    }
    h.next(e);
  }
}

// ── Helper to map DioException to user-facing error ──────────
String dioErrorMessage(DioException e) {
  if (e.response?.data != null) {
    final d = e.response!.data;
    if (d is Map) {
      return (d['message'] ?? d['error'] ?? 'An error occurred').toString();
    }
  }
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout    => 'Connection timed out. Check your network.',
    DioExceptionType.connectionError   => 'No internet connection.',
    _                                  => e.message ?? 'An error occurred.',
  };
}
