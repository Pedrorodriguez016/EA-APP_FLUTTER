import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxService {
  late IO.Socket socket;
  final String _url = 'http://localhost:3000'; 

  void connectWithUserId(String userId) {
    // Configuración del cliente
    socket = IO.io(_url, IO.OptionBuilder()
        .setTransports(['websocket']) // forzar WebSockets
        .disableAutoConnect()         // conectamos manualmente
        .build()
    );

    socket.connect();

    socket.onConnect((_) {
      print('✅ Conectado al Socket Server');
      
      // Emitimos el evento que tu backend espera en la línea 63
      socket.emit('user:online', userId); 
    });

    socket.on('user:online', (data) {
      print('Servidor confirmó usuario online: $data');
    });

    socket.onDisconnect((_) => print('❌ Desconectado del Socket'));
    
    // Aquí puedes añadir los listeners para el chat
    socket.on('chat:message', (payload) {
      print('Nuevo mensaje: $payload');
      // Aquí podrías usar un ChatController para actualizar la UI
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}