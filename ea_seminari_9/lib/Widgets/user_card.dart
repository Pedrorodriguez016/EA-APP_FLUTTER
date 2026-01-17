import 'package:ea_seminari_9/Models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/user_controller.dart';
import '../utils/app_theme.dart';

class UserCard extends GetView<UserController> {
  final User user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Get.toNamed('/user/${user.id}'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.primaryBtn,
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: context.theme.scaffoldBackgroundColor,
                    backgroundImage:
                        controller.getFullPhotoUrl(user.profilePhoto) != null
                        ? NetworkImage(
                            controller.getFullPhotoUrl(user.profilePhoto)!,
                          )
                        : null,
                    child: controller.getFullPhotoUrl(user.profilePhoto) == null
                        ? Text(
                            user.username.isNotEmpty
                                ? user.username[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: context.theme.colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.gmail,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Obx(() {
                        final bool isFriend = controller.friendsList.any(
                          (f) => f.id == user.id,
                        );
                        if (!isFriend) return const SizedBox.shrink();

                        final bool isOnline = user.online ?? false;
                        final statusColor = isOnline
                            ? Colors.green
                            : context.theme.disabledColor;

                        return Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isOnline
                                  ? translate('users.status_online')
                                  : translate('users.status_offline'),
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

                Obx(() {
                  final bool isFriend = controller.friendsList.any(
                    (f) => f.id == user.id,
                  );
                  if (isFriend) {
                    return Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: context.theme.hintColor,
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.person_add_rounded,
                        color: context.theme.colorScheme.primary,
                        size: 22,
                      ),
                      onPressed: () => controller.sendFriendRequest(user.id),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
