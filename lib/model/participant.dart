class Participant {
  final String id;
  final String name;
  final bool isHost;
  final String? joinedAt;

  const Participant({
    required this.id,
    required this.name,
    required this.isHost,
    this.joinedAt,
  });
}