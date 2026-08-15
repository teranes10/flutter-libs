part of 'map_pinning.dart';

abstract class _TMapPinningStateBase extends State<TMapPinning>
    with TPopupStateMixin<TMapPinning>, SingleTickerProviderStateMixin, TInputFieldStateMixin<TMapPinning> {
  late LatLng currentCoordinates;
  late String currentAddress;
  late TextEditingController searchController;
  final double zoomLevel = 15.0; // standard map zoom (1 to 17)

  late LatLng center;
  late LatLng pin;

  bool hasInteracted = false;

  // Geocoding state
  bool isResolvingAddress = false;
  final Dio dio = Dio();
  Timer? reverseGeocodeDebounce;
  int reverseGeocodeRequestId = 0;

  bool get needsReverseGeocode {
    final address = currentAddress.trim();
    if (address.isEmpty) return true;
    if (address == 'Selected Location' || address == 'Your location' || address == 'Selected Address') {
      return true;
    }
    if (address.startsWith('Looking up')) return true;
    if (address.contains('(Adjusted)')) return true;
    return false;
  }

  String? get searchFieldAddress {
    final address = currentAddress.trim();
    if (address.isEmpty || needsReverseGeocode) return null;
    return address;
  }

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

  Future<void> resolveAddressIfNeeded({bool force = false}) async {
    if (!force && !needsReverseGeocode) return;
    if (isResolvingAddress && !force) return;

    final requestId = ++reverseGeocodeRequestId;
    final coordinates = currentCoordinates;
    setState(() => isResolvingAddress = true);
    try {
      final address = await reverseGeocode(coordinates);
      if (!mounted || requestId != reverseGeocodeRequestId) return;
      if (address == null || address.isEmpty) return;
      setState(() {
        currentAddress = address;
        searchController.text = address;
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

  void onPinMoved(LatLng coordinates) {
    setState(() {
      hasInteracted = true;
      pin = coordinates;
      currentCoordinates = coordinates;
      currentAddress = 'Looking up address...';
      searchController.text = currentAddress;
    });

    reverseGeocodeDebounce?.cancel();
    reverseGeocodeDebounce = Timer(const Duration(milliseconds: 450), () {
      resolveAddressIfNeeded(force: true);
    });
  }

  Future<void> getCurrentLocationAndSync() async {
    final position = await TLocationHelper.getCurrentLocation(TLocationHelper.getLocationSettings());
    final loc = position?.toLatLng();
    if (loc != null) {
      setState(() {
        center = loc;
        pin = loc;
        currentCoordinates = loc;
      });
      widget.onCoordinatesChanged?.call(loc);
      if (needsReverseGeocode) {
        await resolveAddressIfNeeded();
        if (currentAddress.isNotEmpty) {
          widget.onAddressChanged?.call(currentAddress);
          widget.addressController?.text = currentAddress;
        }
      }
    }
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
