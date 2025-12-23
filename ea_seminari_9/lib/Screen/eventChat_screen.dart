import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/event_chat_controller.dart';
import '../Models/event_chat.dart';

class EventChatScreen extends GetView<EventChatController> {
  const EventChatScreen({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 1,
        shadowColor: context.theme.shadowColor.withValues(alpha: 0.2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.eventName,
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              translate('events.chat_subtitle'),
              style: TextStyle(color: context.theme.hintColor, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                itemCount: controller.messages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _EventChatBubble(message: controller.messages[index]);
                },
              ),
            ),
          ),
          Divider(height: 1, color: context.theme.dividerColor),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      color: context.theme.cardColor,
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.textController,
                  focusNode: controller.focusNode,
                  style: context.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: translate('events.chat_hint'),
                    hintStyle: TextStyle(color: context.theme.hintColor),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) {
                    final text = controller.textController.text.trim();
                    if (text.isNotEmpty) {
                      // Optimistic Update
                      final myMsg = EventChatMessage(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        eventId: controller.eventId,
                        userId: controller.myUserId,
                        username: controller.myUsername,
                        text: text,
                        createdAt: DateTime.now(),
                        isMine: true,
                      );
                      controller.messages.insert(0, myMsg);
                      controller.sendMessage();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: context.theme.colorScheme.primary,
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: context.theme.colorScheme.onPrimary,
                  size: 20,
                ),
                onPressed: () {
                  final text = controller.textController.text.trim();
                  if (text.isNotEmpty) {
                    final myMsg = EventChatMessage(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      eventId: controller.eventId,
                      userId: controller.myUserId,
                      username: controller.myUsername,
                      text: text,
                      createdAt: DateTime.now(),
                      isMine: true,
                    );
                    controller.messages.insert(0, myMsg);
                    controller.sendMessage();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventChatBubble extends StatelessWidget {
  final EventChatMessage message;
  const _EventChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final time =
        "${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}";

    // Color fijo para mis mensajes (Morado marca) para asegurar contraste con blanco
    const myBubbleColor = Color(0xFF7C3AED);
    // Fixed grey colors for better visibility
    final otherBubbleColor = context.isDarkMode
        ? Color(0xFF424242) // Solid Dark Grey
        : Color(0xFFEEEEEE); // Solid Light Grey

    const myTextColor = Colors.white;
    // Forzamos el color del texto recibido
    final otherTextColor = context.isDarkMode ? Colors.white : Colors.black;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMine ? myBubbleColor : otherBubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: message.isMine
                ? const Radius.circular(12)
                : Radius.zero,
            bottomRight: message.isMine
                ? Radius.zero
                : const Radius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!message.isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: myBubbleColor,
                  ),
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: message.isMine ? myTextColor : otherTextColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: TextStyle(
                color: message.isMine
                    ? myTextColor.withValues(alpha: 0.7)
                    : context.theme.hintColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
