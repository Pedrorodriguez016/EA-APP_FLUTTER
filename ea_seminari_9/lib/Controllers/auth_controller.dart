import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart'; // Importar
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
  
  // Nota: corregido constructor, antes ponía UserServices()
  AuthController() {
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
        
        return {'success': true, 'message': translate('auth.login.success_msg')};
      } else {
        final errorData = response.data;
        // Si el backend devuelve un mensaje, lo mostramos, si no, uno genérico traducido
        return {
          'success': false, 
          'message': errorData['error'] ?? translate('common.error')
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': '${translate("common.error")}: $e'
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

      if (response.statusCode == 201) {
        return {'success': true, 'message': translate('auth.register.success_msg')};
      } else {
        final errorData = response.data;
        return {
          'success': false, 
          'message': errorData['error'] ?? translate('common.error')
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': '${translate("common.error")}: $e'
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
        return {'success': false, 'message': 'Usuario no autenticado'}; // Añadir a JSON si deseas
      }

      final response = await _client.delete('/user/${currentUser.value!.id}');

      if (response.statusCode == 200) {
        logout();
        return {'success': true, 'message': translate('profile.delete_success')};
      } else {
        final errorData = response.data;
        return {
          'success': false, 
          'message': errorData['error'] ?? translate('common.error')
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': '$e'
      };
    }
  }
}