import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class MapSamplePage extends StatefulWidget {
  const MapSamplePage({super.key});

  @override
  State<MapSamplePage> createState() => _MapSamplePageState();
}

class _MapSamplePageState extends State<MapSamplePage> {
  var _coordinates = LatLng(6.9142, 79.8610);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final pins = [
      // 1. Asset taxi pin with label D001
      const TMapPin(coordinates: LatLng(9.663746, 80.005974), label: "D001", assetPath: "assets/taxi-24.png"),
      // 2. Polyline label marker
      const TMapPin(coordinates: LatLng(9.662800, 80.006800), label: "Route 1", icon: Icons.navigation_outlined),
      // 3. Polygon area label marker
      const TMapPin(coordinates: LatLng(9.664500, 80.004500), label: "Zone A", icon: Icons.crop_free_rounded),
      // 4. Custom Builder Pin with Custom Info Window
      TMapPin(
        coordinates: const LatLng(9.663033, 80.005747),
        customBuilder: (context) => Container(
          decoration: BoxDecoration(
            color: colors.error,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: const Padding(
            padding: EdgeInsets.all(6.0),
            child: Icon(Icons.restaurant, color: Colors.white, size: 16),
          ),
        ),
        infoWindowBuilder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, size: 14, color: colors.primary),
                const SizedBox(width: 6),
                const Text("Premium Diner", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            const Text("Experience the best culinary delights in town.", style: TextStyle(fontSize: 11)),
            const SizedBox(height: 6),
            TButton(
              size: TButtonSize.xs,
              text: "Order Now",
              onTap: () {
                TToastService.info(context, "Redirecting to order menu...");
              },
            ),
          ],
        ),
      ),
    ];

    final samplePolylines = [
      TMapPolyline(
        points: [
          const LatLng(9.662822, 80.006714),
          const LatLng(9.663150, 80.007084),
          const LatLng(9.664398, 80.007540),
          const LatLng(9.663774, 80.008860),
          const LatLng(9.663615, 80.010206),
        ],
        color: colors.primary,
        strokeWidth: 4.0,
      ),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Interactive TMap & Pinning Demos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              "Demonstrating customized markers, custom builders, custom info window content, and address pinning.",
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // Card 1: Generic Map with multiple custom pins, polylines, and polygons
            TCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Generic Multi-Pin Map with Paths & Regions",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "This map displays multiple pins, a polyline route (Route 1), and a polygon area (Zone A). Tap on the pins to view default or custom info windows.",
                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  TMap(zoom: 16, height: 380, interactive: true, pins: pins, polylines: samplePolylines),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card 2: Map Pinning Form Input Widget
            TCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Map Pinning Input Field Integration",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Select address to automatically sync coordinates on map. Manual pin adjustments do not shift map zoom center.",
                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  TMapPinning(
                    label: "Pin Business Address",
                    isRequired: true,
                    initialCoordinates: _coordinates,
                    onCoordinatesChanged: (coords) {
                      setState(() {
                        _coordinates = coords;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
