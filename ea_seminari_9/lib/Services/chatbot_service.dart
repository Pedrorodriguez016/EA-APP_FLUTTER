import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Interceptor/auth_interceptor.dart';
import '../utils/logger.dart';

class ChatBotService {
  final String baseUrl = '${dotenv.env['BASE_URL']}/api/ai';
  late final Dio _client;

  ChatBotService() {
    _client = Dio(BaseOptions(baseUrl: baseUrl));
    _client.interceptors.add(AuthInterceptor());
  }

  Future<Map<String, dynamic>> sendQuery(
    String query,
    String userId, {
    String language = 'es',
  }) async {
    try {
      logger.d(
        '🤖 Enviando query al chatbot: $query (UID: $userId, LANG: $language)',
      );
      logger.d('🔗 URL completa: ${_client.options.baseUrl}/search');

      final response = await _client.post(
        '/search',
        data: {'query': query, 'userId': userId, 'language': language},
      );

      logger.i('✅ Respuesta del chatbot recibida');

      final data = response.data;
      final String answer = data['answer'] ?? '';
      final List events = (data['data'] is List) ? data['data'] : [];

      return {'answer': answer, 'events': events};
    } catch (e) {
      logger.e('❌ Error consultando el chatbot', error: e);
      throw Exception('Error al conectar con el asistente');
    }
  }
}
