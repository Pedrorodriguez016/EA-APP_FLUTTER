import 'package:ea_seminari_9/Controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/auth_controller.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/logout_button.dart';
import '../Widgets/user_card.dart';

class HomeScreen extends GetView<UserController>{
  HomeScreen({Key? key}) : super(key: key);
  final AuthController authController = Get.find<AuthController>();
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
            Row(
              children: [
                Expanded(child:
                _buildEventsCard()
                ),
                Expanded(child: 
                _buildFriendsCard())
              ],
            )
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
            const Text('Eventos',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
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
                    backgroundColor: const Color(0xFF667EEA), // Púrpura principal
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Get.toNamed('/eventos'),
                  icon: const Icon(Icons.search),
                  label: const Text('Explorar eventos'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.indigo.shade50,
                    foregroundColor: Colors.indigo.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Get.toNamed('/eventos?mine=true'),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Mis eventos'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.indigo.shade50,
                    foregroundColor: Colors.indigo.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFriends();
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
              const Text('Amigos',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => Text(
                      controller.friendsList.length.toString(), 
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    )),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () { },
                icon: const Icon(Icons.group_add, size: 20),
                label: const Text('Solicitudes'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.indigo.shade50,
                  foregroundColor: Colors.indigo.shade800,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              ElevatedButton.icon(
                      onPressed: () => Get.toNamed('/users'),
                      icon: const Icon(Icons.search, size: 20),
                      label: const Text('Buscar amigos'), 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    )
            ],
          ),
          const SizedBox(height: 20),

          // --- Cuerpo de la Tarjeta (Cargando / Vacío / Con Datos) ---
          Obx(() {
            // --- Estado 1: Cargando ---
            if (controller.isLoading.value) { 
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // --- Estado 2: Vacío ---
            if (controller.friendsList.isEmpty) { 
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Aún no tienes amigos para mostrar.',
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic),
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
              final user = controller.userList[index];
              return UserCard(user: user);
              } ,
            );
          }), // Fin de Obx
        ],
      ),
    ),
  );
  }
}