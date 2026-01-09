import 'package:ea_seminari_9/Controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Models/user.dart';
import '../Controllers/auth_controller.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/logout_button.dart';
import '../Widgets/user_card.dart';
import '../Widgets/solicitudes.dart';
import '../Widgets/mapa.dart';
import '../Controllers/eventos_controller.dart';
import '../Services/eventos_services.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class HomeScreen extends GetView<UserController> {
  HomeScreen({Key? key}) : super(key: key);
  final AuthController authController = Get.find<AuthController>();
  final EventoController eventoController = Get.put(
    EventoController(EventosServices()),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildWelcomeCard(authController),
            const SizedBox(height: 24),
            _buildEventsCard(),
            const SizedBox(height: 24),
            _buildFriendsCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Inicio'),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: LogoutButton(),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_outlined, color: Colors.grey),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(AuthController auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¡Hola!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            auth.currentUser.value?.username ?? 'Usuario',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bienvenido a tu aplicación de eventos',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Eventos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/crear_evento'),
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Crear evento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF667EEA,
                    ), // Púrpura principal
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Get.toNamed('/eventos'),
                  icon: const Icon(Icons.search),
                  label: const Text('Explorar eventos'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.indigo.shade50,
                    foregroundColor: Colors.indigo.shade800,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Get.toNamed('/eventos?mine=true'),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Mis eventos'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.indigo.shade50,
                    foregroundColor: Colors.indigo.shade800,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 200,
              child: Obx(() {
                if (eventoController.isLoadingLocation.value) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text(
                            'Obteniendo ubicación...',
                            style: TextStyle(color: Colors.grey),
                          ),
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
                        width: 45,
                        height: 45,
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed('/evento/${evento.id}');
                          },
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFF667EEA),
                            size: 45,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black26,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                    .toList();
                return CustomMap(
                  height: 200,
                  center:
                      eventoController.userLocation.value ??
                      eventoController.defaultLocation,
                  zoom: 12,
                  enableExpansion: true,
                  markers: myMarkers, // Pasamos la lista limpia
                  // Lógica de recarga al mover el mapa
                  onPositionChanged: (MapPosition position, bool hasGesture) {
                    final bounds = position.bounds;
                    if (bounds != null) {
                      eventoController.fetchMapEventsDebounced(bounds);
                    }
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsCard(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFriends();
      controller.fetchRequest();
    });
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Para que la tarjeta se ajuste
          children: [
            // --- Fila Superior: Título, Contador, Solicitudes ---
            Row(
              children: [
                const Text(
                  'Amigos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => Text(
                      controller.friendsList.length.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      final List<User> users = controller.friendsRequests;
                      FriendRequestsDialog.show(
                        context,
                        requests: users,
                        onAccept: (user) =>
                            controller.acceptFriendRequest(user),
                        onReject: (user) =>
                            controller.rejectFriendRequest(user),
                      );
                    },
                    icon: const Icon(Icons.group_add, size: 20),
                    label: const Text('Solicitudes'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.indigo.shade50,
                      foregroundColor: Colors.indigo.shade800,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/users'),
                    icon: const Icon(Icons.search, size: 20),
                    label: const Text('Buscar amigos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Aún no tienes amigos para mostrar.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: controller.friendsList.length,
                itemBuilder: (context, index) {
                  final user = controller.friendsList[index];
                  return UserCard(user: user);
                },
              );
            }), // Fin de Obx
          ],
        ),
      ),
    );
  }
}
