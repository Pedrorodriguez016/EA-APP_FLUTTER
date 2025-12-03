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
        title: translate('events.list_title'), // Mantenemos la traducción
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Barra de búsqueda (Solo visible en Explorar) - Lógica de 'gestion-eventos' con traducción de 'HEAD'
            Obx(() => controller.currentFilter.value == EventFilter.all
                ? TextField(
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
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 12),
            _buildFilterTabs(),
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
                  return Center(child: Text(translate('events.empty_search'))); // "No se encontraron eventos"
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
                          : const SizedBox.shrink());
                    }
                    final evento = controller.eventosList[index];
                    return EventosCard(evento: evento);
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
        message: translate('common.success'),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }

  Widget _buildFilterTabs() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildFilterButton(
            label: translate('events.explore_tab'), 
            filter: EventFilter.all,
            icon: Icons.explore_outlined,
            isSelected: controller.currentFilter.value == EventFilter.all,
          ),
          const SizedBox(width: 8),
          _buildFilterButton(
            label: translate('events.my_events_tab'), 
            filter: EventFilter.myEvents,
            icon: Icons.event_note_outlined,
            isSelected: controller.currentFilter.value == EventFilter.myEvents,
          ),
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
        controller.setFilter(filter);
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
      return Center(child: Text(translate('events.no_my_events')));
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.misEventosCreados.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(translate('events.created_by_me'), 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            ),
            ...controller.misEventosCreados.map((e) => EventosCard(evento: e)).toList(),
          ],
          if (controller.misEventosInscritos.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
              child: Text(translate('events.attending'), 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            ),
            ...controller.misEventosInscritos.map((e) => EventosCard(evento: e)).toList(),
          ],
        ],
      ),
    );
  }
}