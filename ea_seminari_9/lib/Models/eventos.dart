class Evento {
  final String id;
  final String name;
  final String schedule;
  final String address;
  final double? lat;
  final double? lng;
  final int? capacidadMaxima;
  final List<String> participantes;
  final List<String> listaEspera;
  final bool isPrivate;
  final List<String> invitados;
  final List<String> invitacionesPendientes;

  Evento({
    required this.id,
    required this.name,
    required this.schedule,
    required this.address,
    this.capacidadMaxima,
    this.lat,
    this.lng,
    required this.participantes,
    this.listaEspera = const [],
    this.isPrivate = false,
    this.invitados = const [],
    this.invitacionesPendientes = const [],
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      schedule: json['schedule'] as String? ?? '',
      address: json['address'] as String? ?? '',
      capacidadMaxima: json['maxParticipantes'] as int?,
      lat: (json['lat'] != null) ? json['lat'].toDouble() : null,
      lng: (json['lng'] != null) ? json['lng'].toDouble() : null,
      participantes: List<dynamic>.from(json['participantes'] ?? [])
          .map((p) => p is String ? p : (p['_id'] as String? ?? p.toString()))
          .toList(),
      listaEspera: List<dynamic>.from(json['listaEspera'] ?? [])
          .map((p) => p is String ? p : (p['_id'] as String? ?? p.toString()))
          .toList(),
      isPrivate: json['isPrivate'] as bool? ?? false,
      invitados: List<dynamic>.from(json['invitados'] ?? [])
          .map((i) => i is String ? i : (i['_id'] as String? ?? i.toString()))
          .toList(),
      invitacionesPendientes:
          List<dynamic>.from(json['invitacionesPendientes'] ?? [])
              .map(
                (i) => i is String ? i : (i['_id'] as String? ?? i.toString()),
              )
              .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'schedule': schedule,
      'address': address,
      'participantes': participantes,
      'isPrivate': isPrivate,
      'invitados': invitados,
      'invitacionesPendientes': invitacionesPendientes,
    };
  }
}
