import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/eventos_controller.dart';

class CategoriesGrid extends StatelessWidget {
  final EventoController controller;

  const CategoriesGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Recomendados',
        'icon': Icons.stars_rounded,
        'color': context.theme.colorScheme.primary,
        'isSpecial': true,
      },
      {
        'title': 'Fútbol',
        'icon': Icons.sports_soccer_rounded,
        'color': const Color(0xFF6366F1),
      },
      {
        'title': 'Concierto Pop',
        'icon': Icons.music_note_rounded,
        'color': const Color(0xFFF43F5E),
      },
      {
        'title': 'Teatro',
        'icon': Icons.theater_comedy_rounded,
        'color': const Color(0xFF0EA5E9),
      },
      {
        'title': 'Exposición Arte',
        'icon': Icons.palette_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Restaurante',
        'icon': Icons.restaurant_rounded,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Curso',
        'icon': Icons.school_rounded,
        'color': const Color(0xFF64748B),
      },
      {
        'title': 'Gaming',
        'icon': Icons.sports_esports_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Discoteca',
        'icon': Icons.nightlife_rounded,
        'color': const Color(0xFFD946EF),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              translate('events.categories'),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            TextButton.icon(
              onPressed: () => controller.showFilterSheet(context),
              icon: Icon(
                Icons.tune_rounded,
                size: 18,
                color: context.theme.colorScheme.primary,
              ),
              label: Text(
                translate('events.filters'),
                style: TextStyle(
                  color: context.theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final title = cat['title'] as String;
            return _buildCategoryCard(
              context,
              title,
              cat['icon'] as IconData,
              cat['color'] as Color,
              isSpecial: cat['isSpecial'] as bool? ?? false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    bool isSpecial = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isSpecial) {
              controller.showRecommendedOnly();
            } else {
              controller.searchEditingController.clear();
              controller.filterCategory.value = title;
              controller.isSearching.value = true;
              controller.fetchEventos(1);
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
