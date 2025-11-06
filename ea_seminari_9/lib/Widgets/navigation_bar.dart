import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Screen/home.dart';
import '../Screen/eventos_list.dart';
import '../Screen/user_list.dart';
import '../Screen/settings_screen.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade800,
            Colors.purple.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 11,
        ),
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAll(() => const HomeScreen());
              break;
            case 1:
              Get.offAll(() =>  EventosListScreen());
              break;
            case 2:
              Get.offAll(() => UserListScreen());
              break;
            case 3:
              Get.offAll(() =>  SettingsScreen());
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.event_available), label: 'Eventos'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Usuarios'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
