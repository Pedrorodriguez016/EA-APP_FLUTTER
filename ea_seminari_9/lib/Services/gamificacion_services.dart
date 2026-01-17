import 'package:dio/dio.dart';
import '../Models/usuario_progreso.dart';
import '../Models/insignia.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Interceptor/auth_interceptor.dart';
import '../utils/logger.dart';

class GamificacionServices {
  final String baseUrl = '${dotenv.env['BASE_URL']}/api/gamificacion';
  late final Dio _client;

  GamificacionServices() {
    _client = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    _client.interceptors.add(AuthInterceptor());
  }

  // Obtener mi progreso (usuario autenticado)
  Future<UsuarioProgreso> getMiProgreso() async {
    try {
      final response = await _client.get('/mi-progreso');

      if (response.statusCode == 200) {
        return UsuarioProgreso.fromJson(response.data);
      } else {
        throw Exception('Error al obtener progreso: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Endpoint de gamificación no disponible');
      }
      logger.e('❌ Error en getMiProgreso', error: e);
      rethrow;
    } catch (e) {
      logger.e('❌ Error inesperado en getMiProgreso', error: e);
      rethrow;
    }
  }

  // Obtener progreso de un usuario específico
  Future<UsuarioProgreso> getProgresoUsuario(String usuarioId) async {
    try {
      final response = await _client.get('/progreso/$usuarioId');

      if (response.statusCode == 200) {
        return UsuarioProgreso.fromJson(response.data);
      } else {
        throw Exception(
          'Error al obtener progreso del usuario: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      logger.e('❌ Error en getProgresoUsuario', error: e);
      rethrow;
    } catch (e) {
      logger.e('❌ Error inesperado en getProgresoUsuario', error: e);
      rethrow;
    }
  }

  // Obtener ranking de usuarios
  Future<List<RankingUsuario>> getRanking({int limite = 10}) async {
    try {
      final response = await _client.get(
        '/ranking',
        queryParameters: {'limite': limite},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => RankingUsuario.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener ranking: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('❌ Error en getRanking', error: e);
      rethrow;
    } catch (e) {
      logger.e('❌ Error inesperado en getRanking', error: e);
      rethrow;
    }
  }

  // Obtener todas las insignias
  Future<List<Insignia>> getInsignias() async {
    try {
      final response = await _client.get('/insignias');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Insignia.fromJson(json)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      logger.e('❌ Error en getInsignias', error: e);
      return [];
    } catch (e) {
      logger.e('❌ Error inesperado en getInsignias', error: e);
      return [];
    }
  }

  // Inicializar insignias (solo admin)
  Future<void> inicializarInsignias() async {
    try {
      final response = await _client.post('/inicializar-insignias');

      if (response.statusCode != 200) {
        throw Exception(
          'Error al inicializar insignias: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      logger.e('❌ Error en inicializarInsignias', error: e);
      rethrow;
    } catch (e) {
      logger.e('❌ Error inesperado en inicializarInsignias', error: e);
      rethrow;
    }
  }
}
