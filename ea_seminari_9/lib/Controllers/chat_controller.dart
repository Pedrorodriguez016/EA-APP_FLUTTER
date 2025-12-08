import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Services/socket_services.dart';
import '../Controllers/auth_controller.dart';
import '../Models/chat.dart';
import '../utils/logger.dart';

class ChatController extends GetxController {
  // Dependencias
  final SocketService _socketService;
  final AuthController _authController;

  // UI
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  // Estado
  var messages = <ChatMessage>[].obs;
  
  late String myUserId;
  late String friendId;
  late String friendName;

  ChatController(this._socketService, this._authController);

  @override
  void onInit() {
    super.onInit();
    
    // 1. Preparar datos
    myUserId = _authController.currentUser.value?.id ?? '';
    final args = Get.arguments ?? {};
    friendId = args['friendId'] ?? '';
    friendName = args['friendName'] ?? 'Chat';

    logger.i('💬 Inicializando ChatController - Mi ID: $myUserId, Amigo ID: $friendId');

    if (friendId.isEmpty) {
      logger.w('⚠️ Friend ID vacío, cerrando pantalla de chat');
      Get.back();
      return;
    }

    _socketService.joinChatRoom(myUserId, friendId);
    _socketService.listenToChatMessages(_handleNewMessage);
  }


  void _handleNewMessage(dynamic data) {
    try {
      final newMessage = ChatMessage.fromJson(data, myUserId);
      logger.d('📥 Nuevo mensaje recibido de ${newMessage.from}: ${newMessage.text}');

      if (newMessage.from == friendId || newMessage.from == myUserId) {
        messages.insert(0, newMessage);
      }
    } catch (e) {
      logger.e('❌ Error al parsear mensaje', error: e);
    }
  }

  void sendMessage() {
    String text = textController.text.trim();
    if (text.isEmpty) {
      logger.d('💬 Intento de enviar mensaje vacío, ignorado');
      return;
    }

    logger.i('📤 Enviando mensaje a $friendId: $text');
    textController.clear();
    focusNode.requestFocus();

    _socketService.sendChatMessage(myUserId, friendId, text);
  }

  @override
  void onClose() {
    logger.i('🚪 Cerrando ChatController');
    _socketService.stopListeningToChatMessages();
    
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}