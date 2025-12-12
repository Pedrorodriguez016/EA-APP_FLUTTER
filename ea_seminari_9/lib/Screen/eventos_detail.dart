import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Necesario para DateFormat
import 'package:timeago/timeago.dart' as timeago; // Necesario para timeago

// Tus importaciones
import '../Models/eventos.dart';
import '../Controllers/eventos_controller.dart';
import '../Controllers/auth_controller.dart';

class EventosDetailScreen extends GetView<EventoController> {
  final String eventoId;

  const EventosDetailScreen({super.key, required this.eventoId});

  // --- 1. FUNCIÓN QUE FALTABA (_formatSchedule) ---
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

  // --- 2. Método Build ---
  @override
  Widget build(BuildContext context) {
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

  // --- 3. Cuerpo del Detalle ---
  Widget _buildEventoDetail(BuildContext context, Evento evento) {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id;
    final isParticipant = evento.participantes.contains(currentUserId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
          Center(
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 24),
          
          // Título
          Text(evento.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87), textAlign: TextAlign.center),
          const SizedBox(height: 32),

          // Info Card (Aquí se usa _formatSchedule)
          _buildInfoCard(evento),
          const SizedBox(height: 32),

          // Álbum
          _buildPhotoAlbum(context, evento),
          const SizedBox(height: 32),

          // Botón
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              onPressed: () => controller.toggleParticipation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isParticipant ? Colors.red.shade400 : const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(isParticipant ? "Salir del evento" : "Unirme al evento", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- 4. Info Card ---
  Widget _buildInfoCard(Evento evento) {
    // AQUÍ SE LLAMA A LA FUNCIÓN QUE DABA ERROR
    final String formattedSchedule = _formatSchedule(evento.schedule);
    
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF667EEA))),
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

  // --- 5. Álbum de Fotos ---
  Widget _buildPhotoAlbum(BuildContext context, Evento evento) {
    List<String> displayfotos = List.from(evento.fotos);
    
    // FOTOS DE PRUEBA (Borrar cuando tengas fotos reales)
    if (displayfotos.isEmpty) {
      displayfotos = [
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=500&q=60',
        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=500&q=60',
        'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?auto=format&fit=crop&w=500&q=60',
      ];
    }
    
    if (displayfotos.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const Row(children: [Text('Galería', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: displayfotos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemBuilder: (context, index) {
            final url = displayfotos[index];
            return GestureDetector(
              onTap: () => _openFullScreenImage(context, url),
              child: Hero(tag: url, child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                ),
              )),
            );
          },
        ),
      ],
    );
  }

  // --- 6. Helpers ---
  void _openFullScreenImage(BuildContext context, String imageUrl) {
    Get.to(() => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(child: Hero(tag: imageUrl, child: Image.network(imageUrl, fit: BoxFit.contain))),
    ));
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: Colors.grey.shade700, size: 22),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ])),
    ]);
  }
}