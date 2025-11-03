import 'package:flutter/material.dart';
import '../Models/eventos.dart';
import 'package:get/get.dart';
import '../Screen/eventos_detail.dart';

class EventosCard extends StatelessWidget {
  final Evento evento;

  const EventosCard({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(evento.name),
        subtitle: Text('${evento.schedule}\n${evento.address}'),
        isThreeLine: true,
        onTap: () {
          // 👇 Al tocar la tarjeta, abre la pantalla de detalles
          Get.to(() => EventosDetailScreen(eventoId: evento.id));
        },
      ),
      
    );
  }
}
