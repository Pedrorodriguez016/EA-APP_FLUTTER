import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';
import '../utils/app_theme.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return translate('auth.errors.username_empty');
    }
    if (value.length < 3) return translate('auth.errors.username_short');
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return translate('auth.errors.password_empty');
    }
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: _buildLanguageSelector(context),
                    ),
                    const SizedBox(height: 20),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          child: Image.asset(
            'assets/images/logo_grande.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          translate('auth.login.title'),
          textAlign: TextAlign.center,
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          translate('auth.login.subtitle'),
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final isDark = context.isDarkMode;
    InputDecoration inputDecoration(String label, IconData icon) {
      return InputDecoration(
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
    }

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
          const SizedBox(height: 12),
          // FORGOT PASSWORD
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showForgotPasswordDialog(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                translate('auth.login.forgot_password_link'),
                style: TextStyle(
                  color: context.theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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
          const SizedBox(height: 24),

          // DIVIDER
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: context.theme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  translate('auth.login.or_continue_with'),
                  style: TextStyle(
                    color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.5,
                    ),
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: context.theme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // GOOGLE BUTTON
          Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: isDark ? context.theme.colorScheme.surface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Obx(
              () => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: controller.isLoginLoading.value
                      ? null
                      : controller.signInWithGoogle,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: controller.isLoginLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google.png',
                                height: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                translate('auth.login.google_btn'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
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
          text: '${translate('auth.login.no_account')} ',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

  Widget _buildLanguageSelector(BuildContext context) {
    final delegate = LocalizedApp.of(context).delegate;
    final currentLocale = delegate.currentLocale.languageCode;

    final languages = {'es': 'ESP', 'en': 'ENG', 'ca': 'CAT', 'fr': 'FRA'};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLocale,
          icon: Icon(
            Icons.language_rounded,
            size: 18,
            color: context.theme.colorScheme.primary,
          ),
          elevation: 8,
          dropdownColor: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.theme.colorScheme.onSurface,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              changeLocale(context, newValue);
              Get.updateLocale(Locale(newValue));
            }
          },
          items: languages.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int step = 1; // 1: Email, 2: OTP+Pass
    bool isLoading = false;

    // Pre-fill email if user typed it in login
    if (controller.loginUserCtrl.text.contains('@')) {
      emailCtrl.text = controller.loginUserCtrl.text;
    }

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              step == 1
                  ? translate('auth.forgot_password.title')
                  : translate('auth.forgot_password.reset_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      step == 1
                          ? translate('auth.forgot_password.subtitle')
                          : translate('auth.forgot_password.reset_subtitle'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    if (step == 1)
                      TextFormField(
                        controller: emailCtrl,
                        decoration: InputDecoration(
                          labelText: translate('auth.fields.email'),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => GetUtils.isEmail(v ?? '')
                            ? null
                            : translate('auth.errors.email_invalid'),
                      ),
                    if (step == 2) ...[
                      TextFormField(
                        controller: otpCtrl,
                        decoration: InputDecoration(
                          labelText: translate('auth.verification.code_label'),
                          prefixIcon: const Icon(Icons.lock_clock_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => (v?.length ?? 0) == 6
                            ? null
                            : translate('auth.verification.error_invalid_code'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: translate(
                            'auth.forgot_password.new_password_label',
                          ),
                          prefixIcon: const Icon(Icons.lock_reset),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => (v?.length ?? 0) >= 6
                            ? null
                            : translate('auth.errors.password_short'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPassCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: translate('auth.fields.confirm_password'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) {
                          if ((v?.length ?? 0) < 6)
                            return translate('auth.errors.password_short');
                          if (v != passCtrl.text)
                            return translate('auth.errors.password_mismatch');
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              if (!isLoading)
                TextButton(
                  onPressed: () {
                    if (step == 2) {
                      setState(() => step = 1);
                    } else {
                      Get.back();
                    }
                  },
                  child: Text(
                    step == 2
                        ? translate('common.back')
                        : translate('common.cancel'),
                  ),
                ),
              if (step == 2 && !isLoading)
                TextButton(
                  onPressed: () async {
                    setState(() => isLoading = true);
                    await controller.resendCode(emailCtrl.text.trim());
                    setState(() => isLoading = false);
                  },
                  child: Text(
                    translate('auth.verification.resend_btn'),
                    style: TextStyle(color: context.theme.colorScheme.primary),
                  ),
                ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        setState(() => isLoading = true);

                        if (step == 1) {
                          bool sent = await controller.sendForgotPassword(
                            emailCtrl.text.trim(),
                          );
                          setState(() => isLoading = false);
                          if (sent) {
                            setState(() => step = 2);
                          }
                        } else {
                          if (passCtrl.text != confirmPassCtrl.text) {
                            Get.snackbar(
                              translate('common.error'),
                              translate('auth.errors.password_mismatch'),
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            setState(() => isLoading = false);
                            return;
                          }

                          bool reset = await controller.resetPassword(
                            emailCtrl.text.trim(),
                            otpCtrl.text.trim(),
                            passCtrl.text.trim(),
                          );
                          setState(() => isLoading = false);
                          // Close dialog on success is handled inside this if block by Get.back() if logic is right,
                          // OR we can rely on controller to manage it. But controller just returns bool.
                          // The previous code had Get.back() here.
                          if (reset) {
                            Navigator.of(
                              context,
                            ).pop(); // Force close dialog using Navigator to be safe
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        step == 1
                            ? translate('auth.forgot_password.send_btn')
                            : translate('auth.forgot_password.reset_btn'),
                      ),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }
}
