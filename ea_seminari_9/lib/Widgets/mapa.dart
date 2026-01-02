import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';

class CustomMap extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final double? height;
  final bool enableExpansion;
  final List<Marker> markers;

  final void Function(MapPosition position, bool hasGesture)? onPositionChanged;

  const CustomMap({
    Key? key,
    this.center = const LatLng(41.3851, 2.1734),
    this.zoom = 13.0,
    this.height,
    this.enableExpansion = false,
    this.markers = const [],
    this.onPositionChanged,
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
        // Usamos onMapEvent que se ejecuta también en la carga inicial
        onMapEvent: (MapEvent event) {
          if (onPositionChanged != null) {
            // Obtener los bounds de la cámara actual
            final bounds = event.camera.visibleBounds;
            onPositionChanged!(
              MapPosition(
                bounds: bounds,
                center: event.camera.center,
                zoom: event.camera.zoom,
              ),
              event is MapEventMove || event is MapEventRotate,
            );
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.tu_app.eventos',
        ),
        // Solo mostrar marcadores de eventos cuando existan
        if (markers.isNotEmpty) MarkerLayer(markers: markers),
      ],
    );

    Widget content = height != null
        ? Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: mapWidget,
            ),
          )
        : mapWidget;

    if (!enableExpansion) return content;

    return Stack(
      children: [
        content,
        Positioned(
          right: 12,
          bottom: 12,
          child: Material(
            color: context.theme.cardColor,
            elevation: 4,
            shape: const CircleBorder(),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => _openExpandedMap(context),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.open_in_full_rounded,
                  size: 22,
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openExpandedMap(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: context.theme.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: CustomMap(
                  center: center,
                  zoom: 15.0,
                  markers: markers,
                  enableExpansion: false,
                  onPositionChanged: onPositionChanged,
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }
}