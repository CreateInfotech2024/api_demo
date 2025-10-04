// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meeting _$MeetingFromJson(Map<String, dynamic> json) => Meeting(
  id: json['id'] as String,
  code: json['code'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  hostId: json['hostId'] as String,
  hostName: json['hostName'] as String,
  participants:
      (json['participants'] as List<dynamic>?)
          ?.map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
);

Map<String, dynamic> _$MeetingToJson(Meeting instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'title': instance.title,
  'description': instance.description,
  'hostId': instance.hostId,
  'hostName': instance.hostName,
  'participants': instance.participants,
  'messages': instance.messages,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'endedAt': instance.endedAt?.toIso8601String(),
};

Participant _$ParticipantFromJson(Map<String, dynamic> json) => Participant(
  id: json['id'] as String,
  name: json['name'] as String,
  isHost: json['isHost'] as bool? ?? false,
  hasVideo: json['hasVideo'] as bool? ?? true,
  hasAudio: json['hasAudio'] as bool? ?? true,
  joinedAt: DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isHost': instance.isHost,
      'hasVideo': instance.hasVideo,
      'hasAudio': instance.hasAudio,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  isSystemMessage: json['isSystemMessage'] as bool? ?? false,
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'isSystemMessage': instance.isSystemMessage,
    };
