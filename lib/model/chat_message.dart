class ChatMessage {
  final String id;
  final String sender;
  final String message;
  final String timestamp;
  final String meetingCode;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.meetingCode,
  });
}