import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/course.dart';
import '../models/meeting.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  // Headers for all requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Add authentication header when needed
    // 'Authorization': 'Bearer ${AuthService().token}',
  };

  // Health check
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.health}'),
            headers: _headers,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Health check failed: $e');
    }
  }

  // Get all live courses
  Future<ApiResponse<List<Course>>> getLiveCourses() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.liveCourses}'),
            headers: _headers,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle different response formats
        List<dynamic> coursesData;
        if (data is Map && data.containsKey('data')) {
          coursesData = data['data'] as List<dynamic>;
        } else if (data is List) {
          coursesData = data;
        } else {
          coursesData = [];
        }
        print("course ${coursesData}");
        final courses = coursesData
            .map<Course>((courseJson) => Course.fromJson(courseJson as Map<String, dynamic>))
            .toList();


        return ApiResponse.success(courses);
      } else {
        return ApiResponse.error('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Failed to load courses: $e');
    }
  }

  // Create a new meeting
  Future<ApiResponse<Meeting>> createMeeting({
    required String hostName,
    required String title,
    required String description,
  }) async {
    try {
      final requestBody = {
        'hostName': hostName,
        'title': title,
        'description': description,
      };

      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.meetings}'),
            headers: _headers,
            body: json.encode(requestBody),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final meeting = Meeting.fromJson(data as Map<String, dynamic>);
        return ApiResponse.success(meeting);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          errorData['error'] ?? 'Failed to create meeting: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to create meeting: $e');
    }
  }

  // Join a meeting
  Future<ApiResponse<Meeting>> joinMeeting({
    required String meetingCode,
    required String participantName,
  }) async {
    try {
      final requestBody = {
        'participantName': participantName,
      };

      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.meetings}/$meetingCode/join'),
            headers: _headers,
            body: json.encode(requestBody),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meeting = Meeting.fromJson(data as Map<String, dynamic>);
        return ApiResponse.success(meeting);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          errorData['error'] ?? 'Failed to join meeting: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to join meeting: $e');
    }
  }

  // Leave a meeting
  Future<ApiResponse<void>> leaveMeeting({
    required String meetingCode,
    required String participantId,
  }) async {
    try {
      final requestBody = {
        'participantId': participantId,
      };

      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.meetings}/$meetingCode/leave'),
            headers: _headers,
            body: json.encode(requestBody),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          errorData['error'] ?? 'Failed to leave meeting: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to leave meeting: $e');
    }
  }

  // Get meeting details
  Future<ApiResponse<Meeting>> getMeeting(String meetingCode) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.meetings}/$meetingCode'),
            headers: _headers,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meeting = Meeting.fromJson(data as Map<String, dynamic>);
        return ApiResponse.success(meeting);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          errorData['error'] ?? 'Failed to get meeting: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to get meeting: $e');
    }
  }

  // Send chat message
  Future<ApiResponse<void>> sendChatMessage({
    required String meetingCode,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    try {
      final requestBody = {
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
      };

      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.meetings}/$meetingCode/chat'),
            headers: _headers,
            body: json.encode(requestBody),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          errorData['error'] ?? 'Failed to send message: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to send message: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}