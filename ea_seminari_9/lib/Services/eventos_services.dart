import '../Models/eventos.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../Controllers/auth_controller.dart';
import '../Interceptor/auth_interceptor.dart';

class EventosServices {
  final String baseUrl = 'http://localhost:3000/api/event';
  final AuthController _authController = Get.find<AuthController>();
  late final Dio _client;
  EventosServices(){
    _client = Dio(BaseOptions(baseUrl: baseUrl));
    _client.interceptors.add(AuthInterceptor());
  }
  

  Future<Map<String, dynamic>> fetchEvents({
    int page = 1,
    int limit = 20,
    String q = '',
  }) async {
    try {
      final response = await _client.get('/', queryParameters: {
        'page': page,
        'limit': limit,
        if (q.isNotEmpty) 'q': q,
      });

      final responseData = response.data;
      final List<dynamic> eventosList = responseData['data'];

      return {
        'eventos': eventosList.map((json) => Evento.fromJson(json)).toList(),
        'totalPages': responseData['totalPages'] ?? 1,
        'currentPage': responseData['page'] ?? 1,
        'total': responseData['totalItems'] ?? 0,
      };
    } catch (e) {
      throw Exception('Error al cargar eventos: $e');
    }
  }

  Future<Evento> fetchEventById(String id) async {
    try {
      final response = await _client.get('/$id');
        return Evento.fromJson(response.data);
    } catch (e) {
      print('Error in fetchUserById: $e');
      throw Exception('Error al cargar el usuario: $e');
    }
  }

  // --- ¡NUEVA FUNCIÓN AÑADIDA AQUÍ! ---
  Future<Evento> createEvento(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('/',
        data: data, // Envía los datos del nuevo evento
      );
      return Evento.fromJson(response.data);
    } catch (e) {
      print('Error in createEvento: $e');
      throw Exception('Error al crear el evento: $e');
    }
  }
}