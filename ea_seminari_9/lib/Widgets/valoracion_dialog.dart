import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/valoracion_controller.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../utils/app_theme.dart';

class ValoracionDialog extends StatelessWidget {
  final String eventId;

  const ValoracionDialog({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final valoracionController = Get.find<ValoracionController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: context.theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translate('events.review_dialog_title'),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),

            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < valoracionController.ratingScore.value
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      valoracionController.ratingScore.value = index + 1.0;
                    },
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: valoracionController.commentController,
              maxLines: 3,
              style: context.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: translate('events.review_comment_hint'),
                hintStyle: context.theme.inputDecorationTheme.hintStyle,
                border: context.theme.inputDecorationTheme.border,
                enabledBorder: context.theme.inputDecorationTheme.enabledBorder,
                focusedBorder: context.theme.inputDecorationTheme.focusedBorder,
                filled: true,
                fillColor: context.theme.inputDecorationTheme.fillColor,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryBtn,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.colorScheme.primary.withValues(
                          alpha: 0.4,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: valoracionController.isSubmitting.value
                        ? null
                        : () => valoracionController.submitRating(eventId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: valoracionController.isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            translate('events.review_send_btn'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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
