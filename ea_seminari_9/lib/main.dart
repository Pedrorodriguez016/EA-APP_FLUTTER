import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Screen/home.dart';
import 'Screen/user_list.dart';
import 'Screen/eventos_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Usuarios y Eventos',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen()), 
        GetPage(name: '/usuarios', page: () => UserListScreen()),
        GetPage(name: '/eventos', page: () => EventosListScreen()),
      ],
    );
  }
}
