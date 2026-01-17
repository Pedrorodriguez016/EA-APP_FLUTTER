import 'package:flutter/material.dart';
import '../Models/eventos.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import '../utils/logger.dart';
import '../utils/app_theme.dart';
import '../Controllers/auth_controller.dart';

class EventosCard extends StatelessWidget {
  final Evento evento;
  final bool showParticipationStatus;

  const EventosCard({
    super.key,
    required this.evento,
    this.showParticipationStatus = false,
  });

  String _formatSchedule(BuildContext context, String scheduleString) {
    if (scheduleString.isEmpty) {
      return translate('events.date_unavailable');
    }
    try {
      final DateTime scheduleDate = DateTime.parse(scheduleString);
      final String currentLocale = LocalizedApp.of(
        context,
      ).delegate.currentLocale.languageCode;

      final String fixedTime = DateFormat(
        'd MMM yyyy HH:mm',
        currentLocale,
      ).format(scheduleDate);

      final String relativeTime = timeago.format(
        scheduleDate,
        locale: currentLocale,
        allowFromNow: true,
      );

      return '$fixedTime ($relativeTime)';
    } catch (e) {
      logger.w('⚠️ Fallo al parsear la fecha: $scheduleString, Error: $e');
      return translate('events.format_error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayTime = _formatSchedule(context, evento.schedule);
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id;

    // Comparación robusta
    final bool isParticipant = evento.participantes.any((p) {
      if (currentUserId == null || currentUserId.isEmpty) return false;
      return p.trim() == currentUserId.trim();
    });

    final bool effectiveIsParticipant =
        showParticipationStatus && isParticipant;

    // Check waitlist status
    final bool isInWaitlist = evento.listaEspera.any((p) {
      if (currentUserId == null || currentUserId.isEmpty) return false;
      return p.trim() == currentUserId.trim();
    });

    // Check if event is full
    final bool isFull =
        evento.capacidadMaxima != null &&
        evento.participantes.length >= evento.capacidadMaxima!;

    // Colores inspirados en la web
    final Color greenBase = const Color(0xFF10B981);
    final Color blueBase = const Color(0xFF3B82F6);
    final Color statusColor = effectiveIsParticipant ? greenBase : blueBase;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: showParticipationStatus
            ? Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.5)
            : Border.all(color: Colors.transparent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (showParticipationStatus ? statusColor : Colors.black)
                .withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: showParticipationStatus
              ? statusColor.withValues(alpha: 0.05)
              : null,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.toNamed('/evento/${evento.id}'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: showParticipationStatus
                                ? LinearGradient(
                                    colors: effectiveIsParticipant
                                        ? [
                                            const Color(0xFF10B981),
                                            const Color(0xFF059669),
                                          ]
                                        : [
                                            const Color(0xFF3B82F6),
                                            const Color(0xFF2563EB),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : AppGradients.primaryBtn,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (showParticipationStatus
                                            ? statusColor
                                            : context.theme.colorScheme.primary)
                                        .withValues(alpha: 0.2),
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
                        if (effectiveIsParticipant)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: context.theme.cardColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: greenBase, width: 1),
                              ),
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: greenBase,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  evento.name,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: showParticipationStatus
                                            ? (effectiveIsParticipant
                                                  ? const Color(0xFF065F46)
                                                  : const Color(0xFF1E40AF))
                                            : null,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (evento.isPrivate)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Icon(
                                    Icons.lock_outline,
                                    size: 16,
                                    color: context.theme.hintColor,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Badges Row
                          if (isInWaitlist || isFull)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Wrap(
                                spacing: 6,
                                children: [
                                  if (isFull && !isInWaitlist)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.orange.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.lock_clock,
                                            size: 10,
                                            color: Colors.orange,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Lleno',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (isInWaitlist)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.purple.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.hourglass_empty_rounded,
                                            size: 10,
                                            color: Colors.purple,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Lista espera',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
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
                        color:
                            (showParticipationStatus
                                    ? statusColor
                                    : context.theme.colorScheme.primary)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_rounded,
                            size: 14,
                            color: showParticipationStatus
                                ? statusColor
                                : context.theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${evento.participantes.length}',
                            style: TextStyle(
                              color: showParticipationStatus
                                  ? statusColor
                                  : context.theme.colorScheme.primary,
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
        ),
      ),
    );
  }
}
