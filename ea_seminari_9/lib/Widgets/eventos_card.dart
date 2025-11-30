// Archivo: lib/Widgets/eventos_card.dart (CORREGIDO)
import 'package:flutter/material.dart';
import '../Models/eventos.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart'; 

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
      
      // Formato Fijo (ej: "23 Nov. 2025 a las 23:48")
      final String fixedTime = DateFormat('d MMM. yyyy HH:mm', 'es').format(scheduleDate);
      
      // Formato Relativo (ej: "en 2 días")
      final String relativeTime = timeago.format(
        scheduleDate, 
        locale: 'es', 
        allowFromNow: true, 
      );
      
      // Combinamos ambos formatos
      return '$fixedTime ($relativeTime)';
    } catch (e) {
      // Este catch debería ser rarísimo ahora que usamos la clave correcta
      print('Fallo al parsear la fecha: $scheduleString, Error: $e');
      return 'Error de formato'; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayTime = _formatSchedule(evento.schedule);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          onTap: () => Get.toNamed('/evento/${evento.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        displayTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),  

                      const SizedBox(height: 4),
                      Text(
                        evento.address,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${evento.participantes.length}',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
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