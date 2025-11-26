import 'package:ea_seminari_9/Models/user.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../Interceptor/auth_interceptor.dart';
import '../Controllers/auth_controller.dart';

class UserServices {
  final String baseUrl = 'http://localhost:3000/api/user';
  final AuthController _authController = Get.find<AuthController>();
  
  late final Dio _client;
  
  UserServices(){
    _client = Dio(BaseOptions(baseUrl: baseUrl));
    _client.interceptors.add(AuthInterceptor());
  }

Future<Map<String, dynamic>> fetchUsers({
  int page = 1,
  int limit = 20,
  String q = '',
}) async {
    try {
      final response = await _client.get('/', queryParameters: {
        'page': page,
        'limit': limit,
        if (q.isNotEmpty) 'q': q,
      });

      final responseData = response.data; 
      final List<dynamic> userList = responseData['data'];

      return {
        'users': userList.map((json) => User.fromJson(json)).toList(),
        'totalPages': responseData['totalPages'] ?? 1,
        'currentPage': responseData['page'] ?? 1,
        'total': responseData['totalItems'] ?? 0,
      };
    } catch (e) {

      throw Exception('Error al cargar usuarios: $e');
    }
  }
  Future<User> fetchUserById(String id) async {
    try {
      final response = await _client.get('/$id');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al cargar el usuario: $e');
    }
  }

  Future<User> updateUserById(String id, Map<String, dynamic> newData) async {
    try {
      final updatedData = {
        'username': newData['username'] ?? _authController.currentUser.value?.username,
        'gmail': newData['email'] ?? _authController.currentUser.value?.gmail,
        'birthday': newData['birthday'] ?? _authController.currentUser.value?.birthday,
      };

      // Dio hace el jsonEncode automáticamente
      final response = await _client.put('/$id/self', data: updatedData);

      final user = User(
        id: id,
        username: updatedData['username'],
        gmail: updatedData['gmail'],
        birthday: updatedData['birthday'],
      );
      _authController.currentUser.value = user;
      return user;
    } catch (e) {
      throw Exception('Error al actualizar el usuario: $e');
    }
  }

  Future<bool> disableUserById(String id, password) async {
    try {

      final response = await _client.patch('/$id/delete-with-password',
        data:{
          'password' : password
        }
      );

        print("Usuario eliminado");
        return true;
      } 
    catch (e) {
           print('Error in disableUserByid: $e');
      throw Exception('Error al eliminar el usuario: $e');
    }
  }
  Future<List<User>> fetchFriends(String id) async {
    try {
    final response = await _client.get('/$id/friends');
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> userList = responseData['data'];
      return userList.map((json) => User.fromJson(json)).toList();
    }
    catch (e) {
      print('Error in fetchFriends: $e');
      throw Exception('Error al cargar amigos: $e');
    }
  }
Future<List<User>> fetchRequest(String id) async {
  try {
  final response = await _client.get('/friend-requests/$id');

    final decoded = response.data;

    if (decoded is List) {
      return decoded.map((json) => User.fromJson(json)).toList();
    } 
      throw Exception('Formato inesperado: se esperaba una lista');
  }
  catch (e) {
    print('Error in fetchRequest: $e');
    throw Exception('Error al cargar solicitudes: $e');
  }
}
Future<void> acceptFriendRequest(String userId, String requesterId) async {
  try{
  final response = await _client.post('/friend-accept/',
    data: 
    {
      'id': userId,
      'requesterId': requesterId
    });
  }
  catch (e) {
    print('Error in acceptFriendRequest: $e');
    throw Exception('Error al aceptar solicitud: $e');
  }
}

Future<void> rejectFriendRequest(String userId, String requesterId) async {
  try{
  final response = await _client.post('/friend-reject/',
    data: {
      'id': userId,
      'requesterId': requesterId
    }
  );}
  catch (e) {
    print('Error in rejectFriendRequest: $e');
    throw Exception('Error al rechazar solicitud: $e');
  }
} 
Future<void> sendFriendRequest(String userId, String targetUserId) async {
  try{
  final response = await _client.post('/friend-request/',
    data: {
      'id': userId,
      'targetId': targetUserId
    }
  );
  }
  catch (e) {
    print('Error in sendFriendRequest: $e');
    throw Exception('Error al enviar solicitud: $e');
  }
}
  Future<User?> getUserByUsername(String username) async {
    try {
      final response = await _client.get('/by-username/$username');
      return User.fromJson(response.data);
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('Usuario no encontrado: $username');
        return null; 
      }
      
      throw Exception('Error al buscar usuario por username: ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido al buscar usuario: $e');
    }
  }
}
