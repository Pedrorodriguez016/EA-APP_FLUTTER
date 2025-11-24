import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../Models/user.dart';
import '../Interceptor/auth_interceptor.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();
  String? token;
  String? refreshToken;
  final Dio _client = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api',
    connectTimeout:const Duration(seconds: 5,),
    receiveTimeout: const Duration(seconds: 5,))
    );
  UserServices() {
    // Añadimos nuestro interceptor
    _client.interceptors.add(AuthInterceptor());
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _client.post('/user/auth/login', 
        data: {
          'username': username,
          'password': password,
        },
      );
        

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.data}');

      if (response.statusCode == 200) {
        final user = response.data;
        final userData = user['user'];
        
        currentUser.value = User.fromJson({
          ...userData,
          'token': user['token'],
          'refreshToken': user['refreshToken'],
        });
        
        token = user['token'];
        refreshToken = user['refreshToken'];
        isLoggedIn.value = true;
        print('token $token refrehtoken, $refreshToken');
        
        return {'success': true, 'message': 'Login exitoso'};
      } else {
        final errorData = response.data;
        return {
          'success': false, 
          'message': errorData['error'] ?? 'Error en el login - Código: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error en login: $e');
      return {
        'success': false, 
        'message': 'Error de conexión: $e'
      };
    }
  }

  Future<Map<String, dynamic>> register(User newUser) async {
    try {
      final response = await _client.post('/user', 
        data: {
          "username": newUser.username,
        "gmail": newUser.gmail, 
        "birthday": newUser.birthday, 
        "password": newUser.password,
        },
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.data}');

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Usuario registrado exitosamente'};
      } else {
        final errorData = response.data;
        return {
          'success': false, 
          'message': errorData['error'] ?? 'Error en el registro - Código: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error en registro: $e');
      return {
        'success': false, 
        'message': 'Error de conexión: $e'
      };
    }
  }

  void logout() {
    isLoggedIn.value = false;
    currentUser.value = null;
    token = null;
    Get.offAllNamed('/login');
    
  }

  Future<Map<String, dynamic>> deleteCurrentUser() async {
    try {
      if (currentUser.value == null || token == null) {
        return {'success': false, 'message': 'Usuario no autenticado'};
      }

      final response = await _client.delete('/user/${currentUser.value!.id}',
      );

      if (response.statusCode == 200) {
        logout();
        return {'success': true, 'message': 'Usuario eliminado exitosamente'};
      } else {
        final errorData = response.data;
        return {
          'success': false, 
          'message': errorData['error'] ?? 'Error al eliminar el usuario'
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': 'Error de conexión: $e'
      };
    }
  }
}