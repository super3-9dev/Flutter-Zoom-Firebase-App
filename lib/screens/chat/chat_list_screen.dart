import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';

/// Screen for displaying chat conversations
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchField(
              controller: _searchController,
              hintText: 'Search conversations...',
            ),
          ),
          
          // Chat List
          Expanded(
            child: _buildChatList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // For now, we'll show a placeholder since we don't have class management yet
        return _buildPlaceholderChatList();
      },
    );
  }

  Widget _buildPlaceholderChatList() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildChatCard(
          title: 'Classroom Chat',
          subtitle: 'General classroom discussions',
          lastMessage: 'Welcome to the classroom!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          unreadCount: 3,
          isOnline: true,
        ),
        _buildChatCard(
          title: 'Math Class',
          subtitle: 'Mathematics discussions and homework help',
          lastMessage: 'Can someone help with the algebra problem?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          unreadCount: 1,
          isOnline: false,
        ),
        _buildChatCard(
          title: 'Science Lab',
          subtitle: 'Science experiments and lab reports',
          lastMessage: 'The experiment results are ready!',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          unreadCount: 0,
          isOnline: false,
        ),
        _buildChatCard(
          title: 'Study Group',
          subtitle: 'Collaborative study sessions',
          lastMessage: 'Meeting tomorrow at 3 PM',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          unreadCount: 0,
          isOnline: true,
        ),
      ],
    );
  }

  Widget _buildChatCard({
    required String title,
    required String subtitle,
    required String lastMessage,
    required DateTime timestamp,
    required int unreadCount,
    required bool isOnline,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                title[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lastMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTimestamp(timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          _openChat(title);
        },
      ),
    );
  }

  void _openChat(String chatTitle) {
    // TODO: Navigate to chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat: $chatTitle'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
