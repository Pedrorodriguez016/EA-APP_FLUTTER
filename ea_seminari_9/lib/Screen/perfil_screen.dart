import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';
import '../Controllers/user_controller.dart';
import '../Widgets/gamificacion_card.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/global_drawer.dart';
import '../Controllers/gamificacion_controller.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Models/eventos.dart';
import '../Controllers/eventos_controller.dart';
import '../Widgets/custom_date_picker.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends GetView<UserController> {
  ProfileScreen({super.key});
  final authController = Get.find<AuthController>();
  final gamificacionController = Get.put(GamificacionController());
  final eventoController = Get.find<EventoController>();

  Future<void> _refreshData() async {
    // 1. Refrescar datos del usuario actual
    await authController.fetchCurrentUser();
    // 2. Refrescar gamificación
    await gamificacionController.cargarMiProgreso();
    // 3. Refrescar mis eventos
    await eventoController.fetchMisEventosEspecificos();
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser.value;
    final nameController = TextEditingController(text: user?.username ?? '');
    final emailController = TextEditingController(text: user?.gmail ?? '');
    final birthdayController = TextEditingController();

    // Manage selected date locally
    DateTime? selectedBirthDate;

    if (user?.birthday != null && user!.birthday.isNotEmpty) {
      try {
        final date = DateTime.parse(user.birthday);
        selectedBirthDate = date;
        final String currentLocale = LocalizedApp.of(
          context,
        ).delegate.currentLocale.languageCode;
        birthdayController.text = DateFormat.yMMMMd(currentLocale).format(date);
      } catch (_) {
        birthdayController.text = user.birthday;
      }
    }

    // Cargar mis eventos al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventoController.fetchMisEventosEspecificos();
    });

    return WillPopScope(
      onWillPop: () async {
        return true; // Permitir volver atrás
      },
      child: Scaffold(
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
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: context.theme.colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                        translate('events.progress_achievements'),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const GamificacionCard(),

                      const SizedBox(height: 32),
                      _buildMyEventsSection(context),

                      const SizedBox(height: 32),
                      Text(
                        translate('events.personal_info'),
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
                        (date) => selectedBirthDate = date,
                      ),

                      const SizedBox(height: 40),
                      _buildSaveButton(
                        context,
                        user,
                        nameController,
                        emailController,
                        birthdayController,
                        () => selectedBirthDate, // Pass getter
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
        ),
        bottomNavigationBar: const CustomNavBar(currentIndex: 4),
      ), // Cierre del Scaffold
    ); // Cierre del PopScope
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
    Function(DateTime) onDateChanged,
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
        const SizedBox(height: 16),
        CustomDatePicker(
          controller: birthday,
          label: translate('auth.fields.birthday'),
          hintText: translate('auth.fields.birthday_hint'),
          onDateSelected: (date) {
            // We need to update the outer variable.
            // Since we are inside a build method, we can't easily update a local variable that is passed to save button unless we use a state management or mutable object.
            // Given the context, let's use the controller text for display and rely on `onDateSelected` to update `selectedBirthDate` variable which is captured by closure.
            // Wait, closures capture variables by reference.
          },
        ),
        // Wait, I need a cleaner way to handle the state update for the Save button.
        // I will use a simple ValueNotifier or similar if I want to be reactive, but standard variable capture works if I don't need UI rebuilds for this variable specifically (Save button reads it when pressed).
        // Let's refactor _buildProfileFields to accept the callback.
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

  Widget _buildMyEventsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMyEventsBottomSheet(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event_note_rounded,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translate('profile.created_events'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '${eventoController.misEventosCreados.length} ${translate('events.list_title').toLowerCase()}',
                          style: TextStyle(
                            color: context.theme.hintColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.theme.hintColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMyEventsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: context.height * 0.85,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.theme.dividerColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    translate('profile.created_events'),
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (eventoController.isLoading.value &&
                    eventoController.misEventosCreados.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (eventoController.misEventosCreados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note_rounded,
                          size: 60,
                          color: context.theme.hintColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          translate('profile.no_created_events'),
                          style: TextStyle(
                            color: context.theme.hintColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: eventoController.misEventosCreados.length,
                  itemBuilder: (context, index) {
                    final evento = eventoController.misEventosCreados[index];
                    return _buildEventManagementCard(context, evento);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventManagementCard(BuildContext context, Evento evento) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: context.theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evento.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      translate('categories.${evento.categoria}'),
                      style: TextStyle(
                        color: context.theme.hintColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      eventoController.cargarEventoParaEditar(evento),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(translate('profile.edit')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: Text(
                        translate('events.errors.confirm_delete_title'),
                      ),
                      content: Text(
                        translate(
                          'events.errors.confirm_delete_msg',
                          args: {'name': evento.name},
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(translate('common.cancel')),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            eventoController.eliminarEvento(evento.id);
                          },
                          child: Text(
                            translate('common.delete'),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
                tooltip: translate('common.delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    dynamic user,
    TextEditingController name,
    TextEditingController email,
    TextEditingController birthday,
    DateTime? Function() getDateGetter,
  ) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: () async {
          final date = getDateGetter();
          String finalDateISO = '';
          if (date != null) {
            finalDateISO = DateFormat('yyyy-MM-dd').format(date);
          }

          await controller.updateUserByid(user!.id, {
            'username': name.text,
            'email': email.text,
            'birthday': finalDateISO.isNotEmpty ? finalDateISO : user.birthday,
          });

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
        icon: const Icon(Icons.save_rounded, color: Colors.white),
        label: Text(
          translate('profile.save_changes'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
