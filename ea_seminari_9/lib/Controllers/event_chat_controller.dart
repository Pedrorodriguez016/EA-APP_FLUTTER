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
  }

  void _handleNewMessage(dynamic data) {
    logger.d(
      '📥 [EventChatController] _handleNewMessage called with data: $data',
    );
    try {
      final newMessage = EventChatMessage.fromJson(data, myUserId);
      final exists = messages.any(
        (msg) =>
            msg.id == newMessage.id ||
            (msg.isMine &&
                msg.text == newMessage.text &&
                msg.createdAt.difference(newMessage.createdAt).inSeconds.abs() <
                    2),
      );

      if (!exists && newMessage.eventId == eventId) {
        logger.i('✅ [EventChatController] Adding message to list');
        messages.insert(0, newMessage);
      } else if (exists) {
        logger.d('⚠️ [EventChatController] Message duplicate skipped');
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

    textController.clear();
    focusNode.requestFocus();

    logger.d('📤 Enviando mensaje al chat del evento');
    _socketService.sendEventChatMessage(eventId, myUserId, myUsername, text);
  }

  @override
  void onClose() {
    logger.i('🏟️ EventChatController: Cerrando chat');
    _socketService.stopListeningToEventChatMessages();
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
