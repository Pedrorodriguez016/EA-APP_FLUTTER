import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/user_controller.dart';
import '../Models/user.dart';

class BlockedUsersScreen extends GetView<UserController> {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cargar usuarios bloqueados al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchBlockedUsers();
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          translate('users.blocked_users_title'),
          style: context.textTheme.titleLarge,
        ),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.blockedUsersList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block,
                  size: 80,
                  color: context.theme.hintColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  translate('users.no_blocked_users'),
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.theme.hintColor,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchBlockedUsers,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.blockedUsersList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = controller.blockedUsersList[index];
              return _buildBlockedUserCard(context, user);
            },
          ),
        );
      }),
    );
  }

  Widget _buildBlockedUserCard(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: context.theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: context.theme.colorScheme.primary.withValues(
              alpha: 0.1,
            ),
            backgroundImage: user.profilePhoto != null
                ? NetworkImage(controller.getFullPhotoUrl(user.profilePhoto!)!)
                : null,
            child: user.profilePhoto == null
                ? Text(
                    user.username[0].toUpperCase(),
                    style: TextStyle(
                      color: context.theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.gmail,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _confirmUnblock(context, user),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.theme.colorScheme.primary,
              foregroundColor: context.theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(translate('users.unblock_btn')),
          ),
        ],
      ),
    );
  }

  void _confirmUnblock(BuildContext context, User user) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(translate('users.confirm_unblock_title')),
        content: Text(
          translate(
            'users.confirm_unblock_content',
            args: {'username': user.username},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(translate('common.cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.unblockUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(translate('users.unblock_btn')),
          ),
        ],
      ),
    );
  }
}
