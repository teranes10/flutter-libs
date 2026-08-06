import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:te_widgets/te_widgets.dart';

class TMapConfig {
  /// Global Google Maps API Key fallback.
  static String? googleMapApiKey;
  static LatLng mapCenter = LatLng(9.663812, 80.006043);
}

class TMapPin {
  final LatLng coordinates;
  final String? label;
  final Color? labelColor;
  final IconData? icon;
  final Color? iconColor;
  final String? assetPath;
  final Alignment? alignment;
  final Widget? Function(BuildContext)? customBuilder;
  final Widget? Function(BuildContext)? infoWindowBuilder;

  const TMapPin({
    required this.coordinates,
    this.label,
    this.labelColor,
    this.icon,
    this.iconColor,
    this.assetPath,
    this.alignment,
    this.customBuilder,
    this.infoWindowBuilder,
  });
}

class TMapPolyline {
  final List<LatLng> points;
  final Color color;
  final double strokeWidth;

  const TMapPolyline({
    required this.points,
    this.color = Colors.blue,
    this.strokeWidth = 3.0,
  });
}

class TMapPolygon {
  final List<LatLng> points;
  final Color color;
  final Color? borderColor;
  final double borderWidth;

  const TMapPolygon({
    required this.points,
    this.color = const Color(0x332196F3),
    this.borderColor = Colors.blue,
    this.borderWidth = 1.0,
  });
}

enum MapTileType { google, osm, satellite }

Widget buildTileLayer({
  required MapTileType mapType,
  required bool darkMode,
  String lang = 'en',
  String country = 'Us',
  int keepBuffer = 5,
  String packageName = 'com.te_widgets.app',
}) {
  TileLayer tileLayer;

  switch (mapType) {
    case MapTileType.osm:
      tileLayer = TileLayer(
        urlTemplate: 'https://{s}.basemaps.cartocdn.com/{style}/{z}/{x}/{y}{scale}.png',
        subdomains: const ['a', 'b', 'c', 'd'],
        additionalOptions: {
          'style': darkMode ? 'dark_all' : 'light_all',
          'scale': '@2x',
        },
        userAgentPackageName: packageName,
        keepBuffer: keepBuffer,
      );
      if (darkMode) {
        return RepaintBoundary(
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              // dart format:off
              1.1, 0, 0, 0, 2,
              0, 1.3, 0, 0, 0,
              0, 0, 1.4, 0, 4,
              0, 0, 0, 1, 0,
            ]),
            child: tileLayer,
          ),
        );
      } else {
        return RepaintBoundary(
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              // dart format:off
              1.02, 0, 0, 0, 1,
              0, 1.06, 0, 0, -4,
              0, 0, 1.07, 0, -2,
              0, 0, 0, 1, 0,
            ]),
            child: tileLayer,
          ),
        );
      }
      break;

    case MapTileType.google:
      tileLayer = TileLayer(
        urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m@221097000&hl={hl}&gl={gl}&x={x}&y={y}&z={z}',
        subdomains: const ['0', '1', '2', '3'],
        additionalOptions: {
          'userAgent': packageName,
          'hl': lang,
          'gl': country,
        },
        keepBuffer: keepBuffer,
      );
      if (darkMode) {
        return RepaintBoundary(
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              -0.2,
              -0.5,
              -0.3,
              0,
              255,
              -0.3,
              -0.5,
              -0.2,
              0,
              255,
              -0.3,
              -0.2,
              -0.5,
              0,
              255,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: tileLayer,
          ),
        );
      }
      break;

    case MapTileType.satellite:
      tileLayer = TileLayer(
        urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        keepBuffer: keepBuffer,
      );
      break;
  }

  return RepaintBoundary(child: tileLayer);
}
