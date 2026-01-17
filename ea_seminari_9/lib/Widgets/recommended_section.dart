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
    final cat = category.toLowerCase();

    if (cat.contains('fútbol') ||
        cat.contains('baloncesto') ||
        cat.contains('tenis') ||
        cat.contains('pádel') ||
        cat.contains('running') ||
        cat.contains('ciclismo') ||
        cat.contains('natación') ||
        cat.contains('senderismo') ||
        cat.contains('escalada') ||
        cat.contains('artes marciales') ||
        cat.contains('bolos') ||
        cat.contains('paintball') ||
        cat.contains('laser tag') ||
        cat.contains('deporte')) {
      return const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (cat.contains('concierto') ||
        cat.contains('jazz') ||
        cat.contains('electrónica') ||
        cat.contains('hip hop') ||
        cat.contains('karaoke') ||
        cat.contains('discoteca') ||
        cat.contains('festival') ||
        cat.contains('ópera') ||
        cat.contains('música')) {
      return const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (cat.contains('teatro') ||
        cat.contains('cine') ||
        cat.contains('literatura') ||
        cat.contains('danza') ||
        cat.contains('turismo') ||
        cat.contains('excursión') ||
        cat.contains('cultura')) {
      return const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (cat.contains('gaming') ||
        cat.contains('esports') ||
        cat.contains('programación') ||
        cat.contains('inteligencia artificial') ||
        cat.contains('blockchain') ||
        cat.contains('startups') ||
        cat.contains('hackathon') ||
        cat.contains('meetup tech') ||
        cat.contains('tecnología')) {
      return const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (cat.contains('restaurante') ||
        cat.contains('tapas') ||
        cat.contains('cocina') ||
        cat.contains('vinos') ||
        cat.contains('cerveza') ||
        cat.contains('repostería') ||
        cat.contains('brunch') ||
        cat.contains('food truck') ||
        cat.contains('barbacoa') ||
        cat.contains('picnic') ||
        cat.contains('gastronomía')) {
      return const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (cat.contains('arte') ||
        cat.contains('museo') ||
        cat.contains('fotografía') ||
        cat.contains('pintura') ||
        cat.contains('escultura')) {
      return const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (cat.contains('yoga') ||
        cat.contains('gimnasio') ||
        cat.contains('meditación') ||
        cat.contains('spa') ||
        cat.contains('wellness') ||
        cat.contains('mindfulness') ||
        cat.contains('salud')) {
      return const LinearGradient(
        colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (cat.contains('taller') ||
        cat.contains('curso') ||
        cat.contains('conferencia') ||
        cat.contains('seminario') ||
        cat.contains('workshop') ||
        cat.contains('idiomas') ||
        cat.contains('masterclass') ||
        cat.contains('educación')) {
      return const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (cat.contains('fiesta') ||
        cat.contains('cumpleaños') ||
        cat.contains('boda') ||
        cat.contains('despedida') ||
        cat.contains('after work') ||
        cat.contains('networking') ||
        cat.contains('speed dating') ||
        cat.contains('evento familiar') ||
        cat.contains('social')) {
      return const LinearGradient(
        colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (cat.contains('aire libre')) {
      return const LinearGradient(
        colors: [Color(0xFF059669), Color(0xFF065F46)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return AppGradients.primaryBtn;
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();

    if (cat.contains('fútbol')) return Icons.sports_soccer_rounded;
    if (cat.contains('baloncesto')) return Icons.sports_basketball_rounded;
    if (cat.contains('tenis')) return Icons.sports_tennis_rounded;
    if (cat.contains('pádel')) return Icons.sports_tennis_rounded;
    if (cat.contains('running')) return Icons.directions_run_rounded;
    if (cat.contains('ciclismo')) return Icons.directions_bike_rounded;
    if (cat.contains('natación')) return Icons.pool_rounded;
    if (cat.contains('gimnasio') || cat.contains('yoga'))
      return Icons.fitness_center_rounded;
    if (cat.contains('senderismo') || cat.contains('montañismo'))
      return Icons.hiking_rounded;
    if (cat.contains('escalada')) return Icons.terrain_rounded;
    if (cat.contains('deporte')) return Icons.sports_rounded;

    if (cat.contains('concierto') || cat.contains('festival'))
      return Icons.music_note_rounded;
    if (cat.contains('jazz') || cat.contains('electrónica'))
      return Icons.speaker_group_rounded;
    if (cat.contains('karaoke')) return Icons.mic_rounded;
    if (cat.contains('discoteca')) return Icons.nightlife_rounded;
    if (cat.contains('música')) return Icons.music_note_rounded;

    if (cat.contains('teatro') || cat.contains('cine'))
      return Icons.theater_comedy_rounded;
    if (cat.contains('literatura')) return Icons.auto_stories_rounded;
    if (cat.contains('fotografía')) return Icons.camera_alt_rounded;
    if (cat.contains('pintura') ||
        cat.contains('arte') ||
        cat.contains('museo'))
      return Icons.palette_rounded;
    if (cat.contains('cultura')) return Icons.museum_rounded;

    if (cat.contains('gaming') || cat.contains('esports'))
      return Icons.sports_esports_rounded;
    if (cat.contains('programación') ||
        cat.contains('hackathon') ||
        cat.contains('tech'))
      return Icons.computer_rounded;
    if (cat.contains('tecnología')) return Icons.biotech_rounded;

    if (cat.contains('restaurante') ||
        cat.contains('tapas') ||
        cat.contains('cocina'))
      return Icons.restaurant_rounded;
    if (cat.contains('vinos') || cat.contains('cerveza') || cat.contains('bar'))
      return Icons.local_bar_rounded;
    if (cat.contains('café') ||
        cat.contains('brunch') ||
        cat.contains('repostería'))
      return Icons.local_cafe_rounded;
    if (cat.contains('barbacoa') || cat.contains('picnic'))
      return Icons.outdoor_grill_rounded;
    if (cat.contains('gastronomía')) return Icons.restaurant_rounded;

    if (cat.contains('curso') ||
        cat.contains('taller') ||
        cat.contains('clase'))
      return Icons.school_rounded;
    if (cat.contains('conferencia') || cat.contains('seminario'))
      return Icons.campaign_rounded;
    if (cat.contains('educación')) return Icons.school_rounded;

    if (cat.contains('fiesta') || cat.contains('cumpleaños'))
      return Icons.celebration_rounded;
    if (cat.contains('boda')) return Icons.favorite_rounded;
    if (cat.contains('viaje') ||
        cat.contains('turismo') ||
        cat.contains('excursión'))
      return Icons.flight_rounded;
    if (cat.contains('camping')) return Icons.cabin_rounded;
    if (cat.contains('playa')) return Icons.beach_access_rounded;
    if (cat.contains('safari') || cat.contains('animal'))
      return Icons.pets_rounded;

    if (cat.contains('social')) return Icons.groups_rounded;

    if (cat.contains('juegos de mesa') ||
        cat.contains('ajedrez') ||
        cat.contains('poker'))
      return Icons.casino_rounded;
    if (cat.contains('compras') || cat.contains('mercadillo'))
      return Icons.shopping_bag_rounded;

    if (cat.contains('aire libre')) return Icons.nature_people_rounded;
    if (cat.contains('salud')) return Icons.favorite_rounded;

    return Icons.event_rounded;
  }
}
