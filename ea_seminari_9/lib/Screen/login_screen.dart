import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';

// AHORA SÍ: GetView<AuthController>
class LoginScreen extends GetView<AuthController> {
  const LoginScreen({Key? key}) : super(key: key);

  // Validaciones (pueden ser estáticas o estar en el controller, aquí están bien como helper)
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
    // Redirección de seguridad (usando Obx para reaccionar al cambio)
    return Obx(() {
      if (controller.isLoggedIn.value) {
        // Si ya estamos logueados, nos vamos (útil para el auto-login rápido)
        Future.microtask(() => Get.offAllNamed('/home'));
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                _buildWelcomeHeader(),
                const SizedBox(height: 48),
                _buildLoginForm(),
                const SizedBox(height: 32),
                _buildFooter(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWelcomeHeader() {
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
          child: const Icon(Icons.event, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 24),
        Text(
          translate('auth.login.title'),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          translate('auth.login.subtitle'),
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: controller.loginFormKey, // Usamos la key del controller
      child: Column(
        children: [
          // CAMPO USUARIO
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextFormField(
              controller: controller.loginUserCtrl, // Usamos controller
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: translate('auth.fields.username'),
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Colors.grey,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: _validateUsername,
            ),
          ),
          const SizedBox(height: 16),

          // CAMPO CONTRASEÑA (REACTIVO CON OBX)
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextFormField(
                controller: controller.loginPassCtrl, // Usamos controller
                obscureText:
                    controller.isObscurePassword.value, // Leemos valor reactivo
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: translate('auth.fields.password'),
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.grey,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isObscurePassword.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: controller
                        .togglePasswordVisibility, // Llamamos método del controller
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: _validatePassword,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // BOTÓN LOGIN (REACTIVO CON OBX)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoginLoading.value
                    ? null
                    : controller.submitLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoginLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        translate('auth.login.action_btn'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // DIVIDER
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  translate('auth.login.or_continue_with'),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 24),

          // BOTÓN GOOGLE
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: controller.isLoginLoading.value
                  ? null
                  : controller.signInWithGoogle,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                    height: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          translate('auth.login.no_account') + ' ',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () => Get.toNamed('/register'),
          child: Text(
            translate('auth.login.register_link'),
            style: const TextStyle(
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
