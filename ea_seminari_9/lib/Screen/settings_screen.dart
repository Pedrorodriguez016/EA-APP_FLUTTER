import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/auth_controller.dart';
import '../Widgets/navigation_bar.dart';

class SettingsScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuración de la Cuenta',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.deepPurple),
                      title: const Text('Información del Perfil'),
                      subtitle: Text('Usuario: ${authController.currentUser.value?.username}'),
                      onTap: () {
                        Get.snackbar(
                          'Perfil',
                          'Funcionalidad en desarrollo',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.deepPurple),
                      title: const Text('Notificaciones'),
                      subtitle: const Text('Gestiona tus notificaciones'),
                      onTap: () {
                        Get.snackbar(
                          'Notificaciones',
                          'Funcionalidad en desarrollo',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.security, color: Colors.deepPurple),
                      title: const Text('Privacidad y Seguridad'),
                      subtitle: const Text('Configura tu privacidad'),
                      onTap: () {
                        Get.snackbar(
                          'Privacidad',
                          'Funcionalidad en desarrollo',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acerca de la App',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ListTile(
                      leading: Icon(Icons.info, color: Colors.deepPurple),
                      title: Text('Versión'),
                      subtitle: Text('1.0.0'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help, color: Colors.deepPurple),
                      title: const Text('Ayuda y Soporte'),
                      onTap: () {
                        Get.snackbar(
                          'Ayuda',
                          'Funcionalidad en desarrollo',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 3),

    );
  }
}