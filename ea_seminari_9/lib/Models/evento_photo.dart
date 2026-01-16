class EventoPhoto {
  final String id;
  final String eventId;
  final String userId;
  final String username;
  final String url;
  final DateTime createdAt;

  EventoPhoto({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.username,
    required this.url,
    required this.createdAt,
  });

  factory EventoPhoto.fromJson(Map<String, dynamic> json) {
    return EventoPhoto(
      id: json['_id'] ?? '',
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      url: json['url'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'eventId': eventId,
      'userId': userId,
      'username': username,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
