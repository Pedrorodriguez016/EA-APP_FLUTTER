import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/user_controller.dart';
import '../Widgets/user_card.dart';

class FriendsBottomSheet extends StatelessWidget {
  const FriendsBottomSheet({super.key});

  static void show(BuildContext context) {
    Get.bottomSheet(
      const FriendsBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Container(
      height: context.height * 0.85,
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: context.theme.dividerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translate('home.friends_section.title'),
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (userController.isLoading.value &&
                  userController.friendsList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userController.friendsList.isEmpty) {
                return Center(
                  child: Text(translate('home.friends_section.empty_msg')),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount:
                    userController.friendsList.length +
                    (userController.friendsCurrentPage.value <
                            userController.friendsTotalPages.value
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  if (index < userController.friendsList.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: UserCard(user: userController.friendsList[index]),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: userController.isMoreFriendsLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : Center(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    userController.loadMoreFriends(),
                                icon: const Icon(Icons.add_rounded),
                                label: Text(
                                  translate('common.load_more') ==
                                          'common.load_more'
                                      ? 'Cargar más'
                                      : translate('common.load_more'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context
                                      .theme
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  foregroundColor:
                                      context.theme.colorScheme.primary,
                                  elevation: 0,
                                ),
                              ),
                            ),
                    );
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
