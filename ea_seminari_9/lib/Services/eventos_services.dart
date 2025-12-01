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
  
  Future<List<Evento>> fetchEventsByBounds({
    required double north,
    required double south,
    required double east,
    required double west,
  }) async {
    try {
      final response = await _client.get('/by-bounds', queryParameters: {
        'north': north,
        'south': south,
        'east': east,
        'west': west,
        'limit': 10, 
      });

      var data = response.data;
      List<dynamic> eventosList;

      if (data is List) {
        eventosList = data;
      } else if (data is Map<String, dynamic> && data.containsKey('data')) {
        eventosList = data['data']; 
      } else {
        eventosList = [];
      }
      print('Eventos fetched by bounds: $eventosList');
      return eventosList.map((json) => Evento.fromJson(json)).toList();
    } catch (e) {
      print('Error in fetchEventsByBounds: $e');
      return []; 
    }
  }

  Future<Map<String, dynamic>> fetchEvents({
    int page = 1,
    int limit = 20,
    String q = '',
    String? creatorId,
  }) async {
    try {
      final response = await _client.get('/', queryParameters: {
        'page': page,
        'limit': limit,
        if (q.isNotEmpty) 'q': q,
        if (creatorId != null && creatorId.isNotEmpty) 'creatorId': creatorId,
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

  Future<Evento?> getEventoByName(String name) async {
    try {
      final response = await _client.get('/by-name/$name');
      return Evento.fromJson(response.data);
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('Usuario no encontrado: $name');
        return null; 
      }
      
      throw Exception('Error al buscar usuario por username: ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido al buscar usuario: $e');
    }
  }
}