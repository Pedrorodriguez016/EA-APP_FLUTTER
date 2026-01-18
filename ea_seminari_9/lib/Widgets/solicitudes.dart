import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Models/user.dart';
import 'request_card.dart';

class FriendRequestsDialog {
  static void show(
    BuildContext context, {
    required RxList<User> requests,
    required void Function(User) onAccept,
    required void Function(User) onReject,
  }) {
    Get.dialog(
      Obx(
        () => Dialog(
          backgroundColor: context.theme.cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_rounded,
                        color: context.theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        translate('users.friend_requests_title'),
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: Get.height * 0.5),
                  child: requests.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: Icon(
                                  Icons.mark_email_read_rounded,
                                  size: 48,
                                  color: context.theme.disabledColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                translate('users.no_requests'),
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: requests.length,
                          itemBuilder: (ctx, index) {
                            final user = requests[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FriendRequestCard(
                                user: user,
                                onAccept: () {
                                  onAccept(user);
                                  if (requests.length == 1) Get.back();
                                },
                                onReject: () {
                                  onReject(user);
                                  if (requests.length == 1) Get.back();
                                },
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: context.theme.colorScheme.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: Text(translate('common.close').toUpperCase()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
