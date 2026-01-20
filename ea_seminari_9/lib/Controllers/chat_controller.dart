import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Services/socket_services.dart';
import '../Controllers/auth_controller.dart';
import '../Models/chat.dart';
import '../utils/logger.dart';
import '../Services/user_services.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  // Dependencias
  final SocketService _socketService;
  final AuthController _authController;
  final UserServices _userServices = Get.find<UserServices>();

  // UI
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  // Estado
  var messages = <ChatMessage>[].obs;
  var isLoading = false.obs;

  late String myUserId;
  late String friendId;
  late String friendName;
  String? friendPhoto;

  ChatController(this._socketService, this._authController);

  @override
  void onInit() {
    super.onInit();

    // 1. Preparar datos
    myUserId = _authController.currentUser.value?.id ?? '';
    final args = Get.arguments ?? {};
    friendId = args['friendId'] ?? '';
    friendName = args['friendName'] ?? 'Chat';
    friendPhoto = args['friendPhoto'];

    logger.i(
      '💬 Inicializando ChatController - Mi ID: $myUserId, Amigo ID: $friendId',
    );

    if (friendId.isEmpty) {
      logger.w('⚠️ Friend ID vacío, cerrando pantalla de chat');
      Get.back();
      return;
    }

    fetchHistory();
    _socketService.joinChatRoom(myUserId, friendId);
    _socketService.listenToChatMessages(_handleNewMessage);
    _socketService.listenToChatErrors(_handleChatError);
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      final List<dynamic> history = await _userServices.fetchChatHistory(
        myUserId,
        friendId,
      );
      final List<ChatMessage> historyMessages = history
          .map((json) => ChatMessage.fromJson(json, myUserId))
          .toList();

      // Los mensajes del historial suelen venir en orden cronológico (antiguos primero)
      // En la UI los mostramos de abajo a arriba (insert(0, ...)), así que
      // invertimos el historial para que el más nuevo esté el primero de la lista.
      messages.assignAll(historyMessages.reversed.toList());
      logger.i('✅ Historial de chat cargado con ${messages.length} mensajes');
    } catch (e) {
      logger.e('❌ Error al cargar historial', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleChatError(dynamic data) {
    logger.e('🛑 Error en chat: ${data['message']}');
    Get.snackbar(
      translate('common.error'),
      data['message'] ?? translate('chat_extra.send_error'),
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
    logger.d('📥 [ChatController] _handleNewMessage called with data: $data');
    try {
      final newMessage = ChatMessage.fromJson(data, myUserId);
      logger.d(
        '📥 [ChatController] Parsed message from ${newMessage.from}: ${newMessage.text} (ID: ${newMessage.id})',
      );

      // Evitar duplicados si el mensaje ya fue agregado por el optimistic update
      final exists = messages.any(
        (msg) =>
            msg.id == newMessage.id ||
            (msg.isMine &&
                msg.text == newMessage.text &&
                msg.createdAt.difference(newMessage.createdAt).inSeconds.abs() <
                    2),
      );

      if (exists) {
        logger.d(
          '⚠️ [ChatController] Message already exists, skipping duplicate.',
        );
      }

      if (!exists &&
          (newMessage.from == friendId || newMessage.from == myUserId)) {
        logger.i('✅ [ChatController] Adding message to list');
        messages.insert(0, newMessage);
      } else if (!exists) {
        logger.w(
          '⚠️ [ChatController] Message ignored (from ${newMessage.from} != $friendId or $myUserId)',
        );
      }
    } catch (e) {
      logger.e('❌ [ChatController] Error al parsear mensaje', error: e);
    }
  }

  void sendMessage() {
    String text = textController.text.trim();
    if (text.isEmpty) {
      logger.d('💬 Intento de enviar mensaje vacío, ignorado');
      return;
    }

    // 1. Inserción Optimista
    final tempMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      from: myUserId,
      to: friendId,
      text: text,
      createdAt: DateTime.now(),
      isMine: true,
    );
    messages.insert(0, tempMsg);

    logger.i('📤 Enviando mensaje a $friendId: $text');
    textController.clear();
    focusNode.requestFocus();

    _socketService.sendChatMessage(myUserId, friendId, text);
  }

  Future<void> sendImageMessage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      isLoading.value = true;

      // 1. Subir la imagen al servidor
      final String imageUrl = await _userServices.uploadChatImage(
        myUserId,
        friendId,
        image.path,
      );

      // 2. Enviar el mensaje a través del socket
      _socketService.sendChatMessage(
        myUserId,
        friendId,
        '', // Texto vacío si solo es imagen
        imageUrl,
      );

      logger.i('✅ Imagen enviada al chat');
    } catch (e) {
      logger.e('❌ Error al enviar imagen al chat', error: e);
      Get.snackbar(
        translate('common.error'),
        translate('chat_extra.send_image_error'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    logger.i('🚪 Cerrando ChatController');
    _socketService.stopListeningToChatMessages();
    _socketService.stopListeningToChatErrors();

    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
