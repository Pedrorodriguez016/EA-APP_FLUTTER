import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/user_controller.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/user_info.dart';
import '../Services/storage_service.dart';
import '../utils/logger.dart';

class SettingsScreen extends GetView<UserController> {
  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var currentLocale = LocalizedApp.of(context).delegate.currentLocale;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(translate('settings.title')), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Obx(() {
              final user = controller.authController.currentUser.value;
              if (user == null) {
                return const SizedBox.shrink();
              }
              return UserInfoBasic(name: user.username, email: user.gmail);
            }),
            const SizedBox(height: 20),
            _buildSettingsSection(context, currentLocale.languageCode),
            const SizedBox(height: 20),
            _buildAboutSection(context),
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
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor.withValues(alpha: 0.1),
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
              translate('settings.config_section'),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buildSettingItem(
            context: context,
            icon: Icons.person_outline,
            title: translate('settings.profile'),
            subtitle: translate('settings.profile_subtitle'),
            onTap: () => Get.toNamed('/profile'),
          ),
          const Divider(height: 1),
          _buildThemeSwitchTile(context),
          const Divider(height: 1),
          _buildSettingItem(
            context: context,
            icon: Icons.notifications_outlined,
            title: translate('settings.notifications'),
            subtitle: translate('settings.coming_soon'),
            onTap: () => _showComingSoon(translate('settings.notifications')),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context: context,
            icon: Icons.language_outlined,
            title: translate('settings.language'),
            subtitle: _getLanguageName(currentLangCode),
            onTap: () => _showLanguageSelector(context),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSwitchTile(BuildContext context) {
    final bool isDark = context.isDarkMode;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          color: const Color(0xFF667EEA),
        ),
      ),
      title: Text(
        translate('settings.theme_mode') == 'settings.theme_mode'
            ? 'Modo Oscuro'
            : translate('settings.theme_mode'),
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        isDark ? 'Activado' : 'Desactivado',
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.theme.hintColor,
        ),
      ),
      trailing: Switch(
        value: isDark,
        activeColor: const Color(0xFF667EEA),
        onChanged: (val) {
          Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);

          try {
            Get.find<StorageService>().saveTheme(val);
          } catch (e) {
            logger.e('StorageService error: $e');
          }
        },
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor.withValues(alpha: 0.1),
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
              translate('settings.about_section'),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buildSettingItem(
            context: context,
            icon: Icons.info_outline,
            title: translate('settings.version'),
            subtitle: '1.0.0',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context: context,
            icon: Icons.help_outline,
            title: translate('settings.help'),
            subtitle: translate('settings.coming_soon'),
            onTap: () => _showComingSoon(translate('settings.help')),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context: context,
            icon: Icons.description_outlined,
            title: translate('settings.terms'),
            subtitle: translate('settings.coming_soon'),
            onTap: () => _showComingSoon(translate('settings.terms')),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF667EEA)),
      ),
      title: Text(
        title,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.theme.hintColor,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.theme.dividerColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: context.theme.iconTheme.color,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      translate('settings.coming_soon'),
      '$feature ${translate("settings.coming_soon")}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF667EEA),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'ca':
        return 'Català';
      case 'fr':
        return 'Français';
      default:
        return code.toUpperCase();
    }
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.theme.scaffoldBackgroundColor,
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  translate('settings.language'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
    final currentCode = LocalizedApp.of(
      context,
    ).delegate.currentLocale.languageCode;
    final isSelected = currentCode == code;

    return ListTile(
      leading: isSelected
          ? const Icon(Icons.radio_button_checked, color: Color(0xFF667EEA))
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? const Color(0xFF667EEA)
              : context.theme.textTheme.bodyLarge?.color,
        ),
      ),
      onTap: () {
        changeLocale(context, code);
        Get.back();
      },
    );
  }
}
