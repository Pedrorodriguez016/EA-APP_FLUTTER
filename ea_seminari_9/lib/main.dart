import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Seminario FLutter',
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const CustomNavigationBar(), 
    );
  }
}
