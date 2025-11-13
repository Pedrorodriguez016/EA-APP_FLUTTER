class Evento {
  final String id;
  final String name;
  final String schedule;
  final String address;
  final int? capacidadMaxima;
  final List<String> participantes;

  Evento({
    required this.id,
    required this.name,
    required this.schedule,
    required this.address,
    this.capacidadMaxima,
    required this.participantes,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['_id'],
      name: json['name'],
      schedule: json['schedule'],
      address: json['address'] ?? '',
      capacidadMaxima: json['capacidadMaxima'],
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
