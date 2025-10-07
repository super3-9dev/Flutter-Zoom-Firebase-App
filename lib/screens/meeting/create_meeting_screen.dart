import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/meeting_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Screen for creating new Zoom meetings (Teacher only)
class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.now().replacing(minute: 0);
  int _durationMinutes = 60;
  
  bool _enableWaitingRoom = true;
  bool _enableJoinBeforeHost = false;
  bool _muteUponEntry = true;
  bool _autoRecording = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meeting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Meeting Details Section
              _buildMeetingDetailsSection(),
              
              const SizedBox(height: 24),
              
              // Date and Time Section
              _buildDateTimeSection(),
              
              const SizedBox(height: 24),
              
              // Duration Section
              _buildDurationSection(),
              
              const SizedBox(height: 24),
              
              // Settings Section
              _buildSettingsSection(),
              
              const SizedBox(height: 32),
              
              // Create Button
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meeting Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _titleController,
              labelText: 'Meeting Title',
              hintText: 'Enter meeting title',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a meeting title';
                }
                if (value.length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Description (Optional)',
              hintText: 'Enter meeting description',
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _passwordController,
              labelText: 'Meeting Password (Optional)',
              hintText: 'Leave empty for auto-generated password',
              maxLength: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date & Time',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeSelector(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.textHintColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.textHintColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Meeting Duration: $_durationMinutes minutes',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: _durationMinutes,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _durationMinutes = value;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 30, child: Text('30 min')),
                    DropdownMenuItem(value: 60, child: Text('1 hour')),
                    DropdownMenuItem(value: 90, child: Text('1.5 hours')),
                    DropdownMenuItem(value: 120, child: Text('2 hours')),
                    DropdownMenuItem(value: 180, child: Text('3 hours')),
                    DropdownMenuItem(value: 240, child: Text('4 hours')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meeting Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSettingSwitch(
              title: 'Enable Waiting Room',
              subtitle: 'Participants wait in a virtual waiting room',
              value: _enableWaitingRoom,
              onChanged: (value) {
                setState(() {
                  _enableWaitingRoom = value;
                });
              },
            ),
            
            _buildSettingSwitch(
              title: 'Join Before Host',
              subtitle: 'Allow participants to join before the host',
              value: _enableJoinBeforeHost,
              onChanged: (value) {
                setState(() {
                  _enableJoinBeforeHost = value;
                });
              },
            ),
            
            _buildSettingSwitch(
              title: 'Mute Upon Entry',
              subtitle: 'Automatically mute participants when they join',
              value: _muteUponEntry,
              onChanged: (value) {
                setState(() {
                  _muteUponEntry = value;
                });
              },
            ),
            
            _buildSettingSwitch(
              title: 'Auto Recording',
              subtitle: 'Automatically record the meeting',
              value: _autoRecording,
              onChanged: (value) {
                setState(() {
                  _autoRecording = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.textSecondaryColor,
        ),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildCreateButton() {
    return Consumer<MeetingProvider>(
      builder: (context, meetingProvider, child) {
        return CustomButton(
          text: 'Create Meeting',
          onPressed: meetingProvider.isLoading
              ? null
              : _createMeeting,
          isLoading: meetingProvider.isLoading,
          icon: Icons.video_call,
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _createMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final meetingProvider = Provider.of<MeetingProvider>(context, listen: false);

    // Combine date and time
    final meetingDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Check if meeting time is in the future
    if (meetingDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting time must be in the future'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // For now, we'll use a default class ID
    // In a real app, you'd select from available classes
    const defaultClassId = 'default_class';

    final meeting = await meetingProvider.createMeeting(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      hostId: 'mock_host_id',
      hostName: 'Mock Host',
      startTime: meetingDateTime,
      endTime: meetingDateTime.add(Duration(minutes: _durationMinutes)),
    );

    if (meeting != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting created successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(meetingProvider.error ?? 'Failed to create meeting'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meeting Creation Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Meeting Settings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Waiting Room: Participants wait for host approval'),
              Text('• Join Before Host: Participants can join early'),
              Text('• Mute Upon Entry: Auto-mute new participants'),
              Text('• Auto Recording: Automatically record meetings'),
              SizedBox(height: 16),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Use descriptive titles for better organization'),
              Text('• Set passwords for private meetings'),
              Text('• Enable waiting room for better control'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
