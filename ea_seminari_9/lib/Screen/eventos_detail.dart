import 'package:flutter/material.dart';
import '../Models/eventos.dart';
import '../Services/eventos_services.dart';

class EventosDetailScreen extends StatelessWidget {
  final String eventoId;
  final EventosService service = EventosService();

  EventosDetailScreen({super.key, required this.eventoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Evento'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Evento>(
        future: service.getEventoById(eventoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Evento no encontrado'));
          }
             final evento = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Icon(Icons.event, size: 100, color: Colors.deepPurple),
                ),
                const SizedBox(height: 20),
                Text(' ${evento.name}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Direccion: ${evento.address}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Fecha ${evento.schedule}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Participantes: ${evento.apuntados.length}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
