/// Meeting model
class MeetingModel {
  final String id;
  final String title;
  final String description;
  final String hostId;
  final String hostName;
  final DateTime startTime;
  final DateTime endTime;
  final String meetingId;
  final String meetingPassword;
  final bool isActive;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const MeetingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.hostId,
    required this.hostName,
    required this.startTime,
    required this.endTime,
    required this.meetingId,
    required this.meetingPassword,
    required this.isActive,
    required this.participantIds,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Create MeetingModel from Firestore document - Temporarily disabled
  factory MeetingModel.fromFirestore(dynamic doc) {
    // Mock implementation
    return MeetingModel(
      id: 'mock_id',
      title: 'Mock Meeting',
      description: 'Mock description',
      hostId: 'mock_host',
      hostName: 'Mock Host',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      meetingId: '123456789',
      meetingPassword: '123456',
      isActive: false,
      participantIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Convert MeetingModel to Firestore document - Temporarily disabled
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'hostId': hostId,
      'hostName': hostName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'meetingId': meetingId,
      'meetingPassword': meetingPassword,
      'isActive': isActive,
      'participantIds': participantIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy of MeetingModel with updated fields
  MeetingModel copyWith({
    String? id,
    String? title,
    String? description,
    String? hostId,
    String? hostName,
    DateTime? startTime,
    DateTime? endTime,
    String? meetingId,
    String? meetingPassword,
    bool? isActive,
    List<String>? participantIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      meetingId: meetingId ?? this.meetingId,
      meetingPassword: meetingPassword ?? this.meetingPassword,
      isActive: isActive ?? this.isActive,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if meeting is currently active
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if meeting is upcoming
  bool get isUpcoming {
    return DateTime.now().isBefore(startTime);
  }

  /// Check if meeting has ended
  bool get hasEnded {
    return DateTime.now().isAfter(endTime);
  }

  /// Check if meeting has ended (alias for hasEnded)
  bool get isEnded {
    return DateTime.now().isAfter(endTime);
  }

  /// Get meeting duration
  Duration get duration {
    return endTime.difference(startTime);
  }

  /// Get participant count
  int get participantCount {
    return participantIds.length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MeetingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MeetingModel(id: $id, title: $title, startTime: $startTime, isActive: $isActive)';
  }
}