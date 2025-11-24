import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMap extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final double height;
  final List<LatLng> markers;

  const CustomMap({
    Key? key,
    // Coordenada por defecto (Ej: Madrid centro). 
    // Cuando tu API funcione, esto se sobrescribirá.
    this.center = const LatLng(40.4168, -3.7038), 
    this.zoom = 13.0,
    this.height = 150.0,
    // Por defecto la lista está vacía, así que no pintará nada
    this.markers = const [], 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tu_app.nombre',
            ),
            // Solo dibuja marcadores si la lista NO está vacía
            if (markers.isNotEmpty)
              MarkerLayer(
                markers: markers.map((point) {
                  return Marker(
                    point: point,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}