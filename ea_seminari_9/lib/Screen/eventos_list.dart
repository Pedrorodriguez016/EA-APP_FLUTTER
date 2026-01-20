import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/eventos_controller.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/categories_grid.dart';
import '../Widgets/eventos_card.dart';
import '../Widgets/global_drawer.dart';

class EventosListScreen extends GetView<EventoController> {
  const EventosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Si estamos en modo búsqueda/filtros, volver al estado inicial
        if (controller.isSearching.value) {
          controller.clearFilters();
          return false; // No hacer pop, solo limpiar filtros
        } else {
          // Si estamos en la vista inicial, permitir navegación normal
          return true; // Permitir pop
        }
      },
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        endDrawer: const GlobalDrawer(),
        body: SafeArea(
          child: Obx(() {
            if (controller.isSearching.value) {
              return _buildSearchResultsView(context);
            }
            return _buildInitialView(context);
          }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed('/crear_evento'),
          backgroundColor: context.theme.colorScheme.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
        bottomNavigationBar: const CustomNavBar(currentIndex: 1),
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchEventos(1);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isResults: false),
            const SizedBox(height: 20),
            _buildSearchBar(context),
            const SizedBox(height: 24),
            CategoriesGrid(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _buildHeader(context, isResults: true),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.eventosList.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    translate('events.empty_search'),
                    style: TextStyle(color: context.theme.hintColor),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: controller.eventosList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return EventosCard(
                  evento: controller.eventosList[index],
                  showParticipationStatus: true,
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, {required bool isResults}) {
    return Row(
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            isResults
                ? (controller.searchEditingController.text.isNotEmpty
                      ? controller.searchEditingController.text
                      : translate('events.explore_tab'))
                : translate('events.explore_tab'),
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 28,
              color: context.theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isResults)
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              controller.clearFilters();
            },
          ),
        Builder(
          builder: (scaffoldContext) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: context.theme.colorScheme.primary,
            ),
            onPressed: () => Scaffold.of(scaffoldContext).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
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
          hintStyle: TextStyle(
            color: context.theme.hintColor.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.theme.hintColor.withValues(alpha: 0.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: context.isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.05),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
        onSubmitted: (value) {
          controller.isSearching.value = true;
          controller.searchEventos(value);
        },
      ),
    );
  }
}
