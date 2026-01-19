class Notificacion {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? relatedUserId;
  final String? relatedEventId;
  final String? relatedUsername;
  final String? relatedEventName;
  final bool read;
  final DateTime createdAt;
  final String? actionUrl;

  Notificacion({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedUserId,
    this.relatedEventId,
    this.relatedUsername,
    this.relatedEventName,
    required this.read,
    required this.createdAt,
    this.actionUrl,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      relatedUserId: json['relatedUserId'],
      relatedEventId: json['relatedEventId'],
      relatedUsername: json['relatedUsername'],
      relatedEventName: json['relatedEventName'],
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      actionUrl: json['actionUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'relatedUserId': relatedUserId,
      'relatedEventId': relatedEventId,
      'relatedUsername': relatedUsername,
      'relatedEventName': relatedEventName,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'actionUrl': actionUrl,
    };
  }
}
