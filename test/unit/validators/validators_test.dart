// test/unit/validators/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_bridge/core/utils/validators.dart';

void main() {
  // ═══════════════════════════════════════════════════════
  // EMAIL
  // ═══════════════════════════════════════════════════════
  group('Validators.email', () {
    test('accepts standard valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });
    test('accepts email with subdomain', () {
      expect(Validators.email('user@sub.domain.org'), isNull);
    });
    test('accepts email with plus tag', () {
      expect(Validators.email('user+tag@example.com'), isNull);
    });
    test('rejects null', () {
      expect(Validators.email(null), isNotNull);
    });
    test('rejects empty string', () {
      expect(Validators.email(''), isNotNull);
    });
    test('rejects missing @', () {
      expect(Validators.email('userexample.com'), isNotNull);
    });
    test('rejects missing domain after @', () {
      expect(Validators.email('user@'), isNotNull);
    });
    test('rejects missing TLD', () {
      expect(Validators.email('user@example'), isNotNull);
    });
    test('rejects consecutive dots', () {
      expect(Validators.email('user..name@example.com'), isNotNull);
    });
    test('rejects whitespace in email', () {
      expect(Validators.email('user @example.com'), isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  // PASSWORD
  // ═══════════════════════════════════════════════════════
  group('Validators.password', () {
    test('accepts strong password', () {
      expect(Validators.password('Password1'), isNull);
    });
    test('accepts password with special chars', () {
      expect(Validators.password('Str0ng@Pass!'), isNull);
    });
    test('rejects null', () {
      expect(Validators.password(null), isNotNull);
    });
    test('rejects empty string', () {
      expect(Validators.password(''), isNotNull);
    });
    test('rejects less than 8 chars and mentions 8', () {
      final err = Validators.password('Pass1');
      expect(err, isNotNull);
      expect(err, contains('8'));
    });
    test('rejects no uppercase letter', () {
      expect(Validators.password('password1'), isNotNull);
    });
    test('rejects no digit', () {
      expect(Validators.password('PasswordOnly'), isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  // CONFIRM PASSWORD
  // ═══════════════════════════════════════════════════════
  group('Validators.confirmPassword', () {
    test('accepts matching passwords', () {
      expect(Validators.confirmPassword('Password1', 'Password1'), isNull);
    });
    test('rejects mismatched passwords', () {
      expect(Validators.confirmPassword('Password1', 'Different1'), isNotNull);
    });
    test('rejects null', () {
      expect(Validators.confirmPassword(null, 'Password1'), isNotNull);
    });
    test('rejects empty string', () {
      expect(Validators.confirmPassword('', 'Password1'), isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  // FULL NAME
  // ═══════════════════════════════════════════════════════
  group('Validators.fullName', () {
    test('accepts valid full name', () {
      expect(Validators.fullName('Fahdil Mochtar'), isNull);
    });
    test('accepts single name longer than 3 chars', () {
      expect(Validators.fullName('Alice'), isNull);
    });
    test('rejects null', () {
      expect(Validators.fullName(null), isNotNull);
    });
    test('rejects empty string', () {
      expect(Validators.fullName(''), isNotNull);
    });
    test('rejects whitespace only', () {
      expect(Validators.fullName('   '), isNotNull);
    });
    test('rejects name shorter than 3 chars', () {
      expect(Validators.fullName('Jo'), isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  // PHONE
  // ═══════════════════════════════════════════════════════
  group('Validators.phone', () {
    test('accepts 10-digit number', () {
      expect(Validators.phone('1234567890'), isNull);
    });
    test('accepts international format', () {
      expect(Validators.phone('+237698765432'), isNull);
    });
    test('rejects null', () {
      expect(Validators.phone(null), isNotNull);
    });
    test('rejects empty string', () {
      expect(Validators.phone(''), isNotNull);
    });
    test('rejects fewer than 10 digits', () {
      expect(Validators.phone('12345'), isNotNull);
    });
    test('rejects more than 15 digits', () {
      expect(Validators.phone('1234567890123456'), isNotNull);
    });
    test('rejects letters in number', () {
      expect(Validators.phone('1234abcdef'), isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  // OTP
  // ═══════════════════════════════════════════════════════
  group('Validators.otp', () {
    test('accepts valid 6-digit OTP', () {
      expect(Validators.otp('123456'), isNull);
    });
    test('accepts all-zeros OTP', () {
      expect(Validators.otp('000000'), isNull);
    });
    test('rejects null', () {
      expect(Validators.otp(null), isNotNull);
    });
    test('rejects empty string', () {
      expect(Validators.otp(''), isNotNull);
    });
    test('rejects fewer than 6 digits', () {
      expect(Validators.otp('12345'), isNotNull);
    });
    test('rejects more than 6 digits', () {
      expect(Validators.otp('1234567'), isNotNull);
    });
    test('rejects letters', () {
      expect(Validators.otp('12345a'), isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  // REQUIRED
  // ═══════════════════════════════════════════════════════
  group('Validators.required', () {
    test('accepts non-empty string', () {
      expect(Validators.required('hello'), isNull);
    });
    test('accepts single character', () {
      expect(Validators.required('a'), isNull);
    });
    test('rejects null', () {
      expect(Validators.required(null), isNotNull);
    });
    test('rejects empty string', () {
      expect(Validators.required(''), isNotNull);
    });
    test('rejects whitespace only', () {
      expect(Validators.required('   '), isNotNull);
    });
    test('includes custom field name in error message', () {
      final err = Validators.required('', 'Job Title');
      expect(err, contains('Job Title'));
    });
  });
}
