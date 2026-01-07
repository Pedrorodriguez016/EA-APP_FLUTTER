import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';
import '../Controllers/user_controller.dart';
import '../Widgets/logout_button.dart';
import '../Widgets/gamificacion_card.dart';
import '../utils/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends GetView<UserController> {
  ProfileScreen({super.key});
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser.value;
    final nameController = TextEditingController(text: user?.username ?? '');
    final emailController = TextEditingController(text: user?.gmail ?? '');
    final birthdayController = TextEditingController(
      text: user?.birthday ?? '',
    );

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          translate('profile.title'),
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.theme.iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
        actions: const [LogoutButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.primaryBtn,
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.colorScheme.primary.withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: context.theme.scaffoldBackgroundColor,
                    child: Obx(() {
                      final currentUser = authController.currentUser.value;
                      final fullUrl = controller.getFullPhotoUrl(
                        currentUser?.profilePhoto,
                      );

                      return CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: fullUrl != null
                            ? NetworkImage(fullUrl)
                            : null,
                        child: fullUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.white,
                              )
                            : null,
                      );
                    }),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showPickerOptions(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Obx(() {
              final currentUser = authController.currentUser.value;
              if (currentUser?.profilePhoto != null) {
                return TextButton(
                  onPressed: () =>
                      controller.deleteProfilePhoto(currentUser!.id),
                  child: Text(
                    translate('profile.delete_photo') ?? 'Eliminar foto',
                    style: TextStyle(
                      color: context.theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox(height: 20);
            }),

            // Card de gamificación
            const GamificacionCard(),

            const SizedBox(height: 24),

            _buildTextField(
              context,
              translate('auth.fields.username'),
              nameController,
              Icons.person_rounded,
            ),
            _buildTextField(
              context,
              translate('auth.fields.email'),
              emailController,
              Icons.email_rounded,
            ),
            _buildTextField(
              context,
              translate('auth.fields.birthday'),
              birthdayController,
              Icons.cake_rounded,
            ),

            const SizedBox(height: 40),

            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryBtn,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.theme.colorScheme.primary.withValues(
                      alpha: 0.4,
                    ),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final userId = user!.id;
                  final updatedUser = {
                    'username': nameController.text,
                    'email': emailController.text,
                    'birthday': birthdayController.text,
                  };
                  await controller.updateUserByid(userId, updatedUser);
                  Get.snackbar(
                    translate('profile.update_success'),
                    translate('common.success'),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    borderRadius: 12,
                    margin: const EdgeInsets.all(16),
                  );
                },
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: Text(
                  translate('profile.save_changes'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton.icon(
              onPressed: () {
                _showDeleteConfirmationDialog(context);
              },
              icon: Icon(
                Icons.delete_forever_rounded,
                color: context.theme.colorScheme.error,
              ),
              label: Text(
                translate('profile.delete_account'),
                style: TextStyle(
                  color: context.theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                backgroundColor: context.theme.colorScheme.error.withValues(
                  alpha: 0.1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.photo_library_rounded,
                    color: context.theme.colorScheme.primary,
                  ),
                  title: Text(translate('profile.gallery') ?? 'Galería'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_rounded,
                    color: context.theme.colorScheme.primary,
                  ),
                  title: Text(translate('profile.camera') ?? 'Cámara'),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (image != null) {
      final user = authController.currentUser.value;
      if (user != null) {
        await controller.uploadProfilePhoto(user.id, File(image.path));
      }
    }
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          style: context.textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: context.theme.colorScheme.primary),
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.theme.colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.all(18),
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
          backgroundColor: context.theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: context.theme.colorScheme.error,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  translate('profile.delete_dialog.title'),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translate('profile.delete_dialog.content'),
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                autofocus: true,
                style: context.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: translate(
                    'profile.delete_dialog.password_confirm',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                translate('common.cancel'),
                style: TextStyle(color: context.theme.colorScheme.onSurface),
              ),
              onPressed: () {
                Get.back();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                translate('profile.delete_dialog.confirm_btn'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
                      content: Text('Error'),
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
