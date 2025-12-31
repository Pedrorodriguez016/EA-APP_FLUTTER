import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/usuario_progreso.dart';
import '../Models/insignia.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GamificacionServices {
  final String baseUrl = '${dotenv.env['BASE_URL']}/api/gamificacion';

  // Obtener mi progreso (usuario autenticado)
  Future<UsuarioProgreso> getMiProgreso(String token) async {
    try {
      final url = Uri.parse('$baseUrl/mi-progreso');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UsuarioProgreso.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint de gamificación no disponible');
      } else {
        throw Exception('Error al obtener progreso: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('El servidor no devolvió datos válidos');
      }
      rethrow;
    }
  }

  // Obtener progreso de un usuario específico
  Future<UsuarioProgreso> getProgresoUsuario(String usuarioId) async {
    final url = Uri.parse('$baseUrl/progreso/$usuarioId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UsuarioProgreso.fromJson(data);
    } else {
      throw Exception(
        'Error al obtener progreso del usuario: ${response.statusCode}',
      );
    }
  }

  // Obtener ranking de usuarios
  Future<List<RankingUsuario>> getRanking({int limite = 10}) async {
    final url = Uri.parse('$baseUrl/ranking?limite=$limite');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RankingUsuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener ranking: ${response.statusCode}');
    }
  }

  // Obtener todas las insignias
  Future<List<Insignia>> getInsignias() async {
    try {
      final url = Uri.parse('$baseUrl/insignias');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Insignia.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // Endpoint no existe, retornar lista vacía
        return [];
      } else {
        throw Exception('Error al obtener insignias: ${response.statusCode}');
      }
    } catch (e) {
      // Si hay error de parsing JSON (respuesta HTML), retornar lista vacía
      if (e is FormatException) {
        return [];
      }
      rethrow;
    }
  }

  // Inicializar insignias (solo admin)
  Future<void> inicializarInsignias(String token) async {
    final url = Uri.parse('$baseUrl/inicializar-insignias');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al inicializar insignias: ${response.statusCode}');
    }
  }
}
