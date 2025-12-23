import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';
import '../Controllers/chat_list_controller.dart';
import '../Widgets/navigation_bar.dart';
import '../Models/user.dart';

class ChatListScreen extends GetView<ChatListController> {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          translate('chat.list_title'),
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.theme.iconTheme.color),
            onPressed: controller.loadFriends,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.friendsList.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: controller.friendsList.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final friend = controller.friendsList[index];
            return _buildFriendTile(context, friend, controller);
          },
        );
      }),
      bottomNavigationBar: CustomNavBar(currentIndex: 2),
    );
  }

  Widget _buildFriendTile(
    BuildContext context,
    User friend,
    ChatListController controller,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: context.theme.colorScheme.primary,
        child: Text(
          friend.username.length > 1
              ? friend.username.substring(0, 2).toUpperCase()
              : friend.username.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: context.theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        friend.username,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        translate('chat.subtitle'),
        style: TextStyle(color: context.theme.hintColor, fontSize: 14),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: context.theme.dividerColor,
      ),
      onTap: () => controller.goToChat(friend),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: context.theme.disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            translate("chat.empty_list"),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.theme.hintColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
