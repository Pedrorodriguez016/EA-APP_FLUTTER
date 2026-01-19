import 'package:flutter/material.dart';
import 'dart:async';
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
        title: InkWell(
          onTap: () => Get.toNamed('/evento/${controller.eventId}'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
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
                  style: TextStyle(
                    color: context.theme.hintColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
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
                    translate('events_extra.event_photos'),
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
                          translate('events_extra.no_photos_yet'),
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
              translate('events_extra.share_media'),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: Text(translate('chat_extra.send_image')),
              subtitle: Text(translate('chat_extra.send_image_conv')),
              onTap: () {
                Get.back();
                controller.sendImageMessage();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(translate('events_extra.open_gallery')),
              subtitle: Text(translate('events_extra.photos_videos')),
              onTap: () {
                Get.back();
                controller.uploadMedia(isGeneralGallery: true);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(translate('events_extra.open_camera')),
              subtitle: Text(translate('events_extra.capture_now')),
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
                          translate('profile.camera'),
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: Text(translate('events_extra.take_photo')),
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
                          title: Text(translate('events_extra.record_video')),
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
    final isOwner = media.userId == controller.myUserId;

    Get.to(
      Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            media.type == 'video'
                ? translate('events_extra.video')
                : translate('events_extra.photo'),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            if (isOwner)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  Get.defaultDialog(
                    title: translate('common.delete'),
                    middleText: translate('chat_extra.delete_item_confirm'),
                    textConfirm: translate('common.delete'),
                    textCancel: translate('common.cancel'),
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      Get.back(); // Cierra el dialogo
                      Get.back(); // Cierra el visor de fotos
                      controller.deletePhoto(media.id);
                    },
                  );
                },
              ),
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
  bool _showControls = true;
  Timer? _hideTimer;

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
                _startHideTimer();
              })
              .catchError((e) {
                setState(() {
                  _isError = true;
                });
              });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            translate('events_extra.video_load_error'),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      );
    }

    if (!_controller.value.isInitialized) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    return GestureDetector(
      onTap: _toggleControls,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          if (_showControls)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              _controller.value.volume == 0
                                  ? Icons.volume_off
                                  : Icons.volume_up,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _controller.setVolume(
                                  _controller.value.volume == 0 ? 1.0 : 0.0,
                                );
                              });
                              _startHideTimer();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Center Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.replay_10_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () {
                            final newPos =
                                _controller.value.position -
                                const Duration(seconds: 10);
                            _controller.seekTo(newPos);
                            _startHideTimer();
                          },
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            color: Colors.white,
                            size: 64,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                            _startHideTimer();
                          },
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(
                            Icons.forward_10_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () {
                            final newPos =
                                _controller.value.position +
                                const Duration(seconds: 10);
                            _controller.seekTo(newPos);
                            _startHideTimer();
                          },
                        ),
                      ],
                    ),
                    // Bottom Controls
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_controller.value.position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(_controller.value.duration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                            activeTrackColor: context.theme.colorScheme.primary,
                            inactiveTrackColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            thumbColor: context.theme.colorScheme.primary,
                          ),
                          child: Slider(
                            value: _controller.value.position.inMilliseconds
                                .toDouble(),
                            min: 0.0,
                            max: _controller.value.duration.inMilliseconds
                                .toDouble(),
                            onChanged: (value) {
                              setState(() {
                                _controller.seekTo(
                                  Duration(milliseconds: value.toInt()),
                                );
                              });
                            },
                            onChangeStart: (_) => _hideTimer?.cancel(),
                            onChangeEnd: (_) => _startHideTimer(),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
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
            if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
              GestureDetector(
                onTap: () {
                  final fullUrl =
                      '${Get.find<EventosServices>().baseUrl.replaceAll('/api/event', '')}${message.imageUrl}';
                  Get.to(
                    Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        backgroundColor: Colors.black,
                        iconTheme: const IconThemeData(color: Colors.white),
                      ),
                      body: Center(
                        child: InteractiveViewer(
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
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      '${Get.find<EventosServices>().baseUrl.replaceAll('/api/event', '')}${message.imageUrl}',
                      headers: {
                        'Authorization':
                            'Bearer ${Get.find<AuthController>().token ?? ''}',
                      },
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            if (message.text.isNotEmpty)
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
