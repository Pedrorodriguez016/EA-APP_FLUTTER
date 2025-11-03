import 'package:flutter/material.dart';
import '../Models/user.dart';
import '../services/user_services.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;
  final UserServices userService = UserServices();

  UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Usuario'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<User>(
        future: userService.getUserById(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Usuario no encontrado'));
          }

          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Icon(Icons.person, size: 100, color: Colors.deepPurple),
                ),
                const SizedBox(height: 20),
                Text('👤 Nombre: ${user.username}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('📧 Correo: ${user.gmail}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('🎂 Cumpleaños: ${user.birthday}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('🧩 Rol: ${user.rol}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
