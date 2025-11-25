import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TButton extends StatefulWidget {
  final TButtonTheme? theme;
  final TButtonShape? shape;
  final TButtonType? type;
  final TButtonSize? size;
  final IconData? icon;
  final Color? color;
  final String? text;
  final bool loading;
  final String loadingText;
  final String? tooltip;
  final bool active;
  final IconData? activeIcon;
  final Color? activeColor;
  final Widget? child;
  final VoidCallback? onTap;
  final Function(TButtonPressOptions)? onPressed;
  final ValueChanged<bool>? onChanged;
  final Duration duration;

  const TButton({
    super.key,
    this.theme,
    this.shape,
    this.type,
    this.size,
    this.color,
    this.loading = false,
    this.loadingText = 'Loading...',
    this.icon,
    this.text,
    this.tooltip,
    this.onTap,
    this.onPressed,
    this.active = false,
    this.activeIcon,
    this.activeColor,
    this.child,
    this.onChanged,
    this.duration = const Duration(milliseconds: 400),
  }) : assert(theme == null || (type == null && size == null && shape == null && color == null),
            'If theme is provided, type, shape, color and size must be null.');

  @override
  State<TButton> createState() => _TButtonState();
}

class _TButtonState extends State<TButton> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isActive = false;

  late final AnimationController _pressController = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  late final Animation<double> _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(
    parent: _pressController,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  ));

  @override
  void initState() {
    super.initState();
    _isActive = widget.active;
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (_isLoading || (widget.onPressed == null && widget.onTap == null && widget.onChanged == null)) return;

    _pressController.forward().then((_) {
      if (mounted) _pressController.reverse();
    });

    if (widget.onChanged != null) {
      final newActive = !_isActive;
      setState(() => _isActive = newActive);
      widget.onChanged?.call(newActive);
    }

    if (widget.onTap != null) {
      widget.onTap!();
    }

    if (widget.onPressed != null) {
      if (widget.loading) {
        setState(() => _isLoading = true);
      }

      widget.onPressed!(TButtonPressOptions(
        stopLoading: () {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
      ));
    }
  }

  Set<WidgetState> get _currentStates {
    return {
      if (widget.onPressed == null && widget.onTap == null && widget.onChanged == null) WidgetState.disabled,
      if (_isHovered) WidgetState.hovered,
      if (_isFocused) WidgetState.focused,
      if (_isActive) WidgetState.pressed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final defaultTheme = context.theme.buttonTheme;
    final baseTheme = widget.theme?.baseTheme ?? defaultTheme.baseTheme;
    final size = widget.size ?? defaultTheme.size;

    final activeColor = _isActive ? (widget.activeColor ?? widget.color) : widget.color;
    final icon = _isActive ? (widget.activeIcon ?? widget.icon) : widget.icon;
    final text = widget.text;

    final theme = widget.theme ??
        defaultTheme.copyWith(
          size: size,
          shape: widget.shape,
          baseTheme: baseTheme.copyWidth(color: activeColor, type: widget.type?.colorType),
        );

    assert(theme.shape != TButtonShape.circle || widget.text.isNullOrBlank, 'Circle shape only supports icon, no text.');

    final buttonContent = AnimatedContainer(
      duration: widget.duration,
      curve: Curves.easeInOut,
      child: Row(
        mainAxisSize: size.minW.isInfinite ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: size.spacing,
        children: [
          if (_isLoading)
            SizedBox(
              width: size.icon,
              height: size.icon,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(baseTheme.foregroundState.resolve(_currentStates)),
              ),
            )
          else if (icon != null)
            AnimatedSwitcher(
              duration: widget.duration,
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Icon(key: ValueKey(_isActive), icon, size: size.icon),
            ),
          if (!text.isNullOrBlank) Text(_isLoading ? widget.loadingText : text!),
          if (widget.child != null) widget.child!,
        ],
      ),
    );

    final button = ElevatedButton(
      onPressed: (widget.onPressed == null && widget.onTap == null && widget.onChanged == null) ? null : _handlePress,
      style: theme.buttonStyle,
      child: buttonContent,
    );

    final wrapped = Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: button,
        ),
      ),
    );

    if (widget.tooltip != null) {
      return TTooltip(
        message: widget.tooltip!,
        color: theme.baseTheme.color,
        child: wrapped,
      );
    }

    return wrapped;
  }
}
