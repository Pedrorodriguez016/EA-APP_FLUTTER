class Valoracion {
  final String id;
  final String? usuarioId;
  final String? usuarioNombre;
  final String? usuarioEmail; // Backend envía 'gmail'
  final String eventoId;
  final int puntuacion;
  final String comentario;
  final DateTime createdAt;

  Valoracion({
    required this.id,
    this.usuarioId,
    this.usuarioNombre,
    this.usuarioEmail,
    required this.eventoId,
    required this.puntuacion,
    required this.comentario,
    required this.createdAt,
  });

  factory Valoracion.fromJson(Map<String, dynamic> json) {
    String? uId;
    String? uNom;
    String? uEmail;

    if (json['usuario'] != null) {
      if (json['usuario'] is Map) {
        uId = json['usuario']['_id'];
        uNom = json['usuario']['username'];
        uEmail = json['usuario']['gmail'];
      } else if (json['usuario'] is String) {
        uId = json['usuario'];
      }
    }

    return Valoracion(
      id: json['_id'] ?? '',
      usuarioId: uId,
      usuarioNombre: uNom,
      usuarioEmail: uEmail,
      eventoId: json['evento'] ?? '',
      puntuacion: (json['puntuacion'] ?? 0).toInt(),
      comentario: json['comentario'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'usuario': usuarioId,
      'evento': eventoId,
      'puntuacion': puntuacion,
      'comentario': comentario,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
