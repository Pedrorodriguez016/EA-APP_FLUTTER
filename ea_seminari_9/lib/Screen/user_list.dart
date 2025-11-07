import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Services/user_services.dart';
import '../Widgets/user_card.dart';
import '../Widgets/navigation_bar.dart';

class UserListScreen extends StatelessWidget {
  final UserServices userService = Get.put(UserServices());

  UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Usuarios'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (userService.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando usuarios...'),
                ],
              ),
            );
          }

          if (userService.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No hay usuarios disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: userService.users.length,
            itemBuilder: (context, index) {
              final user = userService.users[index];
              return UserCard(user: user);
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          userService.loadUsers();
          Get.snackbar(
            'Actualizado',
            'Lista de usuarios actualizada',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            borderRadius: 12,
          );
        },
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }
}