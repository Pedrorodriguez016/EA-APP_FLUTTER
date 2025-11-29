import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../Controllers/auth_controller.dart';

class AuthInterceptor extends Interceptor {
  AuthController get _auth => Get.find<AuthController>();

  final Dio _tokenDio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api',
    connectTimeout:const Duration(seconds: 5,),
    receiveTimeout: const Duration(seconds: 5,))
    );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';
    final token = _auth.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    print('Enviando request a: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      print('Token expirado (401). Intentando refrescar...');
      
      final refreshToken = _auth.refreshToken;
      final userId = _auth.currentUser.value?.id;

      if (refreshToken != null && userId != null) {
        try {
          final response = await _tokenDio.post('/user/refresh', data: {
            'refreshToken': refreshToken,
            'userId': userId,
          });

          if (response.statusCode == 200) {
            final newAccessToken = response.data['token'] as String?;
            final newRefreshToken = response.data['refreshToken'] as String?;
            
            _auth.token = newAccessToken;
            if (newRefreshToken != null) {
              _auth.refreshToken = newRefreshToken;
            }

            // REINTENTAR la petición original con el nuevo token
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';

            // Clonamos la petición original y la reenviamos usando la instancia de Dio original (err.requestOptions.extra)
            final clonedRequest = await Dio().fetch(opts); 
            
            // Resolvemos la promesa original con el resultado del reintento
            return handler.resolve(clonedRequest);
          }
        } catch (e) {
          // Si falla el refresh, logout
          print('Fallo al refrescar token: $e');
          _auth.logout();
          Get.offAllNamed('/login');
        }
      } else {
        // No hay refresh token
        _auth.logout();
        Get.offAllNamed('/login');
      }
    }
    
    // Si no fue 401 o falló el refresh, devolvemos el error original
    super.onError(err, handler);
  }
}