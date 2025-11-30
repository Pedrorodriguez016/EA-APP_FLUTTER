class ChatMessage {
  String id;
  String from;
  String to;
  String text;
  DateTime createdAt;
  bool isMine; // Propiedad visual

  ChatMessage({
    required this.id,
    required this.from,
    required this.to,
    required this.text,
    required this.createdAt,
    this.isMine = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myUserId) {
    return ChatMessage(
      id: json['_id'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      text: json['text'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      // Determinamos si es mío comparando el 'from' con mi ID
      isMine: (json['from'] == myUserId),
    );
  }
}