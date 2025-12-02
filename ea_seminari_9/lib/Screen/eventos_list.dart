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
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: StandardAppBar(title: "Eventos"), // O translate('events.list_title')
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Barra de búsqueda (Solo visible en Explorar)
            Obx(() => controller.currentFilter.value == EventFilter.all
                ? TextField(
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
                  )
                : const SizedBox.shrink()),
            
            const SizedBox(height: 12),
            _buildFilterTabs(), // Tus pestañas de filtro
            const SizedBox(height: 12),

            // CONTENIDO PRINCIPAL
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // CASO 1: VISTA DE "MIS EVENTOS" (Dos secciones)
                if (controller.currentFilter.value == EventFilter.myEvents) {
                  return _buildMisEventosView();
                }

                // CASO 2: VISTA DE "EXPLORAR" (Lista normal paginada)
                if (controller.eventosList.isEmpty) {
                  return const Center(child: Text("No se encontraron eventos."));
                }

                return ListView.separated(
                  controller: controller.scrollController,
                  itemCount: controller.eventosList.length + 1,
                  separatorBuilder: (c, i) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == controller.eventosList.length) {
                      return Obx(() => controller.isMoreLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox.shrink());
                    }
                    return EventosCard(evento: controller.eventosList[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: RefreshButton(
        onRefresh: () {
          if (controller.currentFilter.value == EventFilter.myEvents) {
            controller.fetchMisEventosEspecificos();
          } else {
            controller.refreshEventos();
          }
        },
        message: 'Lista actualizada',
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
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
Widget _buildMisEventosView() {
    if (controller.misEventosCreados.isEmpty && controller.misEventosInscritos.isEmpty) {
      return const Center(child: Text("Aún no has creado ni te has unido a eventos."));
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.misEventosCreados.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("Eventos Creados por mí", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            ),
            ...controller.misEventosCreados.map((e) => EventosCard(evento: e)).toList(),
          ],
          if (controller.misEventosInscritos.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
              child: Text("Eventos a los que asisto", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            ),
            ...controller.misEventosInscritos.map((e) => EventosCard(evento: e)).toList(),
          ],
        ],
      ),
    );
  }

}