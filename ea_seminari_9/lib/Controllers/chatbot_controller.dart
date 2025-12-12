import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Services/chatbot_service.dart';

class BotMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<dynamic>? relatedEvents;

  BotMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.relatedEvents,
  }) : this.timestamp = timestamp ?? DateTime.now();
}

class ChatBotController extends GetxController {
  final ChatBotService _service;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  var messages = <BotMessage>[].obs;
  var isLoading = false.obs;

  ChatBotController(this._service);

  @override
  void onInit() {
    super.onInit();
    // Mensaje de bienvenida
    messages.add(
      BotMessage(
        text: "Hola! Soy tu asistente virtual. ¿En qué puedo ayudarte hoy?",
        isUser: false,
      ),
    );
  }

  Future<void> sendQuery() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    // 1. Agregar mensaje del usuario
    messages.add(BotMessage(text: text, isUser: true));
    textController.clear();
    _scrollToBottom();

    isLoading.value = true;
    try {
      // 2. Llamar al servicio
      final result = await _service.sendQuery(text);

      final String responseText = result['text'];
      final List events = result['events'] ?? [];

      // 3. Agregar respuesta del bot
      messages.add(
        BotMessage(
          text: responseText,
          isUser: false,
          relatedEvents: events.isNotEmpty ? events : null,
        ),
      );
    } catch (e) {
      messages.add(
        BotMessage(
          text: "Lo siento, hubo un error al procesar tu solicitud.",
          isUser: false,
        ),
      );
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Pequeño delay para dar tiempo a renderizar el nuevo item
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
