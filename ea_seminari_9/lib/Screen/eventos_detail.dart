import 'package:flutter/material.dart';
import '../Models/eventos.dart';
import '../Controllers/eventos_controller.dart';
import '../Controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Añadido para el formato fijo
import 'package:timeago/timeago.dart'
    as timeago; // Añadido para el tiempo relativo
import '../Controllers/valoracion_controller.dart';
import '../Widgets/valoracion_list.dart';

class EventosDetailScreen extends GetView<EventoController> {
  final String eventoId;

  const EventosDetailScreen({super.key, required this.eventoId});

  String _formatSchedule(String scheduleString) {
    final String cleanScheduleString = scheduleString.trim();

    if (cleanScheduleString.isEmpty) {
      return 'Fecha no disponible';
    }

    try {
      final DateTime? scheduleDate = DateTime.tryParse(cleanScheduleString);

      if (scheduleDate == null) {
        return 'Error de formato';
      }

      // 1. Formato de Fecha: Ejemplo "13 de noviembre de 2025"
      // Usamos las comillas simples ('de') para proteger el texto literal.
      final String formattedDate = DateFormat(
        'd \'de\' MMMM \'de\' yyyy',
        'es',
      ).format(scheduleDate);

      // 2. Formato de Hora: Ejemplo "23:48" (Formato 24h)
      final String formattedTime = DateFormat(
        'HH:mm',
        'es',
      ).format(scheduleDate);

      // 3. Tiempo Relativo: Ejemplo "(hace 17 días)"
      final String relativeTime = timeago.format(
        scheduleDate,
        locale: 'es',
        allowFromNow: true,
      );

      // 4. Combinamos todo: "13 de noviembre de 2025 a las 23:48 (hace 17 días)"
      final String fixedTime = '$formattedDate a las $formattedTime';

      return '$fixedTime ($relativeTime)';
    } catch (e) {
      print('Fallo al formatear la fecha en detalles: $e');
      return 'Error de formato';
    }
  }

  @override
  Widget build(BuildContext context) {
    final valoracionController = Get.put(ValoracionController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.selectedEvento.value?.id != eventoId) {
        controller.fetchEventoById(eventoId);
      }
      valoracionController.loadRatings(eventoId);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalles del Evento'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando evento...'),
              ],
            ),
          );
        }

        if (controller.selectedEvento.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Evento no encontrado',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        // Usar el evento reactivo del controller
        final currentEvento = controller.selectedEvento.value ?? evento;
        final isParticipant = currentEvento.participantes.contains(
          currentUserId,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icono
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event, color: Colors.white, size: 48),
              ),
            ),
            const SizedBox(height: 32),

            // Nombre del evento
            Text(
              currentEvento.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Información del evento
            _buildInfoCard(currentEvento),
            const SizedBox(height: 20),
            // Botones de acción
            if (currentEvento.isPrivate && !isParticipant) ...[
              if (currentEvento.invitacionesPendientes.contains(
                currentUserId,
              )) ...[
                // Caso: Invitación pendiente
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              controller.respondToInvitation(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Rechazar"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              controller.respondToInvitation(true), // Aceptar
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Aceptar Invitación"),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Caso: Privado y NO invitado
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: null, // Deshabilitado
                    icon: const Icon(Icons.lock),
                    label: const Text("Evento Privado"),
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ] else ...[
              // Caso: Público o ya participante/en lista de espera
              _buildActionButton(currentEvento, currentUserId),
            ],
            const SizedBox(height: 20),
            ValoracionList(eventId: eventoId),
          ],
        );
      }),
    );
  }

  Widget _buildActionButton(Evento evento, String? currentUserId) {
    // Calcular estados reactivamente dentro del método
    final isParticipant = evento.participantes.contains(currentUserId);
    final isOnWaitlist = evento.listaEspera.contains(currentUserId);
    final isFull =
        evento.capacidadMaxima != null &&
        evento.participantes.length >= evento.capacidadMaxima!;

    String buttonText;
    Color buttonColor;

    if (isParticipant) {
      buttonText = "Salir del evento";
      buttonColor = Colors.redAccent;
    } else if (isOnWaitlist) {
      buttonText = "Salir de la lista de espera";
      buttonColor = Colors.orange;
    } else if (isFull) {
      buttonText = "Entrar en lista de espera";
      buttonColor = Colors.orange.shade600;
    } else {
      buttonText = "Unirme al evento";
      buttonColor = const Color(0xFF667EEA);
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => controller.toggleParticipation(),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Evento evento) {
    final String formattedSchedule = _formatSchedule(evento.schedule);
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
          const Text(
            'Información del Evento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.schedule, 'Horario:', formattedSchedule),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.location_on, 'Dirección:', evento.address),
          const SizedBox(height: 12),
          // Capacidad con indicador visual
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.people, color: Color(0xFF667EEA), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participantes:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          evento.capacidadMaxima != null
                              ? '${evento.participantes.length}/${evento.capacidadMaxima}'
                              : '${evento.participantes.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (evento.capacidadMaxima != null &&
                            evento.participantes.length >=
                                evento.capacidadMaxima!) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'LLENO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF667EEA), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
