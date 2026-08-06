import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:flutter_map/flutter_map.dart';

class TMap extends StatefulWidget {
  final LatLng? initialCoordinates;
  final List<TMapPin> pins;
  final List<TMapPolyline> polylines;
  final List<TMapPolygon> polygons;
  final String? googleMapApiKey;
  final double height;
  final double width;
  final bool interactive;
  final ValueChanged<LatLng>? onCoordinatesChanged;
  final MapTileType mapType;
  final double zoom;
  final double minZoom;
  final double maxZoom;
  final double borderRadius;

  const TMap({
    super.key,
    this.initialCoordinates,
    this.pins = const [],
    this.polylines = const [],
    this.polygons = const [],
    this.googleMapApiKey,
    this.height = 200,
    this.width = double.infinity,
    this.interactive = true,
    this.onCoordinatesChanged,
    this.mapType = MapTileType.osm,
    this.zoom = 15,
    this.minZoom = 4.0,
    this.maxZoom = 17.0,
    this.borderRadius = 12,
  });

  @override
  State<TMap> createState() => _TMapState();
}

class _TMapState extends State<TMap> {
  late LatLng _center;
  late double _zoomLevel;
  TMapPin? _selectedPin;
  final MapController _mapController = MapController();

  static const Duration _elevationAnimDuration = Duration(milliseconds: 180);
  static const double _pinSize = 32;
  static const double _markerBoxSize = 40;

  double _averageOf(Iterable<double> values) {
    var total = 0.0;
    var count = 0;
    for (final v in values) {
      total += v;
      count++;
    }
    if (count == 0) {
      return 0;
    }
    return total / count;
  }

  LatLng _getCalculatedCenter() => LatLng(
        _averageOf(widget.pins.map((pin) => pin.coordinates.latitude)),
        _averageOf(widget.pins.map((pin) => pin.coordinates.longitude)),
      );

  LatLng _resolveCenter() => widget.initialCoordinates ?? (widget.pins.isEmpty ? TMapConfig.mapCenter : _getCalculatedCenter());

  @override
  void initState() {
    super.initState();
    _center = _resolveCenter();
    _zoomLevel = widget.zoom;
  }

  @override
  void didUpdateWidget(TMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCoordinates != widget.initialCoordinates || oldWidget.pins != widget.pins) {
      _center = _resolveCenter();
      _mapController.move(_center, _zoomLevel);
    }
  }

  /// Shadow tone used for elevated elements. Dark surfaces need a stronger,
  /// more opaque shadow to read as "lifted"; light surfaces need a softer one
  /// or it looks muddy.
  Color _elevationShadow(bool isDark, {double strength = 1}) {
    return Colors.black.withAlpha(((isDark ? 130 : 70) * strength).round().clamp(0, 255));
  }

  // ---------------------------------------------------------------------
  // Pins
  // ---------------------------------------------------------------------

  /// The visual "ground shadow" beneath a pin — a soft radial smudge that
  /// gives the impression the pin is floating above the map surface.
  Widget _pinGroundShadow(bool isDark, bool selected) {
    return Container(
      width: selected ? 18 : 13,
      height: selected ? 8 : 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _elevationShadow(isDark, strength: selected ? 1.3 : 1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _pinCore(TMapPin pin, ColorScheme colors, bool isDark, bool selected) {
    final shadowColor = _elevationShadow(isDark, strength: selected ? 1.4 : 1);
    final shadowOffset = Offset(0, selected ? 4 : 2);
    final shadowBlur = selected ? 8.0 : 4.0;

    if (pin.customBuilder != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: shadowBlur, offset: shadowOffset)],
        ),
        child: pin.customBuilder!(context),
      );
    }
    if (pin.assetPath != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: shadowBlur, offset: shadowOffset)],
        ),
        child: Image.asset(pin.assetPath!, width: _pinSize, height: _pinSize),
      );
    }
    return Icon(
      pin.icon ?? Icons.location_on,
      color: colors.primary,
      size: _pinSize,
      shadows: [Shadow(color: shadowColor, blurRadius: shadowBlur, offset: shadowOffset)],
    );
  }

  /// Builds the full pin widget (ground shadow + lifted icon + optional
  /// label), shared between the interactive marker layer and the static
  /// center pin so the visual treatment never drifts out of sync.
  Widget _buildPin(TMapPin pin, ColorScheme colors, bool isDark, {required bool selected}) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          bottom: 0,
          child: _pinGroundShadow(isDark, selected),
        ),
        AnimatedScale(
          scale: selected ? 1.15 : 1.0,
          duration: _elevationAnimDuration,
          curve: Curves.easeOutBack,
          child: AnimatedSlide(
            offset: Offset(0, selected ? -0.12 : 0),
            duration: _elevationAnimDuration,
            curve: Curves.easeOut,
            child: SizedBox(
              width: _markerBoxSize,
              height: _markerBoxSize,
              child: Center(child: _pinCore(pin, colors, isDark, selected)),
            ),
          ),
        ),
        if (pin.label != null)
          Positioned(
            left: 36,
            top: 12,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                pin.label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                  shadows: [Shadow(color: colors.surface.withAlpha(200), blurRadius: 3)],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Info window / zoom controls (shared chrome)
  // ---------------------------------------------------------------------

  Widget _buildInfoWindowContent(TMapPin pin, ColorScheme colors) {
    return Material(
      elevation: 6,
      shadowColor: colors.shadow,
      color: colors.surface.withAlpha(245),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 200,
        padding: const EdgeInsets.fromLTRB(8, 8, 28, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Stack(
          children: [
            pin.infoWindowBuilder!(context)!,
            Positioned(
              top: -4,
              right: -20,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _selectedPin = null),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.close, size: 14, color: colors.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls(ColorScheme colors, {required VoidCallback onAdd, required VoidCallback onRemove}) {
    return Material(
      elevation: 3,
      shadowColor: colors.shadow,
      color: colors.surface.withAlpha(225),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outlineVariant),
        ),
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.add, size: 16, color: colors.onSurface),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
              onPressed: onAdd,
            ),
            const SizedBox(height: 2),
            IconButton(
              icon: Icon(Icons.remove, size: 16, color: colors.onSurface),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Polylines / polygons — "casing" technique gives raised/embossed feel
  // ---------------------------------------------------------------------

  /// Draws a wider, soft-toned line underneath each real polyline (a
  /// "casing"), the standard cartography trick for making a line look like
  /// it sits above the map rather than being printed flat onto it.
  List<Widget> _buildPolylineLayers(bool isDark) {
    if (widget.polylines.isEmpty) return const [];
    final casingColor = _elevationShadow(isDark, strength: 1.1);
    return [
      PolylineLayer(
        polylines: widget.polylines
            .map((p) => Polyline(
                  points: p.points,
                  color: casingColor,
                  strokeWidth: p.strokeWidth + 3,
                ))
            .toList(),
      ),
      PolylineLayer(
        polylines: widget.polylines
            .map((p) => Polyline(
                  points: p.points,
                  color: p.color,
                  strokeWidth: p.strokeWidth,
                ))
            .toList(),
      ),
    ];
  }

  /// Draws a soft shadow ring behind each polygon's outline before the real
  /// fill/border, so filled regions read as raised rather than flat.
  List<Widget> _buildPolygonLayers(ColorScheme colors, bool isDark) {
    if (widget.polygons.isEmpty) return const [];
    final shadowColor = _elevationShadow(isDark, strength: 1);
    return [
      PolygonLayer(
        polygons: widget.polygons
            .map((p) => Polygon(
                  points: p.points,
                  color: Colors.transparent,
                  borderColor: shadowColor,
                  borderStrokeWidth: p.borderWidth + 4,
                ))
            .toList(),
      ),
      PolygonLayer(
        polygons: widget.polygons
            .map((p) => Polygon(
                  points: p.points,
                  color: p.color,
                  borderColor: p.borderColor ?? colors.outline,
                  borderStrokeWidth: p.borderWidth,
                ))
            .toList(),
      ),
    ];
  }

  // ---------------------------------------------------------------------
  // Interactive map
  // ---------------------------------------------------------------------

  Widget _buildMap(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    final pinMarkers = widget.pins.map((pin) {
      final isCustom = pin.customBuilder != null || pin.assetPath != null;
      final defaultAlignment = isCustom ? Alignment.center : Alignment.topCenter;
      final alignment = pin.alignment ?? defaultAlignment;
      final isSelected = identical(_selectedPin, pin);

      return Marker(
        point: pin.coordinates,
        width: _markerBoxSize,
        height: _markerBoxSize,
        alignment: alignment,
        child: GestureDetector(
          onTap: widget.interactive ? () => setState(() => _selectedPin = pin) : null,
          child: _buildPin(pin, colors, isDark, selected: isSelected),
        ),
      );
    }).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: _zoomLevel.toDouble(),
            minZoom: widget.minZoom,
            maxZoom: widget.maxZoom,
            interactionOptions: InteractionOptions(
              flags: widget.interactive ? InteractiveFlag.all : InteractiveFlag.none,
            ),
            onTap: widget.interactive
                ? (tapPosition, point) {
                    setState(() => _selectedPin = null);
                    widget.onCoordinatesChanged?.call(point);
                  }
                : null,
          ),
          children: [
            buildTileLayer(mapType: MapTileType.osm, darkMode: isDark),
            ..._buildPolygonLayers(colors, isDark),
            ..._buildPolylineLayers(isDark),
            MarkerLayer(
              markers: [
                ...pinMarkers,
                if (_selectedPin?.infoWindowBuilder != null)
                  Marker(
                    point: _selectedPin!.coordinates,
                    width: 200,
                    height: 120,
                    alignment: const Alignment(0.0, -1.6),
                    child: _buildInfoWindowContent(_selectedPin!, colors),
                  ),
              ],
            ),
          ],
        ),
        if (widget.interactive)
          Positioned(
            bottom: 8,
            right: 8,
            child: _buildZoomControls(
              colors,
              onAdd: () {
                setState(() => _zoomLevel = (_zoomLevel + 1).clamp(widget.minZoom, widget.maxZoom));
                _mapController.move(_mapController.camera.center, _zoomLevel.toDouble());
              },
              onRemove: () {
                setState(() => _zoomLevel = (_zoomLevel - 1).clamp(widget.minZoom, widget.maxZoom));
                _mapController.move(_mapController.camera.center, _zoomLevel.toDouble());
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: _buildMap(context),
      ),
    );
  }
}
