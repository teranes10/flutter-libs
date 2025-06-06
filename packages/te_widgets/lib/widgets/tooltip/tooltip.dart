import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/tooltip/tooltip_config.dart';

class TTooltip extends StatefulWidget {
  const TTooltip({
    super.key,
    required this.message,
    required this.child,
    this.richMessage,
    this.icon,
    this.position = TTooltipPosition.auto,
    this.color = AppColors.grey,
    this.size = TTooltipSize.small,
    this.showDelay = const Duration(milliseconds: 100),
    this.hideDelay = const Duration(milliseconds: 50),
    this.waitDuration = Duration.zero,
    this.showDuration = const Duration(seconds: 3),
    this.triggerMode = TTooltipTriggerMode.hover,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.decoration,
    this.textStyle,
    this.textAlign,
    this.margin = const EdgeInsets.all(0),
    this.padding,
    this.verticalOffset = 5,
    this.preferBelow = false,
    this.enableHapticFeedback = false,
    this.showArrow = true,
    this.interactive = false,
    this.maxWidth = 250.0,
    this.onShow,
    this.onHide,
  });

  final String message;
  final Widget? richMessage;
  final Widget child;
  final TTooltipPosition position;
  final MaterialColor color;
  final IconData? icon;
  final TTooltipSize size;
  final Duration showDelay;
  final Duration hideDelay;
  final Duration waitDuration;
  final Duration showDuration;
  final TTooltipTriggerMode triggerMode;
  final bool enableFeedback;
  final bool excludeFromSemantics;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? padding;
  final double verticalOffset;
  final bool preferBelow;
  final bool enableHapticFeedback;
  final bool showArrow;
  final bool interactive;
  final double maxWidth;
  final VoidCallback? onShow;
  final VoidCallback? onHide;

  @override
  State<TTooltip> createState() => _TTooltipState();
}

class _TTooltipState extends State<TTooltip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 250),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  final GlobalKey _childKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;
  bool _isVisible = false;

  @override
  void dispose() {
    _removeTooltip();
    _controller.dispose();
    super.dispose();
  }

  void _showTooltip() {
    if (_isVisible) return;
    setState(() => _isVisible = true);
    widget.onShow?.call();

    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    _controller.forward();
  }

  void _hideTooltip() {
    if (!_isVisible) return;
    setState(() => _isVisible = false);
    widget.onHide?.call();
    _controller.reverse().then((_) => _removeTooltip());
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  TTooltipResolvedPosition _resolveAutoPosition() {
    final overlay = Overlay.of(context, rootOverlay: true);

    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    final targetBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (overlayBox == null || targetBox == null) return TTooltipResolvedPosition.bottom;

    final targetTopLeft = targetBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final targetSize = targetBox.size;

    final screenHeight = overlayBox.size.height;
    final screenWidth = overlayBox.size.width;

    const requiredSpace = 48.0;

    final spaceTop = targetTopLeft.dy;
    final spaceBottom = screenHeight - (targetTopLeft.dy + targetSize.height);
    final spaceRight = screenWidth - (targetTopLeft.dx + targetSize.width);

    if (spaceTop >= requiredSpace) return TTooltipResolvedPosition.top;
    if (spaceBottom >= requiredSpace) return TTooltipResolvedPosition.bottom;
    if (spaceRight >= requiredSpace) return TTooltipResolvedPosition.right;
    return TTooltipResolvedPosition.left;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;
    final targetRect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);

    return OverlayEntry(
      builder: (_) => Stack(
        children: [
          if (widget.interactive)
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideTooltip,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
          _TooltipContent(
            message: widget.message,
            richMessage: widget.richMessage,
            targetRect: targetRect,
            position: widget.position,
            color: widget.color,
            size: widget.size,
            decoration: widget.decoration,
            textStyle: widget.textStyle,
            textAlign: widget.textAlign,
            margin: widget.margin,
            padding: widget.padding,
            verticalOffset: widget.verticalOffset,
            preferBelow: widget.preferBelow,
            showArrow: widget.showArrow,
            maxWidth: widget.maxWidth,
            animation: _animation,
            icon: widget.icon,
            onTap: widget.interactive ? null : _hideTooltip,
            resolvedPosition: _resolveAutoPosition(),
          ),
        ],
      ),
    );
  }

  void _onPointerEnter(PointerEnterEvent event) {
    if (widget.triggerMode == TTooltipTriggerMode.hover) {
      _isHovering = true;
      Future.delayed(widget.showDelay, () {
        if (_isHovering && mounted) _showTooltip();
      });
    }
  }

  void _onPointerExit(PointerExitEvent event) {
    if (widget.triggerMode == TTooltipTriggerMode.hover) {
      _isHovering = false;
      Future.delayed(widget.hideDelay, () {
        if (!_isHovering && mounted) _hideTooltip();
      });
    }
  }

  void _onTap() {
    if (widget.triggerMode != TTooltipTriggerMode.tap) return;

    _isVisible ? _hideTooltip() : _showTooltip();

    if (!_isVisible) return;

    Future.delayed(widget.showDuration, () {
      if (_isVisible && mounted) _hideTooltip();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onPointerEnter,
      onExit: _onPointerExit,
      child: GestureDetector(
        onTap: _onTap,
        child: KeyedSubtree(key: _childKey, child: widget.child),
      ),
    );
  }
}

class _TooltipContent extends StatelessWidget {
  const _TooltipContent({
    required this.message,
    this.richMessage,
    required this.targetRect,
    required this.position,
    required this.color,
    required this.size,
    this.decoration,
    this.textStyle,
    this.textAlign,
    required this.margin,
    this.padding,
    required this.verticalOffset,
    required this.preferBelow,
    required this.showArrow,
    required this.maxWidth,
    required this.animation,
    this.icon,
    this.onTap,
    required this.resolvedPosition,
  });

  final String message;
  final Widget? richMessage;
  final Rect targetRect;
  final TTooltipPosition position;
  final MaterialColor color;
  final TTooltipSize size;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? padding;
  final double verticalOffset;
  final bool preferBelow;
  final bool showArrow;
  final double maxWidth;
  final Animation<double> animation;
  final IconData? icon;
  final VoidCallback? onTap;
  final TTooltipResolvedPosition resolvedPosition;

  Offset _getAnimationOffset() {
    switch (resolvedPosition) {
      case TTooltipResolvedPosition.top:
        return const Offset(0, 8);
      case TTooltipResolvedPosition.bottom:
        return const Offset(0, -8);
      case TTooltipResolvedPosition.left:
        return const Offset(8, 0);
      case TTooltipResolvedPosition.right:
        return const Offset(-8, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, txtColor) = (color.shade50, color.shade500);
    final (defaultPadding, fontSize) = _sizeStyle();
    final effectivePadding = padding ?? defaultPadding;
    final effectiveTextStyle = textStyle ?? TextStyle(color: txtColor, fontSize: fontSize, fontWeight: FontWeight.w400);

    final offset = _getAnimationOffset();

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(offset.dx * (1 - animation.value), offset.dy * (1 - animation.value)),
          child: _PositionedTooltip(
            targetRect: targetRect,
            position: position,
            preferBelow: preferBelow,
            verticalOffset: verticalOffset,
            margin: margin,
            showArrow: showArrow,
            backgroundColor: bgColor,
            maxWidth: maxWidth,
            child: Material(
              type: MaterialType.transparency,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  padding: effectivePadding,
                  decoration: decoration ??
                      BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: color.shade800.withAlpha(25),
                            blurRadius: 8,
                            spreadRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, size: fontSize + 2, color: txtColor),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: richMessage ??
                                  Text(
                                    message,
                                    style: effectiveTextStyle,
                                    textAlign: textAlign,
                                    softWrap: true,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  (EdgeInsets, double) _sizeStyle() {
    switch (size) {
      case TTooltipSize.small:
        return (const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 12);
      case TTooltipSize.medium:
        return (const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 13.6);
      case TTooltipSize.large:
        return (const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 15);
    }
  }
}

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSize extends StatefulWidget {
  final Widget child;
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    super.key,
    required this.child,
    required this.onChange,
  });

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  final _key = GlobalKey();
  Size _oldSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _key.currentContext;
      if (context == null) return;
      final newSize = context.size;
      if (newSize == null) return;
      if (_oldSize != newSize) {
        _oldSize = newSize;
        widget.onChange(newSize);
      }
    });

    return Container(key: _key, child: widget.child);
  }
}

class _PositionedTooltip extends StatefulWidget {
  const _PositionedTooltip({
    required this.child,
    required this.targetRect,
    required this.position,
    required this.preferBelow,
    required this.verticalOffset,
    required this.margin,
    required this.showArrow,
    required this.backgroundColor,
    required this.maxWidth,
  });

  final Widget child;
  final Rect targetRect;
  final TTooltipPosition position;
  final bool preferBelow;
  final double verticalOffset;
  final EdgeInsetsGeometry margin;
  final bool showArrow;
  final Color backgroundColor;
  final double maxWidth;

  @override
  State<_PositionedTooltip> createState() => _PositionedTooltipState();
}

class _PositionedTooltipState extends State<_PositionedTooltip> {
  Size tooltipSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final marginInsets = widget.margin is EdgeInsets ? widget.margin as EdgeInsets : EdgeInsets.zero;

    final spaceAbove = widget.targetRect.top - marginInsets.top;
    final spaceBelow = screenSize.height - widget.targetRect.bottom - marginInsets.bottom;
    final spaceLeft = widget.targetRect.left - marginInsets.left;
    final spaceRight = screenSize.width - widget.targetRect.right - marginInsets.right;

    double tooltipHeight = tooltipSize.height;
    double tooltipWidth = tooltipSize.width.clamp(0.0, widget.maxWidth);

    // Determine position
    TTooltipPosition actualPosition = widget.position;
    TArrowDirection arrowDirection = TArrowDirection.up;

    if (actualPosition == TTooltipPosition.auto) {
      if (widget.preferBelow && spaceBelow >= tooltipHeight + widget.verticalOffset) {
        actualPosition = TTooltipPosition.bottom;
      } else if (spaceAbove >= tooltipHeight + widget.verticalOffset) {
        actualPosition = TTooltipPosition.top;
      } else if (spaceRight >= widget.maxWidth) {
        actualPosition = TTooltipPosition.right;
      } else if (spaceLeft >= widget.maxWidth) {
        actualPosition = TTooltipPosition.left;
      } else {
        actualPosition = spaceBelow > spaceAbove ? TTooltipPosition.bottom : TTooltipPosition.top;
      }
    }

    double tooltipX = 0;
    double tooltipY = 0;

    switch (actualPosition) {
      case TTooltipPosition.top:
        tooltipX = widget.targetRect.center.dx - tooltipWidth / 2;
        tooltipY = widget.targetRect.top - widget.verticalOffset - tooltipHeight;
        arrowDirection = TArrowDirection.down;
        break;
      case TTooltipPosition.bottom:
        tooltipX = widget.targetRect.center.dx - tooltipWidth / 2;
        tooltipY = widget.targetRect.bottom + widget.verticalOffset;
        arrowDirection = TArrowDirection.up;
        break;
      case TTooltipPosition.left:
        tooltipX = widget.targetRect.left - widget.verticalOffset - tooltipWidth;
        tooltipY = widget.targetRect.center.dy - tooltipHeight / 2;
        arrowDirection = TArrowDirection.right;
        break;
      case TTooltipPosition.right:
        tooltipX = widget.targetRect.right + widget.verticalOffset;
        tooltipY = widget.targetRect.center.dy - tooltipHeight / 2;
        arrowDirection = TArrowDirection.left;
        break;
      case TTooltipPosition.auto:
        tooltipX = widget.targetRect.center.dx - tooltipWidth / 2;
        tooltipY = widget.targetRect.bottom + widget.verticalOffset;
        arrowDirection = TArrowDirection.down;
        break;
    }

    tooltipX = tooltipX.clamp(marginInsets.left, screenSize.width - tooltipWidth - marginInsets.right);
    tooltipY = tooltipY.clamp(marginInsets.top, screenSize.height - tooltipHeight - marginInsets.bottom);

    return ClipRect(
      child: Stack(
        children: [
          Positioned(
            left: tooltipX,
            top: tooltipY,
            child: Container(
              margin: marginInsets,
              constraints: BoxConstraints(maxWidth: widget.maxWidth),
              child: MeasureSize(
                onChange: (size) {
                  if (tooltipSize != size) {
                    setState(() {
                      tooltipSize = size;
                    });
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showArrow && arrowDirection == TArrowDirection.up)
                      _TooltipArrow(color: widget.backgroundColor, direction: TArrowDirection.up),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showArrow && arrowDirection == TArrowDirection.left)
                          _TooltipArrow(color: widget.backgroundColor, direction: TArrowDirection.left),
                        widget.child,
                        if (widget.showArrow && arrowDirection == TArrowDirection.right)
                          _TooltipArrow(color: widget.backgroundColor, direction: TArrowDirection.right),
                      ],
                    ),
                    if (widget.showArrow && arrowDirection == TArrowDirection.down)
                      _TooltipArrow(color: widget.backgroundColor, direction: TArrowDirection.down),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TooltipArrow extends StatelessWidget {
  const _TooltipArrow({
    required this.color,
    required this.direction,
  });

  final Color color;
  final TArrowDirection direction;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: direction == TArrowDirection.left || direction == TArrowDirection.right ? const Size(8, 16) : const Size(16, 8),
      painter: _ArrowPainter(color: color, direction: direction),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final TArrowDirection direction;

  const _ArrowPainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    switch (direction) {
      case TArrowDirection.up:
        // Arrow pointing up (tooltip below target)
        path.moveTo(size.width / 2, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case TArrowDirection.down:
        // Arrow pointing down (tooltip above target)
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width / 2, size.height);
        break;
      case TArrowDirection.left:
        // Arrow pointing left (tooltip to the right)
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case TArrowDirection.right:
        // Arrow pointing right (tooltip to the left)
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
    }

    path.close();

    // Draw shadow first
    final shadowPath = path.shift(const Offset(0, 1));
    final shadowPaint = Paint()
      ..color = AppColors.grey.shade900.withAlpha(10)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw arrow
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
