import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/eventos_controller.dart';
import '../Widgets/eventos_card.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/refresh_button.dart';
import '../Widgets/app_bar.dart';
import '../utils/app_theme.dart';

class EventosListScreen extends GetView<EventoController> {
  const EventosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: StandardAppBar(title: translate('events.list_title')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Obx(
              () => controller.currentFilter.value == EventFilter.all
                  ? Container(
                      decoration: BoxDecoration(
                        color: context.theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller.searchEditingController,
                        style: context.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: translate('events.search_hint'),
                          hintStyle: TextStyle(color: context.theme.hintColor),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: context.theme.colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                        ),
                        onSubmitted: (value) => controller.searchEventos(value),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),
            _buildFilterTabs(context),
            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.currentFilter.value == EventFilter.myEvents) {
                  return _buildMisEventosView(context);
                }

                if (controller.eventosList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 60,
                          color: context.theme.disabledColor.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          translate('events.empty_search'),
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  controller: controller.scrollController,
                  itemCount: controller.eventosList.length + 1,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, index) {
                    if (index == controller.eventosList.length) {
                      return Obx(
                        () => controller.isMoreLoading.value
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      );
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
      bottomNavigationBar: CustomNavBar(currentIndex: 1),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return Obx(() {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _buildFilterTabItem(
                context: context,
                label: translate('events.explore_tab'),
                icon: Icons.explore_rounded,
                isSelected: controller.currentFilter.value == EventFilter.all,
                onTap: () => controller.setFilter(EventFilter.all),
              ),
            ),
            Expanded(
              child: _buildFilterTabItem(
                context: context,
                label: translate('events.my_events_tab'),
                icon: Icons.event_note_rounded,
                isSelected:
                    controller.currentFilter.value == EventFilter.myEvents,
                onTap: () => controller.setFilter(EventFilter.myEvents),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterTabItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primaryBtn : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : context.theme.hintColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : context.theme.hintColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMisEventosView(BuildContext context) {
    if (controller.misEventosCreados.isEmpty &&
        controller.misEventosInscritos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 60,
              color: context.theme.disabledColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              translate('events.no_my_events'),
              style: context.textTheme.titleMedium?.copyWith(
                color: context.theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final createdColor = context.isDarkMode
        ? const Color(0xFF818CF8)
        : const Color(0xFF4F46E5);
    final attendingColor = context.isDarkMode
        ? const Color(0xFF34D399)
        : const Color(0xFF059669);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.misEventosCreados.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_calendar_rounded,
                    color: createdColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    translate('events.created_by_me'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: createdColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            ...controller.misEventosCreados
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: EventosCard(evento: e),
                  ),
                )
                .toList(),
          ],

          if (controller.misEventosCreados.isNotEmpty &&
              controller.misEventosInscritos.isNotEmpty)
            const SizedBox(height: 16),

          if (controller.misEventosInscritos.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: attendingColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    translate('events.attending'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: attendingColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            ...controller.misEventosInscritos
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: EventosCard(evento: e),
                  ),
                )
                .toList(),
          ],
        ],
      ),
    );
  }
}
