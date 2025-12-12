class Evento {
  final String id;
  final String name;
  final String schedule;
  final String address;
  final double? lat;
  final double? lng; 
  final int? capacidadMaxima;
  final List<String> participantes;

  // Lista de URLs de las fotos del álbum
  final List<String> fotos;

  Evento({
    required this.id,
    required this.name,
    required this.schedule,
    required this.address,
    this.capacidadMaxima,
    this.lat,
    this.lng,
    required this.participantes,
    this.fotos = const [],
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['_id'] as String? ?? '', 
      name: json['name'] as String? ?? '',
      schedule: json['schedule'] as String? ?? '',
      address: json['address'] as String? ?? '',
      capacidadMaxima: json['capacidadMaxima'] as int?,
      lat: (json['lat'] != null) ? json['lat'].toDouble() : null,
      lng: (json['lng'] != null) ? json['lng'].toDouble() : null,
      participantes: List<dynamic>.from(json['participantes'] ?? [])
          .map((p) => p.toString())
          .toList(),
      fotos: List<dynamic>.from(json['fotos'] ?? [])
          .map((foto) => foto.toString())
          .toList(),
    );
  }
   Map<String, dynamic> toJson() {
    return {
      'name': name,
      'schedule': schedule,
      'address': address,
      'participantes': participantes,
      'fotos': fotos,
    };
  }
}
