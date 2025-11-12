import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/auth_controller.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      tooltip: 'Cerrar sesión',
      onPressed: () {
        Get.defaultDialog(
          title: 'Cerrar sesión',
          middleText: '¿Seguro que quieres cerrar sesión?',
          confirm: ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
              Get.snackbar(
                'Sesión cerrada',
                'Has cerrado sesión correctamente',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                borderRadius: 12,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, salir'),
          ),
          cancel: TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
        );
      },
    );
  }
}
