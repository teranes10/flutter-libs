import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:te_widgets/te_widgets.dart';

import 'eyedropper_stub.dart' if (dart.library.js_interop) 'eyedropper_web.dart';

/// A color picker component for selecting a color from a predefined list or a custom spectrum.
class TColorPicker extends StatefulWidget with TInputValueMixin<Color>, TFocusMixin, TInputValidationMixin<Color> {
  @override
  final Color? value;

  @override
  final ValueNotifier<Color?>? valueNotifier;

  @override
  final ValueChanged<Color?>? onValueChanged;

  @override
  final FocusNode? focusNode;

  @override
  final String? label;

  @override
  final bool isRequired;

  @override
  final List<String? Function(Color?)>? rules;

  @override
  final Duration? validationDebounce;

  final List<Color> colors;
  final double itemSize;
  final bool disabled;
  final bool enableCustomColor;
  final bool onlyPlusIcon;

  const TColorPicker({
    super.key,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.focusNode,
    this.label,
    this.isRequired = false,
    this.rules,
    this.validationDebounce,
    this.colors = const [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ],
    this.itemSize = 36.0,
    this.disabled = false,
    this.enableCustomColor = true,
    this.onlyPlusIcon = false,
  });

  @override
  State<TColorPicker> createState() => _TColorPickerState();
}

class _TColorPickerState extends State<TColorPicker>
    with TInputValueStateMixin<Color, TColorPicker>, TFocusStateMixin<TColorPicker>, TInputValidationStateMixin<Color, TColorPicker> {
  Widget _buildPlusButton(ColorScheme colors) {
    final hasValue = currentValue != null;
    final selectedColor = currentValue;

    final button = Container(
      width: widget.itemSize,
      height: widget.itemSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasValue ? selectedColor : null,
        border: Border.all(
          color: hasValue ? colors.primary : colors.outlineVariant,
          width: hasValue ? 3 : 1,
        ),
        gradient: !hasValue
            ? const SweepGradient(
                colors: [
                  Colors.red,
                  Colors.yellow,
                  Colors.green,
                  Colors.cyan,
                  Colors.blue,
                  Colors.purple,
                  Colors.red,
                ],
              )
            : null,
        boxShadow: hasValue
            ? [
                BoxShadow(
                  color: colors.primary.withAlpha(100),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: TIcon.raw(
        HugeIcons.strokeRoundedAdd01,
        color: !hasValue ? Colors.white : (selectedColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
        size: widget.itemSize * 0.6,
      ),
    );
    if (widget.disabled) return button;
    return TColorPickerPopover(
      title: widget.label ?? 'Colour',
      color: currentValue ?? Colors.blue,
      onChanged: (c) {
        notifyValueChanged(c);
        setState(() {});
      },
      child: button,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (widget.onlyPlusIcon) ...[
              _buildPlusButton(colors),
            ] else ...[
              ...widget.colors.map((color) {
                final isSelected = currentValue == color;
                return GestureDetector(
                  onTap: widget.disabled
                      ? null
                      : () {
                          _saveRecentColorToPrefs(color);
                          notifyValueChanged(color);
                          setState(() {});
                        },
                  child: Container(
                    width: widget.itemSize,
                    height: widget.itemSize,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? colors.primary : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colors.primary.withAlpha(100),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? TIcon.raw(
                            HugeIcons.strokeRoundedTick01,
                            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                            size: widget.itemSize * 0.6,
                          )
                        : null,
                  ),
                );
              }),
              if (widget.enableCustomColor) _buildPlusButton(colors),
            ],
          ],
        ),
        if (errorsNotifier.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorsNotifier.value.first,
              style: TextStyle(color: colors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// Anchored popover that edits [color] live through [onChanged].
class TColorPickerPopover extends StatelessWidget {
  final Widget child;
  final Color color;
  final ValueChanged<Color> onChanged;
  final String? title;
  final bool enableAlpha;
  final TPopupAlignment alignment;

  const TColorPickerPopover({
    super.key,
    required this.child,
    required this.color,
    required this.onChanged,
    this.title,
    this.enableAlpha = false,
    this.alignment = TPopupAlignment.bottomLeft,
  });

  @override
  Widget build(BuildContext context) {
    return TPopover(
      alignment: alignment,
      title: title,
      showCloseButton: true,
      width: 280,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      builder: (context, close) => TColorPickerPanel(color: color, onChanged: onChanged, enableAlpha: enableAlpha),
      child: child,
    );
  }
}

/// Opens the picker in a modal dialog; returns the chosen color (null if cancelled).
Future<Color?> showTColorPickerDialog(
  BuildContext context, {
  String label = 'Custom Color',
  Color initialColor = Colors.blue,
  bool enableAlpha = false,
}) {
  return showDialog<Color>(
    context: context,
    builder: (context) {
      var current = initialColor;
      return AlertDialog(
        title: Text(label),
        content: SizedBox(
          width: 280,
          child: SingleChildScrollView(
            child: TColorPickerPanel(color: initialColor, enableAlpha: enableAlpha, onChanged: (c) => current = c),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(current), child: const Text('Select Color')),
        ],
      );
    },
  );
}

/// Inline color editor: saturation/brightness square, hue strip, optional alpha strip,
/// hex input, browser eyedropper (web) and recently used colors.
class TColorPickerPanel extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onChanged;
  final bool enableAlpha;

  const TColorPickerPanel({super.key, required this.color, required this.onChanged, this.enableAlpha = false});

  @override
  State<TColorPickerPanel> createState() => _TColorPickerPanelState();
}

class _TColorPickerPanelState extends State<TColorPickerPanel> {
  late HSVColor _hsv;
  late double _alpha;
  late final TextEditingController _hex;
  final _hexFocus = FocusNode();
  List<Color> _recent = [];
  late Color _initial;

  Color get _color => _hsv.toColor().withValues(alpha: widget.enableAlpha ? _alpha : 1);

  @override
  void initState() {
    super.initState();
    _initial = widget.color;
    _hsv = HSVColor.fromColor(widget.color);
    _alpha = widget.color.a;
    _hex = TextEditingController(text: _hexOf(_color));
    _getRecentColorsFromPrefs().then((c) {
      if (mounted) setState(() => _recent = c);
    });
  }

  @override
  void didUpdateWidget(TColorPickerPanel old) {
    super.didUpdateWidget(old);
    // External change (not an echo of our own output): adopt it.
    if (widget.color.toARGB32() != _color.toARGB32() && widget.color.toARGB32() != old.color.toARGB32()) {
      _hsv = HSVColor.fromColor(widget.color);
      _alpha = widget.color.a;
      _syncHex();
    }
  }

  @override
  void dispose() {
    if (_color.toARGB32() != _initial.toARGB32()) _saveRecentColorToPrefs(_color);
    _hex.dispose();
    _hexFocus.dispose();
    super.dispose();
  }

  String _hexOf(Color c) {
    final argb = c.toARGB32();
    final rgb = (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
    if (!widget.enableAlpha || c.a >= 1) return rgb;
    return rgb + ((argb >> 24) & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase();
  }

  void _syncHex() {
    if (!_hexFocus.hasFocus) _hex.text = _hexOf(_color);
  }

  void _emit() {
    _syncHex();
    widget.onChanged(_color);
  }

  void _setColor(Color c) {
    setState(() {
      _hsv = HSVColor.fromColor(c);
      if (widget.enableAlpha) _alpha = c.a;
    });
    _hex.text = _hexOf(_color);
    widget.onChanged(_color);
  }

  void _onHexChanged(String text) {
    var t = text.trim().replaceFirst('#', '');
    if (t.length == 3) t = t.split('').map((c) => '$c$c').join();
    if (t.length != 6 && !(t.length == 8 && widget.enableAlpha)) return;
    final v = int.tryParse(t, radix: 16);
    if (v == null) return;
    final c = t.length == 6 ? Color(0xFF000000 | v) : Color.fromARGB(v & 0xFF, (v >> 24) & 0xFF, (v >> 16) & 0xFF, (v >> 8) & 0xFF);
    setState(() {
      _hsv = HSVColor.fromColor(c);
      if (widget.enableAlpha) _alpha = c.a;
    });
    widget.onChanged(_color);
  }

  Future<void> _eyedrop() async {
    final v = await pickScreenColor();
    if (v != null && mounted) _setColor(Color(v));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hue = HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor();
    final opaque = _hsv.toColor();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PanelArea(
          height: 150,
          onChanged: (dx, dy) => setState(() {
            _hsv = _hsv.withSaturation(dx).withValue(1 - dy);
            _emit();
          }),
          position: (w, h) => Offset(_hsv.saturation * w, (1 - _hsv.value) * h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(colors: [Colors.white, hue]),
          ),
          overlay: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black]),
          ),
          thumbColor: opaque,
        ),
        const SizedBox(height: 12),
        _PanelStrip(
          value: _hsv.hue / 360,
          gradient: const LinearGradient(colors: [
            Color(0xFFFF0000),
            Color(0xFFFFFF00),
            Color(0xFF00FF00),
            Color(0xFF00FFFF),
            Color(0xFF0000FF),
            Color(0xFFFF00FF),
            Color(0xFFFF0000),
          ]),
          thumbColor: hue,
          onChanged: (v) => setState(() {
            _hsv = _hsv.withHue((v * 360).clamp(0, 359.999));
            _emit();
          }),
        ),
        if (widget.enableAlpha) ...[
          const SizedBox(height: 10),
          _PanelStrip(
            value: _alpha,
            checker: true,
            gradient: LinearGradient(colors: [opaque.withValues(alpha: 0), opaque]),
            thumbColor: opaque.withValues(alpha: _alpha),
            onChanged: (v) => setState(() {
              _alpha = v;
              _emit();
            }),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.outlineVariant),
                color: _color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _hex,
                focusNode: _hexFocus,
                onChanged: _onHexChanged,
                onSubmitted: (_) => _hex.text = _hexOf(_color),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F#]')), LengthLimitingTextInputFormatter(9)],
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  isDense: true,
                  prefixText: '#',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ),
            if (eyeDropperSupported)
              TButton(
                type: TButtonType.softText,
                tooltip: 'Pick from screen',
                icon: Icons.colorize,
                onTap: _eyedrop,
              ),
          ],
        ),
        if (_recent.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Recent (long-press to remove)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in _recent)
                GestureDetector(
                  onTap: () => _setColor(c),
                  onLongPress: () async {
                    await _removeRecentColorFromPrefs(c);
                    if (mounted) setState(() => _recent.removeWhere((r) => r.toARGB32() == c.toARGB32()));
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: c.toARGB32() == _color.toARGB32() ? colors.onSurface : colors.outlineVariant,
                        width: c.toARGB32() == _color.toARGB32() ? 2 : 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 2D drag surface reporting normalized (0..1) positions.
class _PanelArea extends StatelessWidget {
  final double height;
  final void Function(double dx, double dy) onChanged;
  final Offset Function(double w, double h) position;
  final BoxDecoration decoration;
  final BoxDecoration overlay;
  final Color thumbColor;

  const _PanelArea({
    required this.height,
    required this.onChanged,
    required this.position,
    required this.decoration,
    required this.overlay,
    required this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      void update(Offset p) => onChanged((p.dx / w).clamp(0.0, 1.0), (p.dy / height).clamp(0.0, 1.0));
      final pos = position(w, height);
      return GestureDetector(
        onPanDown: (d) => update(d.localPosition),
        onPanUpdate: (d) => update(d.localPosition),
        child: SizedBox(
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: DecoratedBox(decoration: decoration)),
              Positioned.fill(child: DecoratedBox(decoration: overlay)),
              Positioned(left: pos.dx - 9, top: pos.dy - 9, child: _Thumb(color: thumbColor)),
            ],
          ),
        ),
      );
    });
  }
}

/// Horizontal gradient strip with a draggable thumb (value 0..1).
class _PanelStrip extends StatelessWidget {
  final double value;
  final Gradient gradient;
  final Color thumbColor;
  final bool checker;
  final ValueChanged<double> onChanged;

  const _PanelStrip({required this.value, required this.gradient, required this.thumbColor, required this.onChanged, this.checker = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      void update(Offset p) => onChanged((p.dx / w).clamp(0.0, 1.0));
      return GestureDetector(
        onPanDown: (d) => update(d.localPosition),
        onPanUpdate: (d) => update(d.localPosition),
        child: SizedBox(
          height: 16,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (checker) const CustomPaint(painter: _CheckerPainter()),
                      DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
                    ],
                  ),
                ),
              ),
              Positioned(left: value * w - 9, top: -1, child: _Thumb(color: thumbColor)),
            ],
          ),
        ),
      );
    });
  }
}

class _Thumb extends StatelessWidget {
  final Color color;
  const _Thumb({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 3)],
        ),
      );
}

class _CheckerPainter extends CustomPainter {
  const _CheckerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 8.0;
    final light = Paint()..color = Colors.white;
    final dark = Paint()..color = const Color(0xFFCCCCCC);
    for (var y = 0; y * cell < size.height; y++) {
      for (var x = 0; x * cell < size.width; x++) {
        canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), (x + y).isEven ? light : dark);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const String _kRecentColorsKey = 'te_color_picker_recent_colors';

Future<List<Color>> _getRecentColorsFromPrefs() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kRecentColorsKey) ?? [];
    final result = <Color>[];
    for (final str in list) {
      final val = int.tryParse(str, radix: 16);
      if (val != null) {
        result.add(Color(val));
      }
    }
    return result;
  } catch (_) {
    return [];
  }
}

Future<void> _saveRecentColorToPrefs(Color color) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kRecentColorsKey) ?? [];
    final hexStr = color.toARGB32().toRadixString(16).padLeft(8, '0');
    list.remove(hexStr);
    list.insert(0, hexStr);
    if (list.length > 12) {
      list.removeRange(12, list.length);
    }
    await prefs.setStringList(_kRecentColorsKey, list);
  } catch (_) {}
}

Future<void> _removeRecentColorFromPrefs(Color color) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kRecentColorsKey) ?? [];
    final hexStr = color.toARGB32().toRadixString(16).padLeft(8, '0');
    list.remove(hexStr);
    await prefs.setStringList(_kRecentColorsKey, list);
  } catch (_) {}
}
