// lib/features/auth/data/models/user_model.dart

class UserModel {
  final int?    id;
  final String  fullName;
  final String  email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final String? bio;
  final String? jobTitle;
  final String? company;
  final String? location;
  final String? website;
  final String? linkedinUrl;
  final String? githubUrl;
  final bool    isEmailVerified;
  final String  role;
  final int     xpPoints;
  final DateTime? createdAt;

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.profileImageUrl,
    this.coverImageUrl,
    this.bio,
    this.jobTitle,
    this.company,
    this.location,
    this.website,
    this.linkedinUrl,
    this.githubUrl,
    this.isEmailVerified = false,
    this.role = 'user',
    this.xpPoints = 0,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id:               j['id'],
    fullName:         j['full_name']          ?? '',
    email:            j['email']              ?? '',
    phone:            j['phone'],
    dateOfBirth:      j['date_of_birth'],
    gender:           j['gender'],
    profileImageUrl:  j['profile_image_url'],
    coverImageUrl:    j['cover_image_url'],
    bio:              j['bio'],
    jobTitle:         j['job_title'],
    company:          j['company'],
    location:         j['location'],
    website:          j['website'],
    linkedinUrl:      j['linkedin_url'],
    githubUrl:        j['github_url'],
    isEmailVerified:  j['is_email_verified'] == true || j['is_email_verified'] == 1,
    role:             j['role'] ?? 'user',
    xpPoints:         j['xp_points'] ?? 0,
    createdAt:        j['created_at'] != null
                          ? DateTime.tryParse(j['created_at'].toString())
                          : null,
  );

  Map<String, dynamic> toJson() => {
    'id':                id,
    'full_name':         fullName,
    'email':             email,
    'phone':             phone,
    'date_of_birth':     dateOfBirth,
    'gender':            gender,
    'profile_image_url': profileImageUrl,
    'cover_image_url':   coverImageUrl,
    'bio':               bio,
    'job_title':         jobTitle,
    'company':           company,
    'location':          location,
    'website':           website,
    'linkedin_url':      linkedinUrl,
    'github_url':        githubUrl,
    'is_email_verified': isEmailVerified,
    'role':              role,
    'xp_points':         xpPoints,
    'created_at':        createdAt?.toIso8601String(),
  };

  UserModel copyWith({
    int? id, String? fullName, String? email, String? phone,
    String? dateOfBirth, String? gender, String? profileImageUrl,
    String? coverImageUrl, String? bio, String? jobTitle,
    String? company, String? location, String? website,
    String? linkedinUrl, String? githubUrl,
    bool? isEmailVerified, String? role, int? xpPoints,
  }) => UserModel(
    id:               id               ?? this.id,
    fullName:         fullName         ?? this.fullName,
    email:            email            ?? this.email,
    phone:            phone            ?? this.phone,
    dateOfBirth:      dateOfBirth      ?? this.dateOfBirth,
    gender:           gender           ?? this.gender,
    profileImageUrl:  profileImageUrl  ?? this.profileImageUrl,
    coverImageUrl:    coverImageUrl    ?? this.coverImageUrl,
    bio:              bio              ?? this.bio,
    jobTitle:         jobTitle         ?? this.jobTitle,
    company:          company          ?? this.company,
    location:         location         ?? this.location,
    website:          website          ?? this.website,
    linkedinUrl:      linkedinUrl      ?? this.linkedinUrl,
    githubUrl:        githubUrl        ?? this.githubUrl,
    isEmailVerified:  isEmailVerified  ?? this.isEmailVerified,
    role:             role             ?? this.role,
    xpPoints:         xpPoints         ?? this.xpPoints,
    createdAt:        createdAt,
  );

  String get initials {
    final p = fullName.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return p.isNotEmpty && p[0].isNotEmpty ? p[0][0].toUpperCase() : 'U';
  }

  String get xpLevel {
    if (xpPoints >= 5000) return 'Champion';
    if (xpPoints >= 2000) return 'Leader';
    if (xpPoints >= 1000) return 'Expert';
    if (xpPoints >= 600)  return 'Professional';
    if (xpPoints >= 300)  return 'Achiever';
    if (xpPoints >= 100)  return 'Explorer';
    return 'Newcomer';
  }
}
