import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Services/user_services.dart';
import '../Widgets/user_card.dart';

class UserListScreen extends StatelessWidget {
  final UserServices service = Get.put(UserServices());

  UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    service.loadUsers();

    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: Obx(() {
        if (service.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: service.users.length,
          itemBuilder: (context, index) {
            return UserCard(user: service.users[index]);
          },
        );
      }),
    );
  }
}
