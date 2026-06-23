// test/unit/models/user_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_bridge/features/auth/data/models/user_model.dart';

void main() {
  // ── Sample JSON matching backend response ──────────────
  final Map<String, dynamic> full = {
    'id':                1,
    'full_name':         'Fahdil Mochtar',
    'email':             'fahdil@example.com',
    'phone':             '+237698765432',
    'date_of_birth':     '2000-05-15',
    'gender':            'male',
    'profile_image_url': 'https://res.cloudinary.com/test/profile.jpg',
    'cover_image_url':   'https://res.cloudinary.com/test/cover.jpg',
    'bio':               'Software Engineering student at ICTU',
    'job_title':         'Flutter Developer',
    'company':           'TechCorp Africa',
    'location':          'Yaoundé, CM',
    'website':           'https://fahdil.dev',
    'linkedin_url':      'https://linkedin.com/in/fahdil',
    'github_url':        'https://github.com/fahdil',
    'is_email_verified': true,
    'role':              'user',
    'xp_points':         350,
    'created_at':        '2025-01-01T00:00:00.000Z',
  };

  // ═══════════════════════════════════════════════════════
  // fromJson
  // ═══════════════════════════════════════════════════════
  group('UserModel.fromJson', () {
    test('parses all fields from a complete JSON map', () {
      final u = UserModel.fromJson(full);
      expect(u.id,              1);
      expect(u.fullName,        'Fahdil Mochtar');
      expect(u.email,           'fahdil@example.com');
      expect(u.phone,           '+237698765432');
      expect(u.dateOfBirth,     '2000-05-15');
      expect(u.gender,          'male');
      expect(u.profileImageUrl, 'https://res.cloudinary.com/test/profile.jpg');
      expect(u.coverImageUrl,   'https://res.cloudinary.com/test/cover.jpg');
      expect(u.bio,             'Software Engineering student at ICTU');
      expect(u.jobTitle,        'Flutter Developer');
      expect(u.company,         'TechCorp Africa');
      expect(u.location,        'Yaoundé, CM');
      expect(u.website,         'https://fahdil.dev');
      expect(u.linkedinUrl,     'https://linkedin.com/in/fahdil');
      expect(u.githubUrl,       'https://github.com/fahdil');
      expect(u.isEmailVerified, isTrue);
      expect(u.role,            'user');
      expect(u.xpPoints,        350);
    });

    test('defaults fullName to empty when absent', () {
      expect(UserModel.fromJson({'email': 'a@b.com'}).fullName, '');
    });

    test('defaults email to empty when absent', () {
      expect(UserModel.fromJson({'full_name': 'Test'}).email, '');
    });

    test('defaults isEmailVerified to false when absent', () {
      expect(
        UserModel.fromJson({'full_name': 'T', 'email': 'a@b.com'})
            .isEmailVerified,
        isFalse,
      );
    });

    test('parses integer is_email_verified = 1 as true', () {
      final u = UserModel.fromJson({
        'full_name': 'T',
        'email': 'a@b.com',
        'is_email_verified': 1,
      });
      expect(u.isEmailVerified, isTrue);
    });

    test('defaults xpPoints to 0 when absent', () {
      expect(
        UserModel.fromJson({'full_name': 'T', 'email': 'a@b.com'}).xpPoints,
        0,
      );
    });

    test('defaults role to user when absent', () {
      expect(
        UserModel.fromJson({'full_name': 'T', 'email': 'a@b.com'}).role,
        'user',
      );
    });

    test('handles null optional fields gracefully', () {
      final u = UserModel.fromJson({
        'full_name': 'T',
        'email':     'a@b.com',
        'phone':     null,
        'bio':       null,
        'job_title': null,
        'location':  null,
      });
      expect(u.phone,    isNull);
      expect(u.bio,      isNull);
      expect(u.jobTitle, isNull);
      expect(u.location, isNull);
    });

    test('parses createdAt as DateTime when valid ISO string provided', () {
      expect(UserModel.fromJson(full).createdAt, isA<DateTime>());
    });

    test('leaves createdAt null when field is absent', () {
      expect(
        UserModel.fromJson({'full_name': 'T', 'email': 'a@b.com'}).createdAt,
        isNull,
      );
    });
  });

  // ═══════════════════════════════════════════════════════
  // toJson
  // ═══════════════════════════════════════════════════════
  group('UserModel.toJson', () {
    test('serialises all fields to a map', () {
      final u = UserModel.fromJson(full);
      final j = u.toJson();
      expect(j['id'],                1);
      expect(j['full_name'],         'Fahdil Mochtar');
      expect(j['email'],             'fahdil@example.com');
      expect(j['is_email_verified'], isTrue);
      expect(j['xp_points'],         350);
    });

    test('round-trips: fromJson → toJson → fromJson preserves data', () {
      final orig  = UserModel.fromJson(full);
      final rt    = UserModel.fromJson(orig.toJson());
      expect(rt.fullName,        orig.fullName);
      expect(rt.email,           orig.email);
      expect(rt.xpPoints,        orig.xpPoints);
      expect(rt.isEmailVerified, orig.isEmailVerified);
    });
  });

  // ═══════════════════════════════════════════════════════
  // copyWith
  // ═══════════════════════════════════════════════════════
  group('UserModel.copyWith', () {
    late UserModel base;
    setUp(() => base = UserModel.fromJson(full));

    test('updates only the specified field', () {
      final u = base.copyWith(fullName: 'New Name');
      expect(u.fullName, 'New Name');
      expect(u.email,    base.email);
      expect(u.id,       base.id);
    });

    test('does not mutate the original instance', () {
      base.copyWith(fullName: 'Changed');
      expect(base.fullName, 'Fahdil Mochtar');
    });

    test('can update multiple fields at once', () {
      final u = base.copyWith(
          jobTitle: 'Senior Dev', company: 'NewCorp', xpPoints: 500);
      expect(u.jobTitle, 'Senior Dev');
      expect(u.company,  'NewCorp');
      expect(u.xpPoints, 500);
      expect(u.email,    base.email);
    });

    test('can update isEmailVerified flag', () {
      final u = UserModel.fromJson({'full_name': 'T', 'email': 'a@b.com'})
          .copyWith(isEmailVerified: true);
      expect(u.isEmailVerified, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════
  // initials getter
  // ═══════════════════════════════════════════════════════
  group('UserModel.initials', () {
    test('returns first letters of first and last name uppercased', () {
      final u = UserModel.fromJson(
          {'full_name': 'Fahdil Mochtar', 'email': 'f@e.com'});
      expect(u.initials, 'FM');
    });

    test('returns single letter for one-word name', () {
      expect(
        UserModel.fromJson({'full_name': 'Alice', 'email': 'a@e.com'})
            .initials,
        'A',
      );
    });

    test('uses only first two words when more than two given', () {
      expect(
        UserModel.fromJson({'full_name': 'John Paul Jones', 'email': 'j@e.com'})
            .initials,
        'JP',
      );
    });

    test('returns U fallback for empty fullName', () {
      expect(
        UserModel.fromJson({'full_name': '', 'email': 'a@b.com'}).initials,
        'U',
      );
    });

    test('always returns uppercase regardless of input case', () {
      expect(
        UserModel.fromJson({'full_name': 'john doe', 'email': 'j@e.com'})
            .initials,
        'JD',
      );
    });
  });

  // ═══════════════════════════════════════════════════════
  // xpLevel getter
  // ═══════════════════════════════════════════════════════
  group('UserModel.xpLevel', () {
    UserModel withXp(int xp) =>
        UserModel.fromJson({'full_name': 'T', 'email': 'a@b.com', 'xp_points': xp});

    test('Newcomer at 0 XP',    () => expect(withXp(0).xpLevel,    'Newcomer'));
    test('Explorer at 100 XP',  () => expect(withXp(100).xpLevel,  'Explorer'));
    test('Achiever at 300 XP',  () => expect(withXp(300).xpLevel,  'Achiever'));
    test('Professional at 600 XP', () => expect(withXp(600).xpLevel, 'Professional'));
    test('Expert at 1000 XP',   () => expect(withXp(1000).xpLevel, 'Expert'));
    test('Leader at 2000 XP',   () => expect(withXp(2000).xpLevel, 'Leader'));
    test('Champion at 5000 XP', () => expect(withXp(5000).xpLevel, 'Champion'));
  });
}
