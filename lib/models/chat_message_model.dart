/// Chat message model
class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType messageType;
  final String? replyToMessageId;
  final Map<String, dynamic>? metadata;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.messageType,
    this.replyToMessageId,
    this.metadata,
  });

  /// Create ChatMessageModel from Firestore document - Temporarily disabled
  factory ChatMessageModel.fromFirestore(dynamic doc) {
    // Mock implementation
    return ChatMessageModel(
      id: 'mock_id',
      senderId: 'mock_sender',
      senderName: 'Mock User',
      content: 'Mock message',
      timestamp: DateTime.now(),
      messageType: MessageType.text,
    );
  }

  /// Convert ChatMessageModel to Firestore document - Temporarily disabled
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType.toString(),
      'replyToMessageId': replyToMessageId,
      'metadata': metadata,
    };
  }

  /// Create a copy of ChatMessageModel with updated fields
  ChatMessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    MessageType? messageType,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, senderId: $senderId, content: $content, timestamp: $timestamp)';
  }
}

/// Message types
enum MessageType {
  text,
  image,
  file,
  audio,
  video,
  meeting,
  system,
}

extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.image:
        return 'Image';
      case MessageType.file:
        return 'File';
      case MessageType.audio:
        return 'Audio';
      case MessageType.video:
        return 'Video';
      case MessageType.meeting:
        return 'Meeting';
      case MessageType.system:
        return 'System';
    }
  }
}