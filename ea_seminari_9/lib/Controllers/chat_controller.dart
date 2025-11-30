import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Services/socket_services.dart';
import '../Controllers/auth_controller.dart';
import '../Models/chat.dart';

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

    if (friendId.isEmpty) {
      Get.back();
      return;
    }

    // 2. Llamar al SERVICIO para unirse a la sala
    _socketService.joinChatRoom(myUserId, friendId);

    // 3. Llamar al SERVICIO para escuchar mensajes
    // Pasamos la función _handleNewMessage como "callback"
    _socketService.listenToChatMessages(_handleNewMessage);
  }

  // Esta función se ejecuta cada vez que el Service recibe algo del socket
  void _handleNewMessage(dynamic data) {
    try {
      final newMessage = ChatMessage.fromJson(data, myUserId);
      
      // Validación lógica
      if (newMessage.from == friendId || newMessage.from == myUserId) {
        messages.insert(0, newMessage);
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  void sendMessage() {
    String text = textController.text.trim();
    if (text.isEmpty) return;

    textController.clear();
    focusNode.requestFocus();

    // 4. Delegar el envío al SERVICIO
    _socketService.sendChatMessage(myUserId, friendId, text);
  }

  @override
  void onClose() {
    // 5. Pedir al SERVICIO que limpie los listeners
    _socketService.stopListeningToChatMessages();
    
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}