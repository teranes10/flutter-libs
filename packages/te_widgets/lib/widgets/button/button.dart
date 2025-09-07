import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TButton extends StatefulWidget {
  final TButtonType? type;
  final TButtonSize? size;
  final double? width;
  final double? height;
  final bool block;
  final OutlinedBorder? shape;

  final IconData? icon;
  final double? iconSize;
  final String? text;
  final MaterialColor? color;
  final bool loading;
  final String loadingText;
  final String? tooltip;
  final bool active;
  final Widget? child;
  final Function(TButtonPressOptions)? onPressed;

  const TButton({
    super.key,
    this.type,
    this.size,
    this.color,
    this.block = false,
    this.loading = false,
    this.loadingText = 'Loading...',
    this.icon,
    this.iconSize,
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

  ButtonStyle _getButtonStyle(TWidgetColorScheme wTheme, TButtonSizeData size) {
    return ButtonStyle(
      backgroundColor: wTheme.backgroundState,
      foregroundColor: wTheme.foregroundState,
      iconColor: wTheme.foregroundState,
      side: wTheme.borderSideState,
      padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: size.hPad, vertical: size.vPad)),
      minimumSize: WidgetStateProperty.all(Size(widget.block ? double.infinity : widget.width ?? size.minW, widget.height ?? size.minH)),
      shape: WidgetStateProperty.all(widget.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  Widget _buildContent(TColorScheme exTheme, TWidgetColorScheme wTheme, TButtonSizeData size) {
    final isLoading = _isLoading;

    final resolvedFgColor = _resolveState(
      wTheme.onContainer,
      wTheme.onContainerVariant,
      wTheme.onContainer.withAlpha(100),
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
            width: widget.iconSize ?? size.icon,
            height: widget.iconSize ?? size.icon,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(resolvedFgColor),
            ),
          )
        else if (widget.icon != null)
          Icon(widget.icon, size: widget.iconSize ?? size.icon),
        if ((widget.text?.isNotEmpty ?? false)) ...[
          if (widget.icon != null || isLoading) SizedBox(width: size.spacing),
          Text(
            isLoading ? widget.loadingText : widget.text!,
            style: TextStyle(
              fontSize: size.font,
              fontWeight: (widget.type ?? exTheme.buttonType).fontWeight,
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
    final exTheme = context.exTheme;
    final wTheme =
        TWidgetColorScheme.from(context, widget.color ?? exTheme.primary, mapButtonTypeToColorType(widget.type ?? exTheme.buttonType));
    final size = TButtonSizeData.from(widget.size ?? (widget.type == TButtonType.icon ? TButtonSize.xxs : TButtonSize.md));

    final button = ElevatedButton(
      onPressed: widget.onPressed != null ? _handlePress : null,
      style: _getButtonStyle(wTheme, size),
      child: _buildContent(exTheme, wTheme, size),
    );

    final scaledButton = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: button,
    );

    final wrapped = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: scaledButton,
    );

    if (widget.tooltip != null) {
      return TTooltip(message: widget.tooltip!, color: widget.color, child: wrapped);
    }

    return wrapped;
  }
}
