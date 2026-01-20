import 'package:password_strength_checker/password_strength_checker.dart';
import 'package:flutter_translate/flutter_translate.dart'; // Importar

// ... (El widget HomePage que tenías aquí de prueba parece no usarse, lo omito o lo dejas igual si lo usas)

class PasswordValidator {
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return translate('auth.errors.password_empty'); // 'Por favor ingresa...'
    }
    if (password.length < 6) {
      return translate(
        'auth.errors.password_short',
      ); // '...al menos 6 caracteres'
    }
    final strength = PasswordStrength.calculate(text: password);
    if (strength == PasswordStrength.weak) {
      // Puedes añadir esta clave a tu JSON: "password_weak": "La contraseña es débil..."
      return translate('auth.errors.password_weak');
    }
    return null;
  }

  static String getStrengthText(PasswordStrength? strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return translate('common.weak'); // 'Débil' (Añadir a JSON)
      case PasswordStrength.medium:
        return translate('common.medium'); // 'Media'
      case PasswordStrength.strong:
        return translate('common.strong'); // 'Fuerte'
      default:
        return translate('common.unknown'); // 'Sin evaluar'
    }
  }
}
