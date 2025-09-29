import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiBaseUrl = 'https://krishnabarasiya.space/api';

// Types for API responses
class LiveCourse {
  final String id;
  final String name;
  final String? description;
  final String instructorId;
  final String instructorName;
  final String category;
  final String status; // 'scheduled' | 'active' | 'completed'
  final String scheduledDateTime;
  final int duration;
  final List<String> enrolledUsers;
  final List<String>? joinedUsers;
  final bool recordingEnabled;
  final String? meetingCode;
  final String? meetingId;
  final String createdAt;
  final String updatedAt;

  LiveCourse({
    required this.id,
    required this.name,
    this.description,
    required this.instructorId,
    required this.instructorName,
    required this.category,
    required this.status,
    required this.scheduledDateTime,
    required this.duration,
    required this.enrolledUsers,
    this.joinedUsers,
    required this.recordingEnabled,
    this.meetingCode,
    this.meetingId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LiveCourse.fromJson(Map<String, dynamic> json) {
    return LiveCourse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      instructorId: json['instructorId'] ?? '',
      instructorName: json['instructorName'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'scheduled',
      scheduledDateTime: json['scheduledDateTime'] ?? '',
      duration: json['duration'] ?? 0,
      enrolledUsers: List<String>.from(json['enrolledUsers'] ?? []),
      joinedUsers: json['joinedUsers'] != null
          ? List<String>.from(json['joinedUsers'])
          : null,
      recordingEnabled: json['recordingEnabled'] ?? false,
      meetingCode: json['meetingCode'],
      meetingId: json['meetingId'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'category': category,
      'status': status,
      'scheduledDateTime': scheduledDateTime,
      'duration': duration,
      'enrolledUsers': enrolledUsers,
      'joinedUsers': joinedUsers,
      'recordingEnabled': recordingEnabled,
      'meetingCode': meetingCode,
      'meetingId': meetingId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Meeting {
  final String meetingCode;
  final String meetingId;
  final String hostName;
  final String hostId;
  final String? title;
  final String? description;
  final String createdAt;
  final String? status;

  Meeting({
    required this.meetingCode,
    required this.meetingId,
    required this.hostName,
    required this.hostId,
    this.title,
    this.description,
    required this.createdAt,
    this.status,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      meetingCode: json['meetingCode'] ?? '',
      meetingId: json['meetingId'] ?? '',
      hostName: json['hostName'] ?? '',
      hostId: json['hostId'] ?? '',
      title: json['title'],
      description: json['description'],
      createdAt: json['createdAt'] ?? '',
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meetingCode': meetingCode,
      'meetingId': meetingId,
      'hostName': hostName,
      'hostId': hostId,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'status': status,
    };
  }
}

class Participant {
  final String id;
  final String name;
  final String joinedAt;
  final bool? isHost;

  Participant({
    required this.id,
    required this.name,
    required this.joinedAt,
    this.isHost,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      joinedAt: json['joinedAt'] ?? '',
      isHost: json['isHost'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'joinedAt': joinedAt,
      'isHost': isHost,
    };
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T? Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      error: json['error'],
      message: json['message'],
    );
  }
}

class LiveCourseAPI {
  static const Duration timeout = Duration(seconds: 10);

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  // Create a new live course
  static Future<ApiResponse<LiveCourse>> createCourse({
    required String name,
    String? description,
    required String instructorId,
    required String instructorName,
    required String category,
    required int duration,
    String? scheduledDateTime,
    bool? recordingEnabled,
    List<String>? enrolledUsers,
  }) async {
    try {
      final courseData = {
        'name': name,
        'description': description,
        'instructorId': instructorId,
        'instructorName': instructorName,
        'category': category,
        'duration': duration,
        'scheduledDateTime': scheduledDateTime,
        'recordingEnabled': recordingEnabled,
        'enrolledUsers': enrolledUsers,
      };

      final response = await http.post(
        Uri.parse('$apiBaseUrl/live_courses'),
        headers: headers,
        body: json.encode(courseData),
      ).timeout(timeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<LiveCourse>(
          success: responseData['success'] ?? true,
          data: responseData['data'] != null
              ? LiveCourse.fromJson(responseData['data'])
              : null,
          message: responseData['message'],
        );
      } else {
        return ApiResponse<LiveCourse>(
          success: false,
          error: responseData['error'] ?? 'Failed to create course',
          message: responseData['message'] ?? 'Unknown error',
        );
      }
    } catch (error) {
      return ApiResponse<LiveCourse>(
        success: false,
        error: 'Failed to create course',
        message: error.toString(),
      );
    }
  }

  // Get all live courses
  static Future<ApiResponse<List<LiveCourse>>> getAllCourses() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/live_courses'),
        headers: headers,
      ).timeout(timeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<LiveCourse> courses = [];
        if (responseData['data'] != null) {
          for (var courseJson in responseData['data']) {
            courses.add(LiveCourse.fromJson(courseJson));
          }
        }

        return ApiResponse<List<LiveCourse>>(
          success: responseData['success'] ?? true,
          data: courses,
          message: responseData['message'],
        );
      } else {
        return ApiResponse<List<LiveCourse>>(
          success: false,
          error: responseData['error'] ?? 'Failed to get courses',
          message: responseData['message'] ?? 'Unknown error',
        );
      }
    } catch (error) {
      return ApiResponse<List<LiveCourse>>(
        success: false,
        error: 'Failed to get courses',
        message: error.toString(),
      );
    }
  }

  // Get live course by id
  static Future<ApiResponse<LiveCourse>> getCourseById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/live_courses/$id'),
        headers: headers,
      ).timeout(timeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<LiveCourse>(
          success: responseData['success'] ?? true,
          data: responseData['data'] != null
              ? LiveCourse.fromJson(responseData['data'])
              : null,
          message: responseData['message'],
        );
      } else {
        return ApiResponse<LiveCourse>(
          success: false,
          error: responseData['error'] ?? 'Failed to get course',
          message: responseData['message'] ?? 'Unknown error',
        );
      }
    } catch (error) {
      return ApiResponse<LiveCourse>(
        success: false,
        error: 'Failed to get course',
        message: error.toString(),
      );
    }
  }

  // Start a live course (creates meeting room automatically)
  static Future<ApiResponse<dynamic>> startCourse(
      String courseId, {
        String? instructorId,
        required String instructorName,
      }) async {
    try {
      final instructorData = {
        'instructorId': instructorId,
        'instructorName': instructorName,
      };

      final response = await http.put(
        Uri.parse('$apiBaseUrl/live_courses/$courseId/start'),
        headers: headers,
        body: json.encode(instructorData),
      ).timeout(timeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<dynamic>(
          success: responseData['success'] ?? true,
          data: responseData['data'],
          message: responseData['message'],
        );
      } else {
        return ApiResponse<dynamic>(
          success: false,
          error: responseData['error'] ?? 'Failed to start course',
          message: responseData['message'] ?? 'Unknown error',
        );
      }
    } catch (error) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to start course',
        message: error.toString(),
      );
    }
  }

  // Complete a live course (stops recording and ends meeting)
  static Future<ApiResponse<dynamic>> completeCourse(String courseId) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/live_courses/$courseId/complete'),
        headers: headers,
      ).timeout(timeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<dynamic>(
          success: responseData['success'] ?? true,
          data: responseData['data'],
          message: responseData['message'],
        );
      } else {
        return ApiResponse<dynamic>(
          success: false,
          error: responseData['error'] ?? 'Failed to complete course',
          message: responseData['message'] ?? 'Unknown error',
        );
      }
    } catch (error) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to complete course',
        message: error.toString(),
      );
    }
  }

  // Join a user to a live course
  static Future<ApiResponse<dynamic>> joinCourse(
      String courseId, {
        required String userId,
        required String userName,
      }) async {
    try {
      final participantData = {
        'userId': userId,
        'userName': userName,
      };

      final response = await http.put(
        Uri.parse('$apiBaseUrl/live_courses/$courseId/join'),
        headers: headers,
        body: json.encode(participantData),
      ).timeout(timeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<dynamic>(
          success: responseData['success'] ?? true,
          data: responseData['data'],
          message: responseData['message'],
        );
      } else {
        return ApiResponse<dynamic>(
          success: false,
          error: responseData['error'] ?? 'Failed to join course',
          message: responseData['message'] ?? 'Unknown error',
        );
      }
    } catch (error) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to join course',
        message: error.toString(),
      );
    }
  }

  // Leave a live course
  static Future<ApiResponse<dynamic>> leaveCourse(
      String courseId, {
        required String userId,
      }) async {
    try {
      final participantData = {
        'userId': userId,
      };

      final response = await http.put(
        Uri.parse('$apiBaseUrl/live_courses/$courseId/leave'),
        headers: headers,
        body: json.encode(participantData),
      ).timeout(timeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<dynamic>(
          success: responseData['success'] ?? true,
          data: responseData['data'],
          message: responseData['message'],
        );
      } else {
        return ApiResponse<dynamic>(
          success: false,
          error: responseData['error'] ?? 'Failed to leave course',
          message: responseData['message'] ?? 'Unknown error',
        );
      }
    } catch (error) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to leave course',
        message: error.toString(),
      );
    }
  }

  // Get recording status for a course
  static Future<ApiResponse<dynamic>> getRecordingStatus(String courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/live_courses/$courseId/recording'),
        headers: headers,
      ).timeout(timeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<dynamic>(
          success: responseData['success'] ?? true,
          data: responseData['data'],
          message: responseData['message'],
        );
      } else {
        return ApiResponse<dynamic>(
          success: false,
          error: responseData['error'] ?? 'Failed to get recording status',
          message: responseData['message'] ?? 'Unknown error',
        );
      }
    } catch (error) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to get recording status',
        message: error.toString(),
      );
    }
  }
}

// Keep MeetingAPI for backward compatibility but mark as deprecated
class MeetingAPI {
  // Note: These functions are deprecated. Use LiveCourseAPI instead.
  // Meeting rooms are now created automatically when starting live courses.

  static Future<ApiResponse<Meeting>> createMeeting({
    required String hostName,
    String? title,
    String? description,
  }) async {
    print('⚠️ meetingAPI.createMeeting is deprecated. Use LiveCourseAPI.startCourse instead.');
    return ApiResponse<Meeting>(
      success: false,
      error: 'Deprecated API',
      message: 'Meeting creation is now handled through live courses. Use LiveCourseAPI.startCourse instead.',
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> joinMeeting({
    required String meetingCode,
    required String participantName,
  }) async {
    print('⚠️ meetingAPI.joinMeeting is deprecated. Use LiveCourseAPI.joinCourse instead.');
    return ApiResponse<Map<String, dynamic>>(
      success: false,
      error: 'Deprecated API',
      message: 'Meeting joining is now handled through live courses. Use LiveCourseAPI.joinCourse instead.',
    );
  }

  static Future<ApiResponse<Meeting>> getMeetingInfo(String meetingCode) async {
    print('⚠️ meetingAPI.getMeetingInfo is deprecated. Use LiveCourseAPI.getCourseById instead.');
    return ApiResponse<Meeting>(
      success: false,
      error: 'Deprecated API',
      message: 'Meeting info is now available through live course data. Use LiveCourseAPI.getCourseById instead.',
    );
  }

  static Future<ApiResponse<List<Participant>>> getMeetingParticipants(String meetingCode) async {
    print('⚠️ meetingAPI.getMeetingParticipants is deprecated.');
    return ApiResponse<List<Participant>>(
      success: false,
      error: 'Deprecated API',
      message: 'Participant data is now handled through live course APIs and Socket.IO.',
      data: [],
    );
  }

  static Future<ApiResponse<dynamic>> endMeeting(String meetingCode) async {
    print('⚠️ meetingAPI.endMeeting is deprecated. Use LiveCourseAPI.completeCourse instead.');
    return ApiResponse<dynamic>(
      success: false,
      error: 'Deprecated API',
      message: 'Meeting ending is now handled through live courses. Use LiveCourseAPI.completeCourse instead.',
    );
  }
}

// Health check
Future<ApiResponse<dynamic>> healthCheck() async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:3000/health'),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return ApiResponse<dynamic>(
        success: true,
        data: json.decode(response.body),
      );
    } else {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Backend server is not available',
        message: 'HTTP ${response.statusCode}',
      );
    }
  } catch (error) {
    return ApiResponse<dynamic>(
      success: false,
      error: 'Backend server is not available',
      message: error.toString(),
    );
  }
}