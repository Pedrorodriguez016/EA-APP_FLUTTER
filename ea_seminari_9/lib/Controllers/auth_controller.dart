import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart'; // Importar
import '../Models/user.dart';
import '../Interceptor/auth_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();
  String? token;
  String? refreshToken;
  final Dio _client = Dio(BaseOptions(baseUrl: '${dotenv.env['BASE_URL']}/api',
    connectTimeout:const Duration(seconds: 5,),
    receiveTimeout: const Duration(seconds: 5,))
    );
  
  // Nota: corregido constructor, antes ponía UserServices()
  AuthController() {
    _client.interceptors.add(AuthInterceptor());
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      logger.i('🔐 Iniciando login para usuario: $username');
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
        logger.i('✅ Login exitoso para usuario: $username');
        
        return {'success': true, 'message': translate('auth.login.success_msg')};
      } else {
        final errorData = response.data;
        logger.w('❌ Login fallido: ${errorData['error']}');
        // Si el backend devuelve un mensaje, lo mostramos, si no, uno genérico traducido
        return {
          'success': false, 
          'message': errorData['error'] ?? translate('common.error')
        };
      }
    } catch (e) {
      logger.e('❌ Error durante login', error: e);
      return {
        'success': false, 
        'message': '${translate("common.error")}: $e'
      };
    }
  }

  Future<Map<String, dynamic>> register(User newUser) async {
    try {
      logger.i('📝 Registrando nuevo usuario: ${newUser.username}');
      final response = await _client.post('/user', 
        data: {
          "username": newUser.username,
          "gmail": newUser.gmail, 
          "birthday": newUser.birthday, 
          "password": newUser.password,
        },
      );

      if (response.statusCode == 201) {
        logger.i('✅ Registro exitoso para usuario: ${newUser.username}');
        return {'success': true, 'message': translate('auth.register.success_msg')};
      } else {
        final errorData = response.data;
        logger.w('❌ Registro fallido: ${errorData['error']}');
        return {
          'success': false, 
          'message': errorData['error'] ?? translate('common.error')
        };
      }
    } catch (e) {
      logger.e('❌ Error durante registro', error: e);
      return {
        'success': false, 
        'message': '${translate("common.error")}: $e'
      };
    }
  }

  void logout() {
    logger.i('🚪 Usuario cerrando sesión');
    isLoggedIn.value = false;
    currentUser.value = null;
    token = null;
    Get.offAllNamed('/login');
  }

  Future<Map<String, dynamic>> deleteCurrentUser() async {
    try {
      if (currentUser.value == null || token == null) {
        logger.w('⚠️ Intento de eliminar usuario sin autenticación');
        return {'success': false, 'message': 'Usuario no autenticado'}; // Añadir a JSON si deseas
      }

      logger.i('🗑️ Eliminando usuario: ${currentUser.value!.id}');
      final response = await _client.delete('/user/${currentUser.value!.id}');

      if (response.statusCode == 200) {
        logger.i('✅ Usuario eliminado exitosamente');
        logout();
        return {'success': true, 'message': translate('profile.delete_success')};
      } else {
        final errorData = response.data;
        logger.w('❌ Error al eliminar usuario: ${errorData['error']}');
        return {
          'success': false, 
          'message': errorData['error'] ?? translate('common.error')
        };
      }
    } catch (e) {
      logger.e('❌ Error durante eliminación de usuario', error: e);
      return {
        'success': false, 
        'message': '$e'
      };
    }
  }
}