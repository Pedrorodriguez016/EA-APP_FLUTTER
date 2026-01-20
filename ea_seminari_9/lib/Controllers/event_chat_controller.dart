import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
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
import '../Models/eventos.dart';
import 'dart:io';

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
  var event = Rxn<Evento>();

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
    fetchEventDetails();
    _socketService.joinEventChatRoom(eventId);
    _socketService.listenToEventChatMessages(_handleNewMessage);
    _socketService.listenToChatErrors(_handleChatError);
  }

  Future<void> fetchEventDetails() async {
    try {
      final fetchedEvent = await _eventosServices.fetchEventById(eventId);
      event.value = fetchedEvent;
      logger.i(
        '✅ Detalles del evento cargados con ${fetchedEvent.participantesFull?.length ?? 0} participantes detallados',
      );
    } catch (e) {
      logger.e('❌ Error al cargar detalles del evento para el chat', error: e);
    }
  }

  void _handleChatError(dynamic data) {
    logger.e('🛑 Error en chat: ${data['message']}');
    Get.snackbar(
      translate('common.error'),
      data['message'] ??
          translate(
            'chat_extra.send_error',
          ), // Need to add this to JSON? No, I'll use a generic one or data['message']
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

  Future<void> sendImageMessage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      // 1. Mostrar Preview antes de enviar
      final bool? confirm = await Get.dialog<bool>(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  translate('chat_extra.send_image_confirm'),
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: Image.file(File(image.path), fit: BoxFit.contain),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        translate('common.cancel'),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(result: true),
                      child: Text(
                        translate('common.accept'),
                      ), // Or common.send? Let's check common. I'll use accept for now or add send.
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      if (confirm != true) return;

      isLoading.value = true;

      // 2. Subir la imagen al servidor
      final String imageUrl = await _eventosServices.uploadEventChatImage(
        eventId,
        image.path,
      );

      // 3. Enviar el mensaje a través del socket
      _socketService.sendEventChatMessage(
        eventId,
        myUserId,
        myUsername,
        '', // Texto vacío si solo es imagen
        imageUrl,
      );

      logger.i('✅ Imagen enviada al chat del evento');
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

  Future<void> uploadMedia({
    bool isVideo = false,
    bool fromCamera = false,
    bool isGeneralGallery = false,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? file;

      if (isGeneralGallery) {
        file = await picker.pickMedia();
      } else {
        final source = fromCamera ? ImageSource.camera : ImageSource.gallery;

        if (isVideo) {
          file = await picker.pickVideo(
            source: source,
            maxDuration: const Duration(minutes: 5),
          );
        } else {
          file = await picker.pickImage(source: source, imageQuality: 70);
        }
      }

      if (file == null) return;

      isLoading.value = true;
      final newMedia = await _eventosServices.uploadMedia(eventId, file.path);
      photos.insert(0, newMedia);
    } catch (e) {
      logger.e('❌ Error al subir contenido', error: e);
      Get.snackbar(
        translate('common.error'),
        translate('chat_extra.share_error'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadMedia(String mediaUrl, String type) async {
    try {
      final fullUrl =
          '${_eventosServices.baseUrl.replaceAll('/api/event', '')}$mediaUrl';

      // 1. Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final String fileName = mediaUrl.split('/').last;
      final String fullPath = '${tempDir.path}/$fileName';

      // 2. Descargar el archivo
      await Dio().download(
        fullUrl,
        fullPath,
        options: Options(
          headers: {'Authorization': 'Bearer ${_authController.token ?? ''}'},
        ),
      );

      // 3. Guardar en la galería usando Gal
      if (type == 'video') {
        await Gal.putVideo(fullPath);
      } else {
        await Gal.putImage(fullPath);
      }

      Get.snackbar(
        translate('chat_extra.download_success_title'),
        translate('chat_extra.download_success_msg'),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      logger.e('❌ Error al descargar el contenido', error: e);
      Get.snackbar(
        translate('chat_extra.download_error_title'),
        translate('chat_extra.download_error_msg'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deletePhoto(String photoId) async {
    try {
      isLoading.value = true;
      await _eventosServices.deleteEventoPhoto(eventId, photoId);
      photos.removeWhere((p) => p.id == photoId);
    } catch (e) {
      logger.e('❌ Error al eliminar foto', error: e);
      Get.snackbar(
        translate('common.error'),
        translate('chat_extra.photo_deleted_error'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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
