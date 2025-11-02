import 'package:flutter/material.dart';
import '../Models/eventos.dart';

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
      ),
    );
  }
}
