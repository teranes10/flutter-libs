import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:te_widgets/te_widgets.dart';

import '../place_autocomplete.dart';
import '../route_result.dart';
import 'map_picker.dart';
import 'map_picker_controller.dart';

/// A read-only location field. Tapping it opens a picker: a dialog on large
/// screens, two pages (choose, then adjust on the map) on mobile.
///
/// With [isTwoPoints] it shows a From / To pair inside one container and the
/// picker draws the route and distance between both points.
class TMapPinning extends StatefulWidget {
  final String label;

  final String? placeholder;

  final String? tag;

  final String? helperText;

  final bool isRequired;

  final bool disabled;

  final String? info;

  final bool clearable;

  final TInputFieldTheme? theme;

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

  final VoidCallback? onShow;

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
}

class _TMapPinningState extends State<TMapPinning> {
  LatLng? _from;
  LatLng? _to;
  String _fromAddress = '';
  String _toAddress = '';
  TRouteResult? _route;

  TextEditingController? get _fromExternal => widget.fromAddressController ?? widget.addressController;
  TextEditingController? get _toExternal => widget.toAddressController;

  @override
  void initState() {
    super.initState();
    _from = widget.initialFromCoordinates ?? widget.initialCoordinates;
    _to = widget.initialToCoordinates;
    _fromAddress = _fromExternal?.text ?? '';
    _toAddress = _toExternal?.text ?? '';
    _fromExternal?.addListener(_onFromExternal);
    _toExternal?.addListener(_onToExternal);
  }

  @override
  void didUpdateWidget(TMapPinning old) {
    super.didUpdateWidget(old);
    if ((old.fromAddressController ?? old.addressController) != _fromExternal) {
      (old.fromAddressController ?? old.addressController)?.removeListener(_onFromExternal);
      _fromExternal?.addListener(_onFromExternal);
    }
    if (old.toAddressController != _toExternal) {
      old.toAddressController?.removeListener(_onToExternal);
      _toExternal?.addListener(_onToExternal);
    }
    final newFrom = widget.initialFromCoordinates ?? widget.initialCoordinates;
    if (newFrom != null && newFrom != (old.initialFromCoordinates ?? old.initialCoordinates)) _from = newFrom;
    if (widget.initialToCoordinates != null && widget.initialToCoordinates != old.initialToCoordinates) _to = widget.initialToCoordinates;
  }

  @override
  void dispose() {
    _fromExternal?.removeListener(_onFromExternal);
    _toExternal?.removeListener(_onToExternal);
    super.dispose();
  }

  void _onFromExternal() {
    final text = _fromExternal?.text ?? '';
    if (text == _fromAddress) return;
    setState(() => _fromAddress = text);
  }

  void _onToExternal() {
    final text = _toExternal?.text ?? '';
    if (text == _toAddress) return;
    setState(() => _toAddress = text);
  }

  String _display(String address, LatLng? coords) => address.isNotEmpty ? address : (coords == null ? '' : 'Unknown');

  Future<void> _open(TMapPointType focus) async {
    if (widget.disabled) return;
    widget.onTap?.call();
    widget.onShow?.call();

    final controller = TMapPickerController(
      isTwoPoints: widget.isTwoPoints,
      googleMapApiKey: widget.googleMapApiKey,
      from: _from,
      fromAddress: _fromAddress,
      to: _to,
      toAddress: _toAddress,
      route: _route,
      onLoad: widget.onLoad,
      active: widget.isTwoPoints ? focus : TMapPointType.from,
    );

    final result = await showTMapPicker(
      context,
      controller: controller,
      config: TMapPickerConfig(
        title: widget.label,
        googleMapApiKey: widget.googleMapApiKey,
        placeholder: widget.placeholder,
        fromLabel: widget.fromLabel,
        toLabel: widget.toLabel,
        fromPlaceholder: widget.fromPlaceholder,
        toPlaceholder: widget.toPlaceholder,
      ),
    );
    controller.dispose();
    widget.onHide?.call();
    if (result != null && mounted) _apply(result);
  }

  void _apply(TMapPickerResult r) {
    setState(() {
      _from = r.from;
      _fromAddress = r.fromAddress;
      _to = r.to;
      _toAddress = r.toAddress;
      _route = r.route;
    });

    widget.onAddressChanged?.call(r.fromAddress);
    widget.onCoordinatesChanged?.call(r.from);
    widget.addressController?.text = r.fromAddress;
    widget.onFromAddressChanged?.call(r.fromAddress);
    widget.onFromCoordinatesChanged?.call(r.from);
    widget.fromAddressController?.text = r.fromAddress;

    if (widget.isTwoPoints && r.to != null) {
      widget.onToAddressChanged?.call(r.toAddress);
      widget.onToCoordinatesChanged?.call(r.to!);
      widget.toAddressController?.text = r.toAddress;
    }
    if (r.route != null) {
      widget.onRouteChanged?.call(r.route!);
      widget.onDistanceChanged?.call(r.route!.distanceMeters);
    }
  }

  @override
  Widget build(BuildContext context) => widget.isTwoPoints ? _buildTwoPoints(context) : _buildSingle(context);

  Widget _buildSingle(BuildContext context) {
    return TTextField<String?>(
      label: widget.label,
      tag: widget.tag,
      info: widget.info,
      helperText: widget.helperText,
      isRequired: widget.isRequired,
      disabled: widget.disabled,
      placeholder: widget.placeholder ?? 'Select location',
      readOnly: true,
      // `value` (not a controller) keeps the field's value and required validation in sync.
      value: _display(_fromAddress, _from),
      preWidget: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: TIcon.raw(Icons.location_on, size: 18, color: context.colors.primary),
      ),
      onTap: () => _open(TMapPointType.from),
    );
  }

  Widget _buildTwoPoints(BuildContext context) {
    final colors = context.colors;
    final theme = widget.theme ?? context.theme.inputFieldTheme;
    final noStates = <WidgetState>{};
    final showLabel = widget.label.isNotEmpty || (widget.tag?.isNotEmpty ?? false);

    // The container draws the only border, so the inner fields must be fully bare.
    final bare = context.theme.textFieldTheme.copyWith(
      decorationType: TInputDecorationType.none,
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      borderColor: WidgetStateProperty.all(Colors.transparent),
    );

    Widget field(String text, String placeholder, Widget icon, TMapPointType type) => TTextField<String?>(
      theme: bare.copyWith(
        preWidget: Padding(padding: const EdgeInsets.only(left: 4), child: icon),
      ),
      readOnly: true,
      disabled: widget.disabled,
      value: text,
      placeholder: placeholder,
      onTap: () => _open(type),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          theme.labelBuilder.resolve(noStates)(widget.label, widget.tag, widget.isRequired, null),
          const SizedBox(height: 8),
        ],
        TInputContainer(
          theme: theme,
          disabled: widget.disabled,
          padding: EdgeInsets.zero,
          height: bare.fieldHeight * 2 + 5,
          child: Column(
            children: [
              SizedBox(
                height: bare.fieldHeight,
                child: field(
                  _display(_fromAddress, _from),
                  widget.fromPlaceholder ?? 'Select pickup location',
                  const Icon(Icons.circle, size: 10, color: Colors.green),
                  TMapPointType.from,
                ),
              ),
              Divider(height: 1, thickness: 1, color: colors.outlineVariant.withAlpha(120)),
              SizedBox(
                height: bare.fieldHeight,
                child: field(
                  _display(_toAddress, _to),
                  widget.toPlaceholder ?? 'Select drop-off location',
                  TIcon.raw(Icons.location_on, size: 16, color: Colors.redAccent),
                  TMapPointType.to,
                ),
              ),
            ],
          ),
        ),
        theme.helperTextBuilder.resolve(noStates)(widget.helperText),
      ],
    );
  }
}
