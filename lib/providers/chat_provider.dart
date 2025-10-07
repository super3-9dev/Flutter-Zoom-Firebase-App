import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';

/// Chat provider for managing chat state
class ChatProvider with ChangeNotifier {
  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize chat provider
  ChatProvider() {
    _initializeChat();
  }

  /// Initialize chat with mock data
  void _initializeChat() {
    // Add some mock messages for testing
    _messages = [
      ChatMessageModel(
        id: '1',
        senderId: 'teacher1',
        senderName: 'Teacher',
        content: 'Welcome to the class!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        messageType: MessageType.text,
      ),
      ChatMessageModel(
        id: '2',
        senderId: 'student1',
        senderName: 'Student',
        content: 'Thank you for the welcome!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        messageType: MessageType.text,
      ),
    ];
    notifyListeners();
  }

  /// Send a message - Mock implementation
  Future<void> sendMessage({
    required String content,
    required String senderId,
    required String senderName,
    MessageType messageType = MessageType.text,
  }) async {
    _setLoading(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final message = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
      messageType: messageType,
    );
    
    _messages.add(message);
    _setLoading(false);
    notifyListeners();
  }

  /// Load messages - Mock implementation
  Future<void> loadMessages() async {
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
}