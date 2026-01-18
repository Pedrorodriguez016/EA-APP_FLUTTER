import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/user_controller.dart';

/// Widget reutilizable para mostrar el avatar de un usuario
/// Muestra la foto de perfil si existe, o las iniciales del nombre si no
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String username;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBorder;
  final Color? borderColor;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.username,
    this.radius = 24,
    this.backgroundColor,
    this.textColor,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    // Intentar obtener el UserController para procesar la URL
    String? fullPhotoUrl;
    try {
      final userController = Get.find<UserController>();
      fullPhotoUrl = userController.getFullPhotoUrl(photoUrl);
    } catch (e) {
      // Si no hay UserController, usar la URL directamente
      fullPhotoUrl = photoUrl;
    }

    final defaultBgColor = backgroundColor ?? context.theme.colorScheme.primary;
    final defaultTextColor = textColor ?? Colors.white;

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: defaultBgColor,
      backgroundImage: fullPhotoUrl != null ? NetworkImage(fullPhotoUrl) : null,
      child: fullPhotoUrl == null
          ? Text(
              _getInitials(username),
              style: TextStyle(
                color: defaultTextColor,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.6,
              ),
            )
          : null,
    );

    if (showBorder) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? context.theme.colorScheme.primary,
            width: 2,
          ),
        ),
        child: avatar,
      );
    }

    return avatar;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final words = name.trim().split(' ');
    if (words.length >= 2) {
      // Si tiene nombre y apellido, tomar primera letra de cada uno
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      // Si solo tiene un nombre, tomar las primeras 2 letras
      return name.length >= 2
          ? name.substring(0, 2).toUpperCase()
          : name[0].toUpperCase();
    }
  }
}
