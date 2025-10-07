import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


/// Zoom service for creating and managing Zoom meetings
class ZoomService {
  static const String _baseUrl = 'https://api.zoom.us/v2';
  static const String _tokenUrl = 'https://zoom.us/oauth/token';
  
  // Zoom OAuth credentials - these should be stored securely
  static const String _clientId = 'hAglAZ46TCWBsYxSzhIJMQ'; // Replace with actual credentials
  static const String _clientSecret = 'v8QveCeVhgo21M1qAip5Wu2YKoqVKhv2'; // Replace with actual credentials
  static const String _accountId = 'MXXZau72QbCOcOC-waZlrA'; // Replace with actual credentials
  
  /// Check if Zoom credentials are configured
  static bool get isConfigured => 
      _clientId != 'hAglAZ46TCWBsYxSzhIJMQ' && 
      _clientSecret != 'v8QveCeVhgo21M1qAip5Wu2YKoqVKhv2' && 
      _accountId != 'MXXZau72QbCOcOC-waZlrA';
  
  static String? _accessToken;
  static DateTime? _tokenExpiry;

  /// Initialize Zoom service
  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint('Warning: Zoom credentials not configured. Please update lib/services/zoom_service.dart with your actual Zoom API credentials.');
      return;
    }
    
    await _loadStoredToken();
    if (_accessToken == null || _isTokenExpired()) {
      await _refreshAccessToken();
    }
  }

  /// Create a new Zoom meeting
  static Future<Map<String, dynamic>> createMeeting({
    required String topic,
    required String description,
    required DateTime startTime,
    required int durationMinutes,
    String? password,
    bool enableWaitingRoom = true,
    bool enableJoinBeforeHost = false,
    bool muteUponEntry = true,
    bool autoRecording = false,
  }) async {
    try {
      if (!isConfigured) {
        return {
          'success': false,
          'error': 'Zoom credentials not configured. Please update the Zoom service configuration.',
        };
      }
      
      await _ensureValidToken();

      final meetingData = {
        'topic': topic,
        'type': 2, // Scheduled meeting
        'start_time': startTime.toUtc().toIso8601String(),
        'duration': durationMinutes,
        'timezone': 'UTC',
        'password': password ?? _generateMeetingPassword(),
        'settings': {
          'host_video': true,
          'participant_video': true,
          'cn_meeting': false,
          'in_meeting': false,
          'join_before_host': enableJoinBeforeHost,
          'mute_upon_entry': muteUponEntry,
          'watermark': false,
          'use_pmi': false,
          'approval_type': 0,
          'audio': 'both',
          'auto_recording': autoRecording ? 'cloud' : 'none',
          'waiting_room': enableWaitingRoom,
          'registrants_confirmation_email': false,
        },
        'agenda': description,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/users/me/meetings'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(meetingData),
      );

      if (response.statusCode == 201) {
        final meetingInfo = jsonDecode(response.body);
        return {
          'success': true,
          'meeting': meetingInfo,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Failed to create meeting',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Get meeting details
  static Future<Map<String, dynamic>> getMeeting(String meetingId) async {
    try {
      await _ensureValidToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/meetings/$meetingId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final meetingInfo = jsonDecode(response.body);
        return {
          'success': true,
          'meeting': meetingInfo,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Failed to get meeting',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Update meeting details
  static Future<Map<String, dynamic>> updateMeeting({
    required String meetingId,
    String? topic,
    String? description,
    DateTime? startTime,
    int? durationMinutes,
    String? password,
    Map<String, dynamic>? settings,
  }) async {
    try {
      await _ensureValidToken();

      final updateData = <String, dynamic>{};
      if (topic != null) updateData['topic'] = topic;
      if (description != null) updateData['agenda'] = description;
      if (startTime != null) updateData['start_time'] = startTime.toUtc().toIso8601String();
      if (durationMinutes != null) updateData['duration'] = durationMinutes;
      if (password != null) updateData['password'] = password;
      if (settings != null) updateData['settings'] = settings;

      final response = await http.patch(
        Uri.parse('$_baseUrl/meetings/$meetingId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 204) {
        return {'success': true};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Failed to update meeting',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Delete a meeting
  static Future<Map<String, dynamic>> deleteMeeting(String meetingId) async {
    try {
      await _ensureValidToken();

      final response = await http.delete(
        Uri.parse('$_baseUrl/meetings/$meetingId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return {'success': true};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Failed to delete meeting',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// List user's meetings
  static Future<Map<String, dynamic>> listMeetings({
    String type = 'upcoming',
    int pageSize = 30,
    String? nextPageToken,
  }) async {
    try {
      await _ensureValidToken();

      final queryParams = <String, String>{
        'type': type,
        'page_size': pageSize.toString(),
      };
      if (nextPageToken != null) {
        queryParams['next_page_token'] = nextPageToken;
      }

      final uri = Uri.parse('$_baseUrl/users/me/meetings').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final meetingsInfo = jsonDecode(response.body);
        return {
          'success': true,
          'meetings': meetingsInfo,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Failed to list meetings',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Refresh access token
  static Future<void> _refreshAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'account_credentials',
          'account_id': _accountId,
        },
      );

      if (response.statusCode == 200) {
        final tokenData = jsonDecode(response.body);
        _accessToken = tokenData['access_token'];
        _tokenExpiry = DateTime.now().add(
          Duration(seconds: tokenData['expires_in']),
        );
        
        // Store token locally
        await _storeToken();
      } else {
        throw Exception('Failed to refresh access token');
      }
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  /// Ensure we have a valid access token
  static Future<void> _ensureValidToken() async {
    if (_accessToken == null || _isTokenExpired()) {
      await _refreshAccessToken();
    }
  }

  /// Check if token is expired
  static bool _isTokenExpired() {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!.subtract(const Duration(minutes: 5)));
  }

  /// Store token locally
  static Future<void> _storeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zoom_access_token', _accessToken ?? '');
    await prefs.setString('zoom_token_expiry', _tokenExpiry?.toIso8601String() ?? '');
  }

  /// Load stored token
  static Future<void> _loadStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('zoom_access_token');
    final expiryString = prefs.getString('zoom_token_expiry');
    if (expiryString != null) {
      _tokenExpiry = DateTime.parse(expiryString);
    }
  }

  /// Generate a random meeting password
  static String _generateMeetingPassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final password = StringBuffer();
    
    for (int i = 0; i < 6; i++) {
      password.write(chars[random % chars.length]);
    }
    
    return password.toString();
  }

  /// Get meeting join URL for students
  static String getMeetingJoinUrl(String meetingId, String password) {
    return 'https://zoom.us/j/$meetingId?pwd=$password';
  }

  /// Check if meeting is currently active
  static Future<bool> isMeetingActive(String meetingId) async {
    try {
      final result = await getMeeting(meetingId);
      if (result['success']) {
        final meeting = result['meeting'];
        final startTime = DateTime.parse(meeting['start_time']);
        final duration = meeting['duration'];
        final endTime = startTime.add(Duration(minutes: duration));
        final now = DateTime.now().toUtc();
        
        return now.isAfter(startTime) && now.isBefore(endTime);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
