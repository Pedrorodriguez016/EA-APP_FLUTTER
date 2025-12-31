class Insignia {
  final String id;
  final String codigo;
  final String nombre;
  final String descripcion;
  final String icono;
  final int puntos;
  final CriteriosInsignia criterios;

  Insignia({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    this.icono = '🏆',
    this.puntos = 0,
    required this.criterios,
  });

  factory Insignia.fromJson(Map<String, dynamic> json) {
    return Insignia(
      id: json['_id'] ?? '',
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      icono: json['icono'] ?? '🏆',
      puntos: json['puntos'] ?? 0,
      criterios: CriteriosInsignia.fromJson(json['criterios'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'puntos': puntos,
      'criterios': criterios.toJson(),
    };
  }
}

class CriteriosInsignia {
  final int? eventosCreadosRequeridos;
  final int? eventosUnidosRequeridos;
  final int? valoracionesRequeridas;
  final int? amigosRequeridos;
  final int? puntosRequeridos;

  CriteriosInsignia({
    this.eventosCreadosRequeridos,
    this.eventosUnidosRequeridos,
    this.valoracionesRequeridas,
    this.amigosRequeridos,
    this.puntosRequeridos,
  });

  factory CriteriosInsignia.fromJson(Map<String, dynamic> json) {
    return CriteriosInsignia(
      eventosCreadosRequeridos: json['eventosCreadosRequeridos'],
      eventosUnidosRequeridos: json['eventosUnidosRequeridos'],
      valoracionesRequeridas: json['valoracionesRequeridas'],
      amigosRequeridos: json['amigosRequeridos'],
      puntosRequeridos: json['puntosRequeridos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (eventosCreadosRequeridos != null)
        'eventosCreadosRequeridos': eventosCreadosRequeridos,
      if (eventosUnidosRequeridos != null)
        'eventosUnidosRequeridos': eventosUnidosRequeridos,
      if (valoracionesRequeridas != null)
        'valoracionesRequeridas': valoracionesRequeridas,
      if (amigosRequeridos != null) 'amigosRequeridos': amigosRequeridos,
      if (puntosRequeridos != null) 'puntosRequeridos': puntosRequeridos,
    };
  }
}
