// Temporarily disabled Firebase imports
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_message_model.dart';

/// Chat service for handling real-time messaging
/// Temporarily disabled - using mock implementation
class ChatService {
  // Temporarily disabled Firebase instances
  // static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send a text message - Mock implementation
  static Future<void> sendTextMessage({
    required String content,
    required String classId,
    String? meetingId,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Send a meeting invite message - Mock implementation
  static Future<void> sendMeetingInviteMessage({
    required String classId,
    required String meetingId,
    required String meetingTitle,
    required String joinUrl,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Send a system message - Mock implementation
  static Future<void> sendSystemMessage({
    required String content,
    required String classId,
    Map<String, dynamic>? metadata,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Get chat messages stream for a class - Mock implementation
  static Stream<List<ChatMessageModel>> getChatMessagesStream(String classId) {
    // Mock implementation
    return Stream.value([]);
  }

  /// Get chat messages stream for a meeting - Mock implementation
  static Stream<List<ChatMessageModel>> getMeetingMessagesStream(String meetingId) {
    // Mock implementation
    return Stream.value([]);
  }

  /// Mark message as read - Mock implementation
  static Future<void> markMessageAsRead(String messageId) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Mark all messages in a class as read - Mock implementation
  static Future<void> markAllMessagesAsRead(String classId) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Delete a message - Mock implementation
  static Future<void> deleteMessage(String messageId) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Get unread message count for a class - Mock implementation
  static Stream<int> getUnreadMessageCount(String classId) {
    // Mock implementation
    return Stream.value(0);
  }

  /// Get unread message count for all classes - Mock implementation
  static Stream<int> getTotalUnreadMessageCount() {
    // Mock implementation
    return Stream.value(0);
  }

  /// Search messages in a class - Mock implementation
  static Future<List<ChatMessageModel>> searchMessages({
    required String classId,
    required String query,
    int limit = 50,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  /// Get message by ID - Mock implementation
  static Future<ChatMessageModel?> getMessageById(String messageId) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }
}
