import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';
import '../Controllers/user_controller.dart';
import '../Widgets/gamificacion_card.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/global_drawer.dart';
import '../Controllers/gamificacion_controller.dart';
import '../utils/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends GetView<UserController> {
  ProfileScreen({super.key});
  final authController = Get.find<AuthController>();
  final gamificacionController = Get.put(GamificacionController());

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Builder(
            builder: (scaffoldContext) => IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.theme.scaffoldBackgroundColor.withValues(
                    alpha: 0.8,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: context.theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              onPressed: () => Scaffold.of(scaffoldContext).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: const GlobalDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsBar(context),
                  const SizedBox(height: 32),

                  Text(
                    'Progreso y Logros',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const GamificacionCard(),

                  const SizedBox(height: 32),
                  Text(
                    'Información Personal',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileFields(
                    context,
                    nameController,
                    emailController,
                    birthdayController,
                  ),

                  const SizedBox(height: 40),
                  _buildSaveButton(
                    context,
                    user,
                    nameController,
                    emailController,
                    birthdayController,
                  ),

                  const SizedBox(height: 16),
                  _buildDeleteAccountButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 4),
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
                  title: Text(translate('profile.gallery')),
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
                  title: Text(translate('profile.camera')),
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

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _showDeleteConfirmationDialog(context),
        icon: Icon(
          Icons.delete_forever_rounded,
          color: context.theme.colorScheme.error.withValues(alpha: 0.7),
          size: 20,
        ),
        label: Text(
          translate('profile.delete_account'),
          style: TextStyle(
            color: context.theme.colorScheme.error.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            translate('profile.delete_dialog.title'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(translate('profile.delete_dialog.content')),
              const SizedBox(height: 24),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: translate(
                    'profile.delete_dialog.password_confirm',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  prefixIcon: const Icon(Icons.lock_rounded),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Get.back(),
              child: Text(translate('common.cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.colorScheme.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final String password = passwordController.text;
                if (password.isNotEmpty) {
                  controller.disableUserByid(user!.id, password);
                }
              },
              child: Text(translate('profile.delete_dialog.confirm_btn')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.theme.colorScheme.primary,
                context.theme.colorScheme.primary.withValues(alpha: 0.8),
                context.theme.colorScheme.secondary.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.theme.scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    Obx(() {
                      final currentUser = authController.currentUser.value;
                      final fullUrl = controller.getFullPhotoUrl(
                        currentUser?.profilePhoto,
                      );

                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: context.theme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        backgroundImage: fullUrl != null
                            ? NetworkImage(fullUrl)
                            : null,
                        child: fullUrl == null
                            ? Hero(
                                tag: 'profile_avatar',
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 70,
                                  color: context.theme.colorScheme.primary,
                                ),
                              )
                            : null,
                      );
                    }),
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
                            border: Border.all(
                              color: context.theme.scaffoldBackgroundColor,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: context.theme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final currentUser = authController.currentUser.value;
                if (currentUser?.profilePhoto != null) {
                  return TextButton(
                    onPressed: () =>
                        controller.deleteProfilePhoto(currentUser!.id),
                    child: Text(
                      translate('profile.delete_photo'),
                      style: TextStyle(
                        color: context.theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 10);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(BuildContext context) {
    return Obx(() {
      final amigosCount = controller.friendsList.length.toString();
      final nivelActual =
          gamificacionController.miProgreso.value?.nivel ??
          translate('profile.stats.default_rank');
      final eventosAsistidos =
          gamificacionController
              .miProgreso
              .value
              ?.estadisticas
              .eventosUnidosTotal
              .toString() ??
          '0';

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              amigosCount,
              translate('profile.stats.friends'),
              Icons.people_outline_rounded,
            ),
            VerticalDivider(color: context.theme.dividerColor),
            _buildStatItem(
              context,
              eventosAsistidos,
              translate('profile.stats.attendees'),
              Icons.event_available_rounded,
            ),
            VerticalDivider(color: context.theme.dividerColor),
            _buildStatItem(
              context,
              nivelActual,
              translate('profile.stats.rank'),
              Icons.military_tech_rounded,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: context.theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.theme.hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileFields(
    BuildContext context,
    TextEditingController name,
    TextEditingController email,
    TextEditingController birthday,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          context,
          translate('auth.fields.username'),
          name,
          Icons.person_rounded,
        ),
        _buildTextField(
          context,
          translate('auth.fields.email'),
          email,
          Icons.email_rounded,
        ),
        _buildTextField(
          context,
          translate('auth.fields.birthday'),
          birthday,
          Icons.cake_rounded,
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: context.theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: context.theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: context.theme.colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: context.theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    dynamic user,
    TextEditingController name,
    TextEditingController email,
    TextEditingController birthday,
  ) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppGradients.primaryBtn,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          final userId = user!.id;
          final updatedUser = {
            'username': name.text,
            'email': email.text,
            'birthday': birthday.text,
          };
          await controller.updateUserByid(userId, updatedUser);
          Get.snackbar(
            translate('profile.snackbars.success_title'),
            translate('profile.snackbars.success_msg'),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withValues(alpha: 0.9),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 16,
            icon: const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            duration: const Duration(seconds: 2),
          );
        },
        icon: const Icon(Icons.sync_rounded, color: Colors.white),
        label: Text(
          translate('profile.update_btn'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
