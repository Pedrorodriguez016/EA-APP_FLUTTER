class Evento {
  final String id;
  final String name;
  final String schedule;
  final String address;
  final double? lat;
  final double? lng; 
  final int? capacidadMaxima;
  final List<String> participantes;

  Evento({
    required this.id,
    required this.name,
    required this.schedule,
    required this.address,
    this.capacidadMaxima,
    this.lat,
    this.lng,
    required this.participantes,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['_id'],
      name: json['name'],
      schedule: json['schedule'],
      address: json['address'],
      capacidadMaxima: json['capacidadMaxima'],
      lat: (json['lat'] != null) ? json['lat'].toDouble() : null,
      lng: (json['lng'] != null) ? json['lng'].toDouble() : null,
      participantes: List<dynamic>.from(json['participantes'] ?? [])
          .map((p) => p.toString())
          .toList(),
    );
  }
   Map<String, dynamic> toJson() {
    return {
      'name': name,
      'schedule': schedule,
      'address': address,
      'participantes': participantes,
    };
  }
}
