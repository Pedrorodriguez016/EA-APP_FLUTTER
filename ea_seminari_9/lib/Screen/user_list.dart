import 'package:ea_seminari_9/Controllers/user_controller.dart';
import 'package:ea_seminari_9/Widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Widgets/user_card.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/refresh_button.dart';

class UserListScreen extends GetView<UserController> {

  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar:StandardAppBar(title: "Usuarios"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.isLoading.value) {
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

          if (controller.userList.isEmpty) {
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
            itemCount: controller.userList.length,
            itemBuilder: (context, index) {
              final user = controller.userList[index];
              return UserCard(user: user);
            },
          );
        }),
      ),
      floatingActionButton: RefreshButton(
        onRefresh: () => controller.fetchUsers(),
        message: 'Lista de usuarios actualizada',
),

      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }
}