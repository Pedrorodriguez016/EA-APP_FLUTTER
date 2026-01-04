import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/gamificacion_controller.dart';
import '../Widgets/app_bar.dart';
import '../Widgets/mi_progreso_card.dart';
import '../Widgets/mis_insignias_section.dart';
import '../Widgets/estadisticas_section.dart';
import '../Widgets/ranking_section.dart';

class GamificacionScreen extends GetView<GamificacionController> {
  const GamificacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: StandardAppBar(title: translate('gamification.title')),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.cargarMiProgreso();
          await controller.cargarRanking();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mi progreso
              Obx(() {
                final progreso = controller.miProgreso.value;

                if (controller.isLoading.value && progreso == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (progreso == null) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: context.theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 60,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          translate('gamification.in_development'),
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          translate('gamification.not_active'),
                          style: context.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return MiProgresoCard(progreso: progreso);
              }),

              const SizedBox(height: 24),

              // Mis Insignias
              Obx(() {
                final progreso = controller.miProgreso.value;
                if (progreso == null) return const SizedBox.shrink();

                return MisInsigniasSection(insignias: progreso.insignias);
              }),

              const SizedBox(height: 24),

              // Estadísticas
              Obx(() {
                final progreso = controller.miProgreso.value;
                if (progreso == null) return const SizedBox.shrink();

                return EstadisticasSection(stats: progreso.estadisticas);
              }),

              const SizedBox(height: 24),

              // Ranking
              Text(
                translate('gamification.ranking_title'),
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                // Acceder al valor de la lista observable
                final rankingList = controller.ranking.toList();
                return RankingSection(ranking: rankingList);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
