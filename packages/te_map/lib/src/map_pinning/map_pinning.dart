import 'dart:async';
import 'package:dio/dio.dart';
import '../google_places_client.dart';
import '../openstreet_client.dart';
import '../route_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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

  // Single Point / Primary (From)
  final LatLng? initialCoordinates;
  final TextEditingController? addressController;
  final ValueChanged<LatLng>? onCoordinatesChanged;
  final ValueChanged<String>? onAddressChanged;
  final String? googleMapApiKey;
  final TLoadListener<TPlaceResult>? onLoad;

  // Two-Points (From & To) Support
  final bool isTwoPoints;
  final String? fromLabel;
  final String? toLabel;
  final String? fromPlaceholder;
  final String? toPlaceholder;
  final LatLng? initialFromCoordinates;
  final LatLng? initialToCoordinates;
  final TextEditingController? fromAddressController;
  final TextEditingController? toAddressController;
  final ValueChanged<LatLng>? onFromCoordinatesChanged;
  final ValueChanged<LatLng>? onToCoordinatesChanged;
  final ValueChanged<String>? onFromAddressChanged;
  final ValueChanged<String>? onToAddressChanged;
  final ValueChanged<TRouteResult>? onRouteChanged;
  final ValueChanged<double>? onDistanceChanged;

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
    // Two points mode parameters
    this.isTwoPoints = false,
    this.fromLabel,
    this.toLabel,
    this.fromPlaceholder,
    this.toPlaceholder,
    this.initialFromCoordinates,
    this.initialToCoordinates,
    this.fromAddressController,
    this.toAddressController,
    this.onFromCoordinatesChanged,
    this.onToCoordinatesChanged,
    this.onFromAddressChanged,
    this.onToAddressChanged,
    this.onRouteChanged,
    this.onDistanceChanged,
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
  double get contentMinHeight => widget.isTwoPoints ? 720 : 650;

  @override
  double? get contentMaxWidth => 800;

  @override
  double? get contentMaxHeight => widget.isTwoPoints ? 700 : 660;

  @override
  TPopupMode get effectivePopupMode {
    return MediaQuery.of(context).isMobile ? TPopupMode.page : TPopupMode.centered;
  }

  @override
  void showPopup(BuildContext context) {
    if (widget.isTwoPoints) {
      activePoint = TMapPointType.to;
      if (fromAddress.isEmpty) {
        fromAddress = 'Your location';
        fromSearchController.text = 'Your location';
      }
    }
    super.showPopup(context);
  }

  void _swapPoints() {
    if (toCoordinates == null) return;
    setState(() {
      final tempCoords = fromCoordinates;
      final tempAddr = fromAddress;

      fromCoordinates = toCoordinates!;
      fromAddress = toAddress;
      fromSearchController.text = fromAddress;

      toCoordinates = tempCoords;
      toAddress = tempAddr;
      toSearchController.text = toAddress;
    });

    widget.onFromAddressChanged?.call(fromAddress);
    widget.onFromCoordinatesChanged?.call(fromCoordinates);
    widget.fromAddressController?.text = fromAddress;

    widget.onToAddressChanged?.call(toAddress);
    widget.onToCoordinatesChanged?.call(toCoordinates!);
    widget.toAddressController?.text = toAddress;

    calculateRouteIfNeeded();
  }

  @override
  void initState() {
    super.initState();
    fromCoordinates = widget.initialFromCoordinates ?? widget.initialCoordinates ?? TMapConfig.mapCenter;
    fromAddress = widget.fromAddressController?.text ?? widget.addressController?.text ?? '';
    fromSearchController = TextEditingController(text: fromAddress);

    toCoordinates = widget.initialToCoordinates;
    toAddress = widget.toAddressController?.text ?? '';
    toSearchController = TextEditingController(text: toAddress);

    activePoint = widget.isTwoPoints ? TMapPointType.to : TMapPointType.from;
    center = fromCoordinates;
    pin = fromCoordinates;

    getCurrentLocationAndSync();
  }

  @override
  void didUpdateWidget(TMapPinning oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newFromCoords = widget.initialFromCoordinates ?? widget.initialCoordinates;
    final oldFromCoords = oldWidget.initialFromCoordinates ?? oldWidget.initialCoordinates;
    if (newFromCoords != oldFromCoords && newFromCoords != null) {
      setState(() {
        fromCoordinates = newFromCoords;
        if (activePoint == TMapPointType.from) {
          center = newFromCoords;
          pin = newFromCoords;
        }
      });
      if (widget.isTwoPoints && toCoordinates != null) {
        calculateRouteIfNeeded();
      }
    }

    if (widget.initialToCoordinates != oldWidget.initialToCoordinates && widget.initialToCoordinates != null) {
      setState(() {
        toCoordinates = widget.initialToCoordinates;
        if (activePoint == TMapPointType.to) {
          center = widget.initialToCoordinates!;
          pin = widget.initialToCoordinates!;
        }
      });
      if (widget.isTwoPoints) {
        calculateRouteIfNeeded();
      }
    }

    final newFromAddr = widget.fromAddressController?.text ?? widget.addressController?.text;
    final oldFromAddr = oldWidget.fromAddressController?.text ?? oldWidget.addressController?.text;
    if (newFromAddr != oldFromAddr && newFromAddr != null) {
      setState(() {
        fromAddress = newFromAddr;
        fromSearchController.text = newFromAddr;
      });
    }

    if (widget.toAddressController?.text != oldWidget.toAddressController?.text && widget.toAddressController?.text != null) {
      setState(() {
        toAddress = widget.toAddressController!.text;
        toSearchController.text = widget.toAddressController!.text;
      });
    }
  }

  @override
  void dispose() {
    fromSearchController.dispose();
    toSearchController.dispose();
    reverseGeocodeDebounce?.cancel();
    routeCalculateDebounce?.cancel();
    super.dispose();
  }

  @override
  TInputFieldTheme get wTheme => (widget.theme ??
          Theme.of(context).extension<TWidgetThemeExtension>()?.inputFieldTheme ??
          TInputFieldTheme.defaultTheme(Theme.of(context).colorScheme))
      .copyWith(
    labelPosition: TLabelPosition.aboveField,
  );

  List<TMapPin> _buildMapPins(BuildContext context) {
    final colors = context.colors;
    if (!widget.isTwoPoints || toCoordinates == null) {
      return [
        TMapPin(
          coordinates: fromCoordinates,
          label: fromAddress.isNotEmpty ? fromAddress : 'Your location',
          icon: Icons.location_on,
          iconColor: colors.primary,
        ),
      ];
    }

    return [
      TMapPin(
        coordinates: fromCoordinates,
        label: fromAddress.isNotEmpty ? fromAddress : (widget.fromLabel ?? 'Pickup Point'),
        icon: Icons.trip_origin,
        iconColor: Colors.green,
      ),
      TMapPin(
        coordinates: toCoordinates!,
        label: toAddress.isNotEmpty ? toAddress : (widget.toLabel ?? 'Drop-off Point'),
        icon: Icons.location_on,
        iconColor: Colors.redAccent,
      ),
    ];
  }

  List<TMapPolyline> _buildMapPolylines(BuildContext context) {
    if (!widget.isTwoPoints || routeResult == null || routeResult!.points.isEmpty) {
      return const [];
    }
    return [
      TMapPolyline(
        points: routeResult!.points,
        color: context.colors.primary,
        strokeWidth: 4.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isTwo = widget.isTwoPoints;
    // Map container size is doubled when two points (200 vs 100)
    final double mapHeight = isTwo ? 200.0 : 100.0;

    final pins = _buildMapPins(context);
    final polylines = _buildMapPolylines(context);

    final mapWidget = Container(
      height: mapHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant.withAlpha(120)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: TMap(
                initialCoordinates: isTwo && toCoordinates != null
                    ? LatLng((fromCoordinates.latitude + toCoordinates!.latitude) / 2, (fromCoordinates.longitude + toCoordinates!.longitude) / 2)
                    : fromCoordinates,
                zoom: isTwo && toCoordinates != null ? 13 : zoomLevel,
                interactive: false,
                googleMapApiKey: widget.googleMapApiKey,
                height: mapHeight,
                borderRadius: 10,
                pins: pins,
                polylines: polylines,
              ),
            ),

            // Floating Distance & Duration Badge in Two Points Mode
            if (isTwo && routeResult != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surface.withAlpha(235),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                    border: Border.all(color: colors.outlineVariant.withAlpha(120)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car_rounded, size: 14, color: colors.primary),
                      const SizedBox(width: 5),
                      Text(
                        '${routeResult!.formattedDistance} • ${routeResult!.formattedDuration}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.onSurface),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom Input / Trigger Container
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: isTwo ? _buildTwoPointsTriggerContainer(context) : _buildSinglePointTriggerContainer(context),
            ),
          ],
        ),
      ),
    );

    return buildWithDropdownTarget(
      child: buildWrapper(
        child: mapWidget,
      ),
    );
  }

  Widget _buildSinglePointTriggerContainer(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final displayText = fromAddress.isNotEmpty ? fromAddress : (widget.placeholder ?? 'Select location');
    final hasAddress = fromAddress.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showPopup(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xE61E293B) : Colors.white.withAlpha(240),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.outlineVariant.withAlpha(120)),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: hasAddress ? colors.onSurface : colors.onSurfaceVariant,
                    fontWeight: hasAddress ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.search, size: 16, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTwoPointsTriggerContainer(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showPopup(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xE61E293B) : Colors.white.withAlpha(240),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.outlineVariant.withAlpha(120)),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // From (Pickup) Field
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fromAddress.isNotEmpty ? fromAddress : (widget.fromPlaceholder ?? 'Select pickup location'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: fromAddress.isNotEmpty ? colors.onSurface : colors.onSurfaceVariant,
                        fontWeight: fromAddress.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),

              // Horizontal Separator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Divider(height: 1, thickness: 1, color: colors.outlineVariant.withAlpha(120)),
              ),

              // To (Drop-off) Field
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      toAddress.isNotEmpty ? toAddress : (widget.toPlaceholder ?? 'Select drop-off location'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: toAddress.isNotEmpty ? colors.onSurface : colors.onSurfaceVariant,
                        fontWeight: toAddress.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget getContentWidget(BuildContext context) {
    final isMobile = MediaQuery.of(context).isMobile;

    // 1. Top Header & Place AutoComplete Search Bar(s)
    final headerWidgets = widget.isTwoPoints ? _buildTwoPointsHeader(context) : _buildSinglePointHeader(context);

    // 2. Middle Content: Map + Saved Locations List
    final middleWidgets = _buildMiddleContent(context);

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
          height: widget.isTwoPoints ? 640 : 580,
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

  LatLngBounds? _buildMapBounds() {
    if (!widget.isTwoPoints || toCoordinates == null) return null;
    final List<LatLng> points = [];
    if (routeResult != null && routeResult!.points.isNotEmpty) {
      points.addAll(routeResult!.points);
    } else {
      points.add(fromCoordinates);
      points.add(toCoordinates!);
    }
    if (points.length < 2) return null;
    return LatLngBounds.fromPoints(points);
  }

  Widget _buildSinglePointHeader(BuildContext context) {
    final colors = context.colors;
    return Column(
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
            LatLng? coordinates;
            if (details.latitude != 0.0 || details.longitude != 0.0) {
              coordinates = LatLng(details.latitude, details.longitude);
            } else if (details.coordinates.isNotEmpty) {
              try {
                coordinates = parseCoordinates(details.coordinates);
              } catch (_) {}
            }
            if (coordinates == null) return;

            setState(() {
              hasInteracted = true;
              center = coordinates!;
              pin = coordinates;
              fromCoordinates = coordinates;
              fromAddress = details.address;
              fromSearchController.text = details.address;
            });
            widget.onAddressChanged?.call(details.address);
            widget.onCoordinatesChanged?.call(coordinates);
            widget.addressController?.text = details.address;
            widget.onFromAddressChanged?.call(details.address);
            widget.onFromCoordinatesChanged?.call(coordinates);
            widget.fromAddressController?.text = details.address;
          },
        ),
      ],
    );
  }

  Widget _buildTwoPointsHeader(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.onSurface),
        ),
      ],
    );
  }

  Widget _buildTwoPointsSearchCard(BuildContext context) {
    final colors = context.colors;

    return TCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // From (Pickup) Section
          InkWell(
            onTap: () => setState(() => activePoint = TMapPointType.from),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                children: [
                  Container(width: 9, height: 9, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fromAddress.isNotEmpty ? fromAddress : 'Your location',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: activePoint == TMapPointType.from ? colors.primary : colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Coordinates: ${fromCoordinates.formattedString}',
                          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (activePoint == TMapPointType.from)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Active', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),

          // Divider with Swap Action
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(child: Divider(color: colors.outlineVariant.withAlpha(120), height: 1, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: InkWell(
                    onTap: _swapPoints,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.swap_vert_rounded, size: 16, color: colors.onSurfaceVariant),
                    ),
                  ),
                ),
                Expanded(child: Divider(color: colors.outlineVariant.withAlpha(120), height: 1, thickness: 1)),
              ],
            ),
          ),

          // To (Drop-off) Section
          InkWell(
            onTap: () => setState(() => activePoint = TMapPointType.to),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toAddress.isNotEmpty
                              ? toAddress
                              : (toCoordinates != null ? 'Coordinates: ${toCoordinates!.formattedString}' : (widget.toLabel ?? 'Select drop-off location')),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: toCoordinates != null
                                ? (activePoint == TMapPointType.to ? colors.primary : colors.onSurface)
                                : colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          toCoordinates != null ? 'Coordinates: ${toCoordinates!.formattedString}' : 'Tap map or search below to set destination',
                          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (activePoint == TMapPointType.to)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Active', style: TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),

          // Route distance & duration summary row
          if (routeResult != null) ...[
            Divider(color: colors.outlineVariant.withAlpha(120), height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.route_outlined, size: 15, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Estimated Route Distance:',
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(
                  '${routeResult!.formattedDistance} (${routeResult!.formattedDuration})',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiddleContent(BuildContext context) {
    final colors = context.colors;
    final pins = _buildMapPins(context);
    final polylines = _buildMapPolylines(context);
    final mapBounds = _buildMapBounds();
    final double mapHeight = widget.isTwoPoints ? 260.0 : 220.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Map Viewport (Doubled height in two points mode)
        SizedBox(
          height: mapHeight,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: TMap(
                  initialCoordinates: center,
                  bounds: mapBounds,
                  boundsPadding: const EdgeInsets.all(52),
                  zoom: widget.isTwoPoints && toCoordinates != null ? 13 : zoomLevel,
                  interactive: true,
                  googleMapApiKey: widget.googleMapApiKey,
                  height: mapHeight,
                  onCoordinatesChanged: onPinMoved,
                  pins: pins,
                  polylines: polylines,
                ),
              ),

              // Route Info Header Overlay
              if (widget.isTwoPoints && routeResult != null)
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.surface.withAlpha(240),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                        border: Border.all(color: colors.outlineVariant.withAlpha(150)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_car_filled_rounded, size: 16, color: colors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Distance: ${routeResult!.formattedDistance}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.onSurface),
                          ),
                          const SizedBox(width: 8),
                          Text('•', style: TextStyle(color: colors.onSurfaceVariant)),
                          const SizedBox(width: 8),
                          Text(
                            routeResult!.formattedDuration,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Active Point Hint Bar on Map
              if (widget.isTwoPoints)
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.surface.withAlpha(220),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.outlineVariant.withAlpha(120)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          activePoint == TMapPointType.from ? Icons.trip_origin : Icons.location_on,
                          size: 13,
                          color: activePoint == TMapPointType.from ? Colors.green : Colors.redAccent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Tap map to set ${activePoint == TMapPointType.from ? (widget.fromLabel ?? "Pickup Point") : (widget.toLabel ?? "Drop-off Point")}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // In Two-Points Mode: Summary Card + Search Bar situated below the map
        if (widget.isTwoPoints) ...[
          _buildTwoPointsSearchCard(context),
          const SizedBox(height: 12),
          TPlaceAutoComplete(
            googleMapApiKey: widget.googleMapApiKey,
            onLoad: widget.onLoad,
            placeholder: activePoint == TMapPointType.from
                ? (widget.fromPlaceholder ?? 'Search pickup location...')
                : (widget.toPlaceholder ?? 'Search drop-off location...'),
            selectedAddress: searchFieldAddress,
            onPlaceSelected: (details) {
              LatLng? coordinates;
              if (details.latitude != 0.0 || details.longitude != 0.0) {
                coordinates = LatLng(details.latitude, details.longitude);
              } else if (details.coordinates.isNotEmpty) {
                try {
                  coordinates = parseCoordinates(details.coordinates);
                } catch (_) {}
              }
              if (coordinates == null) return;

              setState(() {
                hasInteracted = true;
                center = coordinates!;
                pin = coordinates;
                if (activePoint == TMapPointType.from) {
                  fromCoordinates = coordinates;
                  fromAddress = details.address;
                  fromSearchController.text = details.address;
                } else {
                  toCoordinates = coordinates;
                  toAddress = details.address;
                  toSearchController.text = details.address;
                }
              });
              if (activePoint == TMapPointType.from) {
                widget.onFromAddressChanged?.call(details.address);
                widget.onFromCoordinatesChanged?.call(coordinates);
                widget.fromAddressController?.text = details.address;
                widget.onAddressChanged?.call(details.address);
                widget.onCoordinatesChanged?.call(coordinates);
                widget.addressController?.text = details.address;
              } else {
                widget.onToAddressChanged?.call(details.address);
                widget.onToCoordinatesChanged?.call(coordinates);
                widget.toAddressController?.text = details.address;
              }
              if (toCoordinates != null) {
                calculateRouteIfNeeded();
              }
            },
          ),
          const SizedBox(height: 12),
        ],

        // Saved Locations & Recent Selections
        TSavedLocationsList(
          key: _savedLocationsKey,
          onLocationSelected: (coordinates) {
            setState(() {
              hasInteracted = false;
              center = coordinates;
              pin = coordinates;
              if (!widget.isTwoPoints || activePoint == TMapPointType.from) {
                fromCoordinates = coordinates;
              } else {
                toCoordinates = coordinates;
              }
            });
            if (widget.isTwoPoints && toCoordinates != null) {
              calculateRouteIfNeeded();
            }
          },
          onAddressSelected: (address) {
            setState(() {
              if (!widget.isTwoPoints || activePoint == TMapPointType.from) {
                fromAddress = address;
                fromSearchController.text = address;
                widget.onFromAddressChanged?.call(address);
                widget.onAddressChanged?.call(address);
                widget.fromAddressController?.text = address;
                widget.addressController?.text = address;
              } else {
                toAddress = address;
                toSearchController.text = address;
                widget.onToAddressChanged?.call(address);
                widget.toAddressController?.text = address;
              }
            });
            if (widget.isTwoPoints && toCoordinates != null) {
              calculateRouteIfNeeded();
            }
          },
        ),
        TPreviousSelectionsList(
          onLocationSelected: (coordinates) {
            setState(() {
              hasInteracted = false;
              center = coordinates;
              pin = coordinates;
              if (!widget.isTwoPoints || activePoint == TMapPointType.from) {
                fromCoordinates = coordinates;
              } else {
                toCoordinates = coordinates;
              }
            });
            if (widget.isTwoPoints && toCoordinates != null) {
              calculateRouteIfNeeded();
            }
          },
          onAddressSelected: (address) {
            setState(() {
              if (!widget.isTwoPoints || activePoint == TMapPointType.from) {
                fromAddress = address;
                fromSearchController.text = address;
                widget.onFromAddressChanged?.call(address);
                widget.onAddressChanged?.call(address);
                widget.fromAddressController?.text = address;
                widget.addressController?.text = address;
              } else {
                toAddress = address;
                toSearchController.text = address;
                widget.onToAddressChanged?.call(address);
                widget.toAddressController?.text = address;
              }
            });
            if (widget.isTwoPoints && toCoordinates != null) {
              calculateRouteIfNeeded();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget? getPopupFooter(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0), child: _buildFooter(context));
  }

  Widget _buildFooter(BuildContext context) {
    return widget.isTwoPoints ? _buildTwoPointsFooter(context) : _buildSinglePointFooter(context);
  }

  Widget _buildSinglePointFooter(BuildContext context) {
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
                      fromAddress.isNotEmpty ? fromAddress : 'Selected Address',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Coordinates: ${fromCoordinates.formattedString}',
                      style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (hasInteracted && fromAddress.isNotEmpty)
                TButton(
                  icon: Icons.bookmark_add_outlined,
                  type: TButtonType.outline,
                  onTap: () => _savedLocationsKey.currentState?.saveCurrentLocation(fromAddress, fromCoordinates),
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
              onTap: () => hidePopup(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TButton(
                text: 'Confirm Location',
                loading: true,
                loadingText: 'Resolving...',
                onPressed: (options) async {
                  setState(() {
                    center = fromCoordinates;
                  });

                  await resolveAddressIfNeeded(force: true, pointType: TMapPointType.from);

                  if (fromAddress.isEmpty || isAddressPlaceholder(fromAddress)) {
                    setState(() {
                      fromAddress =
                          'Selected Location (${fromCoordinates.latitude.toStringAsFixed(5)}, ${fromCoordinates.longitude.toStringAsFixed(5)})';
                      fromSearchController.text = fromAddress;
                    });
                  }

                  widget.onAddressChanged?.call(fromAddress);
                  widget.onCoordinatesChanged?.call(fromCoordinates);
                  widget.addressController?.text = fromAddress;
                  widget.onFromAddressChanged?.call(fromAddress);
                  widget.onFromCoordinatesChanged?.call(fromCoordinates);
                  widget.fromAddressController?.text = fromAddress;

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

  Widget _buildTwoPointsFooter(BuildContext context) {
    return Row(
      children: [
        TButton(
          text: 'Cancel',
          type: TButtonType.outline,
          onTap: () => hidePopup(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TButton(
            text: 'Confirm Route',
            loading: true,
            loadingText: 'Resolving...',
            onPressed: (options) async {
              await resolveAddressIfNeeded(force: true, pointType: TMapPointType.from);
              if (toCoordinates != null) {
                await resolveAddressIfNeeded(force: true, pointType: TMapPointType.to);
              }

              if (fromAddress.isEmpty || isAddressPlaceholder(fromAddress)) {
                setState(() {
                  fromAddress =
                      'Pickup Location (${fromCoordinates.latitude.toStringAsFixed(5)}, ${fromCoordinates.longitude.toStringAsFixed(5)})';
                  fromSearchController.text = fromAddress;
                });
              }

              if (toCoordinates != null && (toAddress.isEmpty || isAddressPlaceholder(toAddress))) {
                setState(() {
                  toAddress =
                      'Drop-off Location (${toCoordinates!.latitude.toStringAsFixed(5)}, ${toCoordinates!.longitude.toStringAsFixed(5)})';
                  toSearchController.text = toAddress;
                });
              }

              if (toCoordinates != null && routeResult == null) {
                await calculateRouteIfNeeded();
              }

              // Fire callbacks
              widget.onFromAddressChanged?.call(fromAddress);
              widget.onFromCoordinatesChanged?.call(fromCoordinates);
              widget.fromAddressController?.text = fromAddress;

              if (toCoordinates != null) {
                widget.onToAddressChanged?.call(toAddress);
                widget.onToCoordinatesChanged?.call(toCoordinates!);
                widget.toAddressController?.text = toAddress;
              }

              if (routeResult != null) {
                widget.onRouteChanged?.call(routeResult!);
                widget.onDistanceChanged?.call(routeResult!.distanceMeters);
              }

              // Single mode compatibility
              widget.onAddressChanged?.call(fromAddress);
              widget.onCoordinatesChanged?.call(fromCoordinates);
              widget.addressController?.text = fromAddress;

              options.stopLoading();
              hidePopup();
            },
          ),
        ),
      ],
    );
  }
}
