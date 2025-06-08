import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/button/button_config.dart';

class TButton extends StatefulWidget {
  final TButtonType type;
  final TButtonSize? size;
  final double? width;
  final double? height;
  final bool block;
  final OutlinedBorder? shape;

  final IconData? icon;
  final String? text;
  final MaterialColor color;
  final bool loading;
  final String loadingText;
  final String? tooltip;
  final bool active;
  final Widget? child;
  final Function(TButtonPressOptions)? onPressed;

  const TButton({
    super.key,
    this.type = TButtonType.fill,
    this.size,
    this.color = AppColors.primary,
    this.block = false,
    this.loading = false,
    this.loadingText = 'Loading...',
    this.icon,
    this.text,
    this.tooltip,
    this.onPressed,
    this.active = false,
    this.width,
    this.height,
    this.child,
    this.shape,
  });

  @override
  State<TButton> createState() => _TButtonState();
}

class _TButtonState extends State<TButton> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isHovered = false;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );
  late final Animation<double> _scaleAnimation =
      Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (_isLoading || widget.onPressed == null) return;

    _controller.forward().then((_) => _controller.reverse());

    if (widget.loading) {
      setState(() => _isLoading = true);
    }

    widget.onPressed?.call(TButtonPressOptions(
      stopLoading: () => setState(() => _isLoading = false),
    ));
  }

  WidgetStateProperty<T> _resolveState<T>(
    T normal,
    T active,
    T disabled,
  ) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return disabled;
      if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered) || widget.active) return active;
      return normal;
    });
  }

  ButtonStyle _getButtonStyle() {
    final scheme = TButtonColorScheme.from(widget.color, widget.type);
    final size = TButtonSizeData.from(widget.size ?? (widget.type == TButtonType.icon ? TButtonSize.xxs : TButtonSize.md));

    return ButtonStyle(
      backgroundColor: _resolveState(scheme.bg, scheme.bgActive, scheme.bg.withAlpha(100)),
      foregroundColor: _resolveState(scheme.fg, scheme.fgActive, scheme.fg.withAlpha(100)),
      iconColor: _resolveState(scheme.fg, scheme.fgActive, scheme.fg.withAlpha(100)),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.border != null ? BorderSide(color: scheme.border!) : BorderSide.none;
        }
        if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered) || widget.active) {
          return scheme.borderActive != null ? BorderSide(color: scheme.borderActive!) : BorderSide.none;
        }
        return scheme.border != null ? BorderSide(color: scheme.border!) : BorderSide.none;
      }),
      padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: size.hPad, vertical: size.vPad)),
      minimumSize: WidgetStateProperty.all(Size(widget.width ?? size.minW, widget.height ?? size.minH)),
      shape: WidgetStateProperty.all(widget.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  Widget _buildContent() {
    final isLoading = _isLoading;
    final size = TButtonSizeData.from(widget.size ?? TButtonSize.md);
    final colorScheme = TButtonColorScheme.from(widget.color, widget.type);

    final resolvedFgColor = _resolveState(
      colorScheme.fg,
      colorScheme.fgActive,
      colorScheme.fg.withAlpha(100),
    ).resolve({
      if (_isHovered) WidgetState.hovered,
      if (widget.active) WidgetState.pressed,
      if (widget.onPressed == null) WidgetState.disabled,
    });

    return Row(
      mainAxisSize: widget.block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: size.icon,
            height: size.icon,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(resolvedFgColor),
            ),
          )
        else if (widget.icon != null)
          Icon(widget.icon, size: size.icon),
        if ((widget.text?.isNotEmpty ?? false)) ...[
          if (widget.icon != null || isLoading) SizedBox(width: size.spacing),
          Text(
            isLoading ? widget.loadingText : widget.text!,
            style: TextStyle(
              fontSize: size.font,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.65,
            ),
          ),
        ],
        if (widget.child != null) widget.child!,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: widget.onPressed != null ? _handlePress : null,
      style: _getButtonStyle(),
      child: _buildContent(),
    );

    final scaledButton = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: button,
    );

    Widget finalButton = SizedBox(
      width: widget.block ? double.infinity : widget.width,
      child: scaledButton,
    );

    final wrapped = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: finalButton,
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: wrapped);
    }

    return wrapped;
  }
}
