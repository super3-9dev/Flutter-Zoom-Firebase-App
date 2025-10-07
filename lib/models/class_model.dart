/// Class model
class ClassModel {
  final String id;
  final String name;
  final String description;
  final String teacherId;
  final String teacherName;
  final List<String> studentIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const ClassModel({
    required this.id,
    required this.name,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    required this.studentIds,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Create ClassModel from Firestore document - Temporarily disabled
  factory ClassModel.fromFirestore(dynamic doc) {
    // Mock implementation
    return ClassModel(
      id: 'mock_id',
      name: 'Mock Class',
      description: 'Mock description',
      teacherId: 'mock_teacher',
      teacherName: 'Mock Teacher',
      studentIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Convert ClassModel to Firestore document - Temporarily disabled
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'studentIds': studentIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy of ClassModel with updated fields
  ClassModel copyWith({
    String? id,
    String? name,
    String? description,
    String? teacherId,
    String? teacherName,
    List<String>? studentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      studentIds: studentIds ?? this.studentIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get student count
  int get studentCount {
    return studentIds.length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ClassModel(id: $id, name: $name, teacherName: $teacherName, studentCount: $studentCount)';
  }
}