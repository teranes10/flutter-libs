import 'google_places_client.dart';
import 'place_search.dart';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TPlaceResult {
  final String address;
  final String coordinates;
  final double latitude;
  final double longitude;
  final String? placeId;

  const TPlaceResult({required this.address, required this.coordinates, required this.latitude, required this.longitude, this.placeId});

  @override
  String toString() => address;
}

class TPlaceAutoComplete extends StatefulWidget {
  final ValueChanged<TPlaceResult> onPlaceSelected;
  final String? googleMapApiKey;
  final TLoadListener<TPlaceResult>? onLoad;
  final String? label;
  final String? placeholder;

  /// When set (e.g. after reverse-geocode), shows this address in the field.
  final String? selectedAddress;
  final TLabelPosition? labelPosition;
  final int limit;
  final TGooglePlacesConfig? config;
  final TTextFieldTheme? theme;
  final Widget? preWidget;
  final VoidCallback? onTap;

  const TPlaceAutoComplete({
    super.key,
    required this.onPlaceSelected,
    this.googleMapApiKey,
    this.onLoad,
    this.limit = 5,
    this.label,
    this.placeholder,
    this.selectedAddress,
    this.labelPosition = TLabelPosition.aboveField,
    this.config,
    this.theme,
    this.preWidget,
    this.onTap,
  });

  @override
  State<TPlaceAutoComplete> createState() => _TPlaceAutoCompleteState();
}

class _TPlaceAutoCompleteState extends State<TPlaceAutoComplete> {
  late final TPlaceSearch _search = TPlaceSearch();
  TPlaceResult? _selectedPlace;

  void _syncSearch() {
    _search
      ..googleMapApiKey = widget.googleMapApiKey
      ..config = widget.config
      ..limit = widget.limit
      ..onLoad = widget.onLoad;
  }

  @override
  void initState() {
    super.initState();
    _syncSearch();
    _applySelectedAddress(widget.selectedAddress, notify: false);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TPlaceAutoComplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSearch();
    if (widget.selectedAddress != oldWidget.selectedAddress) {
      _applySelectedAddress(widget.selectedAddress, notify: true);
    }
  }

  void _applySelectedAddress(String? address, {required bool notify}) {
    final trimmed = address?.trim() ?? '';
    TPlaceResult? next;
    if (trimmed.isNotEmpty) {
      if (_selectedPlace?.address == trimmed) return;
      next = TPlaceResult(address: trimmed, coordinates: '', latitude: 0, longitude: 0);
    } else if (_selectedPlace == null) {
      return;
    }

    if (notify && mounted) {
      setState(() => _selectedPlace = next);
    } else {
      _selectedPlace = next;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultTheme =
        Theme.of(context).extension<TWidgetThemeExtension>()?.textFieldTheme ?? TTextFieldTheme.defaultTheme(Theme.of(context).colorScheme);

    final effectiveTheme = (widget.theme ?? defaultTheme).copyWith(
      labelPosition: widget.labelPosition,
      preWidget: widget.preWidget ?? widget.theme?.preWidget ?? defaultTheme.preWidget,
    );

    return TSelect<TPlaceResult, TPlaceResult, int>(
      theme: effectiveTheme,
      value: _selectedPlace,
      label: widget.label,
      placeholder: widget.placeholder ?? 'Search location...',
      onTap: widget.onTap,
      onLoad: (options) => _search.load(options.search ?? ''),
      itemText: (item) => item.address,
      onValueChanged: (val) async {
        if (val == null) return;
        final place = await _search.resolve(val);
        if (place == null || !mounted) return;
        setState(() => _selectedPlace = place);
        widget.onPlaceSelected(place);
      },
    );
  }
}
