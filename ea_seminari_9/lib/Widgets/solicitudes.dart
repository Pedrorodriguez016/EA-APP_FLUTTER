import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart'; // Importar
import '../Models/user.dart';
import 'request_card.dart';

class FriendRequestsDialog {
  static void show(
    BuildContext context, {
    required List<User> requests,
    required void Function(User) onAccept,
    required void Function(User) onReject,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(translate('users.friend_requests_title')), // 'Solicitudes de amistad'
          content: SizedBox(
            width: double.maxFinite,
            child: requests.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: Text(translate('users.no_requests'))), // 'No tienes solicitudes...'
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: requests.length,
                    itemBuilder: (ctx, index) {
                      final user = requests[index];
                      return FriendRequestCard(
                        user: user,
                        onAccept: () {
                          onAccept(user);
                          Get.back();
                        },
                        onReject: () {
                          onReject(user);
                          Get.back();
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(translate('common.close')), // 'Cerrar'
            ),
          ],
        );
      },
    );
  }
}