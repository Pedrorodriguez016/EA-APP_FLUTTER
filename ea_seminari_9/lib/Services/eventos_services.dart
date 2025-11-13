import 'package:ea_seminari_9/Models/eventos.dart';
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
}