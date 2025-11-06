import 'dart:convert';
import 'package:ea_seminari_9/Models/eventos.dart';
import '../Interceptor/auth_interceptor.dart';

class EventosController {
  final String apiUrl = 'http://localhost:3000/api/event';
  final client = AuthInterceptor();
  Future<List<Evento>> fetchEvents() async {

    final response = await client.get(Uri.parse(apiUrl),);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Evento.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los eventos');
    }
  }
  Future<Evento> fetchEventById(String id) async {
    final response = await client.get(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Evento.fromJson(data);
    } else {
      throw Exception('Error al cargar el evento');
    }
  }

}
