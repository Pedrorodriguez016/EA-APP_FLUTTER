import 'package:ea_seminari_9/Models/user.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../Interceptor/auth_interceptor.dart';
import '../Controllers/auth_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class UserServices {
  final String baseUrl = '${dotenv.env['BASE_URL']}/api/user';
  final AuthController _authController = Get.find<AuthController>();

  late final Dio _client;

  UserServices() {
    _client = Dio(BaseOptions(baseUrl: baseUrl));
    _client.interceptors.add(AuthInterceptor());
  }

  Future<Map<String, dynamic>> fetchUsers({
    int page = 1,
    int limit = 20,
    String q = '',
  }) async {
    try {
      logger.d('📑 Obteniendo usuarios - Página: $page, Límite: $limit');
      final response = await _client.get(
        '/',
        queryParameters: {'page': page, 'limit': limit},
      );

      final responseData = response.data;
      final List<dynamic> userList = responseData['data'];
      logger.i('✅ Usuarios obtenidos: ${userList.length} usuarios');

      return {
        'users': userList.map((json) => User.fromJson(json)).toList(),
        'totalPages': responseData['totalPages'] ?? 1,
        'currentPage': responseData['page'] ?? 1,
        'total': responseData['totalItems'] ?? 0,
      };
    } catch (e) {
      logger.e('❌ Error al cargar usuarios', error: e);
      throw Exception('Error al cargar usuarios: $e');
    }
  }

  Future<User> fetchUserById(String id) async {
    try {
      logger.d('📑 Obteniendo usuario con ID: $id');
      final response = await _client.get('/$id');
      logger.i('✅ Usuario obtenido: ${response.data['username']}');
      return User.fromJson(response.data);
    } catch (e) {
      logger.e('❌ Error al cargar el usuario: $id', error: e);
      throw Exception('Error al cargar el usuario: $e');
    }
  }

  Future<User> updateUserById(String id, Map<String, dynamic> newData) async {
    try {
      logger.i('📁 Actualizando usuario: $id');
      final updatedData = {
        'username':
            newData['username'] ?? _authController.currentUser.value?.username,
        'gmail': newData['email'] ?? _authController.currentUser.value?.gmail,
        'birthday':
            newData['birthday'] ?? _authController.currentUser.value?.birthday,
      };

      // Dio hace el jsonEncode automáticamente
      await _client.put('/$id/self', data: updatedData);
      logger.i('✅ Usuario actualizado exitosamente');

      final user = User(
        id: id,
        username: updatedData['username'],
        gmail: updatedData['gmail'],
        birthday: updatedData['birthday'],
      );
      _authController.currentUser.value = user;
      return user;
    } catch (e) {
      logger.e('❌ Error al actualizar el usuario', error: e);
      throw Exception('Error al actualizar el usuario: $e');
    }
  }

  Future<bool> disableUserById(String id, password) async {
    try {
      logger.i('🗑️ Eliminando usuario: $id');
      await _client.patch(
        '/$id/delete-with-password',
        data: {'password': password},
      );

      logger.i('✅ Usuario eliminado exitosamente');
      return true;
    } catch (e) {
      logger.e('❌ Error al eliminar usuario', error: e);
      throw Exception('Error al eliminar el usuario: $e');
    }
  }

  Future<Map<String, dynamic>> fetchFriends(
    String id, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      logger.d('👥 Obteniendo amigos del usuario: $id - Página: $page');
      final response = await _client.get(
        '/$id/friends',
        queryParameters: {'page': page, 'limit': limit},
      );
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> userList = responseData['data'];
      logger.i('✅ Amigos obtenidos: ${userList.length} amigos');

      return {
        'friends': userList.map((json) => User.fromJson(json)).toList(),
        'totalPages': responseData['totalPages'] ?? 1,
        'currentPage': responseData['page'] ?? 1,
      };
    } catch (e) {
      logger.e('❌ Error al cargar amigos', error: e);
      throw Exception('Error al cargar amigos: $e');
    }
  }

  Future<List<User>> fetchRequest(String id) async {
    try {
      logger.d('📄 Obteniendo solicitudes de amistad para: $id');
      final response = await _client.get('/friend-requests/$id');

      final decoded = response.data;

      if (decoded is List) {
        logger.i('✅ Solicitudes obtenidas: ${decoded.length} solicitudes');
        return decoded.map((json) => User.fromJson(json)).toList();
      }
      logger.w('⚠️ Formato inesperado en respuesta de solicitudes');
      throw Exception('Formato inesperado: se esperaba una lista');
    } catch (e) {
      logger.e('❌ Error al cargar solicitudes', error: e);
      throw Exception('Error al cargar solicitudes: $e');
    }
  }

  Future<void> acceptFriendRequest(String userId, String requesterId) async {
    try {
      logger.i('👍 Aceptando solicitud de amistad de: $requesterId');
      await _client.post(
        '/friend-accept/',
        data: {'id': userId, 'requesterId': requesterId},
      );
      logger.i('✅ Solicitud aceptada exitosamente');
    } catch (e) {
      logger.e('❌ Error al aceptar solicitud', error: e);
      throw Exception('Error al aceptar solicitud: $e');
    }
  }

  Future<void> rejectFriendRequest(String userId, String requesterId) async {
    try {
      logger.i('🚫 Rechazando solicitud de amistad de: $requesterId');
      await _client.post(
        '/friend-reject/',
        data: {'id': userId, 'requesterId': requesterId},
      );
      logger.i('✅ Solicitud rechazada exitosamente');
    } catch (e) {
      logger.e('❌ Error al rechazar solicitud', error: e);
      throw Exception('Error al rechazar solicitud: $e');
    }
  }

  Future<void> sendFriendRequest(String userId, String targetUserId) async {
    try {
      logger.i('📤 Enviando solicitud de amistad a: $targetUserId');
      await _client.post(
        '/friend-request/',
        data: {'id': userId, 'targetId': targetUserId},
      );
      logger.i('✅ Solicitud de amistad enviada exitosamente');
    } catch (e) {
      logger.e('❌ Error al enviar solicitud', error: e);
      throw Exception('Error al enviar solicitud: $e');
    }
  }

  Future<User?> getUserByUsername(String username) async {
    try {
      logger.d('📑 Buscando usuario por username: $username');
      final response = await _client.get('/by-username/$username');
      logger.i('✅ Usuario encontrado: $username');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        logger.w('⚠️ Usuario no encontrado: $username');
        return null;
      }
      logger.e('❌ Error al buscar usuario', error: e);
      throw Exception('Error al buscar usuario por username: ${e.message}');
    } catch (e) {
      logger.e('❌ Error desconocido al buscar usuario', error: e);
      throw Exception('Error desconocido al buscar usuario: $e');
    }
  }
}
