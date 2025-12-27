import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Services/socket_services.dart';
import '../Controllers/auth_controller.dart';
import '../Models/event_chat.dart';
import '../utils/logger.dart';

class EventChatController extends GetxController {
  final SocketService _socketService;
  final AuthController _authController;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  var messages = <EventChatMessage>[].obs;

  late String myUserId;
  late String myUsername;
  late String eventId;
  late String eventName;

  EventChatController(this._socketService, this._authController);

  @override
  void onInit() {
    super.onInit();

    myUserId = _authController.currentUser.value?.id ?? '';
    myUsername = _authController.currentUser.value?.username ?? 'Anónimo';

    final args = Get.arguments ?? {};
    eventId = args['eventId'] ?? '';
    eventName = args['eventName'] ?? 'Chat de Evento';

    if (eventId.isEmpty) {
      logger.w('⚠️ EventChatController: No se proporcionó eventId');
      Get.back();
      return;
    }

    logger.i(
      '🏟️ EventChatController: Inicializando chat para el evento $eventName ($eventId)',
    );
    _socketService.joinEventChatRoom(eventId);
    _socketService.listenToEventChatMessages(_handleNewMessage);
    _socketService.listenToChatErrors(_handleChatError);
  }

  void _handleChatError(dynamic data) {
    logger.e('🛑 Error en chat: ${data['message']}');
    Get.snackbar(
      'Error',
      data['message'] ?? 'No se pudo enviar el mensaje',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      duration: const Duration(seconds: 4),
    );

    // Remove the optimistic message if it exists (assuming it's the last added one)
    if (messages.isNotEmpty && messages.first.isMine) {
      messages.removeAt(0);
    }
  }

  void _handleNewMessage(dynamic data) {
    logger.d(
      '📥 [EventChatController] _handleNewMessage called with data: $data',
    );
    try {
      final newMessage = EventChatMessage.fromJson(data, myUserId);
      final index = messages.indexWhere(
        (msg) =>
            msg.id == newMessage.id ||
            (msg.isMine &&
                msg.text == newMessage.text &&
                msg.createdAt.difference(newMessage.createdAt).inSeconds.abs() <
                    60),
      );

      if (index != -1) {
        // El mensaje ya existe (probablemente el optimista).
        // Actualizamos sus datos con los reales del servidor (ID real, fecha exacta)
        logger.d(
          '🔄 [EventChatController] Actualizando mensaje optimista con datos reales',
        );
        messages[index] = newMessage;
      } else if (newMessage.eventId == eventId) {
        logger.i('✅ [EventChatController] Adding message to list');
        messages.insert(0, newMessage);
      }
    } catch (e) {
      logger.e(
        '❌ [EventChatController] Error parseando mensaje de evento',
        error: e,
      );
    }
  }

  void sendMessage() {
    String text = textController.text.trim();
    if (text.isEmpty) return;

    // 1. Inserción Optimista
    final tempMsg = EventChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventId: eventId,
      userId: myUserId,
      username: myUsername,
      text: text,
      createdAt: DateTime.now(),
      isMine: true,
    );
    messages.insert(0, tempMsg);

    textController.clear();
    focusNode.requestFocus();

    logger.d('📤 Enviando mensaje al chat del evento');
    _socketService.sendEventChatMessage(eventId, myUserId, myUsername, text);
  }

  @override
  void onClose() {
    logger.i('🏟️ EventChatController: Cerrando chat');
    _socketService.stopListeningToEventChatMessages();
    _socketService.stopListeningToChatErrors();
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
