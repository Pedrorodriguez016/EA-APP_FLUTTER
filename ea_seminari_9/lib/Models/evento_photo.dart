class EventoPhoto {
  final String id;
  final String eventId;
  final String userId;
  final String username;
  final String url;
  final String type; // 'image' or 'video'
  final DateTime createdAt;

  EventoPhoto({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.username,
    required this.url,
    required this.type,
    required this.createdAt,
  });

  factory EventoPhoto.fromJson(Map<String, dynamic> json) {
    return EventoPhoto(
      id: json['_id'] ?? '',
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'image',
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
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
