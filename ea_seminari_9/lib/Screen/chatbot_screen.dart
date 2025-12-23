import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/chatbot_controller.dart';

class ChatBotScreen extends GetView<ChatBotController> {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Asistente Virtual",
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount:
                    controller.messages.length +
                    (controller.isLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) {
                    return _buildLoadingBubble(context);
                  }
                  final msg = controller.messages[index];
                  return _buildMessageBubble(context, msg);
                },
              );
            }),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, BotMessage msg) {
    final isUser = msg.isUser;
    // Forzamos color de marca (0xFF7C3AED) y texto blanco para el usuario
    // para garantizar visibilidad en Dark Mode.
    const userBubbleColor = Color(0xFF7C3AED);
    final botBubbleColor = context.isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade200;

    final bubbleColor = isUser ? userBubbleColor : botBubbleColor;
    final textColor = isUser
        ? Colors.white
        : context.textTheme.bodyLarge?.color;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Text(
              msg.text,
              style: TextStyle(color: textColor, fontSize: 15),
            ),
          ),
          if (msg.relatedEvents != null && msg.relatedEvents!.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxWidth: 280),
              margin: const EdgeInsets.only(left: 4, bottom: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: msg.relatedEvents!.map((event) {
                  final String name = event['name'] ?? 'Evento';
                  final String id = event['_id'] ?? event['id'] ?? '';
                  return ActionChip(
                    avatar: Icon(
                      Icons.event,
                      size: 16,
                      color: context.theme.colorScheme.onPrimary,
                    ),
                    label: Text(
                      name,
                      style: TextStyle(
                        color: context.theme.colorScheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: context.theme.colorScheme.primary,
                    side: BorderSide.none,
                    onPressed: () {
                      if (id.isNotEmpty) {
                        Get.toNamed('/evento/$id');
                      }
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: 40,
          height: 20,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.theme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              style: context.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: "Escribe tu consulta...",
                hintStyle: TextStyle(color: context.theme.hintColor),
                filled: true,
                fillColor: context.isDarkMode
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => controller.sendQuery(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: context.theme.colorScheme.primary,
            radius: 24,
            child: IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: context.theme.colorScheme.onPrimary,
                size: 20,
              ),
              onPressed: () => controller.sendQuery(),
            ),
          ),
        ],
      ),
    );
  }
}
