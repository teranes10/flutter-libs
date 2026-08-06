import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:te_widgets/te_widgets.dart';

class TPlaceResult {
  final String address;
  final String coordinates;
  final double latitude;
  final double longitude;
  final String? placeId;

  const TPlaceResult({
    required this.address,
    required this.coordinates,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  @override
  String toString() => address;
}

class TPlaceAutoComplete extends StatefulWidget {
  final ValueChanged<TPlaceResult> onPlaceSelected;
  final String? googleMapApiKey;
  final TLoadListener<TPlaceResult>? onLoad;
  final String? label;
  final String? placeholder;
  final TLabelPosition? labelPosition;
  final int limit;
  final TGooglePlacesConfig? config;

  const TPlaceAutoComplete({
    super.key,
    required this.onPlaceSelected,
    this.googleMapApiKey,
    this.onLoad,
    this.limit = 5,
    this.label,
    this.placeholder,
    this.labelPosition = TLabelPosition.aboveField,
    this.config,
  });

  @override
  State<TPlaceAutoComplete> createState() => _TPlaceAutoCompleteState();
}

class _TMapConfigTemp {
  static String? get googleMapApiKey => TMapConfig.googleMapApiKey;
}

class _TPlaceAutoCompleteState extends State<TPlaceAutoComplete> {
  final Dio _dio = Dio();
  TPlaceResult? _selectedPlace;
  String? _autoSessionToken;

  String? _resolveApiKey() {
    if (widget.googleMapApiKey != null && widget.googleMapApiKey!.isNotEmpty) {
      return widget.googleMapApiKey;
    }
    return _TMapConfigTemp.googleMapApiKey;
  }

  String _generateSessionToken() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    // Set version (4) and variant (10xx)
    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;
    final hex = values.map((val) => val.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  Future<TLoadResult<TPlaceResult>> _loadGooglePlaces(String query) async {
    if (query.isBlank) return const TLoadResult([], 0);

    final apiKey = _resolveApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return _loadNominatimPlaces(query);
    }

    try {
      final client = TGoogleClient(dio: _dio, googleMapApiKey: apiKey);

      String? token = widget.config?.sessionToken;
      if (token == null || token.isEmpty) {
        _autoSessionToken ??= _generateSessionToken();
        token = _autoSessionToken;
      }

      final config = (widget.config ?? const TGooglePlacesConfig()).copyWith(
        sessionToken: token,
      );

      final response = await client.autocomplete(
        query,
        config: config,
        fieldMasks: TGoogleClient.widgetAutocompleteFieldMasks,
      );

      final items = response.suggestions
          .map((s) {
            final p = s.placePrediction;
            if (p == null) return null;
            return TPlaceResult(
              address: p.text?.text ?? '',
              coordinates: '',
              latitude: 0.0,
              longitude: 0.0,
              placeId: p.placeId,
            );
          })
          .whereType<TPlaceResult>()
          .take(widget.limit)
          .toList();

      return TLoadResult(items, items.length);
    } catch (_) {
      return _loadNominatimPlaces(query);
    }
  }

  Future<TLoadResult<TPlaceResult>> _loadNominatimPlaces(String query) async {
    if (query.isEmpty) return const TLoadResult([], 0);

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'limit': widget.limit.toString(),
        },
        options: Options(
          headers: {
            'User-Agent': 'te_widgets_map_autocomplete',
          },
        ),
      );

      if (response.data is List) {
        final List data = response.data;
        final items = data.map((item) {
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
        return TLoadResult(items, items.length);
      }
    } catch (_) {}
    return const TLoadResult([], 0);
  }

  Future<void> _fetchPlaceDetails(String placeId) async {
    final apiKey = _resolveApiKey();
    if (apiKey == null || apiKey.isEmpty) return;

    try {
      final client = TGoogleClient(dio: _dio, googleMapApiKey: apiKey);
      final token = widget.config?.sessionToken ?? _autoSessionToken;

      final response = await client.fetchPlaceDetails(
        placeId,
        fields: TGoogleClient.defaultPlaceDetailsFields,
        sessionToken: token,
      );

      if (widget.config?.sessionToken == null || widget.config!.sessionToken!.isEmpty) {
        setState(() {
          _autoSessionToken = null;
        });
      }

      final loc = response.location;
      final address = response.formattedAddress;

      if (loc != null) {
        final placeResult = TPlaceResult(
          address: address,
          coordinates: '${loc.latitude}, ${loc.longitude}',
          latitude: loc.latitude,
          longitude: loc.longitude,
          placeId: placeId,
        );
        setState(() {
          _selectedPlace = placeResult;
        });
        widget.onPlaceSelected(placeResult);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = _resolveApiKey();
    final hasGoogle = apiKey != null && apiKey.isNotEmpty;

    return TSelect<TPlaceResult, TPlaceResult, String>(
      theme: context.theme.textFieldTheme.copyWith(labelPosition: widget.labelPosition),
      value: _selectedPlace,
      label: widget.label,
      placeholder: widget.placeholder ?? 'Search location...',
      onLoad: widget.onLoad ?? (options) => _loadGooglePlaces(options.search ?? ''),
      itemText: (item) => item.address,
      onValueChanged: (val) async {
        if (val == null) return;

        if (hasGoogle && val.placeId != null && val.placeId!.isNotEmpty && val.coordinates.isEmpty) {
          await _fetchPlaceDetails(val.placeId!);
        } else {
          setState(() {
            _selectedPlace = val;
          });
          widget.onPlaceSelected(val);
        }
      },
    );
  }
}
