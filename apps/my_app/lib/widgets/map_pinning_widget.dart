import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TMapPinningWidget extends StatefulWidget with TPopupMixin {
  final String label;
  final TextEditingController addressController;
  final String initialCoordinates;
  final ValueChanged<String> onCoordinatesChanged;
  final ValueChanged<String> onAddressChanged;

  @override
  final bool disabled;
  @override
  final VoidCallback? onShow;
  @override
  final VoidCallback? onHide;

  const TMapPinningWidget({
    super.key,
    required this.label,
    required this.addressController,
    required this.initialCoordinates,
    required this.onCoordinatesChanged,
    required this.onAddressChanged,
    this.disabled = false,
    this.onShow,
    this.onHide,
  });

  @override
  State<TMapPinningWidget> createState() => _TMapPinningWidgetState();

  @override
  TPopupAlignment get alignment => TPopupAlignment.bottomCenter;
}

class _TMapPinningWidgetState extends State<TMapPinningWidget> with TPopupStateMixin<TMapPinningWidget>, SingleTickerProviderStateMixin {
  late ValueNotifier<Offset> _dragOffset;
  late String _currentCoordinates;
  late String _currentAddress;
  late TextEditingController _searchController;
  late AnimationController _pinAnimationController;
  late Animation<double> _pinTranslateAnimation;
  bool _isDragging = false;
  int _zoomLevel = 15; // standard map zoom (1 to 17)

  // Current center coordinates mapping
  late double _centerLat;
  late double _centerLng;

  // Saved locations list
  List<String> _savedLocations = [];

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
    _dragOffset = ValueNotifier(const Offset(0, 0));
    _currentCoordinates = widget.initialCoordinates;
    _currentAddress = widget.addressController.text;
    _searchController = TextEditingController(text: _currentAddress);

    // Parse lat/lng
    _parseCoordinates(widget.initialCoordinates);

    _pinAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));

    _pinTranslateAnimation = Tween<double>(
      begin: 0,
      end: -15,
    ).animate(CurvedAnimation(parent: _pinAnimationController, curve: Curves.easeOutCubic));

    _loadSavedLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pinAnimationController.dispose();
    _dragOffset.dispose();
    super.dispose();
  }

  void _parseCoordinates(String coords) {
    final parts = coords.split(',');
    if (parts.length == 2) {
      _centerLat = double.tryParse(parts[0].trim()) ?? 6.9271;
      _centerLng = double.tryParse(parts[1].trim()) ?? 79.8612;
    } else {
      _centerLat = 6.9271;
      _centerLng = 79.8612;
    }
  }

  void _loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedLocations = prefs.getStringList('saved_locations') ?? [];
    });
  }

  void _saveCurrentLocation() async {
    if (_currentAddress.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final item = "$_currentAddress|$_currentCoordinates";

    // Remove if already exists to push to top (recency sorting)
    _savedLocations.remove(item);

    setState(() {
      _savedLocations.insert(0, item);
    });
    await prefs.setStringList('saved_locations', _savedLocations);
    if (mounted) {
      TToastService.success(context, "Location saved successfully!");
    }
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

  // Calculate latitude/longitude shifts from pixel displacements
  void _applyDragOffset() {
    // degrees per pixel = 360 / (2^zoom * 256)
    final double degreesPerPixel = 360.0 / (math.pow(2, _zoomLevel) * 256.0);

    // Shift base coordinates
    _centerLat = _centerLat - (_dragOffset.value.dy * degreesPerPixel);
    _centerLng = _centerLng + (_dragOffset.value.dx * degreesPerPixel);

    setState(() {
      _dragOffset.value = const Offset(0, 0); // reset drag offset to center
      _currentCoordinates = "${_centerLat.toStringAsFixed(6)}, ${_centerLng.toStringAsFixed(6)}";

      final mainAddress = _searchController.text.isNotEmpty ? _searchController.text : "Selected Location";
      if (mainAddress.contains("(Adjusted)")) {
        _currentAddress = mainAddress;
      } else {
        _currentAddress = "$mainAddress (Adjusted)";
      }
    });
  }

  void _searchLocation(String query) {
    if (query.isEmpty) return;
    double targetLat = 6.9271;
    double targetLng = 79.8612;
    String locationName = query;

    if (query.toLowerCase().contains("kandy")) {
      targetLat = 7.2906;
      targetLng = 80.6337;
    } else if (query.toLowerCase().contains("galle")) {
      targetLat = 6.0535;
      targetLng = 80.2176;
    } else if (query.toLowerCase().contains("colombo")) {
      targetLat = 6.9271;
      targetLng = 79.8612;
    }

    setState(() {
      _centerLat = targetLat;
      _centerLng = targetLng;
      _dragOffset.value = const Offset(0, 0);
      _currentCoordinates = "$_centerLat, $_centerLng";
      _currentAddress = locationName;
      _searchController.text = locationName;
    });
  }

  // Build the live open source map URL using Yandex Static Maps
  String _getMapUrl(double lat, double lng, int zoom, int w, int h) {
    return "https://static-maps.yandex.ru/1.x/?ll=$lng,$lat&z=$zoom&size=$w,$h&l=map";
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Small Static Map Pin Preview using real map API
    final mapPreview = Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            Image.network(
              _getMapUrl(_centerLat, _centerLng, 14, 120, 80),
              width: 120,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: colors.surfaceContainerLow),
            ),
            Center(child: Icon(Icons.location_on, color: colors.primary, size: 24)),
          ],
        ),
      ),
    );

    return buildWithDropdownTarget(
      child: Row(
        children: [
          GestureDetector(onTap: () => showPopup(context), child: mapPreview),
          const SizedBox(width: 12),
          Expanded(
            child: TButton(
              text: 'Confirm Location',
              icon: Icons.map_outlined,
              onPressed: (_) async {
                showPopup(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget getContentWidget(BuildContext context) {
    final colors = context.colors;
    final isMobile = MediaQuery.of(context).isMobile;

    // 1. Top Header & Search Bar (Sticky)
    final headerWidgets = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Adjust Pin Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TTextField(
                size: TInputSize.md,
                textController: _searchController,
                placeholder: 'Search area or neighborhood...',
                decorationType: TInputDecorationType.outline,
              ),
            ),
            const SizedBox(width: 8),
            TButton(
              size: TButtonSize.fromInputSize(TInputSize.md),
              icon: Icons.search,
              type: TButtonType.solid,
              onTap: () => _searchLocation(_searchController.text),
            ),
          ],
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
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth.toInt().clamp(100, 600);
                    final maxHeight = constraints.maxHeight.toInt().clamp(100, 450);

                    return GestureDetector(
                      onPanStart: (_) {
                        setState(() {
                          _isDragging = true;
                        });
                        _pinAnimationController.forward();
                      },
                      onPanUpdate: (details) {
                        _dragOffset.value += details.delta;
                      },
                      onPanEnd: (_) {
                        setState(() {
                          _isDragging = false;
                        });
                        _pinAnimationController.reverse();
                        _applyDragOffset();
                      },
                      onTapDown: (details) {
                        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
                        final tapVector = details.localPosition - center;
                        _dragOffset.value += tapVector;
                        _applyDragOffset();
                      },
                      child: Container(
                        color: colors.surfaceContainerLow,
                        child: ValueListenableBuilder<Offset>(
                          valueListenable: _dragOffset,
                          builder: (context, offset, child) {
                            return Transform.translate(offset: offset, child: child);
                          },
                          child: Image.network(
                            _getMapUrl(_centerLat, _centerLng, _zoomLevel, maxWidth, maxHeight),
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text('Could not load live map tiles.', style: TextStyle(color: colors.onSurfaceVariant)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Center(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _pinAnimationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _pinTranslateAnimation.value - 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, color: colors.primary, size: 40),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: _isDragging ? 8 : 12,
                                height: 4,
                                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.surface.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, size: 14, color: colors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              'Click or drag map to place exact pin location',
                              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () {
                            setState(() {
                              _zoomLevel = (_zoomLevel + 1).clamp(1, 17);
                            });
                          },
                          tooltip: 'Zoom In',
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () {
                            setState(() {
                              _zoomLevel = (_zoomLevel - 1).clamp(1, 17);
                            });
                          },
                          tooltip: 'Zoom Out',
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          onPressed: () {
                            setState(() {
                              _zoomLevel = 15;
                              _dragOffset.value = const Offset(0, 0);
                              _parseCoordinates(widget.initialCoordinates);
                            });
                            _applyDragOffset();
                          },
                          tooltip: 'Reset View',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                    Text('Coordinates: $_currentCoordinates', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                onTap: () async {
                  // Auto-save on confirm if not exists (last stored first)
                  if (_currentAddress.isNotEmpty) {
                    final item = "$_currentAddress|$_currentCoordinates";
                    _savedLocations.remove(item);
                    setState(() {
                      _savedLocations.insert(0, item);
                    });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setStringList('saved_locations', _savedLocations);
                  }

                  widget.onAddressChanged(_currentAddress);
                  widget.onCoordinatesChanged(_currentCoordinates);
                  widget.addressController.text = _currentAddress;
                  hidePopup();
                },
              ),
            ),
          ],
        ),
      ],
    );
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
        final addr = parts[0];
        final coords = parts.length > 1 ? parts[1] : '';

        return TCard(
          padding: const EdgeInsets.all(12),
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              setState(() {
                _currentAddress = addr;
                _currentCoordinates = coords;
                _searchController.text = addr;
                _parseCoordinates(coords);
                _dragOffset.value = const Offset(0, 0);
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
                        addr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        coords,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
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
                      text: 'Are you sure you want to remove "$addr"?',
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
          ),
        );
      },
    );

    return list;
  }
}
