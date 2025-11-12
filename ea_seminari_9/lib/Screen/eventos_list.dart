import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/eventos_controller.dart';
import '../Widgets/eventos_card.dart';
import '../Widgets/navigation_bar.dart';
import'../Widgets/refresh_button.dart';
import '../Widgets/app_bar.dart';

class EventosListScreen extends GetView<EventoController> {

  const EventosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: StandardAppBar(
        title: "Eventos",
      ),
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
                  Text('Cargando eventos...'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: controller.eventosList.length,
            itemBuilder: (context, index) {
              return EventosCard(evento: controller.eventosList[index]);
            },
          );
        }),
      ),
      floatingActionButton: RefreshButton(
        onRefresh: () => controller.fetchEventos(),
        message: 'Lista de usuarios actualizada',
),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }
}