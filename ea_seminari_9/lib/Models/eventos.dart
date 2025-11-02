
class Evento {
  final String id;
  final String name;
  final String schedule;
  final String address;

  Evento({
    required this.id,
    required this.name,
    required this.schedule,
    required this.address,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['_id'],
      name: json['name'],
      schedule: json['schedule'],
      address: json['address'] ?? '',
    );
  }
}
