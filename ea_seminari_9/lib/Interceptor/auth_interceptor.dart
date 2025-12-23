import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../Controllers/auth_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class AuthInterceptor extends Interceptor {
  AuthController get _auth => Get.find<AuthController>();

  final Dio _tokenDio = Dio(
    BaseOptions(
      baseUrl: '${dotenv.env['BASE_URL']}/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';
    final token = _auth.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    logger.d(
      '📤 Enviando request a: ${options.path} - Método: ${options.method}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      logger.w('⚠️ Token expirado (401). Intentando refrescar...');

      final refreshToken = _auth.refreshToken;
      final userId = _auth.currentUser.value?.id;

      if (refreshToken != null && userId != null) {
        try {
          logger.d('🔄 Refrescando token para usuario: $userId');
          final response = await _tokenDio.post(
            '/user/refresh',
            data: {'refreshToken': refreshToken, 'userId': userId},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['token'] as String?;
            final newRefreshToken = response.data['refreshToken'] as String?;

            _auth.token = newAccessToken;
            if (newRefreshToken != null) {
              _auth.refreshToken = newRefreshToken;
            }
            logger.i('✅ Token refrescado exitosamente');

            // REINTENTAR la petición original con el nuevo token
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';

            // Clonamos la petición original y la reenviamos usando la instancia de Dio original (err.requestOptions.extra)
            final clonedRequest = await Dio().fetch(opts);
            logger.d('🔄 Reintentando request: ${opts.path}');

            // Resolvemos la promesa original con el resultado del reintento
            return handler.resolve(clonedRequest);
          }
        } catch (e) {
          // Si falla el refresh, logout
          logger.e('❌ Fallo al refrescar token', error: e);
          _auth.logout();
          Get.offAllNamed('/login');
        }
      } else {
        // No hay refresh token
        logger.w('❌ No hay refresh token disponible. Cerrando sesión.');
        _auth.logout();
        Get.offAllNamed('/login');
      }
    }

    logger.e(
      '🚨 Error en request: ${err.requestOptions.path} - ${err.response?.statusCode} ${err.message}',
      error: err,
    );
    // Si no fue 401 o falló el refresh, devolvemos el error original
    super.onError(err, handler);
  }
}
