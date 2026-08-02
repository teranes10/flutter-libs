import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:te_widgets/te_widgets.dart';

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
  void _showCustomColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return _CustomColorPickerDialog(
          label: widget.label ?? 'Colour Picker',
          initialColor: currentValue ?? Colors.blue,
          onColorSelected: (color) {
            _saveRecentColorToPrefs(color);
            notifyValueChanged(color);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildPlusButton(ColorScheme colors) {
    final hasValue = currentValue != null;
    final selectedColor = currentValue;

    return GestureDetector(
      onTap: widget.disabled ? null : _showCustomColorPicker,
      child: Container(
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
        child: Icon(
          Icons.add,
          color: !hasValue ? Colors.white : (selectedColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
          size: widget.itemSize * 0.6,
          shadows: !hasValue ? const [Shadow(blurRadius: 2, color: Colors.black)] : null,
        ),
      ),
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
                        ? Icon(
                            Icons.check,
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

class _CustomColorPickerDialog extends StatefulWidget {
  final String label;
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const _CustomColorPickerDialog({
    required this.label,
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<_CustomColorPickerDialog> createState() => _CustomColorPickerDialogState();
}

class _CustomColorPickerDialogState extends State<_CustomColorPickerDialog> {
  late HSVColor _hsvColor;
  List<Color> _recentColors = [];

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor);
    _loadRecentColors();
  }

  Future<void> _loadRecentColors() async {
    final colors = await _getRecentColorsFromPrefs();
    if (mounted) {
      setState(() {
        _recentColors = colors;
      });
    }
  }

  Widget _buildGradientSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required List<Color> gradientColors,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(colors: gradientColors),
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: Colors.white,
                overlayColor: Colors.white.withAlpha(50),
                trackHeight: 12,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hueGradient = [
      const Color(0xFFFF0000),
      const Color(0xFFFFFF00),
      const Color(0xFF00FF00),
      const Color(0xFF00FFFF),
      const Color(0xFF0000FF),
      const Color(0xFFFF00FF),
      const Color(0xFFFF0000),
    ];

    final saturationGradient = [
      HSVColor.fromAHSV(1.0, _hsvColor.hue, 0.0, _hsvColor.value).toColor(),
      HSVColor.fromAHSV(1.0, _hsvColor.hue, 1.0, _hsvColor.value).toColor(),
    ];

    final valueGradient = [
      HSVColor.fromAHSV(1.0, _hsvColor.hue, _hsvColor.saturation, 0.0).toColor(),
      HSVColor.fromAHSV(1.0, _hsvColor.hue, _hsvColor.saturation, 1.0).toColor(),
    ];

    return AlertDialog(
      title: Text(widget.label),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGradientSlider(
                label: 'Hue',
                value: _hsvColor.hue,
                min: 0,
                max: 360,
                gradientColors: hueGradient,
                onChanged: (val) => setState(() => _hsvColor = _hsvColor.withHue(val)),
              ),
              _buildGradientSlider(
                label: 'Saturation',
                value: _hsvColor.saturation,
                min: 0,
                max: 1.0,
                gradientColors: saturationGradient,
                onChanged: (val) => setState(() => _hsvColor = _hsvColor.withSaturation(val)),
              ),
              _buildGradientSlider(
                label: 'Value (Brightness)',
                value: _hsvColor.value,
                min: 0,
                max: 1.0,
                gradientColors: valueGradient,
                onChanged: (val) => setState(() => _hsvColor = _hsvColor.withValue(val)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _hsvColor.toColor(),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${_hsvColor.toColor().toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'R: ${(_hsvColor.toColor().r * 255).round()} G: ${(_hsvColor.toColor().g * 255).round()} B: ${(_hsvColor.toColor().b * 255).round()}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              if (_recentColors.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Previously Selected',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recentColors.map((recentColor) {
                    final isSelected = _hsvColor.toColor().toARGB32() == recentColor.toARGB32();
                    return SizedBox(
                      width: 38,
                      height: 38,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _hsvColor = HSVColor.fromColor(recentColor);
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: recentColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                                    width: isSelected ? 3 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Theme.of(context).colorScheme.primary.withAlpha(100),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: recentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                await _removeRecentColorFromPrefs(recentColor);
                                if (mounted) {
                                  setState(() {
                                    _recentColors.removeWhere((c) => c.toARGB32() == recentColor.toARGB32());
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final selectedColor = _hsvColor.toColor();
            await _saveRecentColorToPrefs(selectedColor);
            widget.onColorSelected(selectedColor);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Select Color'),
        ),
      ],
    );
  }
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
