import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ea_seminari_9/Models/eventos.dart';

class EventosController {
  final String apiUrl = 'http://localhost:3000/api/event';

  Future<List<Evento>> fetchEvents() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Evento.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los eventos');
    }
  }

}
