import 'package:flutter/material.dart';

import '../models/meeting_model.dart';

/// Meeting provider for managing meeting state
class MeetingProvider with ChangeNotifier {
  List<MeetingModel> _meetings = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MeetingModel> get meetings => _meetings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Computed getters
  List<MeetingModel> get upcomingMeetings {
    final now = DateTime.now();
    return _meetings.where((meeting) => meeting.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  
  List<MeetingModel> get liveMeetings {
    final now = DateTime.now();
    return _meetings.where((meeting) => 
      meeting.isActive && 
      now.isAfter(meeting.startTime) && 
      now.isBefore(meeting.endTime)
    ).toList();
  }
  
  List<MeetingModel> get userMeetings {
    // For now, return all meetings. In a real app, this would filter by current user
    return _meetings;
  }

  /// Initialize meeting provider
  MeetingProvider() {
    _initializeMeetings();
  }

  /// Initialize meetings with mock data
  void _initializeMeetings() {
    // Add some mock meetings for testing
    _meetings = [
      MeetingModel(
        id: '1',
        title: 'Math Class',
        description: 'Algebra basics',
        hostId: 'teacher1',
        hostName: 'Teacher',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        meetingId: '123456789',
        meetingPassword: '123456',
        isActive: false,
        participantIds: ['student1', 'student2'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MeetingModel(
        id: '2',
        title: 'Science Class',
        description: 'Physics fundamentals',
        hostId: 'teacher1',
        hostName: 'Teacher',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
        meetingId: '987654321',
        meetingPassword: '654321',
        isActive: false,
        participantIds: ['student1', 'student2', 'student3'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    notifyListeners();
  }

  /// Create a new meeting - Mock implementation
  Future<MeetingModel?> createMeeting({
    required String title,
    required String description,
    required String hostId,
    required String hostName,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final meeting = MeetingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      hostId: hostId,
      hostName: hostName,
      startTime: startTime,
      endTime: endTime,
      meetingId: _generateMeetingId(),
      meetingPassword: _generatePassword(),
      isActive: false,
      participantIds: [hostId],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _meetings.add(meeting);
    _setLoading(false);
    notifyListeners();
    return meeting;
  }

  /// Join a meeting - Mock implementation
  Future<bool> joinMeeting(String meetingId, String userId) async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final meetingIndex = _meetings.indexWhere((m) => m.id == meetingId);
    if (meetingIndex != -1) {
      final meeting = _meetings[meetingIndex];
      if (!meeting.participantIds.contains(userId)) {
        _meetings[meetingIndex] = meeting.copyWith(
          participantIds: [...meeting.participantIds, userId],
          updatedAt: DateTime.now(),
        );
      }
      _setLoading(false);
      notifyListeners();
      return true;
    }
    
    _setLoading(false);
    return false;
  }

  /// Start a meeting - Mock implementation
  Future<bool> startMeeting(String meetingId) async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final meetingIndex = _meetings.indexWhere((m) => m.id == meetingId);
    if (meetingIndex != -1) {
      _meetings[meetingIndex] = _meetings[meetingIndex].copyWith(
        isActive: true,
        updatedAt: DateTime.now(),
      );
      _setLoading(false);
      notifyListeners();
      return true;
    }
    
    _setLoading(false);
    return false;
  }

  /// End a meeting - Mock implementation
  Future<bool> endMeeting(String meetingId) async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final meetingIndex = _meetings.indexWhere((m) => m.id == meetingId);
    if (meetingIndex != -1) {
      _meetings[meetingIndex] = _meetings[meetingIndex].copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      _setLoading(false);
      notifyListeners();
      return true;
    }
    
    _setLoading(false);
    return false;
  }

  /// Load meetings - Mock implementation
  Future<void> loadMeetings() async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    _setLoading(false);
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  String _generateMeetingId() {
    return (100000000 + DateTime.now().millisecondsSinceEpoch % 900000000).toString();
  }

  String _generatePassword() {
    return (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
  }
}