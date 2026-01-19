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
import '../Controllers/valoracion_controller.dart';
import '../Widgets/valoracion_list.dart';
import '../Models/evento_photo.dart';
import '../Services/eventos_services.dart';
import 'package:video_player/video_player.dart';

class EventosDetailScreen extends GetView<EventoController> {
  final String eventoId;

  const EventosDetailScreen({super.key, required this.eventoId});

  String _formatSchedule(BuildContext context, String scheduleString) {
    final String cleanScheduleString = scheduleString.trim();

    if (cleanScheduleString.isEmpty) {
      return translate('events.date_unavailable');
    }

    try {
      final DateTime? scheduleDate = DateTime.tryParse(cleanScheduleString);

      if (scheduleDate == null) {
        return translate('events.format_error');
      }

      final String currentLocale = LocalizedApp.of(
        context,
      ).delegate.currentLocale.languageCode;

      final String formattedDate = DateFormat(
        'd MMMM yyyy',
        currentLocale,
      ).format(scheduleDate);

      final String formattedTime = DateFormat(
        'HH:mm',
        currentLocale,
      ).format(scheduleDate);

      final String relativeTime = timeago.format(
        scheduleDate,
        locale: currentLocale,
        allowFromNow: true,
      );

      final String atLabel = translate('events.at_time');
      final String fixedTime = '$formattedDate $atLabel $formattedTime';

      return '$fixedTime ($relativeTime)';
    } catch (e) {
      logger.w('⚠️ Fallo al formatear la fecha en detalles: $e');
      return translate('events.format_error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final valoracionController = Get.put(ValoracionController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Siempre cargamos los datos más frescos al entrar
      controller.fetchEventoById(eventoId);
      valoracionController.loadRatings(eventoId);
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
                  size: 80,
                  color: context.theme.disabledColor,
                ),
                const SizedBox(height: 24),
                Text(
                  translate('events.not_found'),
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.theme.disabledColor,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Obx(() {
        // Usar el evento reactivo del controller
        final currentEvento = controller.selectedEvento.value ?? evento;
        final currentUserId = Get.find<AuthController>().currentUser.value?.id;

        final bool isParticipant = currentEvento.participantes.any((p) {
          if (currentUserId == null || currentUserId.isEmpty) return false;
          return p.trim() == currentUserId.trim();
        });

        final bool isInvitedButPending = currentEvento.invitacionesPendientes
            .any((p) {
              if (currentUserId == null || currentUserId.isEmpty) return false;
              return p.trim() == currentUserId.trim();
            });

        return Column(
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
                currentEvento.name,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 32),

            _buildInfoCard(context, currentEvento),

            const SizedBox(height: 32),

            // ACTIONS SECTION - Event es privado y usuario no es participante
            if (currentEvento.isPrivate && !isParticipant) ...[
              if (isInvitedButPending) ...[
                // Caso: Invitación pendiente
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              controller.respondToInvitation(null, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(translate('common.cancel')),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppGradients.primaryBtn,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton(
                            onPressed: () =>
                                controller.respondToInvitation(null, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(translate('common.accept')),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Locked - Evento privado y no invitado
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.theme.disabledColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          translate('events_extra.private_event'),
                          style: TextStyle(
                            color: context.theme.disabledColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ] else ...[
              // Public OR Participant - Botón principal de acción
              _buildActionButton(
                context,
                currentEvento,
                currentUserId,
                isParticipant,
              ),
            ],

            const SizedBox(height: 16),
            // Botón de Chat (Solo si es participante)
            if (isParticipant) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.toNamed(
                      '/event-chat',
                      arguments: {
                        'eventId': currentEvento.id,
                        'eventName': currentEvento.name,
                      },
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(
                    translate('events.chat_btn'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.theme.colorScheme.primary,
                    side: BorderSide(
                      color: context.theme.colorScheme.primary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _showPhotoGallery(context),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(
                    translate('events.album_btn'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.theme.colorScheme.secondary,
                    side: BorderSide(
                      color: context.theme.colorScheme.secondary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
            // Ratings Section
            ValoracionList(eventId: eventoId),
          ],
        );
      }),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    Evento evento,
    String? currentUserId,
    bool isParticipant,
  ) {
    // Calcular estados reactivamente
    final isOnWaitlist = evento.listaEspera.any((p) {
      if (currentUserId == null || currentUserId.isEmpty) return false;
      return p.trim() == currentUserId.trim();
    });

    final isFull =
        evento.capacidadMaxima != null &&
        evento.participantes.length >= evento.capacidadMaxima!;

    String buttonText;
    dynamic buttonStyle;

    if (isParticipant) {
      buttonText = translate('events.leave_btn');
      buttonStyle = Colors.redAccent;
    } else if (isOnWaitlist) {
      buttonText = translate('events.left_waitlist');
      buttonStyle = Colors.orange;
    } else if (isFull) {
      buttonText = translate('events_extra.waitlist_btn');
      buttonStyle = Colors.orange.shade600;
    } else {
      buttonText = translate('events.join_btn');
      buttonStyle = AppGradients.primaryBtn;
    }

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: buttonStyle is Gradient ? buttonStyle : null,
        color: buttonStyle is Color ? buttonStyle : null,
        borderRadius: BorderRadius.circular(16),
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
          buttonText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Evento evento) {
    final String formattedSchedule = _formatSchedule(context, evento.schedule);

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

          // Categoría
          _buildDetailRow(
            context,
            Icons.category_rounded,
            translate('events.field_category'),
            translate('categories.${evento.categoria}'),
          ),

          const SizedBox(height: 20),

          // Capacidad con indicador visual
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.people_rounded,
                color: context.theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translate('events.participants'),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.theme.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          evento.capacidadMaxima != null
                              ? '${evento.participantes.length}/${evento.capacidadMaxima}'
                              : '${evento.participantes.length}',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (evento.capacidadMaxima != null &&
                            evento.participantes.length >=
                                evento.capacidadMaxima!) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              translate('events_extra.full_label'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.red.shade700,
                                letterSpacing: 0.5,
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

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: context.theme.colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPhotoGallery(BuildContext context) {
    controller.fetchEventPhotos(eventoId);
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: context.theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translate('events.album_btn'),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: () => controller.uploadEventPhoto(eventoId),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.isPhotosLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.eventoPhotos.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay fotos en el álbum todavía',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.theme.hintColor,
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: controller.eventoPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = controller.eventoPhotos[index];
                    final fullUrl =
                        '${Get.find<EventosServices>().baseUrl.replaceAll('/api/event', '')}${photo.url}';

                    return GestureDetector(
                      onTap: () => _viewMedia(context, photo),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            photo.type == 'video'
                                ? Container(
                                    color: Colors.black87,
                                    child: const Icon(
                                      Icons.videocam,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  )
                                : Image.network(
                                    fullUrl,
                                    fit: BoxFit.cover,
                                    headers: {
                                      'Authorization':
                                          'Bearer ${Get.find<AuthController>().token ?? ''}',
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                  ),
                            if (photo.type == 'video')
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _viewMedia(BuildContext context, EventoPhoto media) {
    final fullUrl =
        '${Get.find<EventosServices>().baseUrl.replaceAll('/api/event', '')}${media.url}';
    final currentUserId = Get.find<AuthController>().currentUser.value?.id;
    final isOwner = media.userId == currentUserId;

    Get.to(
      Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                media.type == 'video' ? 'Video' : 'Foto',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                'Subido por ${media.username}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          actions: [
            if (isOwner)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Eliminar',
                    middleText:
                        '¿Estás seguro de que quieres eliminar este contenido?',
                    textConfirm: 'Eliminar',
                    textCancel: 'Cancelar',
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.redAccent,
                    onConfirm: () {
                      Get.back(); // Cierra el diálogo
                      Get.back(); // Cierra el visor de media
                      controller.deletePhoto(eventoId, media.id);
                    },
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => controller.downloadMedia(fullUrl),
            ),
          ],
        ),
        body: Center(
          child: media.type == 'video'
              ? _VideoPlayerWidget(url: fullUrl)
              : InteractiveViewer(
                  child: Image.network(
                    fullUrl,
                    headers: {
                      'Authorization':
                          'Bearer ${Get.find<AuthController>().token ?? ''}',
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String url;
  const _VideoPlayerWidget({required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(
            Uri.parse(widget.url),
            httpHeaders: {
              'Authorization':
                  'Bearer ${Get.find<AuthController>().token ?? ''}',
            },
          )
          ..initialize()
              .then((_) {
                setState(() {});
                _controller.play();
              })
              .catchError((e) {
                setState(() {
                  _isError = true;
                });
              });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 48),
          SizedBox(height: 16),
          Text(
            'Error al cargar el video',
            style: TextStyle(color: Colors.white),
          ),
        ],
      );
    }

    if (!_controller.value.isInitialized) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        const SizedBox(height: 20),
        IconButton(
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
        ),
      ],
    );
  }
}
