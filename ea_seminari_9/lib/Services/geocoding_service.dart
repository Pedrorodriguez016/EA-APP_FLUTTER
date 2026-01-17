import 'package:dio/dio.dart';
import '../utils/logger.dart';

class AddressSuggestion {
  final String displayName;
  final double lat;
  final double lon;
  final String type;
  final String? street;
  final String? houseNumber;
  final String? postcode;
  final String? city;
  final String? country;

  AddressSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.type,
    this.street,
    this.houseNumber,
    this.postcode,
    this.city,
    this.country,
  });

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return AddressSuggestion(
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lon: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      type: json['type'] ?? '',
      street: address?['road'] ?? address?['street'],
      houseNumber: address?['house_number'],
      postcode: address?['postcode'],
      city: address?['city'] ?? address?['town'] ?? address?['village'],
      country: address?['country'],
    );
  }

  /// Valida la completitud de la dirección
  /// Retorna true si tiene al menos 80% de completitud
  bool get isValid {
    int completeness = 0;

    if (street != null && street!.isNotEmpty) completeness += 20;
    if (houseNumber != null && houseNumber!.isNotEmpty) completeness += 20;
    if (postcode != null && postcode!.isNotEmpty) completeness += 20;
    if (city != null && city!.isNotEmpty) completeness += 20;
    if (country != null && country!.isNotEmpty) completeness += 20;

    return completeness >= 80;
  }

  /// Obtiene los componentes faltantes de la dirección
  List<String> get missingComponents {
    final missing = <String>[];

    if (street == null || street!.isEmpty) missing.add('Calle');
    if (houseNumber == null || houseNumber!.isEmpty) missing.add('Número');
    if (postcode == null || postcode!.isEmpty) missing.add('Código postal');
    if (city == null || city!.isEmpty) missing.add('Ciudad');
    if (country == null || country!.isEmpty) missing.add('País');

    return missing;
  }
}

class GeocodingService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://nominatim.openstreetmap.org',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'User-Agent': 'EventApp/1.0', // Nominatim requiere User-Agent
      },
    ),
  );

  /// Busca direcciones basadas en el texto de búsqueda
  /// [query] - Texto a buscar
  /// [countryCode] - Código de país opcional (ej: 'es' para España)
  /// [limit] - Número máximo de resultados (por defecto 5)
  Future<List<AddressSuggestion>> searchAddress(
    String query, {
    String? countryCode,
    int limit = 5,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      logger.d('🔍 Buscando dirección: $query');

      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': 1,
          'limit': limit,
          if (countryCode != null) 'countrycodes': countryCode,
          'accept-language': 'es', // Preferencia de idioma
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final suggestions = (response.data as List)
            .map((json) => AddressSuggestion.fromJson(json))
            .toList();

        logger.i(
          '✅ Encontradas ${suggestions.length} sugerencias de dirección',
        );
        return suggestions;
      }

      return [];
    } catch (e) {
      logger.e('❌ Error al buscar dirección: $e');
      return [];
    }
  }

  /// Obtiene coordenadas de una dirección específica
  Future<Map<String, double>?> getCoordinates(String address) async {
    try {
      final suggestions = await searchAddress(address, limit: 1);
      if (suggestions.isNotEmpty) {
        return {'lat': suggestions.first.lat, 'lon': suggestions.first.lon};
      }
      return null;
    } catch (e) {
      logger.e('❌ Error al obtener coordenadas: $e');
      return null;
    }
  }
}
