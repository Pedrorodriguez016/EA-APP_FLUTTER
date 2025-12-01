import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart'; // Importar
import '../Controllers/eventos_controller.dart';
import '../Widgets/eventos_card.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/refresh_button.dart';
import '../Widgets/app_bar.dart';

class EventosListScreen extends GetView<EventoController> {

  const EventosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: StandardAppBar(
        title: translate('events.list_title'), // 'Eventos'
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {

          if (controller.isLoading.value && controller.eventosList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              TextField(
                controller: controller.searchEditingController,
                decoration: InputDecoration(
                  hintText: translate('events.search_hint'), // 'Buscar evento...'
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

              _buildFilterTabs(),
              const SizedBox(height: 12),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.eventosList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                
                  if (controller.eventosList.isEmpty) {

                     // Mostrar mensaje diferente si se está filtrando a mis eventos
                      final noEventsMessage = controller.currentFilter.value == EventFilter.myEvents
                        ? "No has creado ningún evento aún."
                        : "No se encontraron eventos.";

                      return Center(child: Text(noEventsMessage));

                  }

                  return ListView.separated(
                    controller: controller.scrollController, 
                    itemCount: controller.eventosList.length + 1, 
                    separatorBuilder: (c, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == controller.eventosList.length) {
                        return Obx(() => controller.isMoreLoading.value
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox.shrink()
                        );
                      }

                      final evento = controller.eventosList[index];
                      return EventosCard(evento: evento);
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: RefreshButton(
        onRefresh: () => controller.refreshEventos(),
        message: translate('common.success'), // Mensaje de éxito genérico o específico
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
 Widget _buildFilterTabs() {
  return Obx(() {
 // Obx reacciona cuando controller.currentFilter.value cambia
return Row(
 mainAxisAlignment: MainAxisAlignment.start,
children: [
// 1. Botón "Explorar eventos" (TODOS)
 _buildFilterButton(
label: 'Explorar eventos',
 filter: EventFilter.all,
 icon: Icons.explore_outlined,
isSelected: controller.currentFilter.value == EventFilter.all,
 ),
 const SizedBox(width: 8),
// 2. Botón "Mis eventos" (FILTRADO POR CREADOR)
 _buildFilterButton(
label: 'Mis eventos',
 filter: EventFilter.myEvents,
 icon: Icons.event_note_outlined,
 isSelected: controller.currentFilter.value == EventFilter.myEvents,
 ),
 // Puedes añadir más filtros aquí si es necesario
 ],
);
 });
 }
Widget _buildFilterButton({
required String label,
required EventFilter filter,
required IconData icon,
required bool isSelected,
 }) {
final Color primaryColor = Theme.of(Get.context!).primaryColor;
final Color activeColor = primaryColor;
 final Color inactiveColor = Colors.grey.shade300;
 final Color inactiveTextColor = Colors.black87;
 return InkWell(
onTap: () {
 // Llama al método del controlador para cambiar el filtro
 controller.setFilter(filter);
 // Asegúrate de restablecer la búsqueda si hay un término
 controller.searchEditingController.clear();
 },
 child: Container(
 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
 decoration: BoxDecoration(
 color: isSelected ? activeColor : inactiveColor,
 borderRadius: BorderRadius.circular(20),
 boxShadow: [
 if (isSelected)
 BoxShadow(
color: activeColor.withOpacity(0.3),
 blurRadius: 4,
offset: const Offset(0, 2),
 ),
 ],
 ),
 child: Row(
 mainAxisSize: MainAxisSize.min,
children: [
Icon(
icon,
 size: 18,
 color: isSelected ? Colors.white : primaryColor,
),
 const SizedBox(width: 6),
 Text(
 label,
style: TextStyle(
 color: isSelected ? Colors.white : inactiveTextColor,
 fontWeight: FontWeight.w600,
),
 ),
 ],
 ),
 ),
 );
}

}