import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/auth_controller.dart';
import 'package:flutter_translate/flutter_translate.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      tooltip: translate('dialogs.logout.title'),
      onPressed: () {
        Get.defaultDialog(
          title: translate('dialogs.logout.title'),
          middleText: translate('dialogs.logout.content'),
          confirm: ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child:  Text(translate('dialogs.logout.confirm')),
          ),
          cancel: TextButton(
            onPressed: () => Get.back(),
            child: Text(translate('common.cancel')),
          ),
        );
      },
    );
  }
}
