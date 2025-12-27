import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../Controllers/valoracion_controller.dart';
import '../Widgets/valoracion_dialog.dart';

class ValoracionList extends StatelessWidget {
  final String eventId;

  const ValoracionList({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final valoracionController = Get.find<ValoracionController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Valoraciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () => Get.dialog(ValoracionDialog(eventId: eventId)),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Escribir reseña'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF667EEA),
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
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Sé el primero en valorar este evento',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: valoracionController.valoraciones.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final val = valoracionController.valoraciones[index];
                final isMe =
                    val.id == valoracionController.myValoracion.value?.id;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      (val.usuarioNombre ?? 'A')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.indigo),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          val.usuarioNombre ?? 'Anonimo',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isMe)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Tú',
                            style: TextStyle(fontSize: 10, color: Colors.green),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildStarDisplay(val.puntuacion.toDouble()),
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
                      const SizedBox(height: 4),
                      Text(val.comentario),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(val.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
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

  Widget _buildStarDisplay(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }
}
