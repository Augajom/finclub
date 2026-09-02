/// User entity representing authenticated member
class UserEntity {
  final int id;
  final String email;
  final String? avatarUrl;
  final bool hasAcceptedTerms;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.avatarUrl,
    required this.hasAcceptedTerms,
    this.createdAt,
  });

  /// Formatted avatar URL safe for both desktop and Android emulator
  String? get formattedAvatarUrl {
    if (avatarUrl == null || avatarUrl!.isEmpty) return null;
    return avatarUrl!.replaceAll('localhost', '10.0.2.2');
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is num) return val != 0;
      if (val is String) return val.toLowerCase() == 'true' || val == '1';
      return false;
    }

    return UserEntity(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      hasAcceptedTerms: parseBool(json['has_accepted_terms']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'avatar_url': avatarUrl,
      'has_accepted_terms': hasAcceptedTerms,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserEntity copyWith({
    int? id,
    String? email,
    String? avatarUrl,
    bool? hasAcceptedTerms,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasAcceptedTerms: hasAcceptedTerms ?? this.hasAcceptedTerms,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
