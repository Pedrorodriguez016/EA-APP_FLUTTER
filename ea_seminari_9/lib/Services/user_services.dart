import 'dart:ffi';

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

  Future<List<User>> fetchUsers() async {
    final response = await _client.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> userList = responseData['data'];
      return userList.map((json) => User.fromJson(json)).toList();
    }
     else {
      throw Exception('Failed to load users');
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
        print("Usuario actualizado ${updatedUser}");
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

}