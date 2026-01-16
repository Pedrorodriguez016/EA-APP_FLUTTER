import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Services/socket_services.dart';
import '../Controllers/auth_controller.dart';
import '../Models/event_chat.dart';
import '../utils/logger.dart';
import '../Services/user_services.dart';
import '../Services/eventos_services.dart';
import '../Models/evento_photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:dio/dio.dart';

class EventChatController extends GetxController {
  final SocketService _socketService;
  final AuthController _authController;
  final UserServices _userServices = Get.find<UserServices>();
  final EventosServices _eventosServices = Get.find<EventosServices>();

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  var messages = <EventChatMessage>[].obs;
  var isLoading = false.obs;

  var photos = <EventoPhoto>[].obs;
  var isPhotosLoading = false.obs;

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
    fetchEventHistory();
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

  Future<void> fetchEventHistory() async {
    isLoading.value = true;
    try {
      final List<dynamic> history = await _userServices.fetchEventChatHistory(
        eventId,
      );
      final List<EventChatMessage> historyMessages = history
          .map((json) => EventChatMessage.fromJson(json, myUserId))
          .toList();

      messages.assignAll(historyMessages.reversed.toList());
      logger.i(
        '✅ Historial de chat de evento cargado con ${messages.length} mensajes',
      );
    } catch (e) {
      logger.e('❌ Error al cargar historial de evento', error: e);
    } finally {
      isLoading.value = false;
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

  Future<void> fetchPhotos() async {
    isPhotosLoading.value = true;
    try {
      final fetchedPhotos = await _eventosServices.fetchEventPhotos(eventId);
      photos.assignAll(fetchedPhotos);
    } catch (e) {
      logger.e('❌ Error al cargar fotos del evento', error: e);
    } finally {
      isPhotosLoading.value = false;
    }
  }

  Future<void> uploadPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      isLoading.value = true;
      final newPhoto = await _eventosServices.uploadPhoto(eventId, image.path);
      photos.insert(0, newPhoto);

      Get.snackbar(
        '¡Éxito!',
        'Foto compartida correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      logger.e('❌ Error al subir foto', error: e);
      Get.snackbar(
        'Error',
        'No se pudo compartir la foto',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadPhoto(String photoUrl) async {
    try {
      final fullUrl =
          '${_eventosServices.baseUrl.replaceAll('/api/event', '')}$photoUrl';

      // 1. Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final String fileName = photoUrl.split('/').last;
      final String fullPath = '${tempDir.path}/$fileName';

      // 2. Descargar la imagen
      await Dio().download(
        fullUrl,
        fullPath,
        options: Options(
          headers: {'Authorization': 'Bearer ${_authController.token ?? ''}'},
        ),
      );

      // 3. Guardar en la galería usando Gal
      await Gal.putImage(fullPath);

      Get.snackbar(
        '¡Descarga completada!',
        'La foto se ha guardado en tu galería',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      logger.e('❌ Error al descargar la foto', error: e);
      Get.snackbar(
        'Error de descarga',
        'No se pudo guardar la foto en la galería',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
