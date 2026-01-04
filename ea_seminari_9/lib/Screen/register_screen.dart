import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';
import '../Models/user.dart';
import '../utils/app_theme.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  Color _getPasswordBorderColor(PasswordStrength? strength) {
    switch (strength) {
      case PasswordStrength.strong:
        return Colors.green;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.weak:
        return Colors.red;
      default:
        return Get.theme.dividerColor;
    }
  }

  final ValueNotifier<PasswordStrength?> passwordStrengthNotifier =
      ValueNotifier<PasswordStrength?>(null);
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController gmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _formKey = GlobalKey<FormState>();

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: context.theme.cardColor,
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              translate('auth.register.success_title'),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          translate('auth.register.success_msg'),
          style: context.textTheme.bodyMedium?.copyWith(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text(
              translate('auth.register.continue'),
              style: TextStyle(
                color: context.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      barrierDismissible: false,
    );
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return translate('auth.errors.username_empty');
    }
    if (value.length < 3) {
      return translate('auth.errors.username_short');
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return translate('auth.errors.username_chars');
    }
    return null;
  }

  Widget _buildPasswordRequirements(String password) {
    final requirements = [
      {
        'label': translate('auth.password_requirements.chars'),
        'valid': password.length >= 12,
      },
      {'label': 'a-z', 'valid': RegExp(r'[a-z]').hasMatch(password)},
      {'label': 'A-Z', 'valid': RegExp(r'[A-Z]').hasMatch(password)},
      {'label': '0-9', 'valid': RegExp(r'[0-9]').hasMatch(password)},
      {
        'label': '!@#\$',
        'valid': RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: requirements.map((req) {
        Color color;
        bool isValid = req['valid'] as bool;

        if (isValid) {
          color = Colors.green;
        } else if (password.isEmpty) {
          color = context.theme.disabledColor;
        } else {
          color = Colors.red;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                req['label'] as String,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String? _validateGmail(String? value) {
    if (value == null || value.isEmpty)
      return translate('auth.errors.email_empty');
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
      return translate('auth.errors.email_invalid');
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty)
      return translate('auth.errors.password_empty');
    if (value != passwordController.text)
      return translate('auth.errors.password_mismatch');
    return null;
  }

  String? _validateBirthday(String? value) {
    if (value == null || value.isEmpty)
      return translate('auth.errors.birthday_empty');
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value))
      return translate('auth.errors.birthday_invalid');
    try {
      final parts = value.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final birthday = DateTime(year, month, day);
      final now = DateTime.now();
      final age = now.year - birthday.year;

      if (birthday.isAfter(now))
        return translate('auth.errors.birthday_invalid');
      if (age < 13) return translate('auth.errors.age_restriction');
      if (age > 120) return translate('auth.errors.birthday_invalid');
    } catch (e) {
      return translate('auth.errors.birthday_invalid');
    }
    return null;
  }

  PasswordStrength _customPasswordStrength(String password) {
    int count = 0;
    if (password.length >= 12) count++;
    if (RegExp(r'[a-z]').hasMatch(password)) count++;
    if (RegExp(r'[A-Z]').hasMatch(password)) count++;
    if (RegExp(r'[0-9]').hasMatch(password)) count++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) count++;
    switch (count) {
      case 5:
        return PasswordStrength.secure;
      case 4:
        return PasswordStrength.strong;
      case 3:
        return PasswordStrength.medium;
      default:
        return PasswordStrength.weak;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.darkSpaceBg : AppGradients.lightBg,
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text(
                  translate('auth.register.title'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.transparent,
                foregroundColor: context.theme.colorScheme.onBackground,
                elevation: 0,
                centerTitle: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildRegisterForm(),
                      const SizedBox(height: 24),
                      _buildFooter(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryBtn,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: context.theme.colorScheme.primary.withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            translate('auth.register.subtitle'),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              color: context.theme.colorScheme.onBackground.withValues(
                alpha: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: usernameController,
            label: translate('auth.fields.username'),
            icon: Icons.person_outline_rounded,
            validator: _validateUsername,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: gmailController,
            label: translate('auth.fields.email'),
            icon: Icons.email_outlined,
            validator: _validateGmail,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPasswordRequirements(passwordController.text),
          ),

          // PRIMARY PASSWORD FIELD
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: passwordController,
              obscureText: _obscurePassword,
              style: context.textTheme.bodyLarge,
              onChanged: (value) {
                passwordStrengthNotifier.value = _customPasswordStrength(value);
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: translate('auth.fields.password'),
                // Dynamic styling
                fillColor: context.isDarkMode
                    ? context.theme.colorScheme.surface.withValues(alpha: 0.5)
                    : Colors.white,
                filled: true,
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
                  borderSide: BorderSide(
                    color: context.theme.colorScheme.primary,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: context.theme.colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // STRENGTH BAR
          ValueListenableBuilder<PasswordStrength?>(
            valueListenable: passwordStrengthNotifier,
            builder: (context, strength, _) {
              String label = '';
              Color color = _getPasswordBorderColor(strength);
              if (strength == PasswordStrength.secure)
                color = const Color(0xFF0B6C0E);

              switch (strength) {
                case PasswordStrength.weak:
                  label = translate('common.error');
                  break;
                case PasswordStrength.medium:
                  label = translate('auth.errors.password_medium');
                  break;
                case PasswordStrength.strong:
                  label = translate('auth.errors.password_strong');
                  break;
                case PasswordStrength.secure:
                  label = translate('auth.errors.password_secure');
                  break;
                default:
                  label = '';
              }

              return Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: context.isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _getStrengthWidth(strength),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),
          _buildPasswordField(
            controller: confirmPasswordController,
            label: translate('auth.fields.confirm_password'),
            obscureText: _obscureConfirmPassword,
            onToggle: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: birthdayController,
            label: translate('auth.fields.birthday'),
            icon: Icons.cake_rounded,
            hintText: translate('auth.fields.birthday_hint'),
            validator: _validateBirthday,
          ),
          const SizedBox(height: 32),

          // GENERATE PASSWORD BUTTON
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton.icon(
              onPressed: () {
                final generated = _generateStrongPassword();
                passwordController.text = generated;
                passwordStrengthNotifier.value = PasswordStrength.calculate(
                  text: generated,
                );
                setState(() {});
              },
              icon: const Icon(Icons.vpn_key_rounded),
              style: TextButton.styleFrom(
                backgroundColor: context.theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                foregroundColor: context.theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              label: Text(
                translate('auth.register.generate_password_btn'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  double _getStrengthWidth(PasswordStrength? strength) {
    switch (strength) {
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.medium:
        return 0.4;
      case PasswordStrength.weak:
        return 0.15;
      case PasswordStrength.secure:
        return 1.0;
      default:
        return 0.0;
    }
  }

  String _generateStrongPassword({int length = 14}) {
    const String lower = 'abcdefghijklmnopqrstuvwxyz';
    const String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String digits = '0123456789';
    const String special = '!@#\$%^&*(),.?":{}|<>';
    final String all = lower + upper + digits + special;
    final rand = DateTime.now().microsecondsSinceEpoch;
    final List<String> password = [];
    password.add(lower[rand % lower.length]);
    password.add(upper[(rand ~/ 2) % upper.length]);
    password.add(digits[(rand ~/ 3) % digits.length]);
    password.add(special[(rand ~/ 4) % special.length]);
    for (int i = password.length; i < length; i++) {
      password.add(all[(rand + i * 17) % all.length]);
    }
    password.shuffle();
    return password.join();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    String? hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: context.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          fillColor: context.isDarkMode
              ? context.theme.colorScheme.surface.withValues(alpha: 0.5)
              : Colors.white,
          filled: true,
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
          prefixIcon: Icon(icon, color: context.theme.colorScheme.primary),
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: context.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          fillColor: context.isDarkMode
              ? context.theme.colorScheme.surface.withValues(alpha: 0.5)
              : Colors.white,
          filled: true,
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
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: context.theme.colorScheme.primary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onPressed: onToggle,
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: AppGradients.primaryBtn,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                translate('auth.register.action_btn'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          translate('auth.register.has_account') + ' ',
          style: TextStyle(
            color: context.theme.colorScheme.onBackground.withValues(
              alpha: 0.6,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Text(
            translate('auth.register.login_link'),
            style: TextStyle(
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      User newUser = User(
        id: '',
        username: usernameController.text,
        gmail: gmailController.text,
        birthday: birthdayController.text,
        password: passwordController.text,
      );

      final result = await authController.register(newUser);
      setState(() => isLoading = false);

      if (result['success'] == true) {
        _showSuccessDialog();
      } else {
        Get.snackbar(
          translate('common.error'),
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
      }
    } else {
      Get.snackbar(
        translate('common.error'),
        translate('common.fix_errors'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
