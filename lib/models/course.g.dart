// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  instructorName: json['instructorName'] as String,
  instructorEmail: json['instructorEmail'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  price: (json['price'] as num).toDouble(),
  discount: (json['discount'] as num).toDouble(),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  category: json['category'] as String,
  difficulty: json['difficulty'] as String,
  estimatedDuration: (json['estimatedDuration'] as num).toInt(),
  isPublished: json['isPublished'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  enrolledStudents: (json['enrolledStudents'] as num).toInt(),
  rating: (json['rating'] as num).toDouble(),
  totalReviews: (json['totalReviews'] as num).toInt(),
  verifyStatus: json['verifyStatus'] as String?,
  meetingUrl: json['meetingUrl'] as String?,
  meetingPassword: json['meetingPassword'] as String?,
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  prerequisites:
      (json['prerequisites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  materialUrl: json['materialUrl'] as String?,
  recordingEnabled: json['recordingEnabled'] as bool,
  timeZone: json['timeZone'] as String,
  enrolledusers:
      (json['enrolledusers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  actualStartTime: json['actualStartTime'] == null
      ? null
      : DateTime.parse(json['actualStartTime'] as String),
  actualEndTime: json['actualEndTime'] == null
      ? null
      : DateTime.parse(json['actualEndTime'] as String),
  scheduledDateTime: json['scheduledDateTime'] == null
      ? null
      : DateTime.parse(json['scheduledDateTime'] as String),
  recordingFileName: json['recordingFileName'] as String?,
  recordingStartedAt: json['recordingStartedAt'] == null
      ? null
      : DateTime.parse(json['recordingStartedAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  joinedUsers:
      (json['joinedUsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  joinedAt: json['joinedAt'] as Map<String, dynamic>?,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  recordingDuration: (json['recordingDuration'] as num?)?.toInt(),
  recordingFileSize: (json['recordingFileSize'] as num?)?.toInt(),
  recordingCompletedAt: json['recordingCompletedAt'] == null
      ? null
      : DateTime.parse(json['recordingCompletedAt'] as String),
  recordingUrl: json['recordingUrl'] as String?,
  meetingCode: json['meetingCode'] as String?,
  meetingId: json['meetingId'] as String?,
  recordingActive: json['recordingActive'] as bool? ?? false,
  status: json['status'] as String,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  duration: (json['duration'] as num).toInt(),
);

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'instructorName': instance.instructorName,
  'instructorEmail': instance.instructorEmail,
  'thumbnailUrl': instance.thumbnailUrl,
  'price': instance.price,
  'discount': instance.discount,
  'tags': instance.tags,
  'category': instance.category,
  'difficulty': instance.difficulty,
  'estimatedDuration': instance.estimatedDuration,
  'isPublished': instance.isPublished,
  'createdAt': instance.createdAt.toIso8601String(),
  'enrolledStudents': instance.enrolledStudents,
  'rating': instance.rating,
  'totalReviews': instance.totalReviews,
  'verifyStatus': instance.verifyStatus,
  'meetingUrl': instance.meetingUrl,
  'meetingPassword': instance.meetingPassword,
  'maxParticipants': instance.maxParticipants,
  'prerequisites': instance.prerequisites,
  'materialUrl': instance.materialUrl,
  'recordingEnabled': instance.recordingEnabled,
  'timeZone': instance.timeZone,
  'enrolledusers': instance.enrolledusers,
  'actualStartTime': instance.actualStartTime?.toIso8601String(),
  'actualEndTime': instance.actualEndTime?.toIso8601String(),
  'scheduledDateTime': instance.scheduledDateTime?.toIso8601String(),
  'recordingFileName': instance.recordingFileName,
  'recordingStartedAt': instance.recordingStartedAt?.toIso8601String(),
  'startedAt': instance.startedAt?.toIso8601String(),
  'joinedUsers': instance.joinedUsers,
  'joinedAt': instance.joinedAt,
  'completedAt': instance.completedAt?.toIso8601String(),
  'recordingDuration': instance.recordingDuration,
  'recordingFileSize': instance.recordingFileSize,
  'recordingCompletedAt': instance.recordingCompletedAt?.toIso8601String(),
  'recordingUrl': instance.recordingUrl,
  'meetingCode': instance.meetingCode,
  'meetingId': instance.meetingId,
  'recordingActive': instance.recordingActive,
  'status': instance.status,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'duration': instance.duration,
};
