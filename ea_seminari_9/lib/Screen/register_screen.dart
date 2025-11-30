import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart'; // Importar
import '../Controllers/auth_controller.dart';
import '../Models/user.dart';
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
        return Colors.grey.shade200;
    }
  }
  final ValueNotifier<PasswordStrength?> passwordStrengthNotifier = ValueNotifier<PasswordStrength?>(null);
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController gmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _formKey = GlobalKey<FormState>();

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 30),
            const SizedBox(width: 10),
            Text(translate('auth.register.success_title')), // '¡Registro Exitoso!'
          ],
        ),
        content: Text(
          translate('auth.register.success_msg'), // 'Tu cuenta ha sido creada...'
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text(
              translate('auth.register.continue'), // 'Continuar'
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
    // Si quieres traducir estos textos, deberías añadir claves al JSON.
    // Por ahora lo dejaré con textos que se entienden universalmente o podrías usar claves.
    final requirements = [
      {
        'label': 'Min 12 chars', // Puedes usar translate('auth.requirements.chars')
        'valid': password.length >= 12,
      },
      {
        'label': 'a-z',
        'valid': RegExp(r'[a-z]').hasMatch(password),
      },
      {
        'label': 'A-Z',
        'valid': RegExp(r'[A-Z]').hasMatch(password),
      },
      {
        'label': '0-9',
        'valid': RegExp(r'[0-9]').hasMatch(password),
      },
      {
        'label': '!@#\$',
        'valid': RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password),
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: requirements.map((req) {
        Color color;
        if (req['valid'] as bool) {
          color = Colors.green;
        } else if (password.isEmpty) {
          color = Colors.grey;
        } else {
          color = Colors.red;
        }
        return Row(
          children: [
            Icon(
              req['valid'] as bool ? Icons.check_circle : Icons.cancel,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              req['label'] as String,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ],
        );
      }).toList(),
    );
  }

  String? _validateGmail(String? value) {
    if (value == null || value.isEmpty) {
      return translate('auth.errors.email_empty');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return translate('auth.errors.email_invalid');
    }
    return null;
  }


  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return translate('auth.errors.password_empty'); // O crear una clave específica 'confirm_empty'
    }
    if (value != passwordController.text) {
      return translate('auth.errors.password_mismatch');
    }
    return null;
  }

  String? _validateBirthday(String? value) {
    if (value == null || value.isEmpty) {
      return translate('auth.errors.birthday_empty');
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return translate('auth.errors.birthday_invalid');
    }
    try {
      final parts = value.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final birthday = DateTime(year, month, day);
      final now = DateTime.now();
      final age = now.year - birthday.year;

      if (birthday.isAfter(now)) {
        return translate('auth.errors.birthday_invalid');
      }

      if (age < 13) {
        return 'Min 13 years'; // Puedes traducir esto también
      }

      if (age > 120) {
        return translate('auth.errors.birthday_invalid');
      }
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(translate('auth.register.title')), // 'Registro'
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildRegisterForm(),
              const SizedBox(height: 24),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.person_add, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 24),
        Text(
          translate('auth.register.title'), // 'Crear Cuenta'
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          translate('auth.register.subtitle'), // 'Completa tus datos...'
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
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
            icon: Icons.person_outline,
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
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildPasswordRequirements(passwordController.text),
          ),
          TextFormField(
            controller: passwordController,
            obscureText: _obscurePassword,
            onChanged: (value) {
              passwordStrengthNotifier.value = _customPasswordStrength(value);
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: translate('auth.fields.password'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _getPasswordBorderColor(passwordStrengthNotifier.value),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _getPasswordBorderColor(passwordStrengthNotifier.value),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _getPasswordBorderColor(passwordStrengthNotifier.value),
                  width: 2,
                ),
              ),
              fillColor: Colors.grey.shade50,
              filled: true,
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<PasswordStrength?>(
            valueListenable: passwordStrengthNotifier,
            builder: (context, strength, _) {
              String label = '';
              Color color = _getPasswordBorderColor(strength);
              if (strength == PasswordStrength.secure) {
                color = const Color(0xFF0B6C0E);
              }
              // Traducir niveles de seguridad
              switch (strength) {
                case PasswordStrength.weak:
                  label = translate('common.error'); // O 'Débil' si añades la clave
                  break;
                case PasswordStrength.medium:
                  label = 'Medium';
                  break;
                case PasswordStrength.strong:
                  label = 'Strong';
                  break;
                case PasswordStrength.secure:
                  label = 'Secure';
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
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade300,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _getStrengthWidth(strength),
                        child: Container(
                          height: 8,
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
            onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: birthdayController,
            label: translate('auth.fields.birthday'),
            icon: Icons.cake_outlined,
            hintText: translate('auth.fields.birthday_hint'),
            validator: _validateBirthday,
          ),
          const SizedBox(height: 32),
          // Botón de generar contraseña eliminado para simplificar, o puedes traducirlo
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final generated = _generateStrongPassword();
                passwordController.text = generated;
                passwordStrengthNotifier.value = PasswordStrength.calculate(text: generated);
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Generar contraseña'), // Traducir si es necesario
            ),
          ),
          const SizedBox(height: 32),
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: onToggle,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667EEA),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                translate('auth.register.action_btn'), // 'Crear Cuenta'
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
          translate('auth.register.has_account') + ' ', // '¿Ya tienes cuenta?'
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Text(
            translate('auth.register.login_link'), // 'Inicia Sesión'
            style: const TextStyle(
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w600,
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
        translate('common.error'), // Error genérico
        'Por favor corrige los errores', // Texto estático o añadir clave
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}