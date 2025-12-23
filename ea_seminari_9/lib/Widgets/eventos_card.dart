import 'package:flutter/material.dart';
import '../Models/eventos.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import '../utils/logger.dart';
import '../utils/app_theme.dart';

class EventosCard extends StatelessWidget {
  final Evento evento;
  const EventosCard({super.key, required this.evento});

  // Función de formateo centralizada
  String _formatSchedule(String scheduleString) {
    if (scheduleString.isEmpty) {
      return 'Fecha no disponible';
    }
    try {
      final DateTime scheduleDate = DateTime.parse(scheduleString);

      final String fixedTime = DateFormat(
        'd MMM. yyyy HH:mm',
        'es',
      ).format(scheduleDate);

      final String relativeTime = timeago.format(
        scheduleDate,
        locale: 'es',
        allowFromNow: true,
      );

      return '$fixedTime ($relativeTime)';
    } catch (e) {
      logger.w('⚠️ Fallo al parsear la fecha: $scheduleString, Error: $e');
      return 'Error de formato';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayTime = _formatSchedule(evento.schedule);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Get.toNamed('/evento/${evento.id}'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryBtn,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento.name,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        displayTime,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: context.theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              evento.address,
                              style: context.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: context.theme.hintColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_rounded,
                        size: 14,
                        color: context.theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${evento.participantes.length}',
                        style: TextStyle(
                          color: context.theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
