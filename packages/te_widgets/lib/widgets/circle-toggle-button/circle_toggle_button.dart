import 'package:flutter/material.dart';

class CircleToggleButton extends StatefulWidget {
  final Duration duration;
  final double size;
  final double iconSize;

  final Widget falseIcon;
  final Widget trueIcon;

  final Color? falseBackground;
  final Color? trueBackground;

  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const CircleToggleButton({
    super.key,
    required this.falseIcon,
    required this.trueIcon,
    this.duration = const Duration(milliseconds: 400),
    this.size = 24,
    this.iconSize = 16,
    this.initialValue = false,
    this.falseBackground,
    this.trueBackground,
    this.onChanged,
  });

  @override
  State<CircleToggleButton> createState() => _CircleToggleButtonState();
}

class _CircleToggleButtonState extends State<CircleToggleButton> {
  late bool value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  void _toggle() {
    setState(() => value = !value);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = (value ? widget.trueBackground : widget.falseBackground) ?? Colors.transparent;
    final icon = value ? widget.trueIcon : widget.falseIcon;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeInOut,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
        child: Center(
          child: AnimatedSwitcher(
            duration: widget.duration,
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: IconTheme(
              key: ValueKey(value),
              data: IconThemeData(size: widget.iconSize),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
