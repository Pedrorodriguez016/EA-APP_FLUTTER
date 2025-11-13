import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/eventos_controller.dart';
import '../Widgets/eventos_card.dart';
import '../Widgets/navigation_bar.dart';
import'../Widgets/refresh_button.dart';
import '../Widgets/app_bar.dart';
import '../Widgets/paginator.dart';

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
        child:Obx(() {

          if (controller.isLoading.value && controller.eventosList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              TextField(
                controller: controller.searchEditingController,
                decoration: InputDecoration(
                  hintText: "Buscar evento...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (value) => controller.searchEventos(value),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {

                  if (controller.isLoading.value &&
                      controller.eventosList.isNotEmpty) {
                    return Stack(
                      children: [
                        _buildEventosList(), 
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withOpacity(0.5),
                            child:
                                const Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ],
                    );
                  }
                  if (controller.eventosList.isEmpty) {
                    return const Center(child: Text("No se encontraron eventos"));
                  }
                  return _buildEventosList();
                }),
              ),
              Obx(() {
                
                final bool isLoading = controller.isLoading.value;
                final int currentPage = controller.currentPage.value;
                final int totalPages = controller.totalPages.value;

                
                return PaginationControls(
                  totalPages: totalPages,
                  currentPage: currentPage,
                  totalItems: controller.totalEventos.value,
                  itemTypePlural: "eventos", 
                  isLoading: isLoading,
                  
                  
                  onPreviousPage: (currentPage > 1 && !isLoading)
                      ? controller.previousPage 
                      : null, 
                      
                  onNextPage: (currentPage < totalPages && !isLoading)
                      ? controller.nextPage 
                      : null, 

                  onPageSelected: (page) => controller.fetchEventos(page),
                );
              }),
            ],
          );
        }),
      ),
      floatingActionButton: RefreshButton(
        onRefresh: () => controller.refreshEventos(),
        message: 'Lista de eventos actualizada',
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }

  Widget _buildEventosList() {
    return ListView.builder(
      itemCount: controller.eventosList.length,
      itemBuilder: (context, index) {
        final evento = controller.eventosList[index];
        return EventosCard(evento: evento);
      },
    );
  }
}