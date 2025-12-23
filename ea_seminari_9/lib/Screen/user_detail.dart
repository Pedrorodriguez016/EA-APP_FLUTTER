import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Models/user.dart';
import '../Controllers/user_controller.dart';

class UserDetailScreen extends GetView<UserController> {
  final String userId;
  UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserById(userId);
    });
    return Scaffold(
      // CAMBIO: Fondo dinámico
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          translate('users.detail_title'),
          // CAMBIO: Estilo dinámico
          style: context.textTheme.titleLarge,
        ),
        // CAMBIO: AppBar integrado con el fondo
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        // CAMBIO: Icono de retroceso dinámico
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  translate('common.loading'),
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }
        if (controller.selectedUser.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: context.theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  translate('users.load_error'),
                  style: context.textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }
        final user = controller.selectedUser.value!;
        return _buildUserDetail(context, user);
      }),
    );
  }

  Widget _buildUserDetail(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildUserHeader(context, user),
          const SizedBox(height: 32),
          _buildUserInfoCard(context, user),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, User user) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // CAMBIO: Gradiente usando colores del tema
              colors: [
                context.theme.colorScheme.primary,
                context.theme.colorScheme.secondary,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 48,
                color: context
                    .theme
                    .colorScheme
                    .onPrimary, // Texto blanco sobre primario
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          user.username,
          // CAMBIO: Estilo de texto dinámico
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.gmail,
          // CAMBIO: Color secundario (hint)
          style: context.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: context.theme.hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(BuildContext context, User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // CAMBIO: Color de tarjeta y sombras dinámicas
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // FIXED: withOpacity -> withValues
            color: context.theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: context.theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('users.info_card_title'),
            // CAMBIO: Título de sección dinámico
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            context,
            Icons.person,
            '${translate("auth.fields.username")}:',
            user.username,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            Icons.email,
            '${translate("auth.fields.email")}:',
            user.gmail,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            Icons.cake,
            '${translate("auth.fields.birthday")}:',
            user.birthday,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // FIXED: withOpacity -> withValues, usando color primario
            color: context.theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: context.theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  // CAMBIO: Color secundario
                  color: context.theme.hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                // CAMBIO: Texto principal dinámico
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
