import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_list.dart';
import 'eventos_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => Get.to(() => UserListScreen()),
                icon: const Icon(Icons.people, size: 28,color:Color( 0xFFFFFFFF),),
                label: const Text(
                  'Ver Usuarios',
                  style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)), 
                  
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => Get.to(() => EventosListScreen()),
                icon: const Icon(Icons.event, size: 28, color : Color(0xFFFFFFFF),),
                label: const Text(
                  'Ver Eventos',
                  style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
