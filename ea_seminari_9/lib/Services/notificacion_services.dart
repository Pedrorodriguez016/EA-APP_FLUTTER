import 'package:dio/dio.dart' as d;
import '../Interceptor/auth_interceptor.dart';
import '../Models/notificacion.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class NotificacionServices {
  final String baseUrl = '${dotenv.env['BASE_URL']}/api/notificaciones';
  late final d.Dio _client;

  NotificacionServices() {
    _client = d.Dio(d.BaseOptions(baseUrl: baseUrl));
    _client.interceptors.add(AuthInterceptor());
  }

  Future<List<Notificacion>> fetchNotificaciones(
    String userId, {
    int limit = 50,
  }) async {
    try {
      logger.d('🔔 Obteniendo notificaciones para: $userId');
      final response = await _client.get(
        '/$userId',
        queryParameters: {'limit': limit},
      );

      if (response.data != null && response.data['ok'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((json) => Notificacion.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      logger.e('❌ Error al obtener notificaciones', error: e);
      return [];
    }
  }

  Future<List<Notificacion>> fetchUnreadNotificaciones(String userId) async {
    try {
      logger.d('🔔 Obteniendo notificaciones no leídas para: $userId');
      final response = await _client.get('/$userId/unread');

      if (response.data != null && response.data['ok'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((json) => Notificacion.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      logger.e('❌ Error al obtener notificaciones no leídas', error: e);
      return [];
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _client.get('/$userId/unread/count');
      return response.data['count'] ?? 0;
    } catch (e) {
      logger.e('❌ Error al obtener el conteo de notificaciones', error: e);
      return 0;
    }
  }

  Future<bool> markAsRead(String notificacionId) async {
    try {
      final response = await _client.patch('/$notificacionId/read');
      return response.statusCode == 200;
    } catch (e) {
      logger.e('❌ Error al marcar como leída', error: e);
      return false;
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _client.patch('/$userId/read-all');
    } catch (e) {
      logger.e('❌ Error al marcar todas como leídas', error: e);
    }
  }

  Future<void> markRelatedAsRead(
    String userId,
    String relatedId,
    String type,
  ) async {
    try {
      await _client.patch(
        '/$userId/mark-related',
        data: {'relatedId': relatedId, 'type': type},
      );
    } catch (e) {
      logger.e('❌ Error al marcar relacionadas como leídas', error: e);
    }
  }

  Future<bool> deleteNotificacion(String notificacionId) async {
    try {
      final response = await _client.delete('/$notificacionId');
      return response.statusCode == 200;
    } catch (e) {
      logger.e('❌ Error al eliminar notificación', error: e);
      return false;
    }
  }
}
