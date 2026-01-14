import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import '../Controllers/eventos_controller.dart';
import '../utils/app_theme.dart';

class RecommendedSection extends StatefulWidget {
  final EventoController controller;

  const RecommendedSection({super.key, required this.controller});

  @override
  State<RecommendedSection> createState() => _RecommendedSectionState();
}

class _RecommendedSectionState extends State<RecommendedSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.controller.fetchMoreRecommended();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recomendados para ti',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.controller.showRecommendedOnly();
                  Get.toNamed('/eventos');
                },
                child: const Text('Ver todos'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 290,
          child: Obx(() {
            final recommended = widget.controller.recommendedEventos;
            if (recommended.isEmpty && !widget.controller.isLoading.value) {
              return Center(
                child: Text(
                  'No hay recomendaciones aún.\n¡Selecciona tus intereses!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.theme.hintColor,
                  ),
                ),
              );
            }
            return ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount:
                  recommended.length +
                  (widget.controller.hasMoreRecommended.value ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                if (index < recommended.length) {
                  final evento = recommended[index];
                  return _buildRecommendedCard(context, evento);
                } else {
                  return _buildLoadingIndicator();
                }
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context, dynamic evento) {
    return GestureDetector(
      onTap: () => Get.toNamed('/evento/${evento.id}'),
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: _getCategoryGradient(evento.categoria),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        _getCategoryIcon(evento.categoria),
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 60,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${evento.participantes.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evento.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: context.theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                evento.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.theme.hintColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            evento.categoria,
                            style: TextStyle(
                              color: context.theme.colorScheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (evento.schedule.isNotEmpty)
                          Text(
                            DateFormat(
                              'd MMM',
                              LocalizedApp.of(
                                context,
                              ).delegate.currentLocale.languageCode,
                            ).format(DateTime.parse(evento.schedule)),
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.theme.colorScheme.secondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'deportes':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'música':
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'cultura':
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'tecnología':
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'gastronomía':
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'aire libre':
        return const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'arte':
        return const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'educación':
        return const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'social':
        return const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'salud':
        return const LinearGradient(
          colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppGradients.primaryBtn;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'deportes':
        return Icons.sports_soccer_rounded;
      case 'música':
        return Icons.music_note_rounded;
      case 'cultura':
        return Icons.museum_rounded;
      case 'tecnología':
        return Icons.biotech_rounded;
      case 'gastronomía':
        return Icons.restaurant_rounded;
      case 'aire libre':
        return Icons.nature_people_rounded;
      case 'arte':
        return Icons.palette_rounded;
      case 'educación':
        return Icons.school_rounded;
      case 'social':
        return Icons.groups_rounded;
      case 'salud':
        return Icons.favorite_rounded;
      default:
        return Icons.event_rounded;
    }
  }
}
