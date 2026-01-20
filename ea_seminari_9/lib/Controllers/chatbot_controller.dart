import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Services/chatbot_service.dart';
import 'auth_controller.dart';

class BotMessage {
  final String? text;
  final String? translationKey;
  final bool isUser;
  final DateTime timestamp;
  final List<dynamic>? relatedEvents;

  BotMessage({
    this.text,
    this.translationKey,
    required this.isUser,
    DateTime? timestamp,
    this.relatedEvents,
  }) : timestamp = timestamp ?? DateTime.now(),
       assert(text != null || translationKey != null);
}

class ChatBotController extends GetxController {
  final ChatBotService _service;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  var messages = <BotMessage>[].obs;
  var isLoading = false.obs;

  ChatBotController(this._service);

  @override
  void onReady() {
    super.onReady();
    // Mensaje de bienvenida reactivo usando llave de traducción
    if (messages.isEmpty) {
      messages.add(
        BotMessage(translationKey: 'chatbot.welcome_message', isUser: false),
      );
    }
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
      // 2. Llamar al servicio con el idioma actual
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id ?? '';

      // Mapeo de idioma ca -> cat para el backend
      String lang = LocalizedApp.of(
        Get.context!,
      ).delegate.currentLocale.languageCode;
      if (lang == 'ca') lang = 'cat';

      final result = await _service.sendQuery(text, userId, language: lang);

      final String answer = result['answer'] ?? '';
      final List events = result['events'] ?? [];

      String responseText = answer;
      if (responseText.isEmpty) {
        if (events.isEmpty) {
          responseText = translate('chatbot.no_events_found');
        } else {
          final String countMsg = translate(
            'chatbot.found_events_count',
            args: {'count': events.length},
          );
          final names = events.map((e) => "- ${e['name']}").join('\n');
          responseText = '$countMsg\n$names';
        }
      }

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
        BotMessage(translationKey: 'chatbot.error_message', isUser: false),
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
