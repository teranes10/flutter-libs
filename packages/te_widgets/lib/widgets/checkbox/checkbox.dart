import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TCheckbox<T> extends StatefulWidget {
  final T? value;
  final String? label;
  final bool? modelValue;
  final ValueChanged<bool>? onChanged;
  final bool disabled;
  final String color;
  final TCheckboxSize size;
  final TCheckboxIcon icon;
  final List<String Function(bool?)>? rules;
  final VoidCallback? onChecked;

  const TCheckbox({
    super.key,
    this.value,
    this.label,
    this.modelValue,
    this.onChanged,
    this.disabled = false,
    this.color = 'primary',
    this.size = TCheckboxSize.medium,
    this.icon = TCheckboxIcon.check,
    this.rules,
    this.onChecked,
  });

  @override
  State<TCheckbox<T>> createState() => _TCheckboxState<T>();
}

class _TCheckboxState<T> extends State<TCheckbox<T>> {
  bool _checked = false;
  List<String> _errors = [];

  @override
  void initState() {
    super.initState();
    _checked = widget.modelValue ?? false;
    _validateField();
  }

  @override
  void didUpdateWidget(TCheckbox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modelValue != widget.modelValue) {
      setState(() {
        _checked = widget.modelValue ?? false;
      });
      _validateField();
    }
  }

  void _validateField() {
    if (widget.rules != null) {
      setState(() {
        _errors = widget.rules!.map((rule) => rule(_checked)).where((error) => error.isNotEmpty).toList();
      });
    }
  }

  void _onCheckChanged() {
    if (widget.disabled) return;

    setState(() {
      _checked = !_checked;
    });

    _validateField();
    widget.onChanged?.call(_checked);
    widget.onChecked?.call();
  }

  Widget _buildCheckboxIcon(ColorScheme theme) {
    if (!_checked) return const SizedBox.shrink();

    switch (widget.icon) {
      case TCheckboxIcon.check:
        return Icon(
          Icons.check,
          size: TCheckboxSizes.sizes[widget.size]! * 0.8,
          color: theme.onPrimary,
        );
      case TCheckboxIcon.minus:
        return Icon(
          Icons.remove,
          size: TCheckboxSizes.sizes[widget.size]! * 0.8,
          color: theme.onPrimary,
        );
      case TCheckboxIcon.square:
        return Icon(
          Icons.square,
          size: TCheckboxSizes.sizes[widget.size]! * 0.8,
          color: theme.onPrimary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final checkboxColor = TCheckboxColors.colors[widget.color] ?? theme.primary;
    final checkboxSize = TCheckboxSizes.sizes[widget.size]!;
    final hasErrors = _errors.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _onCheckChanged,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: checkboxSize,
                height: checkboxSize,
                decoration: BoxDecoration(
                  color: _checked ? checkboxColor : theme.surface,
                  border: Border.all(color: hasErrors ? theme.error : (_checked ? checkboxColor : theme.outline), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildCheckboxIcon(theme),
              ),
              if (widget.label != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label!,
                  style: TextStyle(
                    color: widget.disabled ? theme.onSurfaceVariant : theme.onSurface,
                    fontSize: _getFontSize(),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasErrors) ...[
          const SizedBox(height: 4),
          ...(_errors.map((error) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '• $error',
                  style: TextStyle(
                    color: theme.error,
                    fontSize: 12,
                  ),
                ),
              ))),
        ],
      ],
    );
  }

  double _getFontSize() {
    switch (widget.size) {
      case TCheckboxSize.small:
        return 12;
      case TCheckboxSize.medium:
        return 14;
      case TCheckboxSize.large:
        return 16;
    }
  }
}
