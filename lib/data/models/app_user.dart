import 'package:ghar_bazaar/data/models/enums.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.phone,
    this.isOnboarded = false,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? photoUrl;
  final String? phone;
  final bool isOnboarded;
  final DateTime createdAt;

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    String? photoUrl,
    String? phone,
    bool? isOnboarded,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.value,
      'photoUrl': photoUrl,
      'phone': phone,
      'isOnboarded': isOnboarded,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: userRoleFromValue(map['role'] as String?),
      photoUrl: map['photoUrl'] as String?,
      phone: map['phone'] as String?,
      isOnboarded: map['isOnboarded'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
