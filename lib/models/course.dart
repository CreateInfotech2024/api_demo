import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  final String id;
  final String title;
  final String description;
  final String instructorName;
  final String instructorEmail;
  final String? thumbnailUrl;
  final double price;
  final double discount;
  final List<String> tags;
  final String category;
  final String difficulty;
  final int estimatedDuration;
  final bool isPublished;
  final DateTime createdAt;
  final int enrolledStudents;
  final double rating;
  final int totalReviews;
  final String? verifyStatus;
  final String? meetingUrl;
  final String? meetingPassword;
  final int maxParticipants;
  final List<String> prerequisites;
  final String? materialUrl;
  final bool recordingEnabled;
  final String timeZone;
  final List<String> enrolledusers;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final DateTime? scheduledDateTime;
  final String? recordingFileName;
  final DateTime? recordingStartedAt;
  final DateTime? startedAt;
  final List<String> joinedUsers;
  final Map<String, dynamic>? joinedAt;
  final DateTime? completedAt;
  final int? recordingDuration;
  final int? recordingFileSize;
  final DateTime? recordingCompletedAt;
  final String? recordingUrl;
  final String? meetingCode;
  final String? meetingId;
  final bool recordingActive;
  final String status;
  final DateTime updatedAt;
  final int duration;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorName,
    required this.instructorEmail,
    this.thumbnailUrl,
    required this.price,
    required this.discount,
    this.tags = const [],
    required this.category,
    required this.difficulty,
    required this.estimatedDuration,
    required this.isPublished,
    required this.createdAt,
    required this.enrolledStudents,
    required this.rating,
    required this.totalReviews,
    this.verifyStatus,
    this.meetingUrl,
    this.meetingPassword,
    required this.maxParticipants,
    this.prerequisites = const [],
    this.materialUrl,
    required this.recordingEnabled,
    required this.timeZone,
    this.enrolledusers = const [],
    this.actualStartTime,
    this.actualEndTime,
    this.scheduledDateTime,
    this.recordingFileName,
    this.recordingStartedAt,
    this.startedAt,
    this.joinedUsers = const [],
    this.joinedAt,
    this.completedAt,
    this.recordingDuration,
    this.recordingFileSize,
    this.recordingCompletedAt,
    this.recordingUrl,
    this.meetingCode,
    this.meetingId,
    this.recordingActive = false,
    required this.status,
    required this.updatedAt,
    required this.duration,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? instructorName,
    String? instructorEmail,
    String? thumbnailUrl,
    double? price,
    double? discount,
    List<String>? tags,
    String? category,
    String? difficulty,
    int? estimatedDuration,
    bool? isPublished,
    DateTime? createdAt,
    int? enrolledStudents,
    double? rating,
    int? totalReviews,
    String? verifyStatus,
    String? meetingUrl,
    String? meetingPassword,
    int? maxParticipants,
    List<String>? prerequisites,
    String? materialUrl,
    bool? recordingEnabled,
    String? timeZone,
    List<String>? enrolledusers,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    DateTime? scheduledDateTime,
    String? recordingFileName,
    DateTime? recordingStartedAt,
    DateTime? startedAt,
    List<String>? joinedUsers,
    Map<String, dynamic>? joinedAt,
    DateTime? completedAt,
    int? recordingDuration,
    int? recordingFileSize,
    DateTime? recordingCompletedAt,
    String? recordingUrl,
    String? meetingCode,
    String? meetingId,
    bool? recordingActive,
    String? status,
    DateTime? updatedAt,
    int? duration,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructorName: instructorName ?? this.instructorName,
      instructorEmail: instructorEmail ?? this.instructorEmail,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      verifyStatus: verifyStatus ?? this.verifyStatus,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      meetingPassword: meetingPassword ?? this.meetingPassword,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      prerequisites: prerequisites ?? this.prerequisites,
      materialUrl: materialUrl ?? this.materialUrl,
      recordingEnabled: recordingEnabled ?? this.recordingEnabled,
      timeZone: timeZone ?? this.timeZone,
      enrolledusers: enrolledusers ?? this.enrolledusers,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      recordingFileName: recordingFileName ?? this.recordingFileName,
      recordingStartedAt: recordingStartedAt ?? this.recordingStartedAt,
      startedAt: startedAt ?? this.startedAt,
      joinedUsers: joinedUsers ?? this.joinedUsers,
      joinedAt: joinedAt ?? this.joinedAt,
      completedAt: completedAt ?? this.completedAt,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      recordingFileSize: recordingFileSize ?? this.recordingFileSize,
      recordingCompletedAt: recordingCompletedAt ?? this.recordingCompletedAt,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      meetingCode: meetingCode ?? this.meetingCode,
      meetingId: meetingId ?? this.meetingId,
      recordingActive: recordingActive ?? this.recordingActive,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      duration: duration ?? this.duration,
    );
  }

  bool get isLive => status == 'active';
  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';
  bool get hasRecording => recordingUrl != null && recordingUrl!.isNotEmpty;

  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Live Now';
      case 'scheduled':
        return 'Scheduled';
      case 'completed':
        return 'Completed';
      default:
        return status.toUpperCase();
    }
  }

  // Helper to format recording duration in minutes
  String get formattedRecordingDuration {
    if (recordingDuration == null) return 'N/A';
    final minutes = recordingDuration! ~/ 60;
    final seconds = recordingDuration! % 60;
    return '${minutes}m ${seconds}s';
  }

  // Helper to format file size
  String get formattedFileSize {
    if (recordingFileSize == null) return 'N/A';
    final mb = recordingFileSize! / (1024 * 1024);
    return '${mb.toStringAsFixed(2)} MB';
  }
}