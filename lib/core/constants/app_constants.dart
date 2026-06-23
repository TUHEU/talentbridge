// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  static const String appName = 'Talent Bridge';
  static const String appTagline = 'Connect Talent. Build Futures.';
  static const String appVersion = '1.0.0';

  // ── API (change to your server IP when using a physical device)
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.11.12.182:5003/api',
  );

  // ── SharedPreferences keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user_data';
  static const String keyTheme = 'is_dark_mode';
  static const String keyOnboarded = 'onboarded';

  // ── Timeouts (seconds)
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;

  // ── Pagination
  static const int pageSize = 20;

  // ── OTP
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;

  // ── UI
  static const double radiusS = 8.0;
  static const double radiusM = 14.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 28.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // ── XP thresholds
  static const Map<String, int> xpLevels = {
    'Newcomer': 0,
    'Explorer': 100,
    'Achiever': 300,
    'Professional': 600,
    'Expert': 1000,
    'Leader': 2000,
    'Champion': 5000,
  };
}
