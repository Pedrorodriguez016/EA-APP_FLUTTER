import 'package:flutter/material.dart';
import '../Models/user.dart';
import '../Screen/user_detail.dart';
import 'package:get/get.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        title: Text(user.username),
        onTap: () {
          // 👇 Al tocar la tarjeta, abre la pantalla de detalles
          Get.to(() => UserDetailScreen(userId: user.id));
        },
      ),
    );
  }
}
