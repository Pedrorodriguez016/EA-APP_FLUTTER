import 'package:ea_seminari_9/Models/user.dart';
import 'dart:convert';
import 'package:get/get.dart';
import '../Interceptor/auth_interceptor.dart';
import '../Controllers/auth_controller.dart';

class UserServices {
  final String baseUrl = 'http://localhost:3000/api/user';
  final AuthController _authController= Get.put(AuthController());
  final AuthInterceptor _client = Get.put(AuthInterceptor());
  UserServices();

Future<Map<String, dynamic>> fetchUsers({
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
    final List<dynamic> userList = responseData['data'];

    return {
      'users': userList.map((json) => User.fromJson(json)).toList(),
      'totalPages': responseData['totalPages'] ?? 1,
      'currentPage': responseData['page'] ?? 1,       
      'total': responseData['totalItems'] ?? 0, 
    };


  } else {
    throw Exception('Error al cargar usuarios paginados');
  }
}
  Future<User> fetchUserById(String id) async {
    try {
      
      final response = await _client.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Error al cargar el usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchUserById: $e');
      throw Exception('Error al cargar el usuario: $e');
    }
  }

  Future<User> updateUserById(String id, Map<String, dynamic> newData) async {
    try {
      final updatedUser = User(
        id: id,
        username: newData['username'] ?? _authController.currentUser.value?.username ?? '',
        gmail: newData['email'] ?? _authController.currentUser.value?.gmail ?? '',
        birthday: newData['birthday'] ?? _authController.currentUser.value?.birthday ?? '',
      );
      final response = await _client.put(Uri.parse('$baseUrl/$id/self'),
      body: jsonEncode({
        'username': updatedUser.username,
        'gmail': updatedUser.gmail,
        'birthday': updatedUser.birthday,
      }),
      );
      if (response.statusCode == 200){
        print("Usuario actualizado $updatedUser");
      _authController.currentUser.value = updatedUser;
      return updatedUser;
      }
      else{
        throw Exception('Error al actualizar el usuario: ${response.statusCode}');
      }
    } catch (e) {
           print('Error in updateUserByid: $e');
      throw Exception('Error al actualizar el usuario: $e');

    }
  }

  Future<bool> disableUserById(String id, password) async {
    try {

      final response = await _client.patch(Uri.parse('$baseUrl/$id/delete-with-password'),
      body: 
      jsonEncode({
      'password' : password}),
      );
      if (response.statusCode == 204){
        print("Usuario eliminado");
        return true;
      }
      else{
        throw Exception('Error al actualizar el usuario: ${response.statusCode}');
      }
    } catch (e) {
           print('Error in disableUserByid: $e');
      throw Exception('Error al eliminar el usuario: $e');
    }
  }
  Future<List<User>> fetchFriends(String id) async {
    final response = await _client.get(Uri.parse('$baseUrl/$id/friends'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> userList = responseData['data'];
      return userList.map((json) => User.fromJson(json)).toList();
    }
     else {
      throw Exception('Failed to load users');
    }
  }
Future<List<User>> fetchRequest(String id) async {
  final response = await _client.get(Uri.parse('$baseUrl/friend-requests/$id'));

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);

    if (decoded is List) {
      return decoded.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Formato inesperado: se esperaba una lista');
    }
  } else {
    throw Exception('Error ${response.statusCode} al obtener solicitudes');
  }
}
Future<void> acceptFriendRequest(String userId, String requesterId) async {
  final response = await _client.post(
    Uri.parse('$baseUrl/friend-accept/'),
    body: 
    jsonEncode({
      'id': userId,
      'requesterId': requesterId
    }
    )
  );

  if (response.statusCode != 200) {
    throw Exception('Error al aceptar solicitud: ${response.body}');
  }
}

Future<void> rejectFriendRequest(String userId, String requesterId) async {
  final response = await _client.post(
    Uri.parse('$baseUrl/friend-reject/'),
    body: 
    jsonEncode({
      'id': userId,
      'requesterId': requesterId
    })
  );

  if (response.statusCode != 200) {
    throw Exception('Error al rechazar solicitud: ${response.body}');
  }
} 
Future<void> sendFriendRequest(String userId, String targetUserId) async {
  final response = await _client.post(
    Uri.parse('$baseUrl/friend-request/'),
    body: 
    jsonEncode({
      'id': userId,
      'targetId': targetUserId
    })
  );

  if (response.statusCode != 200) {
    throw Exception('Error al enviar solicitud: ${response.body}');
  }
}
}
