// lib/core/utils/validators.dart

class Validators {
  Validators._();

  static final _email = RegExp(
    r'^[a-zA-Z0-9]([a-zA-Z0-9._%-]*[a-zA-Z0-9])?'
    r'@[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?'
    r'(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$',
  );
  static final _phone = RegExp(r'^\+?[0-9]{10,15}$');

  static String? email(String? v) {
    if (v == null || v.isEmpty)   return 'Email is required';
    if (v.trim().contains('..'))  return 'Email cannot have consecutive dots';
    if (v.trim().startsWith('-')) return 'Invalid email format';
    if (!_email.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8)           return 'Password must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Must include at least one uppercase letter';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Must include at least one number';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != original)          return 'Passwords do not match';
    return null;
  }

  static String? fullName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 3)           return 'Name must be at least 3 characters';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Phone number is required';
    final c = v.replaceAll(RegExp(r'[\s\-]'), '');
    if (!_phone.hasMatch(c)) return 'Enter a valid phone number (10–15 digits)';
    return null;
  }

  static String? otp(String? v) {
    if (v == null || v.isEmpty) return 'Code is required';
    if (v.length != 6)          return 'Enter the 6-digit code';
    if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Code must contain only digits';
    return null;
  }

  static String? required(String? v, [String? field]) {
    if (v == null || v.trim().isEmpty) return '${field ?? 'This field'} is required';
    return null;
  }
}
