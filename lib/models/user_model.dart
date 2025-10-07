import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing both teachers and students
class UserModel {
  final String id;
  final String email;
  final String? phoneNumber;
  final String displayName;
  final String? photoUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime lastSeen;
  final bool isOnline;
  final List<String> classIds; // For students: classes they're enrolled in
  final List<String> createdClassIds; // For teachers: classes they created

  const UserModel({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    required this.lastSeen,
    this.isOnline = false,
    this.classIds = const [],
    this.createdClassIds = const [],
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      displayName: data['displayName'] ?? 'User',
      photoUrl: data['photoUrl'],
      role: UserRole.fromString(data['role'] ?? 'student'),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      lastSeen: DateTime.parse(data['lastSeen'] ?? DateTime.now().toIso8601String()),
      isOnline: data['isOnline'] ?? false,
      classIds: List<String>.from(data['enrolledClassIds'] ?? []),
      createdClassIds: List<String>.from(data['createdClassIds'] ?? []),
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.toString(),
      'createdAt': createdAt.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
      'isOnline': isOnline,
      'enrolledClassIds': classIds, // For students
      'createdClassIds': createdClassIds, // For teachers
    };
  }


  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isOnline,
    List<String>? classIds,
    List<String>? createdClassIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      classIds: classIds ?? this.classIds,
      createdClassIds: createdClassIds ?? this.createdClassIds,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// User roles in the classroom system
enum UserRole {
  teacher,
  student;

  /// Convert string to UserRole
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
        return UserRole.teacher;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.student;
    }
  }

  /// Convert UserRole to string
  @override
  String toString() {
    switch (this) {
      case UserRole.teacher:
        return 'teacher';
      case UserRole.student:
        return 'student';
    }
  }

  /// Get display name for the role
  String get displayName {
    switch (this) {
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
    }
  }

  /// Check if user is a teacher
  bool get isTeacher => this == UserRole.teacher;

  /// Check if user is a student
  bool get isStudent => this == UserRole.student;
}
