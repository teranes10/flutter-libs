import 'dart:async';
import 'package:dio/dio.dart';
import '../google_places_client.dart';
import '../openstreet_client.dart';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:latlong2/latlong.dart';
import '../map.dart';
import '../map_config.dart';
import '../place_autocomplete.dart';
import '../extensions/latlng_x.dart';
import '../extensions/position_x.dart';
import '../helpers/location/location_helper.dart';

import 'saved_locations_list.dart';
import 'previous_selections_list.dart';

part 'map_pinning_base.dart';

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

class _TMapPinningState extends _TMapPinningStateBase {
  final GlobalKey<TSavedLocationsListState> _savedLocationsKey = GlobalKey<TSavedLocationsListState>();

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
    currentCoordinates = widget.initialCoordinates ?? TMapConfig.mapCenter;
    currentAddress = widget.addressController?.text ?? '';
    searchController = TextEditingController(text: currentAddress);

    center = currentCoordinates;
    pin = currentCoordinates;

    getCurrentLocationAndSync();
  }

  @override
  void didUpdateWidget(TMapPinning oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCoordinates != oldWidget.initialCoordinates && widget.initialCoordinates != null) {
      setState(() {
        currentCoordinates = widget.initialCoordinates!;
        center = widget.initialCoordinates!;
        pin = widget.initialCoordinates!;
      });
    }
    if (widget.addressController?.text != oldWidget.addressController?.text && widget.addressController?.text != null) {
      setState(() {
        currentAddress = widget.addressController!.text;
        searchController.text = widget.addressController!.text;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  TInputFieldTheme get wTheme => (widget.theme ?? context.theme.inputFieldTheme).copyWith(
    size: TInputSize.xs,
    decorationType: TInputDecorationType.filled,
    backgroundColor: WidgetStateProperty.all(colors.surface.withAlpha(175)),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final mapWidget = Container(
      height: 100,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: TMap(
              initialCoordinates: center,
              zoom: zoomLevel,
              interactive: false,
              googleMapApiKey: widget.googleMapApiKey,
              height: 100,
              borderRadius: 10,
              pins: [TMapPin(coordinates: pin, label: currentAddress.isNotEmpty ? currentAddress : 'Your location')],
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: buildContainer(
              hasValue: currentAddress.isNotEmpty,
              onTap: () {
                showPopup(context);
              },
              child: Text(
                currentAddress,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: colors.onSurface, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );

    return buildWithDropdownTarget(child: mapWidget);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    final colors = context.colors;
    final isMobile = MediaQuery.of(context).isMobile;

    // 1. Top Header & Place AutoComplete Search Bar (Sticky)
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
          selectedAddress: searchFieldAddress,
          onPlaceSelected: (details) {
            final coordinates = parseCoordinates(details.coordinates);
            setState(() {
              hasInteracted = true;
              center = coordinates;
              pin = coordinates;
              currentCoordinates = coordinates;
              currentAddress = details.address;
              searchController.text = details.address;
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
              initialCoordinates: center,
              zoom: zoomLevel,
              interactive: true,
              googleMapApiKey: widget.googleMapApiKey,
              height: 320,
              onCoordinatesChanged: onPinMoved,
              pins: [TMapPin(coordinates: pin, label: currentAddress.isNotEmpty ? currentAddress : 'Selected Pin')],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TSavedLocationsList(
          key: _savedLocationsKey,
          onLocationSelected: (coordinates) {
            setState(() {
              hasInteracted = false;
              center = coordinates;
              pin = coordinates;
              currentCoordinates = coordinates;
            });
          },
          onAddressSelected: (address) {
            setState(() {
              currentAddress = address;
              searchController.text = address;
            });
          },
        ),
        TPreviousSelectionsList(
          onLocationSelected: (coordinates) {
            setState(() {
              hasInteracted = false;
              center = coordinates;
              pin = coordinates;
              currentCoordinates = coordinates;
            });
          },
          onAddressSelected: (address) {
            setState(() {
              currentAddress = address;
              searchController.text = address;
            });
          },
        ),
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
                      currentAddress.isNotEmpty ? currentAddress : 'Selected Address',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Coordinates: ${currentCoordinates.formattedString}',
                      style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (hasInteracted && currentAddress.isNotEmpty)
                TButton(
                  icon: Icons.bookmark_add_outlined,
                  type: TButtonType.outline,
                  onTap: () => _savedLocationsKey.currentState?.saveCurrentLocation(currentAddress, currentCoordinates),
                ),
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
                    center = currentCoordinates;
                  });

                  await resolveAddressIfNeeded(force: true);

                  if (currentAddress.isEmpty || currentAddress.startsWith('Looking up') || currentAddress.contains('(Adjusted)')) {
                    setState(() {
                      currentAddress =
                          'Selected Location (${currentCoordinates.latitude.toStringAsFixed(5)}, ${currentCoordinates.longitude.toStringAsFixed(5)})';
                      searchController.text = currentAddress;
                    });
                  }

                  if (currentAddress.isNotEmpty) {}

                  widget.onAddressChanged?.call(currentAddress);
                  widget.onCoordinatesChanged?.call(currentCoordinates);
                  widget.addressController?.text = currentAddress;
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
}
