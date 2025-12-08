import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart'; 
import '../Controllers/user_controller.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/user_info.dart';

class SettingsScreen extends GetView<UserController> {
  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var currentLocale = LocalizedApp.of(context).delegate.currentLocale;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(translate('settings.title')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Obx(() {
              final user = controller.authController.currentUser.value;
              if (user == null) {
                return const SizedBox.shrink();
              }
              return UserInfoBasic(
                name: user.username,
                email: user.gmail,
              );
            }),
            _buildSettingsSection(context, currentLocale.languageCode),
            const SizedBox(height: 20),
            _buildAboutSection()
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 3),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String currentLangCode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              translate('settings.config_section'), // 'Configuración'
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          _buildSettingItem(
            icon: Icons.person_outline,
            title: translate('settings.profile'), // 'Perfil'
            subtitle: translate('settings.profile_subtitle'),
            onTap: () => Get.toNamed('/profile'),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: translate('settings.notifications'),
            subtitle: translate('settings.coming_soon'),
            onTap: () => _showComingSoon(translate('settings.notifications')),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.security_outlined,
            title: translate('settings.privacy'),
            subtitle: translate('settings.coming_soon'),
            onTap: () => _showComingSoon(translate('settings.privacy')),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.language_outlined,
            title: translate('settings.language'),
            // Mostramos el nombre del idioma actual
            subtitle: _getLanguageName(currentLangCode), 
            // CORREGIDO: Ahora podemos usar 'context' aquí
            onTap: () => _showLanguageSelector(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              translate('settings.about_section'), // 'Acerca de'
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: translate('settings.version'), // 'Versión'
            subtitle: '1.0.0',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: translate('settings.help'), // 'Ayuda y Soporte'
            subtitle: translate('settings.coming_soon'),
            onTap: () => _showComingSoon(translate('settings.help')),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.description_outlined,
            title: translate('settings.terms'), // 'Términos y Condiciones'
            subtitle: translate('settings.coming_soon'),
            onTap: () => _showComingSoon(translate('settings.terms')),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF667EEA)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
      onTap: onTap,
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      translate('settings.coming_soon'),
      '$feature ${translate("settings.coming_soon")}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'es': return 'Español';
      case 'en': return 'English';
      case 'ca': return 'Català';
      case 'fr': return 'Français';
      default: return code.toUpperCase();
    }
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, 
                height: 4, 
                decoration: BoxDecoration(
                  color: Colors.grey[300], 
                  borderRadius: BorderRadius.circular(2)
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  translate('settings.language'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildLanguageOption(context, 'Español', 'es'),
              _buildLanguageOption(context, 'English', 'en'),
              _buildLanguageOption(context, 'Català', 'ca'),
              _buildLanguageOption(context, 'Français', 'fr'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, String code) {
    // Verificamos si este es el idioma seleccionado actualmente
    final currentCode = LocalizedApp.of(context).delegate.currentLocale.languageCode;
    final isSelected = currentCode == code;

    return ListTile(
      leading: isSelected 
          ? const Icon(Icons.radio_button_checked, color: Color(0xFF667EEA))
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      title: Text(
        name, 
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF667EEA) : Colors.black87
        )
      ),
      onTap: () {
        // Cambia el idioma de la app al instante
        changeLocale(context, code);
        // Cierra el selector
        Navigator.pop(context);
      },
    );
  }
}