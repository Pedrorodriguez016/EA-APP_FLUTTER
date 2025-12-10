import 'package:flutter/material.dart';
import '../Models/eventos.dart';
import '../Controllers/eventos_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../utils/logger.dart';
import '../utils/app_theme.dart';

class EventosDetailScreen extends GetView<EventoController> {
  final String eventoId;

  const EventosDetailScreen({super.key, required this.eventoId});

  String _formatSchedule(String scheduleString) {
    final String cleanScheduleString = scheduleString.trim();

    if (cleanScheduleString.isEmpty) {
      return translate('events.date_unavailable');
    }

    try {
      final DateTime? scheduleDate = DateTime.tryParse(cleanScheduleString);

      if (scheduleDate == null) {
        return translate('events.format_error');
      }

      final String formattedDate = DateFormat(
        'd \'de\' MMMM \'de\' yyyy',
        'es',
      ).format(scheduleDate);
      final String formattedTime = DateFormat(
        'HH:mm',
        'es',
      ).format(scheduleDate);

      final String relativeTime = timeago.format(
        scheduleDate,
        locale: 'es',
        allowFromNow: true,
      );

      final String fixedTime = '$formattedDate a las $formattedTime';

      return '$fixedTime ($relativeTime)';
    } catch (e) {
      logger.w('⚠️ Fallo al formatear la fecha en detalles: $e');
      return 'Error de formato';
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.selectedEvento.value?.id != eventoId) {
        controller.fetchEventoById(eventoId);
      }
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          translate('events.detail_title'),
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.theme.iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  translate('common.loading'),
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        if (controller.selectedEvento.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  size: 64,
                  color: context.theme.disabledColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  translate('events.not_found'),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.theme.hintColor,
                  ),
                ),
              ],
            ),
          );
        }
        final evento = controller.selectedEvento.value!;
        return _buildEventoDetail(context, evento);
      }),
    );
  }

  Widget _buildEventoDetail(BuildContext context, Evento evento) {
    final currentUserId = Get.find<AuthController>().currentUser.value?.id;
    final isParticipant = evento.participantes.contains(currentUserId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryBtn,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.theme.colorScheme.primary.withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.event_note_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 32),

          Center(
            child: Text(
              evento.name,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 32),

          _buildInfoCard(context, evento),

          const SizedBox(height: 32),

          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: isParticipant ? null : AppGradients.primaryBtn,
              color: isParticipant ? Colors.redAccent : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isParticipant
                      ? Colors.redAccent.withValues(alpha: 0.4)
                      : context.theme.colorScheme.primary.withValues(
                          alpha: 0.4,
                        ),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => controller.toggleParticipation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isParticipant
                    ? translate('events.leave_btn')
                    : translate('events.join_btn'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Evento evento) {
    final String formattedSchedule = _formatSchedule(evento.schedule);

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
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: context.theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                translate('events.info_card_title'),
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildDetailRow(
            context,
            Icons.calendar_today_rounded,
            translate('events.schedule'),
            formattedSchedule,
          ),

          const SizedBox(height: 20),
          _buildDetailRow(
            context,
            Icons.location_on_rounded,
            translate('events.field_address'),
            evento.address,
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            context,
            Icons.people_alt_rounded,
            translate('events.participants'),
            '${evento.participantes.length} personas',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: context.theme.colorScheme.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: context.theme.hintColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
