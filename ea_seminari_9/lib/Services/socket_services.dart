import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class SocketService extends GetxService {
  late IO.Socket _socket;
  final String _url = '${dotenv.env['BASE_URL']}';

  void connectWithUserId(String userId) {
    logger.i('🔌 Iniciando conexión Socket con usuario: $userId');
    // Configuración del cliente
    _socket = IO.io(
      _url,
      IO.OptionBuilder()
          .setTransports(['websocket']) // forzar WebSockets
          .disableAutoConnect() // conectamos manualmente
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      logger.i('✅ Conectado al Socket Server');

      // Emitimos el evento que tu backend espera en la línea 63
      _socket.emit('user:online', userId);
      logger.d('📤 Evento user:online emitido para: $userId');
    });

    _socket.on('user:online', (data) {
      logger.d('📥 Servidor confirmó usuario online: $data');
    });

    _socket.onDisconnect((_) => logger.i('❌ Desconectado del Socket'));
  }

  void joinChatRoom(String myUserId, String friendId) {
    logger.i(
      '💬 Uniendose a sala de chat - Mi ID: $myUserId, Amigo ID: $friendId',
    );
    _socket.emit('chat:join', {'userId': myUserId, 'friendId': friendId});
  }

  void sendChatMessage(String from, String to, String text) {
    logger.d('📤 Enviando mensaje de $from a $to: $text');
    _socket.emit('chat:message', {'from': from, 'to': to, 'text': text});
  }

  // El controlador pasará una función aquí para saber qué hacer cuando llegue un mensaje
  void listenToChatMessages(Function(dynamic) onMessageReceived) {
    _socket.on('chat:message', onMessageReceived);
  }

  void stopListeningToChatMessages() {
    _socket.off('chat:message');
  }

  void disconnect() {
    try {
      if (_socket.connected) {
        logger.i('🚪 Desconectando del Socket Server');
        _socket.disconnect();
      }
    } catch (e) {
      logger.e('❌ Error al desconectar del socket', error: e);
    }
  }
}
