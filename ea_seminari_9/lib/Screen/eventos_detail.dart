import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

// Asegúrate de que estas rutas sean correctas en tu proyecto
import '../Models/eventos.dart';
import '../Controllers/eventos_controller.dart';
import '../Controllers/auth_controller.dart';

class EventosDetailScreen extends GetView<EventoController> {
  final String eventoId;

  const EventosDetailScreen({super.key, required this.eventoId});

  // --- 1. Formateo de Fecha ---
  String _formatSchedule(String scheduleString) {
    final String cleanScheduleString = scheduleString.trim();
    if (cleanScheduleString.isEmpty) return 'Fecha no disponible';
    try {
      final DateTime? scheduleDate = DateTime.tryParse(cleanScheduleString);
      if (scheduleDate == null) return 'Fecha inválida';
      
      // Requiere inicializar locale 'es' en main.dart
      final String formattedDate = DateFormat('d \'de\' MMMM \'de\' yyyy', 'es').format(scheduleDate);
      final String formattedTime = DateFormat('HH:mm', 'es').format(scheduleDate);
      final String relativeTime = timeago.format(scheduleDate, locale: 'es', allowFromNow: true);
      
      return '$formattedDate a las $formattedTime ($relativeTime)';
    } catch (e) {
      return 'Error de formato';
    }
  }

  // --- 2. Método Build Principal ---
  @override
  Widget build(BuildContext context) {
    // Carga de datos segura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.selectedEvento.value?.id != eventoId) {
        controller.fetchEventoById(eventoId);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalles del Evento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF667EEA)));
        }

        if (controller.selectedEvento.value == null) {
          return const Center(child: Text('Evento no encontrado'));
        }

        final evento = controller.selectedEvento.value!;
        return _buildEventoDetail(context, evento);
      }),
    );
  }

  // --- 3. Construcción del Cuerpo del Detalle ---
  Widget _buildEventoDetail(BuildContext context, Evento evento) {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id;
    final isParticipant = evento.participantes.contains(currentUserId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono Header
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 24),

          // Título
          Text(
            evento.name,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Tarjeta de Info
          _buildInfoCard(evento),
          const SizedBox(height: 32),

          // ÁLBUM DE FOTOS CON BOTÓN
          _buildPhotoAlbum(context, evento), 
          
          const SizedBox(height: 32),

          // Botón de Acción (Unirse/Salir)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => controller.toggleParticipation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isParticipant ? Colors.red.shade400 : const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                isParticipant ? "Salir del evento" : "Unirme al evento",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- 4. Widget del Álbum de Fotos (ACTUALIZADO CON BOTÓN) ---
  Widget _buildPhotoAlbum(BuildContext context, Evento evento) {
    
    // Obtenemos las fotos reales del evento
    List<String> displayfotos = List.from(evento.fotos);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CABECERA: TÍTULO Y BOTÓN DE SUBIDA
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Galería',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            
            // BOTÓN SUBIR FOTO
            TextButton.icon(
              // Asegúrate de haber agregado el método uploadPhoto en tu Controller
              onPressed: () => controller.uploadPhoto(), 
              icon: const Icon(Icons.add_a_photo, size: 18, color: Color(0xFF667EEA)),
              label: const Text(
                "Subir foto", 
                style: TextStyle(color: Color(0xFF667EEA), fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // ESTADO 1: LISTA VACÍA
        if (displayfotos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.photo_library_outlined, size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                Text(
                  "Aún no hay fotos",
                  style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                ),
                Text(
                  "¡Sube la primera!",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),

        // ESTADO 2: GRID DE FOTOS
        if (displayfotos.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayfotos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final photoUrl = displayfotos[index];
              return GestureDetector(
                onTap: () => _openFullScreenImage(context, photoUrl),
                child: Hero(
                  tag: photoUrl,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(photoUrl),
                        fit: BoxFit.cover,
                        onError: (e, s) {
                          // Manejo de error si la URL falla
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // --- 5. Lógica para abrir imagen Full Screen ---
  void _openFullScreenImage(BuildContext context, String imageUrl) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Center(
          child: Hero(
            tag: imageUrl,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      transition: Transition.fadeIn,
    );
  }

  // --- 6. Widgets Auxiliares ---
  Widget _buildInfoCard(Evento evento) {
    final String formattedSchedule = _formatSchedule(evento.schedule);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF667EEA)),
          ),
          const Divider(height: 30),
          _buildDetailRow(Icons.access_time_filled_rounded, 'Horario', formattedSchedule),
          const SizedBox(height: 20),
          _buildDetailRow(Icons.location_on_rounded, 'Ubicación', evento.address),
          const SizedBox(height: 20),
          _buildDetailRow(Icons.groups_rounded, 'Participantes', '${evento.participantes.length} personas'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.grey.shade700, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}