class EventChatMessage {
  String id;
  String eventId;
  String userId;
  String username;
  String text;
  DateTime createdAt;
  bool isMine;

  EventChatMessage({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
    this.isMine = false,
  });

  factory EventChatMessage.fromJson(
    Map<String, dynamic> json,
    String myUserId,
  ) {
    return EventChatMessage(
      id: json['_id'] ?? '',
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      text: json['text'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isMine: (json['userId'] == myUserId),
    );
  }
}
