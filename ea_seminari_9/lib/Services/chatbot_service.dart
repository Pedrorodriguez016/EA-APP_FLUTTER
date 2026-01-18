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

  Future<Map<String, dynamic>> sendQuery(String query, String userId) async {
    try {
      logger.d('🤖 Enviando query al chatbot: $query (UID: $userId)');
      logger.d('🔗 URL completa: ${_client.options.baseUrl}/search');

      final response = await _client.post(
        '/search',
        data: {'query': query, 'userId': userId},
      );

      logger.i('✅ Respuesta del chatbot recibida');

      final data = response.data;
      final String answer = data['answer'] ?? '';
      final List events = (data['data'] is List) ? data['data'] : [];

      // Si el backend no devuelve un texto procesado por la IA, usamos un fallback
      String responseText = answer;
      if (responseText.isEmpty) {
        if (events.isEmpty) {
          responseText =
              'No he encontrado eventos que coincidan con tu búsqueda.';
        } else {
          final names = events.map((e) => "- ${e['name']}").join('\n');
          responseText = 'He encontrado ${events.length} eventos:\n$names';
        }
      }

      return {'text': responseText, 'events': events};
    } catch (e) {
      logger.e('❌ Error consultando el chatbot', error: e);
      throw Exception('Error al conectar con el asistente');
    }
  }
}
