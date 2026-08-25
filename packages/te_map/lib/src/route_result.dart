import 'package:latlong2/latlong.dart';

/// Represents the result of a route query between two points.
class TRouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final String? distanceText;
  final String? durationText;

  const TRouteResult({
    required this.points,
    required this.distanceMeters,
    this.durationSeconds = 0,
    this.distanceText,
    this.durationText,
  });

  /// Human-readable distance format (e.g. "12.4 km" or "850 m").
  String get formattedDistance {
    if (distanceText != null && distanceText!.isNotEmpty) return distanceText!;
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.toStringAsFixed(0)} m';
  }

  /// Human-readable duration format (e.g. "25 mins" or "1 hr 10 mins").
  String get formattedDuration {
    if (durationText != null && durationText!.isNotEmpty) return durationText!;
    final minutes = (durationSeconds / 60).round();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMins = minutes % 60;
      return remainingMins > 0 ? '$hours hr $remainingMins min' : '$hours hr';
    }
    return '$minutes min';
  }

  @override
  String toString() => 'TRouteResult(points: ${points.length}, distance: $formattedDistance, duration: $formattedDuration)';
}

/// Decodes an encoded Google polyline string into a list of [LatLng] coordinates.
List<LatLng> decodePolyline(String encoded) {
  final List<LatLng> polyline = [];
  int index = 0;
  final int len = encoded.length;
  int lat = 0;
  int lng = 0;

  while (index < len) {
    int b;
    int shift = 0;
    int result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    polyline.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return polyline;
}
