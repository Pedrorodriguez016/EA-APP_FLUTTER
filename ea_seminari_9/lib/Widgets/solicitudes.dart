import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Models/user.dart';
import 'request_card.dart';

class FriendRequestsDialog {
  /// Muestra un diálogo con la lista de solicitudes.
  /// IMPORTANTE: usa parámetros con nombre: requests, onAccept, onReject
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
          title: const Text('Solicitudes de amistad'),
          content: SizedBox(
            width: double.maxFinite,
            child: requests.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No tienes solicitudes pendientes.')),
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
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
