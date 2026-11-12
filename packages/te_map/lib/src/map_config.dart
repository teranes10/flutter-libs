import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'google_places_client.dart';

class TMapConfig {
  /// Global Google Maps API Key fallback.
  static String? googleMapApiKey;

  /// Global defaults for Places autocomplete / details / geocoding (language, region, country filter, bias...).
  /// Per-widget `config` values override these. Example:
  /// `TMapConfig.placesConfig = TGooglePlacesConfig(languageCode: 'en', regionCode: 'lk', includedRegionCodes: ['lk']);`
  static TGooglePlacesConfig placesConfig = const TGooglePlacesConfig();

  /// Google Places API (New) base, e.g. point at a proxy to hide the key.
  static String placesApiBase = 'https://places.googleapis.com/v1';

  /// Google Maps web-service base (Geocoding / Directions).
  static String mapsApiBase = 'https://maps.googleapis.com/maps/api';

  /// Tile url for [MapTileType.osm]. Defaults to the keyless OSM server (CARTO now requires an API key).
  /// Placeholders: {z} {x} {y}, plus {s} (see [osmSubdomains]), {style} (dark_all/light_all) and {scale} (@2x).
  /// Set this to a keyed provider (MapTiler, Stadia, CARTO...) if needed.
  static String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static List<String> osmSubdomains = const [];

  /// Tile type used when a map doesn't set `mapType`. Defaults to google when [googleMapApiKey] is set, else osm.
  static MapTileType? mapType;
  static MapTileType get defaultMapType =>
      mapType ?? ((googleMapApiKey?.isNotEmpty ?? false) ? MapTileType.google : MapTileType.osm);

  static LatLng mapCenter = LatLng(9.663812, 80.006043);
}

class TMapPin {
  final LatLng coordinates;
  final String? label;
  final Color? labelColor;
  final dynamic icon;
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

  const TMapPolyline({required this.points, this.color = Colors.blue, this.strokeWidth = 3.0});
}

class TMapPolygon {
  final List<LatLng> points;
  final Color color;
  final Color? borderColor;
  final double borderWidth;

  const TMapPolygon({required this.points, this.color = const Color(0x332196F3), this.borderColor = Colors.blue, this.borderWidth = 1.0});
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
        urlTemplate: TMapConfig.osmTileUrl,
        subdomains: TMapConfig.osmSubdomains.isEmpty ? const ['a', 'b', 'c'] : TMapConfig.osmSubdomains,
        additionalOptions: {'style': darkMode ? 'dark_all' : 'light_all', 'scale': '@2x'},
        userAgentPackageName: packageName,
        keepBuffer: keepBuffer,
      );
      if (darkMode) {
        return RepaintBoundary(
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              // dart format:off
              -0.6, -0.3, -0.1, 0, 235,
              -0.2, -0.7, -0.1, 0, 235,
              -0.2, -0.3, -0.5, 0, 240,
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
              1, 0, 0, 0, 0,
              0, 1, 0, 0, 0,
              0, 0, 1, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            child: tileLayer,
          ),
        );
      }

    case MapTileType.google:
      tileLayer = TileLayer(
        urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m@221097000&hl={hl}&gl={gl}&x={x}&y={y}&z={z}',
        subdomains: const ['0', '1', '2', '3'],
        additionalOptions: {'userAgent': packageName, 'hl': lang, 'gl': country},
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
