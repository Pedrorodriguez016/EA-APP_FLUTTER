import 'package:dio/dio.dart';
import '../Models/valoracion.dart';
import '../Interceptor/auth_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class ValoracionServices {
  final String baseUrl = '${dotenv.env['BASE_URL']}/api/ratings';
  late final Dio _client;

  ValoracionServices() {
    _client = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    _client.interceptors.add(AuthInterceptor());
  }

  Future<List<Valoracion>> getValoracionesEvento(String eventoId) async {
    try {
      final response = await _client.get('/event/$eventoId');

      var data = response.data;

      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }

      if (data is List) {
        final lista = data
            .map((json) {
              try {
                return Valoracion.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .whereType<Valoracion>()
            .toList();

        return lista;
      }
      return [];
    } catch (e) {
      // It's often better to log or return empty lists rather than crashing entire flows
      logger.e('Error getting ratings: $e');
      return [];
    }
  }

  Future<Valoracion?> getUserValoracion(String eventoId) async {
    try {
      final response = await _client.get('/event/$eventoId/my-rating');
      if (response.statusCode == 200 && response.data != null) {
        return Valoracion.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      // Re-throw or handle other errors
      logger.e('Error getting user rating: $e');
      return null;
    } catch (e) {
      logger.e('Unknown error getting user rating: $e');
      return null;
    }
  }

  Future<Valoracion> createValoracion(
    String eventoId,
    double puntuacion,
    String comentario,
  ) async {
    try {
      final response = await _client.post(
        '/event/$eventoId',
        data: {'puntuacion': puntuacion, 'comentario': comentario},
      );
      return Valoracion.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear valoración: $e');
    }
  }

  Future<Valoracion> updateValoracion(
    String id,
    double puntuacion,
    String comentario,
  ) async {
    try {
      final response = await _client.put(
        '/$id',
        data: {'puntuacion': puntuacion, 'comentario': comentario},
      );
      return Valoracion.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar valoración: $e');
    }
  }

  Future<void> deleteValoracion(String id) async {
    try {
      await _client.delete('/$id');
    } catch (e) {
      throw Exception('Error al eliminar valoración: $e');
    }
  }
}
