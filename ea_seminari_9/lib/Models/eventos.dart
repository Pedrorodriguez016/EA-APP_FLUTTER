const List<String> listaCategorias = [
'Fútbol', 'Baloncesto', 'Tenis', 'Pádel', 'Running', 'Ciclismo', 
      'Natación', 'Yoga', 'Gimnasio', 'Senderismo', 'Escalada', 'Artes Marciales',
      'Concierto Rock', 'Concierto Pop', 'Concierto Clásica', 'Jazz', 'Electrónica', 
      'Hip Hop', 'Karaoke', 'Discoteca', 'Festival Musical',
      'Exposición Arte', 'Teatro', 'Cine', 'Museo', 'Literatura', 'Fotografía', 
      'Pintura', 'Escultura', 'Danza', 'Ópera',
      'Restaurante', 'Tapas', 'Cocina Internacional', 'Vinos', 'Cerveza Artesanal', 
      'Repostería', 'Brunch', 'Food Truck',
      'Fiesta Privada', 'Fiesta Temática', 'Cumpleaños', 'Boda', 'Despedida', 
      'After Work', 'Networking', 'Speed Dating',
      'Taller', 'Curso', 'Conferencia', 'Seminario', 'Workshop', 'Idiomas', 'Masterclass',
      'Hackathon', 'Meetup Tech', 'Gaming', 'eSports', 'Programación', 
      'Inteligencia Artificial', 'Blockchain', 'Startups',
      'Meditación', 'Spa', 'Wellness', 'Mindfulness', 'Salud Mental',
      'Voluntariado Ambiental', 'Voluntariado Social', 'Donación de Sangre', 
      'Rescate Animal', 'Limpieza Playas', 'Banco de Alimentos',
      'Camping', 'Montañismo', 'Playa', 'Barbacoa', 'Picnic', 'Observación Aves', 'Safari',
      'Juegos de Mesa', 'Ajedrez', 'Poker', 'Escape Room', 'Paintball', 'Laser Tag', 'Bolos',
      'Evento Familiar', 'Parque Infantil', 'Teatro Infantil', 'Animación Infantil', 'Taller Niños',
      'Mercadillo', 'Feria', 'Turismo', 'Excursión', 'Compras', 'Otros'
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
  final String categoria;

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
      participantes: List<dynamic>.from(
        json['participantes'] ?? [],
      ).map((p) => p.toString()).toList(),
      categoria: json['categoria'] as String? ?? 'Otros',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'schedule': schedule,
      'address': address,
      'participantes': participantes,
      'categoria': categoria,
    };
  }
}
