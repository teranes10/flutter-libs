part of 'map_pinning.dart';

/// Point type indicating whether the user is interacting with the From (Pickup) or To (Drop-off) location.
enum TMapPointType { from, to }

abstract class _TMapPinningStateBase extends State<TMapPinning>
    with TPopupStateMixin<TMapPinning>, SingleTickerProviderStateMixin, TInputFieldStateMixin<TMapPinning> {
  // From / Primary Point State
  late LatLng fromCoordinates;
  late String fromAddress;
  late TextEditingController fromSearchController;

  // To / Secondary Point State (Two-Points mode)
  LatLng? toCoordinates;
  late String toAddress;
  late TextEditingController toSearchController;

  // Currently active point for map taps and location pickers
  TMapPointType activePoint = TMapPointType.from;

  // Route & Distance state
  TRouteResult? routeResult;
  bool isCalculatingRoute = false;

  final double zoomLevel = 15.0; // standard map zoom (1 to 17)

  late LatLng center;
  late LatLng pin;

  bool hasInteracted = false;

  // Geocoding state
  bool isResolvingAddress = false;
  final Dio dio = Dio();
  Timer? reverseGeocodeDebounce;
  Timer? routeCalculateDebounce;
  int reverseGeocodeRequestId = 0;

  // Backward compatibility getters
  LatLng get currentCoordinates => activePoint == TMapPointType.from ? fromCoordinates : (toCoordinates ?? fromCoordinates);
  set currentCoordinates(LatLng val) {
    if (activePoint == TMapPointType.from) {
      fromCoordinates = val;
    } else {
      toCoordinates = val;
    }
  }

  String get currentAddress => activePoint == TMapPointType.from ? fromAddress : toAddress;
  set currentAddress(String val) {
    if (activePoint == TMapPointType.from) {
      fromAddress = val;
    } else {
      toAddress = val;
    }
  }

  TextEditingController get searchController => activePoint == TMapPointType.from ? fromSearchController : toSearchController;

  bool isAddressPlaceholder(String address) {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return true;
    if (trimmed == 'Selected Location' ||
        trimmed == 'Your location' ||
        trimmed == 'Selected Address' ||
        trimmed == 'Pickup Location' ||
        trimmed == 'Drop-off Location') {
      return true;
    }
    if (trimmed.startsWith('Looking up')) return true;
    if (trimmed.contains('(Adjusted)')) return true;
    return false;
  }

  bool get needsReverseGeocode => isAddressPlaceholder(currentAddress);

  String? get fromSearchFieldAddress {
    final addr = fromAddress.trim();
    if (addr.isEmpty || isAddressPlaceholder(addr)) return null;
    return addr;
  }

  String? get toSearchFieldAddress {
    final addr = toAddress.trim();
    if (addr.isEmpty || isAddressPlaceholder(addr)) return null;
    return addr;
  }

  String? get searchFieldAddress => activePoint == TMapPointType.from ? fromSearchFieldAddress : toSearchFieldAddress;

  Future<String?> reverseGeocode(LatLng coordinates) async {
    final apiKey = resolveApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final client = TGoogleClient(dio: dio, googleMapApiKey: apiKey);
        final address = await client.reverseGeocode(coordinates.latitude, coordinates.longitude);
        if (address != null && address.isNotEmpty) return address;
      } catch (_) {}
    }

    final osClient = TOpenStreetMapClient(dio: dio);
    final osAddress = await osClient.reverseGeocode(coordinates.latitude, coordinates.longitude);
    if (osAddress != null && osAddress.isNotEmpty) return osAddress;

    return null;
  }

  Future<void> resolveAddressIfNeeded({bool force = false, TMapPointType? pointType}) async {
    final target = pointType ?? activePoint;
    final isFrom = target == TMapPointType.from;
    final coords = isFrom ? fromCoordinates : toCoordinates;
    if (coords == null) return;

    final targetAddr = isFrom ? fromAddress : toAddress;
    if (!force && !isAddressPlaceholder(targetAddr)) return;
    if (isResolvingAddress && !force) return;

    final requestId = ++reverseGeocodeRequestId;
    setState(() => isResolvingAddress = true);
    try {
      final address = await reverseGeocode(coords);
      if (!mounted || requestId != reverseGeocodeRequestId) return;
      if (address == null || address.isEmpty) return;
      setState(() {
        if (isFrom) {
          fromAddress = address;
          fromSearchController.text = address;
        } else {
          toAddress = address;
          toSearchController.text = address;
        }
      });
    } finally {
      if (mounted && requestId == reverseGeocodeRequestId) {
        setState(() => isResolvingAddress = false);
      }
    }
  }

  String? resolveApiKey() {
    if (widget.googleMapApiKey != null && widget.googleMapApiKey!.isNotEmpty) {
      return widget.googleMapApiKey;
    }
    return TMapConfig.googleMapApiKey;
  }

  /// Calculates the driving route between [fromCoordinates] and [toCoordinates].
  Future<void> calculateRouteIfNeeded() async {
    if (!widget.isTwoPoints || toCoordinates == null) {
      if (routeResult != null) {
        setState(() => routeResult = null);
      }
      return;
    }

    setState(() => isCalculatingRoute = true);

    try {
      TRouteResult? result;
      final apiKey = resolveApiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        final googleClient = TGoogleClient(dio: dio, googleMapApiKey: apiKey);
        result = await googleClient.fetchRoute(fromCoordinates, toCoordinates!);
      }

      if (result == null) {
        final osClient = TOpenStreetMapClient(dio: dio);
        result = await osClient.fetchRoute(fromCoordinates, toCoordinates!);
      }

      if (!mounted) return;

      if (result != null) {
        setState(() {
          routeResult = result;
        });
        widget.onRouteChanged?.call(result);
        widget.onDistanceChanged?.call(result.distanceMeters);
      }
    } finally {
      if (mounted) {
        setState(() => isCalculatingRoute = false);
      }
    }
  }

  void onPinMoved(LatLng coordinates) {
    setState(() {
      hasInteracted = true;
      if (!widget.isTwoPoints || activePoint == TMapPointType.from) {
        fromCoordinates = coordinates;
        fromAddress = 'Looking up address...';
        fromSearchController.text = fromAddress;
      } else {
        toCoordinates = coordinates;
        toAddress = 'Looking up address...';
        toSearchController.text = toAddress;
      }
      pin = coordinates;
      center = coordinates;
    });

    reverseGeocodeDebounce?.cancel();
    reverseGeocodeDebounce = Timer(const Duration(milliseconds: 450), () async {
      await resolveAddressIfNeeded(force: true, pointType: activePoint);
      if (widget.isTwoPoints && toCoordinates != null) {
        await calculateRouteIfNeeded();
      }
    });
  }

  Future<void> getCurrentLocationAndSync() async {
    try {
      final position = await TLocationHelper.getCurrentLocation(TLocationHelper.getLocationSettings());
      final loc = position?.toLatLng();
      if (loc != null) {
        if (!mounted) return;
        setState(() {
          center = loc;
          pin = loc;
          fromCoordinates = loc;
        });
        widget.onFromCoordinatesChanged?.call(loc);
        widget.onCoordinatesChanged?.call(loc);

        if (isAddressPlaceholder(fromAddress)) {
          await resolveAddressIfNeeded(pointType: TMapPointType.from);
          if (fromAddress.isNotEmpty) {
            widget.onFromAddressChanged?.call(fromAddress);
            widget.onAddressChanged?.call(fromAddress);
            widget.fromAddressController?.text = fromAddress;
            widget.addressController?.text = fromAddress;
          }
        }

        if (widget.isTwoPoints && toCoordinates != null) {
          await calculateRouteIfNeeded();
        }
      }
    } catch (_) {}
  }

  LatLng parseCoordinates(String coords) {
    String clean = coords
        .replaceAll('LatLng(', '')
        .replaceAll(')', '')
        .replaceAll('latitude:', '')
        .replaceAll('longitude:', '')
        .replaceAll('lat:', '')
        .replaceAll('lng:', '')
        .trim();

    final parts = clean.split(',');
    if (parts.length != 2) throw ArgumentError('Invalid coordinates: "$coords"');

    final latitude = double.tryParse(parts[0].trim());
    final longitude = double.tryParse(parts[1].trim());

    if (latitude == null || longitude == null) throw ArgumentError('Invalid coordinate values: "$coords"');

    return LatLng(latitude, longitude);
  }
}
