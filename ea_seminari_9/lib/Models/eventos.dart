const List<String> listaCategorias = [
  'Fútbol',
  'Baloncesto',
  'Tenis',
  'Pádel',
  'Running',
  'Ciclismo',
  'Natación',
  'Yoga',
  'Gimnasio',
  'Senderismo',
  'Escalada',
  'Artes Marciales',
  'Concierto Rock',
  'Concierto Pop',
  'Concierto Clásica',
  'Jazz',
  'Electrónica',
  'Hip Hop',
  'Karaoke',
  'Discoteca',
  'Festival Musical',
  'Exposición Arte',
  'Teatro',
  'Cine',
  'Museo',
  'Literatura',
  'Fotografía',
  'Pintura',
  'Escultura',
  'Danza',
  'Ópera',
  'Restaurante',
  'Tapas',
  'Cocina Internacional',
  'Vinos',
  'Cerveza Artesanal',
  'Repostería',
  'Brunch',
  'Food Truck',
  'Fiesta Privada',
  'Fiesta Temática',
  'Cumpleaños',
  'Boda',
  'Despedida',
  'After Work',
  'Networking',
  'Speed Dating',
  'Taller',
  'Curso',
  'Conferencia',
  'Seminario',
  'Workshop',
  'Idiomas',
  'Masterclass',
  'Hackathon',
  'Meetup Tech',
  'Gaming',
  'eSports',
  'Programación',
  'Inteligencia Artificial',
  'Blockchain',
  'Startups',
  'Meditación',
  'Spa',
  'Wellness',
  'Mindfulness',
  'Salud Mental',
  'Voluntariado Ambiental',
  'Voluntariado Social',
  'Donación de Sangre',
  'Rescate Animal',
  'Limpieza Playas',
  'Banco de Alimentos',
  'Camping',
  'Montañismo',
  'Playa',
  'Barbacoa',
  'Picnic',
  'Observación Aves',
  'Safari',
  'Juegos de Mesa',
  'Ajedrez',
  'Poker',
  'Escape Room',
  'Paintball',
  'Laser Tag',
  'Bolos',
  'Evento Familiar',
  'Parque Infantil',
  'Teatro Infantil',
  'Animación Infantil',
  'Taller Niños',
  'Mercadillo',
  'Feria',
  'Turismo',
  'Excursión',
  'Compras',
  'Otros',
];

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
  final String categoria;
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
    required this.categoria,
    this.listaEspera = const [],
    this.isPrivate = false,
    this.invitados = const [],
    this.invitacionesPendientes = const [],
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic p) {
      if (p == null) return '';
      if (p is String) return p.trim();
      if (p is Map) return (p['_id'] ?? p['id'] ?? '').toString().trim();
      return p.toString().trim();
    }

    return Evento(
      id: (json['_id'] ?? json['id'] ?? '').toString().trim(),
      name: json['name'] as String? ?? '',
      schedule: json['schedule'] as String? ?? '',
      address: json['address'] as String? ?? '',
      capacidadMaxima: json['maxParticipantes'] as int?,
      lat: (json['lat'] != null) ? json['lat'].toDouble() : null,
      lng: (json['lng'] != null) ? json['lng'].toDouble() : null,
      participantes: (json['participantes'] as List? ?? [])
          .map((p) => extractId(p))
          .where((id) => id.isNotEmpty)
          .toList(),
      listaEspera: (json['listaEspera'] as List? ?? [])
          .map((p) => extractId(p))
          .where((id) => id.isNotEmpty)
          .toList(),
      categoria: json['categoria'] as String? ?? 'Otros',
      isPrivate: json['isPrivate'] as bool? ?? false,
      invitados: (json['invitados'] as List? ?? [])
          .map((i) => extractId(i))
          .where((id) => id.isNotEmpty)
          .toList(),
      invitacionesPendientes: (json['invitacionesPendientes'] as List? ?? [])
          .map((i) => extractId(i))
          .where((id) => id.isNotEmpty)
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'schedule': schedule,
      'address': address,
      'participantes': participantes,
      'categoria': categoria,
      'isPrivate': isPrivate,
      'invitados': invitados,
      'invitacionesPendientes': invitacionesPendientes,
    };
  }
}
