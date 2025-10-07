import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/meeting_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Screen for displaying and managing meetings
class MeetingListScreen extends StatefulWidget {
  const MeetingListScreen({super.key});

  @override
  State<MeetingListScreen> createState() => _MeetingListScreenState();
}

class _MeetingListScreenState extends State<MeetingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: const Text('Meetings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Live'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchField(
              controller: _searchController,
              hintText: 'Search meetings...',
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingMeetings(),
                _buildLiveMeetings(),
                _buildPastMeetings(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMeetings() {
    return Consumer<MeetingProvider>(
      builder: (context, meetingProvider, child) {
        if (meetingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final meetings = meetingProvider.upcomingMeetings
            .where((meeting) => _matchesSearch(meeting))
            .toList();

        if (meetings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.schedule,
            title: 'No Upcoming Meetings',
            subtitle: 'Your upcoming meetings will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            final meeting = meetings[index];
            return _buildMeetingCard(meeting, isUpcoming: true);
          },
        );
      },
    );
  }

  Widget _buildLiveMeetings() {
    return Consumer<MeetingProvider>(
      builder: (context, meetingProvider, child) {
        if (meetingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final meetings = meetingProvider.liveMeetings
            .where((meeting) => _matchesSearch(meeting))
            .toList();

        if (meetings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.live_tv,
            title: 'No Live Meetings',
            subtitle: 'Live meetings will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            final meeting = meetings[index];
            return _buildMeetingCard(meeting, isLive: true);
          },
        );
      },
    );
  }

  Widget _buildPastMeetings() {
    return Consumer<MeetingProvider>(
      builder: (context, meetingProvider, child) {
        if (meetingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final meetings = meetingProvider.userMeetings
            .where((meeting) => 
                meeting.isEnded && _matchesSearch(meeting))
            .toList();

        if (meetings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            title: 'No Past Meetings',
            subtitle: 'Your past meetings will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            final meeting = meetings[index];
            return _buildMeetingCard(meeting, isPast: true);
          },
        );
      },
    );
  }

  Widget _buildMeetingCard(dynamic meeting, {
    bool isUpcoming = false,
    bool isLive = false,
    bool isPast = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showMeetingDetails(meeting),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getMeetingColor(isUpcoming, isLive, isPast),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      _getMeetingIcon(isUpcoming, isLive, isPast),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meeting.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meeting.hostName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              if (meeting.description.isNotEmpty) ...[
                Text(
                  meeting.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              
              // Details
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatMeetingTime(meeting.startTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.timer,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${meeting.duration.inMinutes} min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Actions
              Row(
                children: [
                  if (isUpcoming || isLive) ...[
                    Expanded(
                      child: CustomButton(
                        text: isLive ? 'Join Now' : 'Join Meeting',
                        onPressed: () => _joinMeeting(meeting),
                        icon: Icons.video_call,
                        height: 36,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (isUpcoming) ...[
                    Expanded(
                      child: CustomButton(
                        text: 'Details',
                        onPressed: () => _showMeetingDetails(meeting),
                        backgroundColor: Colors.transparent,
                        textColor: AppTheme.primaryColor,
                        borderColor: AppTheme.primaryColor,
                        height: 36,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textHintColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textHintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getMeetingColor(bool isUpcoming, bool isLive, bool isPast) {
    if (isLive) return Colors.red;
    if (isUpcoming) return AppTheme.primaryColor;
    return AppTheme.textSecondaryColor;
  }

  IconData _getMeetingIcon(bool isUpcoming, bool isLive, bool isPast) {
    if (isLive) return Icons.live_tv;
    if (isUpcoming) return Icons.schedule;
    return Icons.history;
  }

  bool _matchesSearch(dynamic meeting) {
    if (_searchQuery.isEmpty) return true;
    
    return meeting.title.toLowerCase().contains(_searchQuery) ||
           meeting.description.toLowerCase().contains(_searchQuery) ||
           meeting.hostName.toLowerCase().contains(_searchQuery);
  }

  void _joinMeeting(dynamic meeting) {
    // TODO: Implement meeting join functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining meeting: ${meeting.title}'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showMeetingDetails(dynamic meeting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(meeting.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (meeting.description.isNotEmpty) ...[
                Text(
                  'Description:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(meeting.description),
                const SizedBox(height: 16),
              ],
              Text(
                'Host: ${meeting.hostName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Start Time: ${_formatMeetingTime(meeting.startTime)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: ${meeting.duration.inMinutes} minutes',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${meeting.isActive ? "Active" : "Inactive"}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (meeting.isActive || meeting.isScheduled)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _joinMeeting(meeting);
              },
              child: const Text('Join'),
            ),
        ],
      ),
    );
  }

  String _formatMeetingTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final meetingDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (meetingDate == today) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (meetingDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow at ${_formatTime(dateTime)}';
    } else {
      return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }
}
