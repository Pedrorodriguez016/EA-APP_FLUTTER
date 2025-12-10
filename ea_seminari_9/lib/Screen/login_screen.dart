import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';
import '../utils/app_theme.dart'; // Import AppTheme for AppGradients

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({Key? key}) : super(key: key);

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty)
      return translate('auth.errors.username_empty');
    if (value.length < 3) return translate('auth.errors.username_short');
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty)
      return translate('auth.errors.password_empty');
    if (value.length < 6) return translate('auth.errors.password_short');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoggedIn.value) {
        Future.microtask(() => Get.offAllNamed('/home'));
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final isDark = context.isDarkMode;

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark ? AppGradients.darkSpaceBg : AppGradients.lightBg,
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(context),
                    const SizedBox(height: 48),
                    _buildLoginForm(context),
                    const SizedBox(height: 32),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 70,
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
          child: const Icon(
            Icons.event_note_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          translate('auth.login.title'),
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: context.theme.colorScheme.onBackground,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          translate('auth.login.subtitle'),
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.theme.colorScheme.onBackground.withValues(
              alpha: 0.7,
            ),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final isDark = context.isDarkMode;
    // Enhanced Input Decoration
    final inputDecoration = (String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: context.theme.colorScheme.primary),
      filled: true,
      fillColor: isDark
          ? context.theme.colorScheme.surface.withValues(alpha: 0.5)
          : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: context.theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.all(20),
      labelStyle: TextStyle(
        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );

    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          // USERNAME
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller.loginUserCtrl,
              style: context.textTheme.bodyLarge,
              decoration: inputDecoration(
                translate('auth.fields.username'),
                Icons.person_rounded,
              ),
              validator: _validateUsername,
            ),
          ),
          const SizedBox(height: 20),

          // PASSWORD
          Obx(
            () => Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller.loginPassCtrl,
                obscureText: controller.isObscurePassword.value,
                style: context.textTheme.bodyLarge,
                decoration:
                    inputDecoration(
                      translate('auth.fields.password'),
                      Icons.lock_rounded,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isObscurePassword.value
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                validator: _validatePassword,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // BUTTON
          Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryBtn,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.theme.colorScheme.primary.withValues(
                    alpha: 0.4,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoginLoading.value
                    ? null
                    : controller.submitLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: controller.isLoginLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        translate('auth.login.action_btn'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: translate('auth.login.no_account') + ' ',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.theme.colorScheme.onBackground.withValues(
              alpha: 0.6,
            ),
          ),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => Get.toNamed('/register'),
                child: Text(
                  translate('auth.login.register_link'),
                  style: TextStyle(
                    color: context.theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
