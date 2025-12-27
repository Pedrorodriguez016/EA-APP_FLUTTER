import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/valoracion_controller.dart';
import '../Widgets/valoracion_dialog.dart';
import '../utils/app_theme.dart';

class ValoracionList extends StatelessWidget {
  final String eventId;

  const ValoracionList({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final valoracionController = Get.find<ValoracionController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Valoraciones', // Could be translate('events.reviews_title')
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              TextButton.icon(
                onPressed: () => Get.dialog(ValoracionDialog(eventId: eventId)),
                icon: Icon(Icons.edit, size: 18, color: context.theme.colorScheme.primary),
                label: Text(
                  'Escribir reseña', // Could be translate('events.write_review')
                  style: TextStyle(
                     color: context.theme.colorScheme.primary,
                     fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (valoracionController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (valoracionController.valoraciones.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface, 
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.theme.dividerColor),
                ),
                child: Center(
                  child: Text(
                    'Sé el primero en valorar este evento',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.hintColor,
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: valoracionController.valoraciones.length,
              separatorBuilder: (_, __) => Divider(color: context.theme.dividerColor.withValues(alpha: 0.5)),
              itemBuilder: (context, index) {
                final val = valoracionController.valoraciones[index];
                final isMe =
                    val.id == valoracionController.myValoracion.value?.id;

                final avatarInitial = (val.usuarioNombre ?? 'A')[0].toUpperCase();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                         backgroundColor: context.theme.colorScheme.primary.withValues(alpha: 0.2),
                         child: Text(
                           avatarInitial,
                           style: TextStyle(
                             color: context.theme.colorScheme.primary,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Row(
                               children: [
                                 Expanded(
                                  child: Text(
                                      val.usuarioNombre ?? 'Anonimo',
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  ),
                                 ),
                                 if (isMe) ...[
                                   const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                                      ),
                                      child: const Text(
                                        'Tú',
                                        style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                 ]
                               ],
                             ),
                             const SizedBox(height: 4),
                             Row(
                               children: [
                                  _buildStarDisplay(val.puntuacion.toDouble(), context),
                                  const Spacer(),
                                  if (isMe)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                        color: Colors.redAccent,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () =>
                                          valoracionController.deleteRating(eventId),
                                    ),
                               ],
                             ),
                             if (val.comentario.isNotEmpty) ...[
                               const SizedBox(height: 6),
                               Text(
                                 val.comentario,
                                 style: context.textTheme.bodyMedium,
                               ),
                             ],
                             const SizedBox(height: 4),
                             Text(
                               DateFormat('dd MMM yyyy').format(val.createdAt),
                               style: context.textTheme.bodySmall?.copyWith(
                                 fontSize: 12,
                               ),
                             ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStarDisplay(double rating, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }
}
