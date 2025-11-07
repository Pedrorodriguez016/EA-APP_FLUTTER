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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Eventos'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.grey),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (service.isLoading.value) {
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
            itemCount: service.events.length,
            itemBuilder: (context, index) {
              return EventosCard(evento: service.events[index]);
            },
          );
        }),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }
}