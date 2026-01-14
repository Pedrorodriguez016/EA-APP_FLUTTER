import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class SocketService extends GetxService {
  late IO.Socket _socket;
  String get _url => dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  @override
  void onInit() {
    super.onInit();
    _socket = IO.io(
      _url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect() // Changed from disable to enable for better stability
          .build(),
    );
  }

  void connectWithUserId(String userId) {
    if (!_socket.connected) {
      _socket.connect();
    } else {
      // Si ya estaba conectado, identificamos al usuario igualmente
      _socket.emit('user:online', userId);
      logger.d(
        '📤 Socket ya conectado, re-emitiendo user:online para: $userId',
      );
    }

    _socket.onConnect((_) {
      logger.i('✅ Conectado al Socket Server');

      // Emitimos el evento que tu backend espera
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
    logger.d(
      '📤 [SocketService] Enviando mensaje privado de $from a $to: $text',
    );
    _socket.emit('chat:message', {'from': from, 'to': to, 'text': text});
  }

  // El controlador pasará una función aquí para saber qué hacer cuando llegue un mensaje
  void listenToChatMessages(Function(dynamic) onMessageReceived) {
    _socket.on('chat:message', (data) {
      logger.d('🔍 [SocketService] RAW chat:message received: $data');
      onMessageReceived(data);
    });
  }

  void stopListeningToChatMessages() {
    _socket.off('chat:message');
  }

  // EVENT CHAT
  void joinEventChatRoom(String eventId) {
    if (!_socket.connected) {
      logger.w(
        '⚠️ [SocketService] Socket desconectado al intentar unirse a sala. Reconectando...',
      );
      _socket.connect();
    }
    logger.i(
      '🏟️ [SocketService] Uniendose a sala de chat de evento: $eventId',
    );
    _socket.emit('eventChat:join', {'eventId': eventId});
  }

  void sendEventChatMessage(
    String eventId,
    String userId,
    String username,
    String text,
  ) {
    logger.d(
      '📤 [SocketService] Enviando mensaje al evento $eventId de $username: $text',
    );
    _socket.emit('eventChat:message', {
      'eventId': eventId,
      'userId': userId,
      'username': username,
      'text': text,
    });
  }

  void listenToEventChatMessages(Function(dynamic) onMessageReceived) {
    _socket.on('eventChat:message', (data) {
      logger.d('🔍 [SocketService] RAW eventChat:message received: $data');
      onMessageReceived(data);
    });
  }

  void stopListeningToEventChatMessages() {
    _socket.off('eventChat:message');
  }

  void listenToChatErrors(Function(dynamic) onErrorReceived) {
    _socket.on('chat:error', (data) {
      logger.w('⚠️ [SocketService] Chat Error received: $data');
      onErrorReceived(data);
    });
  }

  void stopListeningToChatErrors() {
    _socket.off('chat:error');
  }

  void listenToNotifications(Function(dynamic) onNotificationReceived) {
    _socket.on('notification:new', (data) {
      logger.d('🔍 [SocketService] RAW notification:new received: $data');
      onNotificationReceived(data);
    });
  }

  void stopListeningToNotifications() {
    _socket.off('notification:new');
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

  void forceOffline(String userId) {
    if (_socket.connected) {
      _socket.emit('user:force_offline', userId);
      logger.d('📤 Enviado user:force_offline para: $userId');
    }
  }
}
