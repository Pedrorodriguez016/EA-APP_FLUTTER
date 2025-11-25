import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Exporta PositionCallback
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';

class CustomMap extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final double? height; 
  final bool enableExpansion; 
  final List<Marker> markers; // <--- Ya lo tenías
  
  // 1. AGREGAMOS EL CALLBACK AQUÍ
  final void Function(MapPosition position, bool hasGesture)? onPositionChanged; 

  const CustomMap({
    Key? key,
    this.center = const LatLng(41.3851, 2.1734),
    this.zoom = 13.0,
    this.height, 
    this.enableExpansion = false, 
    this.markers = const [],
    this.onPositionChanged, // 2. LO AGREGAMOS AL CONSTRUCTOR
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapWidget = FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all, 
        ),
        // 3. LO CONECTAMOS AL MAPA
        onPositionChanged: (camera, hasGesture) {
          if (onPositionChanged != null) {
            onPositionChanged!(camera, hasGesture);
          }
        } 
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.tu_app.eventos',
        ),
        // Lógica de marcadores (la mantenemos igual)
        if (markers.isNotEmpty)
          MarkerLayer(markers: markers)
        else
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
      ],
    );

    Widget content = height != null
        ? Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: mapWidget,
            ),
          )
        : mapWidget;

    if (!enableExpansion) return content;

    return Stack(
      children: [
        content,
        Positioned(
          right: 8,
          bottom: 8,
          child: Material(
            color: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => _openExpandedMap(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.open_in_full,
                  size: 20,
                  color: Colors.indigo.shade800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openExpandedMap() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: CustomMap(
                center: center,
                zoom: 15.0,
                markers: markers,
                enableExpansion: false,
                // 4. PASAMOS EL CALLBACK TAMBIÉN AL MAPA EXPANDIDO
                // (Para que cargue eventos si te mueves en el mapa grande)
                onPositionChanged: onPositionChanged, 
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }
}