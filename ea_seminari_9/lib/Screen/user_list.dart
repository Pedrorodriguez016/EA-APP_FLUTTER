import 'package:ea_seminari_9/Controllers/user_controller.dart';
import 'package:ea_seminari_9/Widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Widgets/user_card.dart';
import '../Widgets/refresh_button.dart';

class UserListScreen extends GetView<UserController> {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: StandardAppBar(title: "Usuarios"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {

          if (controller.isLoading.value && controller.userList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              TextField(
                controller: controller.searchEditingController,
                decoration: InputDecoration(
                  hintText: "Buscar usuario...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (value) => controller.searchUsers(value),
              ),
              const SizedBox(height: 12),
              Expanded(
              child: Obx(() {

                if (controller.isLoading.value && controller.userList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
              
                if (controller.userList.isEmpty) {
                   return const Center(child: Text("No se encontraron usuarios"));
                }

                return ListView.separated(
                  // 1. ASIGNAMOS EL CONTROLLER AQUÍ
                  controller: controller.scrollController, 
                  itemCount: controller.userList.length + 1, 
                  separatorBuilder: (c, i) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    
                    // 2. DETECTAMOS SI ES EL ÚLTIMO ITEM PARA MOSTRAR SPINNER
                    if (index == controller.userList.length) {
                      return Obx(() => controller.isMoreLoading.value
                          ? const Center(
                              child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ))
                          : const SizedBox.shrink()); // Si no carga, espacio vacío
                    }
                    final user = controller.userList[index];
                    return UserCard(user: user);
                  },
                );
              }
            )
              ),
            ],
          );
        }),
      ),
      floatingActionButton: RefreshButton(
        onRefresh: () => controller.refreshUsers(),
        message: 'Lista de usuarios actualizada',
      ),
    );
  }
}