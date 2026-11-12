import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:te_widgets/te_widgets.dart';

import 'google_places_client.dart';
import 'map_config.dart';
import 'openstreet_client.dart';
import 'place_autocomplete.dart';

/// Place search used by [TPlaceAutoComplete] and the location picker:
/// Google Places when an API key is available, OpenStreetMap otherwise.
class TPlaceSearch {
  TPlaceSearch({this.googleMapApiKey, this.config, this.limit = 5, this.onLoad});

  String? googleMapApiKey;
  TGooglePlacesConfig? config;
  int limit;

  /// Optional custom loader that replaces the built-in search.
  TLoadListener<TPlaceResult>? onLoad;

  final http.Client _client = http.Client();
  String? _autoSessionToken;

  String? get _apiKey => (googleMapApiKey?.isNotEmpty ?? false) ? googleMapApiKey : TMapConfig.googleMapApiKey;
  bool get _hasGoogle => _apiKey?.isNotEmpty ?? false;

  String _generateSessionToken() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;
    final hex = values.map((val) => val.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  Future<TLoadResult<TPlaceResult>> load(String query) async {
    if (query.trim().isEmpty) return const TLoadResult([], 0);
    if (onLoad != null) return onLoad!(TLoadOptions<TPlaceResult>(page: 1, itemsPerPage: limit, search: query));
    if (!_hasGoogle) return _nominatim(query);

    try {
      final client = TGoogleClient(client: _client, googleMapApiKey: _apiKey!);
      var token = config?.sessionToken;
      if (token == null || token.isEmpty) {
        _autoSessionToken ??= _generateSessionToken();
        token = _autoSessionToken;
      }
      final response = await client.autocomplete(
        query,
        config: (config ?? const TGooglePlacesConfig()).copyWith(sessionToken: token),
        fieldMasks: TGoogleClient.widgetAutocompleteFieldMasks,
      );
      final items = response.suggestions
          .map((s) {
            final p = s.placePrediction;
            if (p == null) return null;
            return TPlaceResult(address: p.text?.text ?? '', coordinates: '', latitude: 0.0, longitude: 0.0, placeId: p.placeId);
          })
          .whereType<TPlaceResult>()
          .take(limit)
          .toList();
      return TLoadResult(items, items.length);
    } catch (_) {
      return _nominatim(query);
    }
  }

  Future<List<TPlaceResult>> search(String query) async => (await load(query)).items;

  Future<TLoadResult<TPlaceResult>> _nominatim(String query) async {
    final results = await TOpenStreetMapClient(client: _client).search(query, limit: limit);
    return TLoadResult(results, results.length);
  }

  /// Returns [place] with coordinates filled in (fetching Google place details
  /// when needed), or null if they could not be resolved.
  Future<TPlaceResult?> resolve(TPlaceResult place) async {
    final needsDetails = _hasGoogle && (place.placeId?.isNotEmpty ?? false) && place.coordinates.isEmpty;
    if (!needsDetails) return place;

    try {
      final client = TGoogleClient(client: _client, googleMapApiKey: _apiKey!);
      final token = config?.sessionToken ?? _autoSessionToken;
      final response = await client.fetchPlaceDetails(place.placeId!, fields: TGoogleClient.defaultPlaceDetailsFields, sessionToken: token);
      if (config?.sessionToken == null || config!.sessionToken!.isEmpty) _autoSessionToken = null;

      final loc = response.location;
      if (loc == null) return null;
      return TPlaceResult(
        address: response.formattedAddress,
        coordinates: '${loc.latitude}, ${loc.longitude}',
        latitude: loc.latitude,
        longitude: loc.longitude,
        placeId: place.placeId,
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}
