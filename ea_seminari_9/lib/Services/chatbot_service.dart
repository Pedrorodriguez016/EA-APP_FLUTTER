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

  Future<Map<String, dynamic>> sendQuery(String query) async {
    try {
      logger.d('🤖 Enviando query al chatbot: $query');
      logger.d('🔗 URL completa: ${_client.options.baseUrl}/search');

      final response = await _client.post('/search', data: {'query': query});

      logger.i('✅ Respuesta del chatbot recibida');

      final data = response.data;
      final int count = (data['count'] is int) ? data['count'] : 0;
      final List events = (data['data'] is List) ? data['data'] : [];

      String responseText;
      if (count == 0) {
        responseText =
            "No he encontrado eventos que coincidan con tu búsqueda.";
      } else {
        final names = events.map((e) => "- ${e['name']}").join('\n');
        responseText = "He encontrado $count eventos:\n$names";
      }

      return {'text': responseText, 'events': events};
    } catch (e) {
      logger.e('❌ Error consultando el chatbot', error: e);
      throw Exception('Error al conectar con el asistente');
    }
  }
}
