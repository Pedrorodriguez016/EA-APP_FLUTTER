import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/valoracion_controller.dart';

class ValoracionDialog extends StatelessWidget {
  final String eventId;

  const ValoracionDialog({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final valoracionController = Get.find<ValoracionController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tu Opinión',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < valoracionController.ratingScore.value
                          ? Icons.star
                          : Icons.star_border,
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
              decoration: InputDecoration(
                hintText: 'Escribe un comentario...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: valoracionController.isSubmitting.value
                      ? null
                      : () => valoracionController.submitRating(eventId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                      : const Text('Enviar Valoración'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
