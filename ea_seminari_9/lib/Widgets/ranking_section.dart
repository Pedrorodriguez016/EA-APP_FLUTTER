import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Models/usuario_progreso.dart';

class RankingSection extends StatelessWidget {
  final List<RankingUsuario> ranking;

  const RankingSection({super.key, required this.ranking});

  @override
  Widget build(BuildContext context) {
    if (ranking.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ranking.length,
      itemBuilder: (context, index) {
        final usuario = ranking[index];
        final isTop3 = index < 3;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: isTop3
                ? Border.all(
                    color: [Colors.amber, Colors.grey, Colors.brown][index],
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isTop3
                    ? [Colors.amber, Colors.grey, Colors.brown][index]
                    : context.theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${usuario.posicion}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isTop3
                        ? Colors.white
                        : context.theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            title: Text(
              usuario.usuario,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(usuario.nivel),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${usuario.puntos} pts',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '${usuario.insignias} ${translate('gamification.insignias_unit')}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
