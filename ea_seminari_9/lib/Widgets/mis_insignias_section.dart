import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Models/insignia.dart';

class MisInsigniasSection extends StatelessWidget {
  final List<Insignia> insignias;

  const MisInsigniasSection({super.key, required this.insignias});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis Insignias (${insignias.length})',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (insignias.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Aún no has desbloqueado insignias'),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: insignias.map((insignia) {
              return Container(
                width: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(insignia.icono, style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text(
                      insignia.nombre,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
