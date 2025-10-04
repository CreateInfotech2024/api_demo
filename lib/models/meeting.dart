import 'package:json_annotation/json_annotation.dart';

part 'meeting.g.dart';

@JsonSerializable()
class Meeting {
  final String id;
  final String code;
  final String title;
  final String description;
  final String hostId;
  final String hostName;
  final List<Participant> participants;
  final List<ChatMessage> messages;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? endedAt;

  Meeting({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.hostId,
    required this.hostName,
    this.participants = const [],
    this.messages = const [],
    this.isActive = true,
    required this.createdAt,
    this.endedAt,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) => _$MeetingFromJson(json);
  Map<String, dynamic> toJson() => _$MeetingToJson(this);

  Meeting copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? hostId,
    String? hostName,
    List<Participant>? participants,
    List<ChatMessage>? messages,
    bool? isActive,
    DateTime? createdAt,
    DateTime? endedAt,
  }) {
    return Meeting(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  int get participantCount => participants.length;
}

@JsonSerializable()
class Participant {
  final String id;
  final String name;
  final bool isHost;
  final bool hasVideo;
  final bool hasAudio;
  final DateTime joinedAt;

  Participant({
    required this.id,
    required this.name,
    this.isHost = false,
    this.hasVideo = true,
    this.hasAudio = true,
    required this.joinedAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
}

@JsonSerializable()
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isSystemMessage;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isSystemMessage = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  factory ChatMessage.system(String message) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'system',
      senderName: 'System',
      message: message,
      timestamp: DateTime.now(),
      isSystemMessage: true,
    );
  }
}