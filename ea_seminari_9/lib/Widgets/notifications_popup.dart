import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../Controllers/notificacion_controller.dart';
import '../Models/notificacion.dart';
import 'package:flutter_translate/flutter_translate.dart';

class NotificationsPopup extends StatelessWidget {
  const NotificationsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificacionController>();

    return Container(
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar for bottom sheet
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translate('notificaciones.titulo'),
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: translate('notificaciones.marcar_todas_leidas'),
                  onPressed: () => controller.markAllAsRead(),
                ),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.notificaciones.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.notificaciones.isEmpty) {
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          translate('notificaciones.vacia'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Get.height * 0.7),
                child: RefreshIndicator(
                  onRefresh: () => controller.fetchNotificaciones(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.notificaciones.length,
                    itemBuilder: (context, index) {
                      final notif = controller.notificaciones[index];
                      return _NotificacionTile(notif: notif);
                    },
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _NotificacionTile extends StatelessWidget {
  final Notificacion notif;

  const _NotificacionTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificacionController>();

    IconData iconData;
    Color iconColor;

    switch (notif.type) {
      case 'friend_request':
        iconData = Icons.person_add;
        iconColor = Colors.blue;
        break;
      case 'friend_accepted':
        iconData = Icons.person;
        iconColor = Colors.green;
        break;
      case 'event_join':
        iconData = Icons.event_available;
        iconColor = Colors.orange;
        break;
      case 'event_reminder':
        iconData = Icons.alarm;
        iconColor = Colors.red;
        break;
      case 'new_message':
        iconData = Icons.message;
        iconColor = Colors.purple;
        break;
      case 'event_spot_available':
        iconData = Icons.check_circle;
        iconColor = Colors.teal;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteNotificacion(notif.id),
      child: Container(
        color: notif.read ? null : context.theme.primaryColor.withOpacity(0.05),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          title: Text(
            notif.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: notif.read ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notif.message, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                timeago.format(notif.createdAt, locale: 'es'),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          onTap: () {
            controller.markAsRead(notif.id);
            _handleNavigation(notif);
          },
        ),
      ),
    );
  }

  void _handleNavigation(Notificacion notif) {
    Get.back(); // Cierra el popup primero
    if (notif.relatedEventId != null) {
      Get.toNamed('/evento/${notif.relatedEventId}');
    } else if (notif.type == 'friend_request' ||
        notif.type == 'friend_accepted') {
      if (notif.relatedUserId != null) {
        Get.toNamed('/user/${notif.relatedUserId}');
      }
    } else if (notif.type == 'new_message') {
      Get.toNamed('/chat-list');
    }
  }
}
