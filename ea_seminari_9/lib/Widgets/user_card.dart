import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Models/user.dart';
import '../Controllers/user_controller.dart';

class UserCard extends GetView<UserController> {
  final User user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          onTap: () => Get.toNamed('/user/${user.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF667EEA),
                  child: Text(
                    user.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // --- Info principal del usuario ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.gmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),

                      
                      Obx(() {
                        final bool isFriend = controller.friendsList.any((f) => f.id == user.id);
                        if (!isFriend) return const SizedBox.shrink();

                        final bool isOnline = user.online ?? false;
                        return Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: isOnline
                                        ? Colors.green.withOpacity(0.4)
                                        : Colors.grey.withOpacity(0.4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOnline ? "Conectado" : "Desconectado",
                              style: TextStyle(
                                fontSize: 13,
                                color: isOnline ? Colors.green.shade700 : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

                Obx(() {
                  final bool isFriend = controller.friendsList.any((f) => f.id == user.id);
                  if (isFriend) {
                    return const Icon(Icons.arrow_forward, color: Colors.grey);
                  }
                  return Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        controller.sendFriendRequest(user.id);
                      },
                      child: const Icon(Icons.person_add, color: Colors.blue),
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
