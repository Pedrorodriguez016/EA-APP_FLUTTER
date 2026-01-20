import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Models/user.dart';
import '../Interceptor/auth_interceptor.dart';
import '../utils/logger.dart';

class AuthService {
  late final Dio _client;

  AuthService() {
    _client = Dio(
      BaseOptions(
        baseUrl: '${dotenv.env['BASE_URL']}/api',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    _client.interceptors.add(AuthInterceptor());
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      logger.d('📡 POST /user/auth/login - username: $username');
      final response = await _client.post(
        '/user/auth/login',
        data: {'username': username, 'password': password},
      );
      logger.i('✅ Login HTTP OK para usuario: $username');
      return response.data;
    } catch (e) {
      logger.e('❌ Error en login HTTP para usuario: $username', error: e);
      rethrow;
    }
  }

  Future<dynamic> register(User newUser) async {
    try {
      logger.d(
        '📡 POST /auth/register - registrando usuario: ${newUser.username}',
      );
      final response = await _client.post(
        '/auth/register',
        data: {
          'username': newUser.username,
          'gmail': newUser.gmail,
          'birthday': newUser.birthday,
          'password': newUser.password,
        },
      );
      logger.i('✅ Registro HTTP OK para usuario: ${newUser.username}');
      return response.data;
    } catch (e) {
      logger.e(
        '❌ Error en registro HTTP para usuario: ${newUser.username}',
        error: e,
      );
      rethrow;
    }
  }

  // Google Login: Envía el idToken al backend para validación
  Future<Map<String, dynamic>> loginWithGoogle(
    String idToken, {
    String? birthday,
    String? username,
  }) async {
    try {
      logger.d('📡 POST /auth/google - Enviando idToken');
      final Map<String, dynamic> data = {'credential': idToken};
      if (birthday != null) data['birthday'] = birthday;
      if (username != null) data['username'] = username;

      final response = await _client.post('/auth/google', data: data);
      logger.i('✅ Google Login HTTP OK');
      return response.data;
    } catch (e) {
      logger.e('❌ Error en Google login HTTP', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkGoogleUser(String idToken) async {
    try {
      logger.d('📡 POST /user/auth/google/check - Comprobando usuario');
      // Fix: this endpoint is in usuarioRoutes (mounted at /api/user)
      final response = await _client.post(
        '/user/auth/google/check',
        data: {'credential': idToken},
      );
      logger.i('✅ Check Google User HTTP OK');
      return response.data;
    } catch (e) {
      logger.e('❌ Error en check Google User HTTP', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String otp) async {
    try {
      logger.d('📡 POST /auth/verify-email - email: $email');
      final response = await _client.post(
        '/auth/verify-email',
        data: {'email': email, 'otp': otp},
      );
      logger.i('✅ Email verificado correctamente para: $email');
      return response.data;
    } catch (e) {
      logger.e('❌ Error verificando email para: $email', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resendVerification(String email) async {
    try {
      logger.d('📡 POST /auth/resend-verification - email: $email');
      final response = await _client.post(
        '/auth/resend-verification',
        data: {'email': email},
      );
      logger.i('✅ Código reenviado a: $email');
      return response.data;
    } catch (e) {
      logger.e('❌ Error reenviando código a: $email', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      logger.d('📡 POST /auth/forgot-password - email: $email');
      final response = await _client.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      logger.i('✅ Solicitud cambio contraseña enviada a: $email');
      return response.data;
    } catch (e) {
      logger.e('❌ Error solicitando cambio contraseña para: $email', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      logger.d('📡 POST /auth/reset-password - email: $email');
      final response = await _client.post(
        '/auth/reset-password',
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );
      logger.i('✅ Contraseña restablecida correctamente para: $email');
      return response.data;
    } catch (e) {
      logger.e('❌ Error restableciendo contraseña para: $email', error: e);
      rethrow;
    }
  }
}
