import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/auth_controller.dart';
import 'package:flutter_translate/flutter_translate.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      tooltip: translate('dialogs.logout.title'),
      onPressed: () {
        Get.generalDialog(
          barrierDismissible: true,
          barrierLabel: '',
          barrierColor: Colors.black.withValues(alpha: 0.5),
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (ctx, anim1, anim2) => Container(),
          transitionBuilder: (ctx, anim1, anim2, child) {
            return ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
              child: AlertDialog(
                backgroundColor: ctx.theme.cardTheme.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: ctx.theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                title: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ctx.theme.colorScheme.error.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: ctx.theme.colorScheme.error,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      translate('dialogs.logout.title'),
                      style: ctx.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                content: Text(
                  translate('dialogs.logout.content'),
                  textAlign: TextAlign.center,
                  style: ctx.textTheme.bodyMedium?.copyWith(
                    color: ctx.theme.hintColor,
                  ),
                ),
                actionsPadding: const EdgeInsets.all(24),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      translate('common.cancel'),
                      style: TextStyle(
                        color: ctx.theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      authController.logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ctx.theme.colorScheme.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(translate('dialogs.logout.confirm')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
