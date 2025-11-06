import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Services/eventos_services.dart';
import '../Widgets/eventos_card.dart';
import '../Widgets/navigation_bar.dart';

class EventosListScreen extends StatelessWidget {
  final EventosService service = Get.put(EventosService());

  EventosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    service.loadEvents();

    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      body: Obx(() {
        if (service.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: service.events.length,
          itemBuilder: (context, index) {
            return EventosCard(evento: service.events[index]);
          },
        );
      }),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }
}
