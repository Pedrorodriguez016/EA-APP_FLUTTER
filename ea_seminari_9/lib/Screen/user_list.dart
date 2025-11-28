import 'package:ea_seminari_9/Controllers/user_controller.dart';
import 'package:ea_seminari_9/Widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Widgets/user_card.dart';
import '../Widgets/refresh_button.dart';
import '../Widgets/paginator.dart';

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

                  if (controller.isLoading.value &&
                      controller.userList.isNotEmpty) {
                    return Stack(
                      children: [
                        _buildUserList(), 
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withOpacity(0.5),
                            child:
                                const Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ],
                    );
                  }
                  if (controller.userList.isEmpty) {
                    return const Center(child: Text("No se encontraron usuarios"));
                  }
                  return _buildUserList();
                }),
              ),
              Obx(() {
                
                final bool isLoading = controller.isLoading.value;
                final int currentPage = controller.currentPage.value;
                final int totalPages = controller.totalPages.value;

                
                return PaginationControls(
                  totalPages: totalPages,
                  currentPage: currentPage,
                  totalItems: controller.totalUsers.value,
                  itemTypePlural: "usuarios", 
                  isLoading: isLoading,
                  
                  
                  onPreviousPage: (currentPage > 1 && !isLoading)
                      ? controller.previousPage 
                      : null, 
                      
                  onNextPage: (currentPage < totalPages && !isLoading)
                      ? controller.nextPage 
                      : null, 

                  onPageSelected: (page) => controller.fetchUsers(page),
                );
              }),
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

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: controller.userList.length,
      itemBuilder: (context, index) {
        final user = controller.userList[index];
        return UserCard(user: user);
      },
    );
  }
}