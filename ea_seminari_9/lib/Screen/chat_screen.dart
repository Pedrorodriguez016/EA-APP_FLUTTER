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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF667EEA),
              child: Text(
                controller.friendName.substring(0, 2).toUpperCase(),
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => Get.toNamed('/user/${controller.friendId}'),
              child: Text(
                controller.friendName,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
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
          
          const Divider(height: 1),
          
          // INPUT AREA
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.textController,
                  focusNode: controller.focusNode,
                  decoration: InputDecoration(
                    hintText: translate("chat.input_hint"),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF667EEA),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
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
    final time = "${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}";
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMine ? const Color(0xFF667EEA) : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: message.isMine ? const Radius.circular(12) : Radius.zero,
            bottomRight: message.isMine ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ocupa el mínimo espacio posible
          crossAxisAlignment: CrossAxisAlignment.end, // Alinea la hora a la derecha siempre
          children: [
            // El mensaje de texto
            Flexible(
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isMine ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 4), // Espacio entre texto y hora
            // La hora
            Text(
              time,
              style: TextStyle(
                color: message.isMine ? Colors.white70 : Colors.black54,
                fontSize: 10, // Letra pequeña para la hora
              ),
            ),
          ],
        ),
      ),
    );
  }
}