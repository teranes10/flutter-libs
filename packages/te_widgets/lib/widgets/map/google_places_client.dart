import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:te_widgets/widgets/map/map_config.dart';

/// Circle defining location bias or restriction.
class TGoogleCircle {
  final LatLng center;
  final double radius;

  const TGoogleCircle({required this.center, required this.radius});

  Map<String, dynamic> toJson() => {
        'center': {
          'latitude': center.latitude,
          'longitude': center.longitude,
        },
        'radius': radius,
      };

  factory TGoogleCircle.fromJson(Map<String, dynamic> json) {
    final centerJson = json['center'] as Map<String, dynamic>;
    return TGoogleCircle(
      center: LatLng(
        double.parse(centerJson['latitude'].toString()),
        double.parse(centerJson['longitude'].toString()),
      ),
      radius: double.parse(json['radius'].toString()),
    );
  }
}

/// Rectangle defining location bias or restriction.
class TGoogleRectangle {
  final LatLng low;
  final LatLng high;

  const TGoogleRectangle({required this.low, required this.high});

  Map<String, dynamic> toJson() => {
        'low': {
          'latitude': low.latitude,
          'longitude': low.longitude,
        },
        'high': {
          'latitude': high.latitude,
          'longitude': high.longitude,
        },
      };

  factory TGoogleRectangle.fromJson(Map<String, dynamic> json) {
    final lowJson = json['low'] as Map<String, dynamic>;
    final highJson = json['high'] as Map<String, dynamic>;
    return TGoogleRectangle(
      low: LatLng(
        double.parse(lowJson['latitude'].toString()),
        double.parse(lowJson['longitude'].toString()),
      ),
      high: LatLng(
        double.parse(highJson['latitude'].toString()),
        double.parse(highJson['longitude'].toString()),
      ),
    );
  }
}

/// Location bias for Google Places API.
class TGoogleLocationBias {
  final TGoogleCircle? circle;
  final TGoogleRectangle? rectangle;

  const TGoogleLocationBias({this.circle, this.rectangle});

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};
    if (circle != null) val['circle'] = circle!.toJson();
    if (rectangle != null) val['rectangle'] = rectangle!.toJson();
    return val;
  }

  factory TGoogleLocationBias.fromJson(Map<String, dynamic> json) {
    return TGoogleLocationBias(
      circle: json['circle'] != null
          ? TGoogleCircle.fromJson(json['circle'] as Map<String, dynamic>)
          : null,
      rectangle: json['rectangle'] != null
          ? TGoogleRectangle.fromJson(json['rectangle'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Location restriction for Google Places API.
class TGoogleLocationRestriction {
  final TGoogleCircle? circle;
  final TGoogleRectangle? rectangle;

  const TGoogleLocationRestriction({this.circle, this.rectangle});

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};
    if (circle != null) val['circle'] = circle!.toJson();
    if (rectangle != null) val['rectangle'] = rectangle!.toJson();
    return val;
  }

  factory TGoogleLocationRestriction.fromJson(Map<String, dynamic> json) {
    return TGoogleLocationRestriction(
      circle: json['circle'] != null
          ? TGoogleCircle.fromJson(json['circle'] as Map<String, dynamic>)
          : null,
      rectangle: json['rectangle'] != null
          ? TGoogleRectangle.fromJson(json['rectangle'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Request configuration for Google Places Autocomplete API.
class TGooglePlacesConfig {
  final String? languageCode;
  final String? regionCode;
  final LatLng? origin;
  final TGoogleLocationBias? locationBias;
  final TGoogleLocationRestriction? locationRestriction;
  final List<String>? includedPrimaryTypes;
  final bool? includeQueryPredictions;
  final int? inputOffset;
  final bool? includeFutureOpeningBusinesses;
  final bool? includePureServiceAreaBusinesses;
  final String? sessionToken;

  const TGooglePlacesConfig({
    this.languageCode,
    this.regionCode,
    this.origin,
    this.locationBias,
    this.locationRestriction,
    this.includedPrimaryTypes,
    this.includeQueryPredictions,
    this.inputOffset,
    this.includeFutureOpeningBusinesses,
    this.includePureServiceAreaBusinesses,
    this.sessionToken,
  });

  Map<String, dynamic> toJson(String input) {
    final data = <String, dynamic>{
      'input': input,
    };
    if (languageCode != null) data['languageCode'] = languageCode;
    if (regionCode != null) data['regionCode'] = regionCode;
    if (origin != null) {
      data['origin'] = {
        'latitude': origin!.latitude,
        'longitude': origin!.longitude,
      };
    }
    if (locationBias != null) data['locationBias'] = locationBias!.toJson();
    if (locationRestriction != null) {
      data['locationRestriction'] = locationRestriction!.toJson();
    }
    if (includedPrimaryTypes != null) {
      data['includedPrimaryTypes'] = includedPrimaryTypes;
    }
    if (includeQueryPredictions != null) {
      data['includeQueryPredictions'] = includeQueryPredictions;
    }
    if (inputOffset != null) data['inputOffset'] = inputOffset;
    if (includeFutureOpeningBusinesses != null) {
      data['includeFutureOpeningBusinesses'] = includeFutureOpeningBusinesses;
    }
    if (includePureServiceAreaBusinesses != null) {
      data['includePureServiceAreaBusinesses'] = includePureServiceAreaBusinesses;
    }
    if (sessionToken != null) data['sessionToken'] = sessionToken;
    return data;
  }

  TGooglePlacesConfig copyWith({
    String? languageCode,
    String? regionCode,
    LatLng? origin,
    TGoogleLocationBias? locationBias,
    TGoogleLocationRestriction? locationRestriction,
    List<String>? includedPrimaryTypes,
    bool? includeQueryPredictions,
    int? inputOffset,
    bool? includeFutureOpeningBusinesses,
    bool? includePureServiceAreaBusinesses,
    String? sessionToken,
  }) {
    return TGooglePlacesConfig(
      languageCode: languageCode ?? this.languageCode,
      regionCode: regionCode ?? this.regionCode,
      origin: origin ?? this.origin,
      locationBias: locationBias ?? this.locationBias,
      locationRestriction: locationRestriction ?? this.locationRestriction,
      includedPrimaryTypes: includedPrimaryTypes ?? this.includedPrimaryTypes,
      includeQueryPredictions: includeQueryPredictions ?? this.includeQueryPredictions,
      inputOffset: inputOffset ?? this.inputOffset,
      includeFutureOpeningBusinesses: includeFutureOpeningBusinesses ?? this.includeFutureOpeningBusinesses,
      includePureServiceAreaBusinesses: includePureServiceAreaBusinesses ?? this.includePureServiceAreaBusinesses,
      sessionToken: sessionToken ?? this.sessionToken,
    );
  }
}

/// Text model for Google Place predictions.
class TGooglePredictionText {
  final String text;
  final List<dynamic>? matches;

  const TGooglePredictionText({required this.text, this.matches});

  factory TGooglePredictionText.fromJson(Map<String, dynamic> json) {
    return TGooglePredictionText(
      text: json['text']?.toString() ?? '',
      matches: json['matches'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        if (matches != null) 'matches': matches,
      };
}

/// Structured format model for Autocomplete predictions.
class TGoogleStructuredFormat {
  final TGooglePredictionText? mainText;
  final TGooglePredictionText? secondaryText;

  const TGoogleStructuredFormat({this.mainText, this.secondaryText});

  factory TGoogleStructuredFormat.fromJson(Map<String, dynamic> json) {
    return TGoogleStructuredFormat(
      mainText: json['mainText'] != null
          ? TGooglePredictionText.fromJson(json['mainText'] as Map<String, dynamic>)
          : null,
      secondaryText: json['secondaryText'] != null
          ? TGooglePredictionText.fromJson(json['secondaryText'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (mainText != null) 'mainText': mainText!.toJson(),
        if (secondaryText != null) 'secondaryText': secondaryText!.toJson(),
      };
}

/// Prediction model for places.
class TGooglePlacePrediction {
  final String place;
  final String placeId;
  final TGooglePredictionText? text;
  final TGoogleStructuredFormat? structuredFormat;
  final List<String>? types;

  const TGooglePlacePrediction({
    required this.place,
    required this.placeId,
    this.text,
    this.structuredFormat,
    this.types,
  });

  factory TGooglePlacePrediction.fromJson(Map<String, dynamic> json) {
    final placeStr = json['place']?.toString() ?? '';
    final placeIdStr = json['placeId']?.toString() ?? placeStr.split('/').last;
    return TGooglePlacePrediction(
      place: placeStr,
      placeId: placeIdStr,
      text: json['text'] != null
          ? TGooglePredictionText.fromJson(json['text'] as Map<String, dynamic>)
          : null,
      structuredFormat: json['structuredFormat'] != null
          ? TGoogleStructuredFormat.fromJson(json['structuredFormat'] as Map<String, dynamic>)
          : null,
      types: (json['types'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'place': place,
        'placeId': placeId,
        if (text != null) 'text': text!.toJson(),
        if (structuredFormat != null) 'structuredFormat': structuredFormat!.toJson(),
        if (types != null) 'types': types,
      };
}

/// Prediction model for queries.
class TGoogleQueryPrediction {
  final TGooglePredictionText? text;
  final String? query;

  const TGoogleQueryPrediction({this.text, this.query});

  factory TGoogleQueryPrediction.fromJson(Map<String, dynamic> json) {
    return TGoogleQueryPrediction(
      text: json['text'] != null
          ? TGooglePredictionText.fromJson(json['text'] as Map<String, dynamic>)
          : null,
      query: json['query']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (text != null) 'text': text!.toJson(),
        if (query != null) 'query': query,
      };
}

/// Individual suggestion returned by Autocomplete endpoint.
class TGoogleSuggestion {
  final TGooglePlacePrediction? placePrediction;
  final TGoogleQueryPrediction? queryPrediction;

  const TGoogleSuggestion({this.placePrediction, this.queryPrediction});

  factory TGoogleSuggestion.fromJson(Map<String, dynamic> json) {
    return TGoogleSuggestion(
      placePrediction: json['placePrediction'] != null
          ? TGooglePlacePrediction.fromJson(json['placePrediction'] as Map<String, dynamic>)
          : null,
      queryPrediction: json['queryPrediction'] != null
          ? TGoogleQueryPrediction.fromJson(json['queryPrediction'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (placePrediction != null) 'placePrediction': placePrediction!.toJson(),
        if (queryPrediction != null) 'queryPrediction': queryPrediction!.toJson(),
      };
}

/// Response model for Google Places Autocomplete API.
class TGoogleAutocompleteResponse {
  final List<TGoogleSuggestion> suggestions;

  const TGoogleAutocompleteResponse({required this.suggestions});

  factory TGoogleAutocompleteResponse.fromJson(Map<String, dynamic> json) {
    final list = json['suggestions'] as List<dynamic>? ?? [];
    return TGoogleAutocompleteResponse(
      suggestions: list
          .map((e) => TGoogleSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'suggestions': suggestions.map((e) => e.toJson()).toList(),
      };
}

/// Response model for Google Place Details API.
class TGooglePlaceDetailsResponse {
  final String id;
  final String name;
  final String formattedAddress;
  final LatLng? location;
  final TGooglePredictionText? displayName;
  final Map<String, dynamic> raw;

  const TGooglePlaceDetailsResponse({
    required this.id,
    required this.name,
    required this.formattedAddress,
    this.location,
    this.displayName,
    required this.raw,
  });

  factory TGooglePlaceDetailsResponse.fromJson(Map<String, dynamic> json) {
    final locJson = json['location'] as Map<String, dynamic>?;
    LatLng? loc;
    if (locJson != null) {
      final lat = double.tryParse(locJson['latitude'].toString());
      final lng = double.tryParse(locJson['longitude'].toString());
      if (lat != null && lng != null) {
        loc = LatLng(lat, lng);
      }
    }
    return TGooglePlaceDetailsResponse(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      formattedAddress: json['formattedAddress']?.toString() ?? '',
      location: loc,
      displayName: json['displayName'] != null
          ? TGooglePredictionText.fromJson(json['displayName'] as Map<String, dynamic>)
          : null,
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'formattedAddress': formattedAddress,
        if (location != null)
          'location': {
            'latitude': location!.latitude,
            'longitude': location!.longitude,
          },
        if (displayName != null) 'displayName': displayName!.toJson(),
        'raw': raw,
      };
}

/// Google Client to interact with the new Google Places API v1 endpoints.
class TGoogleClient {
  // Autocomplete individual field masks
  static const String autocompletePlaceId = 'suggestions.placePrediction.placeId';
  static const String autocompletePlace = 'suggestions.placePrediction.place';
  static const String autocompletePlaceText = 'suggestions.placePrediction.text';
  static const String autocompletePlaceStructuredFormat = 'suggestions.placePrediction.structuredFormat';
  static const String autocompletePlaceTypes = 'suggestions.placePrediction.types';
  static const String autocompleteQueryText = 'suggestions.queryPrediction.text';
  static const String autocompleteQuery = 'suggestions.queryPrediction.query';

  // Place Details individual fields
  static const String detailsId = 'id';
  static const String detailsName = 'name';
  static const String detailsFormattedAddress = 'formattedAddress';
  static const String detailsLocation = 'location';
  static const String detailsDisplayName = 'displayName';

  static const List<String> defaultAutocompleteFieldMasks = [
    autocompletePlaceId,
    autocompletePlace,
    autocompletePlaceText,
    autocompletePlaceStructuredFormat,
    autocompletePlaceTypes,
    autocompleteQueryText,
    autocompleteQuery,
  ];

  static const List<String> widgetAutocompleteFieldMasks = [
    autocompletePlaceId,
    autocompletePlace,
    autocompletePlaceText,
  ];

  static const List<String> defaultPlaceDetailsFields = [
    detailsId,
    detailsName,
    detailsFormattedAddress,
    detailsLocation,
    detailsDisplayName,
  ];

  final Dio _dio;
  final String? _googleMapApiKey;

  TGoogleClient({Dio? dio, String? googleMapApiKey})
      : _dio = dio ?? Dio(),
        _googleMapApiKey = googleMapApiKey;

  String? _resolveApiKey() {
    if (_googleMapApiKey != null && _googleMapApiKey!.isNotEmpty) {
      return _googleMapApiKey;
    }
    return TMapConfig.googleMapApiKey;
  }

  /// Get auto-complete suggestions from Google Places API.
  Future<TGoogleAutocompleteResponse> autocomplete(
    String input, {
    TGooglePlacesConfig? config,
    List<String> fieldMasks = defaultAutocompleteFieldMasks,
  }) async {
    final apiKey = _resolveApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Google Map API Key not resolved.');
    }

    final data = (config ?? const TGooglePlacesConfig()).toJson(input);

    final response = await _dio.post(
      'https://places.googleapis.com/v1/places:autocomplete',
      data: data,
      options: Options(
        headers: {
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': fieldMasks.join(','),
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.data is Map<String, dynamic>) {
      return TGoogleAutocompleteResponse.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Invalid response format from Autocomplete API.');
  }

  /// Fetch place details by ID.
  Future<TGooglePlaceDetailsResponse> fetchPlaceDetails(
    String placeId, {
    List<String> fields = defaultPlaceDetailsFields,
    String? sessionToken,
  }) async {
    final apiKey = _resolveApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Google Map API Key not resolved.');
    }

    final id = placeId.startsWith('places/') ? placeId.split('/').last : placeId;

    final response = await _dio.get(
      'https://places.googleapis.com/v1/places/$id',
      queryParameters: {
        if (sessionToken != null && sessionToken.isNotEmpty) 'sessionToken': sessionToken,
      },
      options: Options(
        headers: {
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': fields.join(','),
        },
      ),
    );

    if (response.data is Map<String, dynamic>) {
      return TGooglePlaceDetailsResponse.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Invalid response format from Place Details API.');
  }
}
