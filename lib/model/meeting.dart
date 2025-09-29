class Meeting {
  final String id;
  final String code;
  final String? name;

  const Meeting({
    required this.id,
    required this.code,
    this.name,
  });
}