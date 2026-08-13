import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TMapPinning extends StatefulWidget with TPopupMixin, TInputFieldMixin {
  @override
  final String label;

  final String? placeholder;
  @override
  final String? tag;
  @override
  final String? helperText;
  @override
  final bool isRequired;
  @override
  final bool disabled;
  @override
  final String? info;
  @override
  final bool clearable;
  @override
  final TInputFieldTheme? theme;
  @override
  final VoidCallback? onTap;

  final LatLng? initialCoordinates;
  final TextEditingController? addressController;
  final ValueChanged<LatLng>? onCoordinatesChanged;
  final ValueChanged<String>? onAddressChanged;
  final String? googleMapApiKey;
  final TLoadListener<TPlaceResult>? onLoad;

  @override
  final VoidCallback? onShow;
  @override
  final VoidCallback? onHide;

  const TMapPinning({
    super.key,
    this.placeholder,
    required this.label,
    this.addressController,
    this.initialCoordinates,
    this.onCoordinatesChanged,
    this.onAddressChanged,
    this.disabled = false,
    this.tag,
    this.helperText,
    this.isRequired = false,
    this.info,
    this.clearable = false,
    this.theme,
    this.onTap,
    this.onShow,
    this.onHide,
    this.googleMapApiKey,
    this.onLoad,
  });

  @override
  State<TMapPinning> createState() => _TMapPinningState();

  @override
  TPopupAlignment get alignment => TPopupAlignment.bottomCenter;
}

class _TMapPinningState extends State<TMapPinning>
    with TPopupStateMixin<TMapPinning>, SingleTickerProviderStateMixin, TInputFieldStateMixin<TMapPinning> {
  late LatLng _currentCoordinates;
  late String _currentAddress;
  late TextEditingController _searchController;
  final double _zoomLevel = 15.0; // standard map zoom (1 to 17)

  // Current center coordinates mapping (map viewport center)
  late LatLng _center;

  // Selected Pin Coordinates (pin marker placement)
  late LatLng _pin;

  // Saved locations list
  List<String> _savedLocations = [];
  List<String> _previousSelections = [];

  bool _hasInteracted = false;
  bool _isResolvingAddress = false;
  final Dio _dio = Dio();
  Timer? _reverseGeocodeDebounce;
  int _reverseGeocodeRequestId = 0;

  bool get _needsReverseGeocode {
    final address = _currentAddress.trim();
    if (address.isEmpty) return true;
    if (address == 'Selected Location' || address == 'Your location' || address == 'Selected Address') {
      return true;
    }
    if (address.startsWith('Looking up')) return true;
    // Legacy placeholder from older builds.
    if (address.contains('(Adjusted)')) return true;
    return false;
  }

  /// Address suitable for showing in the search field (skips placeholders).
  String? get _searchFieldAddress {
    final address = _currentAddress.trim();
    if (address.isEmpty || _needsReverseGeocode) return null;
    return address;
  }

  Future<String?> _reverseGeocode(LatLng coordinates) async {
    final apiKey = _resolveApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final client = TGoogleClient(dio: _dio, googleMapApiKey: apiKey);
        final address = await client.reverseGeocode(coordinates.latitude, coordinates.longitude);
        if (address != null && address.isNotEmpty) return address;
      } catch (_) {}
    }

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': coordinates.latitude.toString(),
          'lon': coordinates.longitude.toString(),
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

  Future<void> _resolveAddressIfNeeded({bool force = false}) async {
    if (!force && !_needsReverseGeocode) return;
    if (_isResolvingAddress && !force) return;

    final requestId = ++_reverseGeocodeRequestId;
    final coordinates = _currentCoordinates;
    setState(() => _isResolvingAddress = true);
    try {
      final address = await _reverseGeocode(coordinates);
      if (!mounted || requestId != _reverseGeocodeRequestId) return;
      if (address == null || address.isEmpty) return;
      setState(() {
        _currentAddress = address;
        _searchController.text = address;
      });
    } finally {
      if (mounted && requestId == _reverseGeocodeRequestId) {
        setState(() => _isResolvingAddress = false);
      }
    }
  }

  void _onPinMoved(LatLng coordinates) {
    setState(() {
      _hasInteracted = true;
      _pin = coordinates;
      _currentCoordinates = coordinates;
      _currentAddress = 'Looking up address...';
      _searchController.text = _currentAddress;
    });

    _reverseGeocodeDebounce?.cancel();
    _reverseGeocodeDebounce = Timer(const Duration(milliseconds: 450), () {
      _resolveAddressIfNeeded(force: true);
    });
  }

  @override
  double get contentMinWidth => 600;
  @override
  double get contentMinHeight => 650;
  @override
  double? get contentMaxWidth => 800;
  @override
  double? get contentMaxHeight => 720;

  @override
  TPopupMode get effectivePopupMode {
    return MediaQuery.of(context).isMobile ? TPopupMode.page : TPopupMode.centered;
  }

  @override
  void initState() {
    super.initState();
    _currentCoordinates = widget.initialCoordinates ?? TMapConfig.mapCenter;
    _currentAddress = widget.addressController?.text ?? '';
    _searchController = TextEditingController(text: _currentAddress);

    _center = _currentCoordinates;
    _pin = _currentCoordinates;

    _loadSavedLocations();
    _getCurrentLocationAndSync();
  }

  @override
  void didUpdateWidget(TMapPinning oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCoordinates != oldWidget.initialCoordinates && widget.initialCoordinates != null) {
      setState(() {
        _currentCoordinates = widget.initialCoordinates!;
        _center = widget.initialCoordinates!;
        _pin = widget.initialCoordinates!;
      });
    }
    if (widget.addressController?.text != oldWidget.addressController?.text && widget.addressController?.text != null) {
      setState(() {
        _currentAddress = widget.addressController!.text;
        _searchController.text = widget.addressController!.text;
      });
    }
  }

  @override
  void dispose() {
    _reverseGeocodeDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  TInputFieldTheme get wTheme => (widget.theme ?? context.theme.inputFieldTheme).copyWith(padding: EdgeInsets.symmetric(vertical: 8));

  String? _resolveApiKey() {
    if (widget.googleMapApiKey != null && widget.googleMapApiKey!.isNotEmpty) {
      return widget.googleMapApiKey;
    }
    return TMapConfig.googleMapApiKey;
  }

  Future<void> _getCurrentLocationAndSync() async {
    final position = await TLocationHelper.getCurrentLocation(TLocationHelper.getLocationSettings());
    final loc = position?.toLatLng();
    if (loc != null) {
      setState(() {
        _center = loc;
        _pin = loc;
        _currentCoordinates = loc;
      });
      widget.onCoordinatesChanged?.call(loc);
      // Fill address for GPS pin when none was provided yet.
      if (_needsReverseGeocode) {
        await _resolveAddressIfNeeded();
        if (_currentAddress.isNotEmpty) {
          widget.onAddressChanged?.call(_currentAddress);
          widget.addressController?.text = _currentAddress;
        }
      }
    }
  }

  void _loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedLocations = prefs.getStringList('saved_locations') ?? [];
      _previousSelections = prefs.getStringList('previous_selections') ?? [];
    });
  }

  void _saveCurrentLocation() async {
    if (_currentAddress.isEmpty) return;

    TAlertService.prompt(
      context,
      title: 'Save Location',
      placeholder: 'Enter a name for this location (e.g., Home, Work)',
      initialValue: _currentAddress.split(',').first,
      onConfirm: (name) async {
        if (name.isEmpty) return;

        final prefs = await SharedPreferences.getInstance();
        final item = "$name|$_currentAddress|${_currentCoordinates.latitude},${_currentCoordinates.longitude}";

        // Remove existing matches of same address/coordinates
        _savedLocations.removeWhere((loc) {
          final parts = loc.split('|');
          if (parts.length >= 3) {
            return parts[1] == _currentAddress && parts[2] == "${_currentCoordinates.latitude},${_currentCoordinates.longitude}";
          } else if (parts.length == 2) {
            return parts[0] == _currentAddress && parts[1] == "${_currentCoordinates.latitude},${_currentCoordinates.longitude}";
          }
          return false;
        });

        setState(() {
          _savedLocations.insert(0, item);
        });
        await prefs.setStringList('saved_locations', _savedLocations);
        if (mounted) {
          TToastService.success(context, "Location saved successfully!");
        }
      },
    );
  }

  void _deleteSavedLocation(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedLocations.removeAt(index);
    });
    await prefs.setStringList('saved_locations', _savedLocations);
    if (mounted) {
      TToastService.success(context, "Location removed!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final mapWidget = Container(
      height: 100,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: TMap(
                initialCoordinates: _center,
                zoom: _zoomLevel,
                interactive: false,
                googleMapApiKey: widget.googleMapApiKey,
                height: 100,
                borderRadius: 10,
                pins: [TMapPin(coordinates: _pin, label: _currentAddress.isNotEmpty ? _currentAddress : 'Your location')],
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surface.withAlpha(230),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Text(
                  _currentAddress.isNotEmpty ? _currentAddress : 'Your location',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.onSurface, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return buildWithDropdownTarget(
      child: buildContainer(
        child: mapWidget,
        onTap: () {
          showPopup(context);
        },
      ),
    );
  }

  @override
  Widget getContentWidget(BuildContext context) {
    final colors = context.colors;
    final isMobile = MediaQuery.of(context).isMobile;

    // Always show search — Google Places when keyed, Nominatim otherwise.
    final headerWidgets = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TPlaceAutoComplete(
          googleMapApiKey: widget.googleMapApiKey,
          onLoad: widget.onLoad,
          placeholder: widget.placeholder ?? 'Search location...',
          selectedAddress: _searchFieldAddress,
          onPlaceSelected: (details) {
            final coordinates = parseCoordinates(details.coordinates);
            setState(() {
              _hasInteracted = true;
              _center = coordinates;
              _pin = coordinates;
              _currentCoordinates = coordinates;
              _currentAddress = details.address;
              _searchController.text = details.address;
            });
            widget.onAddressChanged?.call(details.address);
            widget.onCoordinatesChanged?.call(coordinates);
            widget.addressController?.text = details.address;
          },
        ),
      ],
    );

    // 2. Middle Content: Map + Saved Locations List (Scrollable)
    final middleWidgets = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Map Viewport
        SizedBox(
          height: 320,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: TMap(
              initialCoordinates: _center,
              zoom: _zoomLevel,
              interactive: true,
              googleMapApiKey: widget.googleMapApiKey,
              height: 320,
              onCoordinatesChanged: _onPinMoved,
              pins: [TMapPin(coordinates: _pin, label: _currentAddress.isNotEmpty ? _currentAddress : 'Selected Pin')],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_savedLocations.isNotEmpty) ...[
          Text(
            'Saved Locations',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 6),
          _buildSavedLocationsList(context, isMobile),
          const SizedBox(height: 12),
        ],
        if (_previousSelections.isNotEmpty) ...[
          Text(
            'Recent Locations',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 6),
          _buildPreviousSelectionsList(context, isMobile),
          const SizedBox(height: 12),
        ],
      ],
    );

    final footer = _buildFooter(context);

    // Desktop: Sticky Header + Sticky Footer + Scrollable Middle
    // Mobile: Render only Header + Middle (Footer is passed to TPageWrapper via getPopupFooter)
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [headerWidgets, const SizedBox(height: 12), middleWidgets],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 680,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              headerWidgets,
              const SizedBox(height: 12),
              Expanded(child: SingleChildScrollView(child: middleWidgets)),
              const SizedBox(height: 12),
              footer,
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget? getPopupFooter(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0), child: _buildFooter(context));
  }

  Widget _buildFooter(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.pin_drop_outlined, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentAddress.isNotEmpty ? _currentAddress : 'Selected Address',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Coordinates: ${_currentCoordinates.formattedString}',
                      style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_hasInteracted && _currentAddress.isNotEmpty)
                TButton(icon: Icons.bookmark_add_outlined, type: TButtonType.outline, onTap: _saveCurrentLocation),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TButton(
              text: 'Cancel',
              type: TButtonType.outline,
              onTap: () {
                hidePopup();
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TButton(
                text: 'Confirm Location',
                loading: true,
                loadingText: 'Resolving...',
                onPressed: (options) async {
                  setState(() {
                    _center = _currentCoordinates;
                  });

                  await _resolveAddressIfNeeded(force: true);

                  if (_currentAddress.isEmpty ||
                      _currentAddress.startsWith('Looking up') ||
                      _currentAddress.contains('(Adjusted)')) {
                    setState(() {
                      _currentAddress =
                          'Selected Location (${_currentCoordinates.latitude.toStringAsFixed(5)}, ${_currentCoordinates.longitude.toStringAsFixed(5)})';
                      _searchController.text = _currentAddress;
                    });
                  }

                  if (_currentAddress.isNotEmpty) {
                    final timestamp = DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now());
                    final item = "$_currentAddress|${_currentCoordinates.latitude},${_currentCoordinates.longitude}|$timestamp";
                    _previousSelections.removeWhere((loc) => loc.startsWith("$_currentAddress|"));
                    setState(() {
                      _previousSelections.insert(0, item);
                      if (_previousSelections.length > 5) {
                        _previousSelections.removeLast();
                      }
                    });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setStringList('previous_selections', _previousSelections);
                  }

                  widget.onAddressChanged?.call(_currentAddress);
                  widget.onCoordinatesChanged?.call(_currentCoordinates);
                  widget.addressController?.text = _currentAddress;
                  options.stopLoading();
                  hidePopup();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  LatLng parseCoordinates(String coords) {
    // Clean string by removing LatLng(...) or label prefixes
    String clean = coords
        .replaceAll('LatLng(', '')
        .replaceAll(')', '')
        .replaceAll('latitude:', '')
        .replaceAll('longitude:', '')
        .replaceAll('lat:', '')
        .replaceAll('lng:', '')
        .trim();

    final parts = clean.split(',');

    if (parts.length != 2) {
      throw ArgumentError('Invalid coordinates: "$coords"');
    }

    final latitude = double.tryParse(parts[0].trim());
    final longitude = double.tryParse(parts[1].trim());

    if (latitude == null || longitude == null) {
      throw ArgumentError('Invalid coordinate values: "$coords"');
    }

    return LatLng(latitude, longitude);
  }

  Widget _buildSavedLocationsList(BuildContext context, bool isMobile) {
    final colors = context.colors;

    final list = ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: _savedLocations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final parts = _savedLocations[index].split('|');
        final String displayName;
        final String addr;
        final String coords;
        if (parts.length >= 3) {
          displayName = parts[0];
          addr = parts[1];
          coords = parts[2];
        } else {
          displayName = parts[0];
          addr = parts[0];
          coords = parts.length > 1 ? parts[1] : '';
        }

        return TCard(
          padding: const EdgeInsets.all(12),
          margin: EdgeInsets.zero,
          onTap: () {
            setState(() {
              _hasInteracted = false;
              _currentAddress = displayName;
              final coordinates = parseCoordinates(coords);
              _currentCoordinates = coordinates;
              _searchController.text = displayName;
              _center = coordinates;
              _pin = coordinates;
            });
          },
          child: Row(
            children: [
              Icon(Icons.pin_drop_outlined, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coords,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant.withAlpha(180)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TButton(
                icon: Icons.bookmark_remove_outlined,
                type: TButtonType.outline,
                color: colors.error,
                onTap: () {
                  TAlertService.show(
                    context,
                    title: 'Remove Saved Location',
                    text: 'Are you sure you want to remove "$displayName"?',
                    icon: Icons.delete_forever_rounded,
                    color: colors.error,
                    confirmButton: AlertButton(
                      text: 'Remove',
                      onClick: () {
                        _deleteSavedLocation(index);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    return list;
  }

  Widget _buildPreviousSelectionsList(BuildContext context, bool isMobile) {
    final colors = context.colors;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: _previousSelections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final parts = _previousSelections[index].split('|');
        final String addr = parts[0];
        final String coords = parts.length > 1 ? parts[1] : '';
        final String timestamp = parts.length > 2 ? parts[2] : '';

        return TCard(
          padding: const EdgeInsets.all(12),
          margin: EdgeInsets.zero,
          onTap: () {
            setState(() {
              _hasInteracted = false;
              _currentAddress = addr;
              final coordinates = parseCoordinates(coords);
              _currentCoordinates = coordinates;
              _searchController.text = addr;
              _center = coordinates;
              _pin = coordinates;
            });
          },
          child: Row(
            children: [
              Icon(Icons.history_outlined, color: colors.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      addr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    if (timestamp.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Recorded: $timestamp',
                        style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant.withAlpha(160)),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      coords,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant.withAlpha(180)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TButton(
                icon: Icons.close,
                type: TButtonType.outline,
                color: colors.error,
                onTap: () {
                  _deletePreviousSelection(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deletePreviousSelection(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _previousSelections.removeAt(index);
    });
    await prefs.setStringList('previous_selections', _previousSelections);
    if (mounted) {
      TToastService.success(context, "Location removed from recent list!");
    }
  }
}
