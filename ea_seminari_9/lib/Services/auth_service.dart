import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Models/user.dart';
import '../Interceptor/auth_interceptor.dart';
import '../utils/logger.dart';

class AuthService {
  late final Dio _client;

  AuthService() {
    _client = Dio(BaseOptions(
      baseUrl: '${dotenv.env['BASE_URL']}/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ));
    // Agregamos el interceptor para manejar tokens automáticamente
    _client.interceptors.add(AuthInterceptor());
  }

  // Login: Devuelve la respuesta cruda (Map) o lanza un error
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      logger.d('📡 POST /user/auth/login - username: $username');
      final response = await _client.post('/user/auth/login', data: {
        'username': username,
        'password': password,
      });
      logger.i('✅ Login HTTP OK para usuario: $username');
      return response.data;
    } catch (e) {
      logger.e('❌ Error en login HTTP para usuario: $username', error: e);
      throw e;
    }
  }

  // Register
  Future<dynamic> register(User newUser) async {
    try {
      logger.d('📡 POST /user - registrando usuario: ${newUser.username}');
      final response = await _client.post('/user', data: {
        "username": newUser.username,
        "gmail": newUser.gmail,
        "birthday": newUser.birthday,
        "password": newUser.password,
      });
      logger.i('✅ Registro HTTP OK para usuario: ${newUser.username}');
      return response.data;
    } catch (e) {
      logger.e('❌ Error en registro HTTP para usuario: ${newUser.username}', error: e);
      throw e;
    }
  }
}