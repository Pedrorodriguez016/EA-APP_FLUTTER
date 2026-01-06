import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../Controllers/user_controller.dart';
import '../Controllers/auth_controller.dart';
import '../Controllers/eventos_controller.dart';
import '../Services/eventos_services.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/user_card.dart';
import '../Widgets/solicitudes.dart';
import '../Widgets/mapa.dart';
import '../Widgets/global_drawer.dart';
import '../utils/app_theme.dart';

class HomeScreen extends GetView<UserController> {
  HomeScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();
  final EventoController eventoController = Get.put(
    EventoController(EventosServices()),
  );

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.friendsList.isEmpty) {
        controller.fetchFriends();
        controller.fetchRequest();
      }
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      endDrawer: const GlobalDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildWelcomeCard(authController, context),
            const SizedBox(height: 24),
            _buildEventsCard(context),
            const SizedBox(height: 24),
            _buildFriendsCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/chatbot'),
        backgroundColor: context.theme.colorScheme.primary,
        heroTag: 'chatbotFab',
        child: Icon(
          Icons.smart_toy_rounded,
          color: context.theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(translate('home.title')),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.onSurface.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          onPressed: () {},
        ),
        Builder(
          builder: (scaffoldContext) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: context.theme.colorScheme.primary,
            ),
            onPressed: () => Scaffold.of(scaffoldContext).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(AuthController auth, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryBtn,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                translate('home.welcome_card.greeting'),
                style: context.textTheme.headlineSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => Text(
              auth.currentUser.value?.username ?? translate('common.user'),
              style: context.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 32,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            translate('home.welcome_card.subtitle'),
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translate('home.events_section.title'),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.toNamed('/eventos'),
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildActionButton(
                    context,
                    Icons.add_circle_rounded,
                    translate('home.events_section.create_btn'),
                    () => Get.toNamed('/crear_evento'),
                    isPrimary: true,
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    context,
                    Icons.explore_rounded,
                    translate('home.events_section.explore_btn'),
                    () => Get.toNamed('/eventos'),
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    context,
                    Icons.calendar_month_rounded,
                    translate('home.events_section.my_events_btn'),
                    () => Get.toNamed('/eventos?mine=true'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Obx(() {
                  if (eventoController.isLoadingLocation.value) {
                    return Container(
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surfaceVariant
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Obteniendo ubicación...'),
                          ],
                        ),
                      ),
                    );
                  }

                  final eventos = eventoController.mapEventosList;
                  final myMarkers = eventos
                      .where((e) => e.lat != null && e.lng != null)
                      .map((evento) {
                        return Marker(
                          point: LatLng(
                            evento.lat!.toDouble(),
                            evento.lng!.toDouble(),
                          ),
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () => Get.toNamed('/evento/${evento.id}'),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: context.theme.colorScheme.primary,
                              size: 50,
                              shadows: [
                                Shadow(
                                  blurRadius: 12,
                                  color: context.theme.shadowColor.withValues(
                                    alpha: 0.6,
                                  ),
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                      .toList();

                  return CustomMap(
                    height: 220,
                    center:
                        eventoController.userLocation.value ??
                        eventoController.defaultLocation,
                    zoom: 12,
                    enableExpansion: true,
                    markers: myMarkers,
                    onPositionChanged: (MapPosition position, bool hasGesture) {
                      final bounds = position.bounds;
                      if (bounds != null) {
                        eventoController.fetchMapEvents(
                          bounds.north,
                          bounds.south,
                          bounds.east,
                          bounds.west,
                        );
                      }
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  translate('home.friends_section.title'),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => Text(
                      controller.friendsList.length.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildActionButton(
                    context,
                    Icons.group_add_rounded,
                    translate('home.friends_section.requests_btn'),
                    () {
                      FriendRequestsDialog.show(
                        context,
                        requests: controller.friendsRequests,
                        onAccept: (user) =>
                            controller.acceptFriendRequest(user),
                        onReject: (user) =>
                            controller.rejectFriendRequest(user),
                      );
                    },
                    isPrimary: true,
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    context,
                    Icons.search_rounded,
                    translate('home.friends_section.search_btn'),
                    () => Get.toNamed('/users'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.friendsList.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      translate('home.friends_section.empty_msg'),
                      style: context.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.friendsList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: UserCard(user: controller.friendsList[index]),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary
              ? context.theme.colorScheme.primary
              : context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: isPrimary
              ? null
              : Border.all(
                  color: context.theme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: context.theme.colorScheme.primary.withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary
                  ? Colors.white
                  : context.theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? Colors.white
                    : context.theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
