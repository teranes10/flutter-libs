import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:te_widgets/te_widgets.dart';

import '../extensions/position_x.dart';
import '../google_places_client.dart';
import '../helpers/location/location_helper.dart';
import '../map_config.dart';
import '../openstreet_client.dart';
import '../place_autocomplete.dart';
import '../place_search.dart';
import '../route_result.dart';
import 'previous_selections_list.dart';
import 'saved_locations_list.dart';

/// Which end of the route the picker is currently editing.
enum TMapPointType { from, to }

/// Final selection returned by the location picker.
class TMapPickerResult {
  final LatLng from;
  final String fromAddress;
  final LatLng? to;
  final String toAddress;
  final TRouteResult? route;

  const TMapPickerResult({required this.from, required this.fromAddress, this.to, this.toAddress = '', this.route});
}

/// Holds the state and logic shared by every part of the picker UI
/// (desktop dialog, mobile list page, mobile map page).
class TMapPickerController extends ChangeNotifier {
  TMapPickerController({
    required this.isTwoPoints,
    this.googleMapApiKey,
    this.from,
    this.fromAddress = '',
    this.to,
    this.toAddress = '',
    this.active = TMapPointType.from,
    this.route,
    TLoadListener<TPlaceResult>? onLoad,
  }) : search = TPlaceSearch(googleMapApiKey: googleMapApiKey, onLoad: onLoad),
       fromText = TextEditingController(text: fromAddress),
       toText = TextEditingController(text: toAddress),
       mapCenter = (active == TMapPointType.to ? to : from) ?? from ?? to ?? TMapConfig.mapCenter {
    _lastFrom = fromText.text;
    _lastTo = toText.text;
    suggestionList.addListener(_notify);
    fromText.addListener(() => _onText(TMapPointType.from));
    toText.addListener(() => _onText(TMapPointType.to));
  }

  final bool isTwoPoints;
  final String? googleMapApiKey;

  final TPlaceSearch search;
  final TextEditingController fromText;
  final TextEditingController toText;

  /// Place suggestions shown while the user is typing in a search field.
  /// A [TListController] owns the debounce, request cancellation and loading state.
  late final TListController<TPlaceResult, String> suggestionList = TListController<TPlaceResult, String>(
    onLoad: (options) => search.load(options.search ?? ''),
    searchDelay: 2500,
    loadOnSearchOnly: true,
    itemKey: (p) => p.placeId ?? '${p.address}|${p.latitude},${p.longitude}',
  );
  bool suggesting = false;
  bool _resolvingPlace = false;
  String _query = '';

  List<TPlaceResult> get suggestions => suggestionList.value.displayItems.map((e) => e.data).toList();

  /// True while the debounce is pending, a request is running, or a place is being resolved.
  bool get loadingSuggestions => _resolvingPlace || suggestionList.isLoading || _query != suggestionList.value.search;
  TMapPointType? _editing;
  bool _syncing = false;
  String _lastFrom = '';
  String _lastTo = '';

  // Listens to the text itself (not TTextField.onValueChanged, which skips a value equal to its last one).
  void _onText(TMapPointType type) {
    if (_syncing || _disposed) return;
    final text = type == TMapPointType.from ? fromText.text : toText.text;
    if (text == (type == TMapPointType.from ? _lastFrom : _lastTo)) return;
    if (type == TMapPointType.from) {
      _lastFrom = text;
    } else {
      _lastTo = text;
    }
    onQueryChanged(type, text);
  }

  /// Lets the "Save location" button reach the saved list wherever it is mounted.
  final GlobalKey<TSavedLocationsListState> savedKey = GlobalKey<TSavedLocationsListState>();

  LatLng? from;
  String fromAddress;
  LatLng? to;
  String toAddress;
  TMapPointType active;
  TRouteResult? route;

  /// Where the map camera should be; only changed by non-map selections.
  LatLng mapCenter;

  /// True once the user picked a point by tapping the map (enables "save").
  bool fromIsCurrent = false;
  bool toIsCurrent = false;
  bool interacted = false;
  bool resolving = false;
  bool locating = false;

  final http.Client _http = http.Client();
  Timer? _debounce;
  int _requestId = 0;
  bool _disposed = false;

  LatLng? get activeCoords => active == TMapPointType.from ? from : to;
  String get activeAddress => active == TMapPointType.from ? fromAddress : toAddress;
  bool get canConfirm => from != null && (!isTwoPoints || to != null);

  /// Address to show for [type]: the resolved address, or the raw coordinates.
  String addressOf(TMapPointType type) {
    final addr = type == TMapPointType.from ? fromAddress : toAddress;
    final coords = type == TMapPointType.from ? from : to;
    if (addr.isNotEmpty) return addr;
    if (coords == null) return '';
    return (type == TMapPointType.from ? fromIsCurrent : toIsCurrent) ? 'Current Location' : 'Unknown';
  }

  void _notify() {
    if (_disposed) return;
    _syncTexts();
    notifyListeners();
  }

  String _fieldText(TMapPointType type) {
    final addr = type == TMapPointType.from ? fromAddress : toAddress;
    if (addr.isNotEmpty) return addr;
    final coords = type == TMapPointType.from ? from : to;
    final current = type == TMapPointType.from ? fromIsCurrent : toIsCurrent;
    return coords != null && current ? 'Current Location' : '';
  }

  // Keeps the search fields showing the chosen addresses, except the one being typed in.
  void _syncTexts() {
    _syncing = true;
    if (_editing != TMapPointType.from && fromText.text != _fieldText(TMapPointType.from)) {
      fromText.text = _lastFrom = _fieldText(TMapPointType.from);
    }
    if (_editing != TMapPointType.to && toText.text != _fieldText(TMapPointType.to)) {
      toText.text = _lastTo = _fieldText(TMapPointType.to);
    }
    _syncing = false;
  }

  /// Called when the user types in the search field of [type].
  void onQueryChanged(TMapPointType type, String text) {
    if (type != active) active = type;
    _editing = type;
    _query = text.trim();
    if (_query.isEmpty) {
      suggesting = false;
      suggestionList.handleSearchImmediate('');
    } else {
      suggesting = true;
      suggestionList.handleSearchChange(_query);
    }
    _notify();
  }

  Future<void> selectSuggestion(TPlaceResult place) async {
    _resolvingPlace = true;
    _notify();
    final resolved = await search.resolve(place);
    _resolvingPlace = false;
    if (_disposed) return;
    LatLng? coords;
    if (resolved != null) {
      if (resolved.latitude != 0.0 || resolved.longitude != 0.0) {
        coords = LatLng(resolved.latitude, resolved.longitude);
      } else if (resolved.coordinates.isNotEmpty) {
        try {
          coords = TLocationHelper.parseCoordinates(resolved.coordinates);
        } catch (_) {}
      }
    }
    suggesting = false;
    _query = '';
    suggestionList.handleSearchImmediate('');
    if (coords == null) {
      _notify();
      return;
    }
    setPoint(coords, address: resolved!.address);
  }

  void setActive(TMapPointType type) {
    if (active == type) return;
    if (_editing != null && _editing != type) {
      _editing = null;
      suggesting = false;
      _query = '';
      suggestionList.handleSearchImmediate('');
    }
    active = type;
    final c = activeCoords;
    if (c != null) mapCenter = c;
    _notify();
  }

  /// Sets the active point. When [address] is null it is reverse-geocoded.
  void setPoint(LatLng coords, {String? address, bool fromMap = false, bool current = false}) {
    final type = active;
    if (_editing == type) _editing = null;
    if (type == TMapPointType.from) {
      fromIsCurrent = current;
    } else {
      toIsCurrent = current;
    }
    if (type == TMapPointType.from) {
      from = coords;
      fromAddress = address ?? '';
    } else {
      to = coords;
      toAddress = address ?? '';
    }
    if (fromMap) {
      interacted = true;
    } else {
      mapCenter = coords;
    }

    // After choosing the first point, jump to the empty second one.
    if (isTwoPoints && type == TMapPointType.from && to == null) {
      active = TMapPointType.to;
    }
    _notify();

    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: address == null ? 450 : 0), () async {
      if (address == null) await _resolve(type);
      await _calculateRoute();
    });
  }

  void swap() {
    if (to == null || from == null) return;
    _editing = null;
    final c = from;
    final a = fromAddress;
    from = to;
    fromAddress = toAddress;
    to = c;
    toAddress = a;
    _notify();
    _calculateRoute();
  }

  Future<void> useCurrentLocation() async {
    if (locating) return;
    locating = true;
    _notify();
    try {
      final position = await TLocationHelper.getCurrentLocation(TLocationHelper.getLocationSettings());
      final loc = position?.toLatLng();
      if (loc != null && !_disposed) setPoint(loc, current: true);
    } catch (_) {
    } finally {
      locating = false;
      _notify();
    }
  }

  String? _apiKey() => (googleMapApiKey?.isNotEmpty ?? false) ? googleMapApiKey : TMapConfig.googleMapApiKey;

  Future<String?> reverseGeocode(LatLng c) async {
    final apiKey = _apiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final address = await TGoogleClient(client: _http, googleMapApiKey: apiKey).reverseGeocode(c.latitude, c.longitude);
        if (address != null && address.isNotEmpty) return address;
      } catch (_) {}
    }
    try {
      final address = await TOpenStreetMapClient(client: _http).reverseGeocode(c.latitude, c.longitude);
      if (address != null && address.isNotEmpty) return address;
    } catch (_) {}
    return null;
  }

  Future<void> _resolve(TMapPointType type) async {
    final coords = type == TMapPointType.from ? from : to;
    if (coords == null) return;
    final id = ++_requestId;
    resolving = true;
    _notify();
    try {
      final address = await reverseGeocode(coords);
      if (_disposed || id != _requestId || address == null) return;
      if (type == TMapPointType.from) {
        fromAddress = address;
      } else {
        toAddress = address;
      }
    } finally {
      if (!_disposed && id == _requestId) {
        resolving = false;
        _notify();
      }
    }
  }

  Future<void> _calculateRoute() async {
    final a = from;
    final b = to;
    if (!isTwoPoints || a == null || b == null) return;
    TRouteResult? result;
    try {
      final apiKey = _apiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        result = await TGoogleClient(client: _http, googleMapApiKey: apiKey).fetchRoute(a, b);
      }
      result ??= await TOpenStreetMapClient(client: _http).fetchRoute(a, b);
    } catch (_) {}
    // Ignore a stale answer if either end moved meanwhile.
    if (_disposed || a != from || b != to) return;
    route = result;
    _notify();
  }

  /// Resolves any missing addresses and builds the final result.
  Future<TMapPickerResult?> finalize() async {
    _debounce?.cancel();
    if (from == null) return null;
    if (fromAddress.isEmpty) await _resolve(TMapPointType.from);
    if (to != null && toAddress.isEmpty) await _resolve(TMapPointType.to);
    if (to != null && route == null) await _calculateRoute();
    final a = addressOf(TMapPointType.from);
    final b = addressOf(TMapPointType.to);
    final result = TMapPickerResult(from: from!, fromAddress: a, to: to, toAddress: b, route: route);
    await _remember(a, from!);
    if (to != null) await _remember(b, to!);
    return result;
  }

  Future<void> _remember(String address, LatLng c) async {
    if (address == 'Unknown') return;
    await TPreviousSelectionsList.record(address, c);
  }

  void saveActive(BuildContext context) {
    final c = activeCoords;
    if (c == null) return;
    savedKey.currentState?.saveCurrentLocation(addressOf(active), c);
  }

  // ---- map presentation -------------------------------------------------

  List<TMapPin> pins(BuildContext context, {String? fromLabel, String? toLabel}) {
    final colors = context.colors;
    if (!isTwoPoints) {
      return [if (from != null) TMapPin(coordinates: from!, icon: Icons.location_on, iconColor: colors.primary)];
    }
    return [
      if (from != null) TMapPin(coordinates: from!, label: fromLabel ?? 'Pickup Point', icon: Icons.trip_origin, iconColor: Colors.green),
      if (to != null) TMapPin(coordinates: to!, label: toLabel ?? 'Drop-off Point', icon: Icons.location_on, iconColor: Colors.redAccent),
    ];
  }

  List<TMapPolyline> polylines(BuildContext context) {
    final r = route;
    if (!isTwoPoints || r == null || r.points.isEmpty) return const [];
    return [TMapPolyline(points: r.points, color: context.colors.primary, strokeWidth: 4)];
  }

  LatLngBounds? get bounds {
    if (!isTwoPoints || from == null || to == null) return null;
    final points = route != null && route!.points.isNotEmpty ? route!.points : [from!, to!];
    return LatLngBounds.fromPoints(points);
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    suggestionList.dispose();
    _http.close();
    search.dispose();
    fromText.dispose();
    toText.dispose();
    super.dispose();
  }
}
