import '../Models/eventos.dart';
import 'dart:convert';
import 'package:get/get.dart';
import '../Interceptor/auth_interceptor.dart';

class EventosServices {
  final String baseUrl = 'http://localhost:3000/api/event';
  final AuthInterceptor _client = Get.put(AuthInterceptor());
  EventosServices();

  Future<Map<String, dynamic>> fetchEvents({
    int page = 1,
    int limit = 20,
    String q = '',
  }) async {
    final uri = Uri.parse('$baseUrl').replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
      if (q.isNotEmpty) 'q': q,
    });

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> eventosList = responseData['data'];

      return {
        'eventos': eventosList.map((json) => Evento.fromJson(json)).toList(),
        'totalPages': responseData['totalPages'] ?? 1,
        'currentPage': responseData['page'] ?? 1,
        'total': responseData['totalItems'] ?? 0,
      };
    } else {
      throw Exception('Error al cargar usuarios paginados');
    }
  }

  Future<Evento> fetchEventById(String id) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Evento.fromJson(data);
      } else {
        throw Exception('Error al cargar el usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchUserById: $e');
      throw Exception('Error al cargar el usuario: $e');
    }
  }

  // --- ¡NUEVA FUNCIÓN AÑADIDA AQUÍ! ---
  Future<Evento> createEvento(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse(baseUrl), // Llama al endpoint base: /api/event
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(data), // Envía los datos del nuevo evento
      );

      // Un '201 Created' es el estándar para un POST exitoso
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Devuelve el evento que el servidor acaba de crear
        return Evento.fromJson(responseData);
      } else {
        throw Exception(
            'Error al crear el evento: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error in createEvento: $e');
      throw Exception('Error al crear el evento: $e');
    }
  }
}