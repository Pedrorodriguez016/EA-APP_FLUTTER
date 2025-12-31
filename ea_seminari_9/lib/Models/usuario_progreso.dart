import 'insignia.dart';

class UsuarioProgreso {
  final String id;
  final String usuario;
  final int puntos;
  final String nivel;
  final List<Insignia> insignias;
  final EstadisticasProgreso estadisticas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UsuarioProgreso({
    required this.id,
    required this.usuario,
    this.puntos = 0,
    this.nivel = 'Novato',
    this.insignias = const [],
    required this.estadisticas,
    this.createdAt,
    this.updatedAt,
  });

  factory UsuarioProgreso.fromJson(Map<String, dynamic> json) {
    return UsuarioProgreso(
      id: json['_id'] ?? '',
      usuario: json['usuario'] ?? '',
      puntos: json['puntos'] ?? 0,
      nivel: json['nivel'] ?? 'Novato',
      insignias:
          (json['insignias'] as List<dynamic>?)
              ?.map((i) => Insignia.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      estadisticas: EstadisticasProgreso.fromJson(json['estadisticas'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'usuario': usuario,
      'puntos': puntos,
      'nivel': nivel,
      'insignias': insignias.map((i) => i.toJson()).toList(),
      'estadisticas': estadisticas.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class EstadisticasProgreso {
  final int eventosCreadosTotal;
  final int eventosUnidosTotal;
  final int valoracionesTotal;
  final int amigosTotal;

  EstadisticasProgreso({
    this.eventosCreadosTotal = 0,
    this.eventosUnidosTotal = 0,
    this.valoracionesTotal = 0,
    this.amigosTotal = 0,
  });

  factory EstadisticasProgreso.fromJson(Map<String, dynamic> json) {
    return EstadisticasProgreso(
      eventosCreadosTotal: json['eventosCreadosTotal'] ?? 0,
      eventosUnidosTotal: json['eventosUnidosTotal'] ?? 0,
      valoracionesTotal: json['valoracionesTotal'] ?? 0,
      amigosTotal: json['amigosTotal'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventosCreadosTotal': eventosCreadosTotal,
      'eventosUnidosTotal': eventosUnidosTotal,
      'valoracionesTotal': valoracionesTotal,
      'amigosTotal': amigosTotal,
    };
  }
}

class RankingUsuario {
  final int posicion;
  final String usuario;
  final String gmail;
  final int puntos;
  final String nivel;
  final int insignias;

  RankingUsuario({
    required this.posicion,
    required this.usuario,
    required this.gmail,
    required this.puntos,
    required this.nivel,
    required this.insignias,
  });

  factory RankingUsuario.fromJson(Map<String, dynamic> json) {
    return RankingUsuario(
      posicion: json['posicion'] ?? 0,
      usuario: json['usuario'] ?? '',
      gmail: json['gmail'] ?? '',
      puntos: json['puntos'] ?? 0,
      nivel: json['nivel'] ?? 'Novato',
      insignias: json['insignias'] ?? 0,
    );
  }
}
