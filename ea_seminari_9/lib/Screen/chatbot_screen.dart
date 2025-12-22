import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/chatbot_controller.dart';

class ChatBotScreen extends GetView<ChatBotController> {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asistente Virtual"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                    return _buildLoadingBubble();
                  }
                  final msg = controller.messages[index];
                  return _buildMessageBubble(msg);
                },
              );
            }),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BotMessage msg) {
    final isUser = msg.isUser;
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
              color: isUser ? const Color(0xFF667EEA) : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
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
                    avatar: const Icon(
                      Icons.event,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: const Color(0xFF667EEA),
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

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          width: 40,
          height: 20,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              decoration: InputDecoration(
                hintText: "Escribe tu consulta...",
                filled: true,
                fillColor: Colors.grey.shade100,
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
            backgroundColor: const Color(0xFF667EEA),
            radius: 24,
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
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
