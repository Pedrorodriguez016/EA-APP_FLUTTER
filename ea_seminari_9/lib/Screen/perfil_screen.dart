import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart'; // Importar
import '../Controllers/auth_controller.dart';
import '../Controllers/user_controller.dart';
import '../Widgets/logout_button.dart';

class ProfileScreen extends GetView<UserController> {
  ProfileScreen({super.key});
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
  final user = authController.currentUser.value;
    final nameController = TextEditingController(text: user?.username ?? '');
    final emailController = TextEditingController(text: user?.gmail ?? '');
    final birthdayController = TextEditingController(text: user?.birthday ?? '');

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(translate('profile.title')), // 'Mi perfil'
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        actions: const [LogoutButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo.shade100,
              child: const Icon(Icons.person, size: 60, color: Colors.indigo),
            ),
            const SizedBox(height: 20),

            _buildTextField(translate('auth.fields.username'), nameController, Icons.person),
            _buildTextField(translate('auth.fields.email'), emailController, Icons.email),
            _buildTextField(translate('auth.fields.birthday'), birthdayController, Icons.cake_outlined),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () async {
                final userId= user!.id;
                final updatedUser = {
                  'username': nameController.text,
                  'email': emailController.text,
                  'birthday': birthdayController.text,
                };
                await controller.updateUserByid(userId, updatedUser); 
                Get.snackbar(
                  translate('profile.update_success'), // 'Perfil actualizado'
                  translate('common.success'),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  borderRadius: 12,
                );
              },
              icon: const Icon(Icons.save),
              label: Text(translate('profile.save_changes')), // 'Guardar cambios'
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton.icon(
              onPressed: () {
                      _showDeleteConfirmationDialog(context);
              },
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              label: Text(
                translate('profile.delete_account'), // 'Eliminar cuenta'
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
  void _showDeleteConfirmationDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final user = authController.currentUser.value;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(translate('profile.delete_dialog.title')), // '¿Estás seguro?'
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(translate('profile.delete_dialog.content')), // 'Esta acción es permanente...'
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                autofocus: true, 
                decoration: InputDecoration(
                  labelText: translate('profile.delete_dialog.password_confirm'), // 'Confirma tu contraseña'
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(translate('common.cancel')), // 'Cancelar'
              onPressed: () {
                Get.back();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, 
              ),
              child: Text(
                translate('profile.delete_dialog.confirm_btn'), // 'Confirmar Eliminación'
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () {
                final String password = passwordController.text;
                if (password.isNotEmpty) {
                  controller.disableUserByid(user!.id, password);
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                      content: Text(translate('common.success')),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error'), // O usar una clave traducida para error de contraseña vacía
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}