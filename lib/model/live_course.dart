class LiveCourse {
  final String id;
  final String name;
  final String? description;
  final String instructorId;
  final String instructorName;
  final String category;
  final int duration;
  final bool recordingEnabled;
  final String status;
  final String? scheduledDateTime;
  final List<String>? enrolledUsers;
  final String? meetingCode;
  final String? meetingId;

  const LiveCourse({
    required this.id,
    required this.name,
    this.description,
    required this.instructorId,
    required this.instructorName,
    required this.category,
    required this.duration,
    required this.recordingEnabled,
    required this.status,
    this.scheduledDateTime,
    this.enrolledUsers,
    this.meetingCode,
    this.meetingId,
  });

  factory LiveCourse.empty() {
    return const LiveCourse(
      id: '',
      name: '',
      instructorId: '',
      instructorName: '',
      category: '',
      duration: 0,
      recordingEnabled: false,
      status: '',
    );
  }

  LiveCourse copyWith({
    String? id,
    String? name,
    String? description,
    String? instructorId,
    String? instructorName,
    String? category,
    int? duration,
    bool? recordingEnabled,
    String? status,
    String? scheduledDateTime,
    List<String>? enrolledUsers,
    String? meetingCode,
    String? meetingId,
  }) {
    return LiveCourse(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      recordingEnabled: recordingEnabled ?? this.recordingEnabled,
      status: status ?? this.status,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      enrolledUsers: enrolledUsers ?? this.enrolledUsers,
      meetingCode: meetingCode ?? this.meetingCode,
      meetingId: meetingId ?? this.meetingId,
    );
  }
}
