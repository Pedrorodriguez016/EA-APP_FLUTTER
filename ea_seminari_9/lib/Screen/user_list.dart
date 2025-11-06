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
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay usuarios disponibles',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: userService.users.length,
          itemBuilder: (context, index) {
            final user = userService.users[index];
            return UserCard(user: user);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          userService.loadUsers();
          Get.snackbar(
            'Actualizado',
            'Lista de usuarios actualizada',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),

    );
  }
}