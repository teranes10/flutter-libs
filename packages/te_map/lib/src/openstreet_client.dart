import 'package:dio/dio.dart';
import 'place_autocomplete.dart';

/// Client to interact with Nominatim OpenStreetMap API.
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
}
