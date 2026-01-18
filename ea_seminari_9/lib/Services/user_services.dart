import 'package:ea_seminari_9/Models/user.dart';
import 'package:dio/dio.dart' as d;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../Interceptor/auth_interceptor.dart';
import '../Controllers/auth_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';
import 'dart:io';

class UserServices {
  final String baseUrl = '${dotenv.env['BASE_URL']}/api/user';
  final AuthController _authController = Get.find<AuthController>();

  late final d.Dio _client;

  UserServices() {
    _client = d.Dio(d.BaseOptions(baseUrl: baseUrl));
    _client.interceptors.add(AuthInterceptor());
  }

  Future<Map<String, dynamic>> fetchVisibleUsers({
    int page = 1,
    int limit = 20,
    String? query,
  }) async {
    try {
      logger.d(
        '📑 Obteniendo usuarios visibles - Página: $page, Límite: $limit${query != null ? ", Búsqueda: $query" : ""}',
      );
      final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      final response = await _client.get(
        '/visibleusers',
        queryParameters: queryParams,
      );

      final responseData = response.data;
      final List<dynamic> userList = responseData['data'] ?? [];
      logger.i(
        '✅ Usuarios visibles obtenidos: ${userList.length} usuarios, Total: ${responseData['totalItems']}',
      );

      return {
        'users': userList.map((json) => User.fromJson(json)).toList(),
        'totalPages': responseData['totalPages'] ?? 1,
        'currentPage': responseData['page'] ?? 1,
        'total': responseData['totalItems'] ?? 0,
      };
    } catch (e) {
      logger.e('❌ Error al cargar usuarios visibles', error: e);
      throw Exception('Error al cargar usuarios visibles: $e');
    }
  }

  Future<User> fetchUserById(String id) async {
    if (id.isEmpty) {
      logger.e('Error: ID de usuario vacío en fetchUserById');
      throw Exception('ID de usuario vacío');
    }
    try {
      logger.d('Obteniendo usuario con ID: $id');
      final response = await _client.get('/$id');
      logger.i('Usuario obtenido: ${response.data['username']}');
      return User.fromJson(response.data);
    } catch (e) {
      logger.e('Error al cargar el usuario: $id', error: e);
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
        profilePhoto:
            _authController.currentUser.value?.profilePhoto, // Mantener la foto
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
    } on d.DioException catch (e) {
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

  // --- MÉTODOS DE FOTO DE PERFIL ---

  String? getFullPhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return null;
    if (photoPath.startsWith('http')) return photoPath;

    final serverUrl = _client.options.baseUrl.replaceAll('/api/user', '');
    return '$serverUrl$photoPath';
  }

  Future<User?> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      logger.i('📤 Subiendo foto de perfil para: $userId');

      String fileName = imageFile.path.split('/').last;
      final formData = d.FormData.fromMap({
        'photo': await d.MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _client.post(
        '/$userId/profile-photo',
        data: formData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        if (data['ok'] == true && data['user'] != null) {
          final updatedUser = User.fromJson(data['user']);
          _authController.currentUser.value = updatedUser;
          logger.i('✅ Foto de perfil subida exitosamente');
          return updatedUser;
        }
      }
      throw Exception(
        'Error al subir la foto de perfil: ${response.statusCode}',
      );
    } catch (e) {
      logger.e('❌ Error en uploadProfilePhoto', error: e);
      throw Exception('Error al subir la foto de perfil: $e');
    }
  }

  Future<bool> deleteProfilePhoto(String userId) async {
    try {
      logger.i('🗑️ Eliminando foto de perfil: $userId');
      final response = await _client.delete('/$userId/profile-photo');

      if (response.statusCode == 200) {
        final currentUser = _authController.currentUser.value;
        if (currentUser != null) {
          _authController.currentUser.value = User(
            id: currentUser.id,
            username: currentUser.username,
            gmail: currentUser.gmail,
            birthday: currentUser.birthday,
            profilePhoto: null,
            token: currentUser.token,
            refreshToken: currentUser.refreshToken,
            online: currentUser.online,
          );
        }
        logger.i('✅ Foto de perfil eliminada exitosamente');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('❌ Error en deleteProfilePhoto', error: e);
      return false;
    }
  }

  Future<void> blockUser(String blockId) async {
    try {
      final myId = _authController.currentUser.value!.id;
      logger.i('Bloqueando usuario: $blockId');
      await _client.post('/info/block', data: {'id': myId, 'blockId': blockId});
      logger.i('Usuario bloqueado exitosamente');
    } catch (e) {
      logger.e(' Error al bloquear usuario', error: e);
      throw Exception('Error al bloquear usuario: $e');
    }
  }

  Future<void> unblockUser(String unblockId) async {
    try {
      final myId = _authController.currentUser.value!.id;
      logger.i('Desbloqueando usuario: $unblockId');
      await _client.post(
        '/info/unblock',
        data: {'id': myId, 'unblockId': unblockId},
      );
      logger.i(' Usuario desbloqueado exitosamente');
    } catch (e) {
      logger.e('Error al desbloquear usuario', error: e);
      throw Exception('Error al desbloquear usuario: $e');
    }
  }

  Future<List<User>> fetchBlockedUsers() async {
    try {
      final myId = _authController.currentUser.value!.id;
      logger.d('Obteniendo lista de usuarios bloqueados para: $myId');
      final response = await _client.get('/$myId/blocked');

      if (response.data is List) {
        final List<dynamic> blockedList = response.data;
        logger.i('Usuarios bloqueados obtenidos: ${blockedList.length}');
        return blockedList.map((json) => User.fromJson(json)).toList();
      }
      logger.w('Formato inesperado en respuesta de bloqueados');
      return [];
    } catch (e) {
      logger.e('Error al cargar usuarios bloqueados', error: e);
      throw Exception('Error al cargar usuarios bloqueados: $e');
    }
  }

  Future<List<dynamic>> fetchChatHistory(String userId, String friendId) async {
    try {
      logger.d('📑 Cargando historial de chat entre $userId y $friendId');
      final response = await _client.get('/$userId/chat/$friendId');
      logger.i(
        '✅ Historial de chat cargado: ${(response.data as List).length} mensajes',
      );
      return response.data;
    } catch (e) {
      logger.e('❌ Error al cargar historial de chat', error: e);
      return [];
    }
  }

  Future<List<dynamic>> fetchEventChatHistory(String eventId) async {
    try {
      logger.d('📑 Cargando historial de chat para evento: $eventId');
      final response = await _client.get('/events/$eventId/chat');
      logger.i(
        '✅ Historial de chat de evento cargado: ${(response.data as List).length} mensajes',
      );
      return response.data;
    } catch (e) {
      logger.e('❌ Error al cargar historial de chat de evento', error: e);
      return [];
    }
  }

  Future<String> uploadChatImage(
    String userId,
    String friendId,
    String filePath,
  ) async {
    try {
      logger.i('📤 Subiendo imagen al chat con: $friendId');
      String fileName = filePath.split('/').last;

      d.FormData formData = d.FormData.fromMap({
        "image": await d.MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _client.post(
        '/$userId/chat/$friendId/image',
        data: formData,
      );

      logger.i('✅ Imagen de chat subida exitosamente');
      return response.data['imageUrl'];
    } catch (e) {
      logger.e('❌ Error al subir imagen al chat', error: e);
      throw Exception('Error al subir la imagen del chat: $e');
    }
  }

  Future<bool> updateInterests(List<String> interests) async {
    try {
      logger.i('🌟 Actualizando intereses del usuario');
      final response = await _client.post(
        '/interests/update',
        data: {'interests': interests},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        if (data['ok'] == true && data['user'] != null) {
          final updatedUser = User.fromJson(data['user']);
          _authController.currentUser.value = updatedUser;
          logger.i('✅ Intereses actualizados exitosamente');
          return true;
        }
      }
      return false;
    } catch (e) {
      logger.e('❌ Error en updateInterests', error: e);
      return false;
    }
  }
}
