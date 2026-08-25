import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'place_autocomplete.dart';
import 'route_result.dart';

/// Client to interact with Nominatim and OSRM OpenStreetMap APIs.
class TOpenStreetMapClient {
  final Dio _dio;

  TOpenStreetMapClient({Dio? dio}) : _dio = dio ?? Dio();

  /// Reverse-geocode lat/lng to a formatted address.
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'format': 'json',
          'addressdetails': '1',
        },
        options: Options(
          headers: {'User-Agent': 'te_widgets_map_pinning'},
        ),
      );
      final data = response.data;
      if (data is Map) {
        final address = data['display_name']?.toString().trim();
        if (address != null && address.isNotEmpty) return address;
      }
    } catch (_) {}
    return null;
  }

  /// Search for places using Nominatim.
  Future<List<TPlaceResult>> search(String query, {int limit = 5}) async {
    if (query.isEmpty) return [];

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'limit': limit.toString(),
        },
        options: Options(headers: {'User-Agent': 'te_widgets_map_autocomplete'}),
      );

      if (response.data is List) {
        final List data = response.data;
        return data.map((item) {
          final latVal = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
          final lonVal = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
          return TPlaceResult(
            address: item['display_name']?.toString() ?? '',
            coordinates: '$latVal, $lonVal',
            latitude: latVal,
            longitude: lonVal,
            placeId: item['place_id']?.toString() ?? '',
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Fetches the best driving route between [origin] and [destination] using OSRM.
  Future<TRouteResult?> fetchRoute(LatLng origin, LatLng destination) async {
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';
      final response = await _dio.get(
        url,
        queryParameters: {
          'overview': 'full',
          'geometries': 'geojson',
        },
        options: Options(headers: {'User-Agent': 'te_widgets_map_routing'}),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      if (data['code']?.toString() != 'Ok') return null;

      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final firstRoute = routes.first as Map<String, dynamic>;
      final geometry = firstRoute['geometry'] as Map<String, dynamic>?;
      final coordinates = geometry?['coordinates'] as List<dynamic>?;

      final List<LatLng> points = [];
      if (coordinates != null) {
        for (final coord in coordinates) {
          if (coord is List && coord.length >= 2) {
            final lng = double.tryParse(coord[0].toString()) ?? 0.0;
            final lat = double.tryParse(coord[1].toString()) ?? 0.0;
            points.add(LatLng(lat, lng));
          }
        }
      }

      final distanceMeters = double.tryParse(firstRoute['distance']?.toString() ?? '') ?? 0.0;
      final durationSeconds = double.tryParse(firstRoute['duration']?.toString() ?? '') ?? 0.0;

      return TRouteResult(
        points: points.isNotEmpty ? points : [origin, destination],
        distanceMeters: distanceMeters,
        durationSeconds: durationSeconds,
      );
    } catch (_) {
      // Fallback straight line distance using Haversine Distance
      const distanceCalc = Distance();
      final meters = distanceCalc.as(LengthUnit.Meter, origin, destination);
      return TRouteResult(
        points: [origin, destination],
        distanceMeters: meters.toDouble(),
      );
    }
  }
}
