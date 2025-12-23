import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';
import '../Controllers/chat_controller.dart';
import '../Models/chat.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CAMBIO: Fondo dinámico
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // CAMBIO: Fondo y elevación adaptativos
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 1,
        shadowColor: context.theme.shadowColor.withValues(alpha: 0.2),
        leading: IconButton(
          // CAMBIO: Icono dinámico
          icon: Icon(Icons.arrow_back, color: context.theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              // CAMBIO: Color primario del tema
              backgroundColor: context.theme.colorScheme.primary,
              child: Text(
                controller.friendName.isNotEmpty
                    ? controller.friendName.substring(0, 2).toUpperCase()
                    : "?",
                style: TextStyle(
                  fontSize: 14,
                  color: context.theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => Get.toNamed('/user/${controller.friendId}'),
              child: Text(
                controller.friendName,
                // CAMBIO: Texto título dinámico
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // LISTA DE MENSAJES
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                itemCount: controller.messages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _ChatBubble(message: controller.messages[index]);
                },
              ),
            ),
          ),

          Divider(height: 1, color: context.theme.dividerColor),

          // INPUT AREA
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      // CAMBIO: Fondo de la barra de input (blanco en light, gris oscuro en dark)
      color: context.theme.cardColor,
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  // CAMBIO: Fondo del input text field
                  color: context.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.textController,
                  focusNode: controller.focusNode,
                  // CAMBIO: Color del texto input
                  style: context.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: translate("chat.input_hint"),
                    // CAMBIO: Color del hint
                    hintStyle: TextStyle(color: context.theme.hintColor),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              // CAMBIO: Botón enviar con color primario
              backgroundColor: context.theme.colorScheme.primary,
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: context.theme.colorScheme.onPrimary,
                  size: 20,
                ),
                onPressed: () => controller.sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final time =
        "${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}";

    // CAMBIO: Colores dinámicos para las burbujas
    final myBubbleColor = context.theme.colorScheme.primary;
    final otherBubbleColor = context.isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade300;

    final myTextColor = context.theme.colorScheme.onPrimary;
    final otherTextColor = context.textTheme.bodyLarge?.color;

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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // El mensaje de texto
            Flexible(
              child: Text(
                message.text,
                style: TextStyle(
                  // CAMBIO: Texto legible según el fondo
                  color: message.isMine ? myTextColor : otherTextColor,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // La hora
            Text(
              time,
              style: TextStyle(
                // CAMBIO: Color de hora más sutil
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
