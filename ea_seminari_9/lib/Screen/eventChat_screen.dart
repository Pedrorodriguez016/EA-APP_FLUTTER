import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/event_chat_controller.dart';
import '../Models/event_chat.dart';
import '../Models/evento_photo.dart';
import '../Services/eventos_services.dart';
import '../Controllers/auth_controller.dart';
import '../Widgets/user_card.dart';
import 'package:video_player/video_player.dart';

class EventChatScreen extends GetView<EventChatController> {
  const EventChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 1,
        shadowColor: context.theme.shadowColor.withValues(alpha: 0.2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.eventName,
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              translate('events.chat_subtitle'),
              style: TextStyle(color: context.theme.hintColor, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () => _showParticipants(context),
          ),
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: () => _showPhotoGallery(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                itemCount: controller.messages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _EventChatBubble(message: controller.messages[index]);
                },
              );
            }),
          ),
          Divider(height: 1, color: context.theme.dividerColor),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      color: context.theme.cardColor,
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: context.theme.colorScheme.primary,
              ),
              onPressed: () => _showMediaUploadOptions(context),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.textController,
                  focusNode: controller.focusNode,
                  style: context.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: translate('events.chat_hint'),
                    hintStyle: TextStyle(color: context.theme.hintColor),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) {
                    controller.sendMessage();
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: context.theme.colorScheme.primary,
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: context.theme.colorScheme.onPrimary,
                  size: 20,
                ),
                onPressed: () {
                  controller.sendMessage();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showParticipants(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.theme.dividerColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    translate('events.chat_participants'),
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                // Filtramos para no mostrarnos a nosotros mismos en la lista
                final participants = controller.event.value?.participantesFull
                    ?.where((u) => u.id != controller.myUserId)
                    .toList();

                if (participants == null || participants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: context.theme.hintColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          translate('home.friends_section.empty_msg'),
                          style: TextStyle(color: context.theme.hintColor),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final user = participants[index];
                    return UserCard(user: user);
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

  void _showPhotoGallery(BuildContext context) {
    controller.fetchPhotos();
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fotos del Evento',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _showMediaUploadOptions(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                if (controller.isPhotosLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.photos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: context.theme.hintColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay fotos compartidas aún',
                          style: TextStyle(color: context.theme.hintColor),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: controller.photos.length,
                  itemBuilder: (context, index) {
                    final photo = controller.photos[index];
                    return InkWell(
                      onTap: () => _viewMedia(context, photo),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              '${Get.find<EventosServices>().baseUrl.replaceAll('/api/event', '')}${photo.url}',
                              headers: {
                                'Authorization':
                                    'Bearer ${Get.find<AuthController>().token ?? ''}',
                              },
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.broken_image),
                                  ),
                            ),
                            if (photo.type == 'video')
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 20,
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

  void _showMediaUploadOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Compartir Multimedia',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Abrir Galería'),
              subtitle: const Text('Fotos y vídeos'),
              onTap: () {
                Get.back();
                controller.uploadMedia(isGeneralGallery: true);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Abrir Cámara'),
              subtitle: const Text('Capturar foto o vídeo ahora'),
              onTap: () {
                Get.back();
                Get.bottomSheet(
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Cámara',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Tomar Foto'),
                          onTap: () {
                            Get.back();
                            controller.uploadMedia(
                              isVideo: false,
                              fromCamera: true,
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.videocam),
                          title: const Text('Grabar Vídeo'),
                          onTap: () {
                            Get.back();
                            controller.uploadMedia(
                              isVideo: true,
                              fromCamera: true,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _viewMedia(BuildContext context, EventoPhoto media) {
    final fullUrl =
        '${Get.find<EventosServices>().baseUrl.replaceAll('/api/event', '')}${media.url}';
    Get.to(
      Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            media.type == 'video' ? 'Video' : 'Foto',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => controller.downloadMedia(media.url, media.type),
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
        mainAxisAlignment: MainAxisAlignment.center,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Text(
              '${_controller.value.position.inMinutes}:${(_controller.value.position.inSeconds % 60).toString().padLeft(2, '0')} / '
              '${_controller.value.duration.inMinutes}:${(_controller.value.duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}

class _EventChatBubble extends StatelessWidget {
  final EventChatMessage message;
  const _EventChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final time =
        "${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}";

    const myBubbleColor = Color(0xFF7C3AED);
    final otherBubbleColor = context.isDarkMode
        ? const Color(0xFF424242)
        : const Color(0xFFEEEEEE);

    const myTextColor = Colors.white;
    final otherTextColor = context.isDarkMode ? Colors.white : Colors.black;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMine ? myBubbleColor : otherBubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: message.isMine
                ? const Radius.circular(12)
                : Radius.zero,
            bottomRight: message.isMine
                ? Radius.zero
                : const Radius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!message.isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: myBubbleColor,
                  ),
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: message.isMine ? myTextColor : otherTextColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: TextStyle(
                color: message.isMine
                    ? myTextColor.withValues(alpha: 0.7)
                    : context.theme.hintColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
