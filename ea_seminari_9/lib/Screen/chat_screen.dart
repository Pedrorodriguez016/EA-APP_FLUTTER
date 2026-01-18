import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';
import '../Controllers/chat_controller.dart';
import '../Controllers/auth_controller.dart';
import '../Services/user_services.dart';
import '../Models/chat.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({Key? key}) : super(key: key);

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
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: context.theme.colorScheme.primary,
              child: Text(
                controller.friendName.isNotEmpty
                    ? controller.friendName.substring(0, 2).toUpperCase()
                    : '?',
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
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                itemCount: controller.messages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _ChatBubble(message: controller.messages[index]);
                },
              );
            }),
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
            IconButton(
              icon: Icon(
                Icons.image_outlined,
                color: context.theme.colorScheme.primary,
              ),
              onPressed: () => controller.sendImageMessage(),
            ),
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
                    hintText: translate('chat.input_hint'),
                    hintStyle: TextStyle(color: context.theme.hintColor),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) {
                    controller.sendMessage();
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
                  controller.sendMessage();
                },
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

    const myBubbleColor = Color(0xFF7C3AED);
    final otherBubbleColor = context.isDarkMode
        ? const Color(0xFF424242)
        : const Color(0xFFEEEEEE);

    const myTextColor = Colors.white;
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
            if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
              GestureDetector(
                onTap: () {
                  final fullUrl =
                      '${Get.find<UserServices>().baseUrl.replaceAll('/api/user', '')}${message.imageUrl}';
                  Get.to(
                    Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        backgroundColor: Colors.black,
                        iconTheme: const IconThemeData(color: Colors.white),
                      ),
                      body: Center(
                        child: InteractiveViewer(
                          child: Image.network(
                            fullUrl,
                            headers: {
                              'Authorization':
                                  'Bearer ${Get.find<AuthController>().token ?? ''}',
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      '${Get.find<UserServices>().baseUrl.replaceAll('/api/user', '')}${message.imageUrl}',
                      headers: {
                        'Authorization':
                            'Bearer ${Get.find<AuthController>().token ?? ''}',
                      },
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            if (message.text.isNotEmpty)
              Text(
                message.text,
                style: TextStyle(
                  color: message.isMine ? myTextColor : otherTextColor,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 4),
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
