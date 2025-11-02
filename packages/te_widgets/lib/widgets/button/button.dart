import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TButton extends StatefulWidget {
  final TButtonTheme? theme;
  final TButtonType? type;
  final TButtonSize? size;
  final IconData? icon;
  final String? text;
  final Color? color;
  final bool loading;
  final String loadingText;
  final String? tooltip;
  final bool active;
  final Widget? child;
  final VoidCallback? onTap;
  final Function(TButtonPressOptions)? onPressed;

  const TButton({
    super.key,
    this.theme,
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
    this.child,
  }) : assert(theme == null || (type == null && size == null), 'If theme is provided, type and size must be null.');

  @override
  State<TButton> createState() => _TButtonState();
}

class _TButtonState extends State<TButton> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isHovered = false;
  bool _isFocused = false;

  late final AnimationController _controller = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
  late final Animation<double> _scaleAnimation =
      Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (_isLoading || (widget.onPressed == null && widget.onTap == null)) return;

    _controller.forward().then((_) => _controller.reverse());

    if (widget.onTap != null) {
      widget.onTap!();
      return;
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
      if (widget.onPressed == null && widget.onTap == null) WidgetState.disabled,
      if (_isHovered) WidgetState.hovered,
      if (_isFocused) WidgetState.focused,
      if (widget.active) WidgetState.pressed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final wTheme = widget.theme ?? context.theme.buttonTheme.copyWith(type: widget.type, size: widget.size);
    final baseTheme = context.getWidgetTheme(wTheme.type.colorType, widget.color);

    final button = ElevatedButton(
      onPressed: (widget.onPressed == null && widget.onTap == null) ? null : _handlePress,
      style: wTheme.getButtonStyle(baseTheme),
      child: wTheme.buildButtonContent(
        baseTheme,
        icon: widget.icon,
        text: widget.text,
        isLoading: _isLoading,
        loadingText: widget.loadingText,
        child: widget.child,
        states: _currentStates,
      ),
    );

    final wrapped = Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: button,
        ),
      ),
    );

    if (widget.tooltip != null) {
      return TTooltip(message: widget.tooltip!, color: baseTheme.color, child: wrapped);
    }

    return wrapped;
  }
}
