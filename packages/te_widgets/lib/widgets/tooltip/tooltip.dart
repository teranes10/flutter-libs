import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

/// A customizable tooltip with rich content and positioning options.
///
/// `TTooltip` provides an advanced tooltip widget with:
/// - Auto-positioning based on available space
/// - Manual position control (top/bottom/left/right)
/// - Rich content support (text or custom widgets)
/// - Icons and custom styling
/// - Hover or tap trigger modes
/// - Interactive tooltips
/// - Configurable delays and durations
/// - Arrow indicators
///
/// ## Basic Usage
///
/// ```dart
/// TTooltip(
///   message: 'Click to edit',
///   child: IconButton(
///     icon: Icon(Icons.edit),
///     onPressed: () {},
///   ),
/// )
/// ```
///
/// ## With Custom Position
///
/// ```dart
/// TTooltip(
///   message: 'This is a tooltip',
///   position: TTooltipPosition.right,
///   icon: Icons.info,
///   child: Text('Hover me'),
/// )
/// ```
///
/// ## Interactive Tooltip
///
/// ```dart
/// TTooltip(
///   message: 'Click anywhere to close',
///   interactive: true,
///   triggerMode: TTooltipTriggerMode.tap,
///   child: ElevatedButton(
///     onPressed: () {},
///     child: Text('Show Tooltip'),
///   ),
/// )
/// ```
///
/// See also:
/// - [TTooltipPosition] for position options
/// - [TTooltipTriggerMode] for trigger modes
class TTooltip extends StatefulWidget with TPopupMixin {
  /// The text message to display in the tooltip.
  final String message;

  /// Rich content widget to display instead of plain text.
  final Widget? richMessage;

  /// The widget that triggers the tooltip.
  final Widget child;

  /// The position of the tooltip relative to the child.
  ///
  /// Defaults to [TTooltipPosition.auto].
  final TTooltipPosition position;

  /// Custom color for the tooltip.
  final Color? color;

  /// Optional icon to display in the tooltip.
  final IconData? icon;

  /// The size of the tooltip.
  final TTooltipSize size;

  /// Delay before showing the tooltip.
  final Duration showDelay;

  /// Delay before hiding the tooltip.
  final Duration hideDelay;

  /// Wait duration before the tooltip can be shown again.
  final Duration waitDuration;

  /// Duration to show the tooltip (for tap mode).
  final Duration showDuration;

  /// How the tooltip is triggered (hover or tap).
  final TTooltipTriggerMode triggerMode;

  /// Whether to provide haptic feedback.
  final bool enableFeedback;

  /// Whether to exclude from semantics.
  final bool excludeFromSemantics;

  /// Custom decoration for the tooltip.
  final Decoration? decoration;

  /// Custom text style for the message.
  final TextStyle? textStyle;

  /// Text alignment for the message.
  final TextAlign? textAlign;

  /// Margin around the tooltip.
  final EdgeInsetsGeometry margin;

  /// Padding inside the tooltip.
  final EdgeInsets? padding;

  /// Vertical offset from the child.
  final double verticalOffset;

  /// Whether to prefer showing below the child.
  final bool preferBelow;

  /// Whether to enable haptic feedback on show.
  final bool enableHapticFeedback;

  /// Whether to show the arrow indicator.
  final bool showArrow;

  /// Whether the tooltip is interactive (can be clicked).
  final bool interactive;

  /// Maximum width of the tooltip.
  final double maxWidth;

  /// Callback fired when the tooltip is shown.
  @override
  final VoidCallback? onShow;

  /// Callback fired when the tooltip is hidden.
  @override
  final VoidCallback? onHide;

  /// The variant type for theming.
  final TVariant? type;

  /// Whether the tooltip is disabled.
  @override
  final bool disabled;

  @override
  TPopupAlignment get alignment {
    return switch (position) {
      TTooltipPosition.auto => TPopupAlignment.bottomCenter,
      TTooltipPosition.top => TPopupAlignment.topCenter,
      TTooltipPosition.bottom => TPopupAlignment.bottomCenter,
      TTooltipPosition.left => TPopupAlignment.leftCenter,
      TTooltipPosition.right => TPopupAlignment.rightCenter,
    };
  }

  @override
  double get offset => verticalOffset;

  @override
  bool get showCloseButton => false;

  /// Creates a tooltip.
  const TTooltip({
    super.key,
    required this.message,
    required this.child,
    this.richMessage,
    this.icon,
    this.position = TTooltipPosition.auto,
    this.color,
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
    this.type,
    this.disabled = false,
  });

  @override
  State<TTooltip> createState() => _TTooltipState();
}

class _TTooltipState extends State<TTooltip> with SingleTickerProviderStateMixin, TPopupStateMixin<TTooltip> {
  late AnimationController _animationController;
  bool _isHovering = false;

  @override
  bool get shouldCenteredOverlay => false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void showPopup(BuildContext context) {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    super.showPopup(context);
    _animationController.forward();
  }

  @override
  void hidePopup() {
    if (!isPopupShowing) return;
    _animationController.reverse().then((_) {
      if (mounted) super.hidePopup();
    });
  }

  @override
  Widget getContentWidget(BuildContext context) {
    // This is called by TPopupStateMixin but we override buildAnchoredOverlayChild
    // to pass more context (like targetRect and animation) to _TooltipContent.
    return const SizedBox.shrink();
  }

  @override
  Widget buildAnchoredOverlayChild(BuildContext context, TPopupConstraints constraints) {
    final targetRect = Rect.fromLTWH(
      constraints.targetOffset.dx,
      constraints.targetOffset.dy,
      constraints.targetSize.width,
      constraints.targetSize.height,
    );

    return Stack(
      children: [
        if (widget.interactive)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: hidePopup,
              child: const SizedBox.expand(),
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
          animation: CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
          icon: widget.icon,
          onTap: widget.interactive ? null : hidePopup,
          resolvedPosition: _resolveAutoPosition(targetRect),
          onPointerEnter: _onTooltipPointerEnter,
          onPointerExit: _onTooltipPointerExit,
          type: widget.type,
        ),
      ],
    );
  }

  TTooltipResolvedPosition _resolveAutoPosition(Rect targetRect) {
    if (widget.position != TTooltipPosition.auto) {
      return switch (widget.position) {
        TTooltipPosition.top => TTooltipResolvedPosition.top,
        TTooltipPosition.bottom => TTooltipResolvedPosition.bottom,
        TTooltipPosition.left => TTooltipResolvedPosition.left,
        TTooltipPosition.right => TTooltipResolvedPosition.right,
        TTooltipPosition.auto => TTooltipResolvedPosition.bottom,
      };
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) return TTooltipResolvedPosition.bottom;

    final screenHeight = overlayBox.size.height;
    final screenWidth = overlayBox.size.width;

    final requiredSpace = widget.maxWidth + 20.0;

    final spaceTop = targetRect.top;
    final spaceBottom = screenHeight - targetRect.bottom;
    final spaceLeft = targetRect.left;
    final spaceRight = screenWidth - targetRect.right;

    if (spaceBottom >= 60.0) return TTooltipResolvedPosition.bottom;
    if (spaceTop >= 60.0) return TTooltipResolvedPosition.top;
    if (spaceRight >= requiredSpace) return TTooltipResolvedPosition.right;
    if (spaceLeft >= requiredSpace) return TTooltipResolvedPosition.left;

    return spaceBottom > spaceTop ? TTooltipResolvedPosition.bottom : TTooltipResolvedPosition.top;
  }

  void _onPointerEnter(PointerEnterEvent event) {
    _isHovering = true;
    Future.delayed(widget.showDelay, () {
      if (_isHovering && mounted) showPopup(context);
    });
  }

  void _onPointerExit(PointerExitEvent event) {
    _isHovering = false;
    Future.delayed(widget.hideDelay, () {
      if (!_isHovering && mounted) hidePopup();
    });
  }

  void _onTooltipPointerEnter(PointerEnterEvent event) {
    _isHovering = true;
  }

  void _onTooltipPointerExit(PointerExitEvent event) {
    _isHovering = false;
    Future.delayed(widget.hideDelay, () {
      if (!_isHovering && mounted) hidePopup();
    });
  }

  void _onTap(PointerDownEvent event) {
    if (widget.triggerMode == TTooltipTriggerMode.hover) return;
    if (widget.triggerMode == TTooltipTriggerMode.adaptive && event.kind != PointerDeviceKind.touch) return;

    isPopupShowing ? hidePopup() : showPopup(context);

    if (!isPopupShowing) return;

    Future.delayed(widget.showDuration, () {
      if (isPopupShowing && mounted) hidePopup();
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildWithDropdownTarget(
      child: MouseRegion(
        onEnter: _onPointerEnter,
        onExit: _onPointerExit,
        child: Listener(
          onPointerDown: _onTap,
          child: widget.child,
        ),
      ),
    );
  }
}

class _TooltipContent extends StatelessWidget {
  final String message;
  final Widget? richMessage;
  final Rect targetRect;
  final TTooltipPosition position;
  final Color? color;
  final TTooltipSize size;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry margin;
  final EdgeInsets? padding;
  final double verticalOffset;
  final bool preferBelow;
  final bool showArrow;
  final double maxWidth;
  final Animation<double> animation;
  final IconData? icon;
  final VoidCallback? onTap;
  final TTooltipResolvedPosition resolvedPosition;
  final void Function(PointerEnterEvent)? onPointerEnter;
  final void Function(PointerExitEvent)? onPointerExit;
  final TVariant? type;

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
    this.onPointerEnter,
    this.onPointerExit,
    this.type,
  });

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
    final theme = context.theme;
    final mType = type ?? theme.tooltipType;
    final wTheme = context.getWidgetTheme(mType, color);

    final (defaultPadding, fontSize) = _sizeStyle();
    final effectivePadding = padding ?? defaultPadding;
    final effectiveTextStyle = textStyle ?? TextStyle(color: wTheme.onContainer, fontSize: fontSize, fontWeight: FontWeight.w400);

    final offset = _getAnimationOffset();

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(offset.dx * (1 - animation.value), offset.dy * (1 - animation.value)),
          child: _PositionedTooltip(
            targetRect: targetRect,
            resolvedPosition: resolvedPosition,
            verticalOffset: verticalOffset,
            margin: margin,
            showArrow: showArrow,
            backgroundColor: wTheme.container,
            shadowColor: wTheme.shadow,
            maxWidth: maxWidth,
            child: Material(
              elevation: 8,
              shadowColor: wTheme.shadow,
              borderRadius: BorderRadius.circular(8),
              child: MouseRegion(
                onEnter: onPointerEnter,
                onExit: onPointerExit,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    padding: effectivePadding,
                    decoration: decoration ?? BoxDecoration(color: wTheme.container, borderRadius: BorderRadius.circular(8)),
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
                                Icon(icon, size: fontSize + 2, color: wTheme.onContainer),
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

class _PositionedTooltip extends StatelessWidget {
  final Widget child;
  final Rect targetRect;
  final TTooltipResolvedPosition resolvedPosition;
  final double verticalOffset;
  final EdgeInsetsGeometry margin;
  final bool showArrow;
  final Color backgroundColor;
  final Color? shadowColor;
  final double maxWidth;

  const _PositionedTooltip({
    required this.child,
    required this.targetRect,
    required this.resolvedPosition,
    required this.verticalOffset,
    required this.margin,
    required this.showArrow,
    required this.backgroundColor,
    this.shadowColor,
    required this.maxWidth,
  });

  TArrowDirection get _arrowDirection => switch (resolvedPosition) {
        TTooltipResolvedPosition.top => TArrowDirection.down,
        TTooltipResolvedPosition.bottom => TArrowDirection.up,
        TTooltipResolvedPosition.left => TArrowDirection.right,
        TTooltipResolvedPosition.right => TArrowDirection.left,
      };

  @override
  Widget build(BuildContext context) {
    final arrowDirection = _arrowDirection;
    final marginInsets = margin is EdgeInsets ? margin as EdgeInsets : EdgeInsets.zero;

    return CustomSingleChildLayout(
      delegate: _TooltipPositionDelegate(
        targetRect: targetRect,
        resolvedPosition: resolvedPosition,
        verticalOffset: verticalOffset,
        marginInsets: marginInsets,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, minWidth: 50.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showArrow && arrowDirection == TArrowDirection.up)
              _TooltipArrow(color: backgroundColor, shadowColor: shadowColor, direction: TArrowDirection.up),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showArrow && arrowDirection == TArrowDirection.left)
                  _TooltipArrow(color: backgroundColor, shadowColor: shadowColor, direction: TArrowDirection.left),
                Flexible(child: child),
                if (showArrow && arrowDirection == TArrowDirection.right)
                  _TooltipArrow(color: backgroundColor, shadowColor: shadowColor, direction: TArrowDirection.right),
              ],
            ),
            if (showArrow && arrowDirection == TArrowDirection.down)
              _TooltipArrow(color: backgroundColor, shadowColor: shadowColor, direction: TArrowDirection.down),
          ],
        ),
      ),
    );
  }
}

class _TooltipPositionDelegate extends SingleChildLayoutDelegate {
  final Rect targetRect;
  final TTooltipResolvedPosition resolvedPosition;
  final double verticalOffset;
  final EdgeInsets marginInsets;

  const _TooltipPositionDelegate({
    required this.targetRect,
    required this.resolvedPosition,
    required this.verticalOffset,
    required this.marginInsets,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // Let child measure its own natural size (loose constraints).
    return BoxConstraints(
      maxWidth: constraints.maxWidth,
      maxHeight: constraints.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final tw = childSize.width;
    final th = childSize.height;

    final spaceAbove = targetRect.top;
    final spaceBelow = size.height - targetRect.bottom;
    final spaceLeft = targetRect.left;
    final spaceRight = size.width - targetRect.right;

    TTooltipResolvedPosition effectivePosition = resolvedPosition;
    switch (resolvedPosition) {
      case TTooltipResolvedPosition.bottom:
        if (spaceBelow < th + verticalOffset && spaceAbove >= th + verticalOffset) {
          effectivePosition = TTooltipResolvedPosition.top;
        }
        break;
      case TTooltipResolvedPosition.top:
        if (spaceAbove < th + verticalOffset && spaceBelow >= th + verticalOffset) {
          effectivePosition = TTooltipResolvedPosition.bottom;
        }
        break;
      case TTooltipResolvedPosition.left:
        if (spaceLeft < tw + verticalOffset && spaceRight >= tw + verticalOffset) {
          effectivePosition = TTooltipResolvedPosition.right;
        }
        break;
      case TTooltipResolvedPosition.right:
        if (spaceRight < tw + verticalOffset && spaceLeft >= tw + verticalOffset) {
          effectivePosition = TTooltipResolvedPosition.left;
        }
        break;
    }

    double tooltipX;
    double tooltipY;

    switch (effectivePosition) {
      case TTooltipResolvedPosition.top:
        tooltipX = targetRect.center.dx - tw / 2;
        tooltipY = targetRect.top - verticalOffset - th;
        break;
      case TTooltipResolvedPosition.bottom:
        tooltipX = targetRect.center.dx - tw / 2;
        tooltipY = targetRect.bottom + verticalOffset;
        break;
      case TTooltipResolvedPosition.left:
        tooltipX = targetRect.left - verticalOffset - tw;
        tooltipY = targetRect.center.dy - th / 2;
        break;
      case TTooltipResolvedPosition.right:
        tooltipX = targetRect.right + verticalOffset;
        tooltipY = targetRect.center.dy - th / 2;
        break;
    }

    // Clamp within screen bounds respecting margin.
    final minX = marginInsets.left;
    final maxX = (size.width - tw - marginInsets.right).clamp(0.0, double.infinity);
    final minY = marginInsets.top;
    final maxY = (size.height - th - marginInsets.bottom).clamp(0.0, double.infinity);

    return Offset(
      tooltipX.clamp(minX, maxX),
      tooltipY.clamp(minY, maxY),
    );
  }

  @override
  bool shouldRelayout(_TooltipPositionDelegate old) {
    return targetRect != old.targetRect ||
        resolvedPosition != old.resolvedPosition ||
        verticalOffset != old.verticalOffset ||
        marginInsets != old.marginInsets;
  }

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;
}

class _TooltipArrow extends StatelessWidget {
  final Color color;
  final Color? shadowColor;
  final TArrowDirection direction;

  const _TooltipArrow({
    required this.color,
    this.shadowColor,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: direction == TArrowDirection.left || direction == TArrowDirection.right ? const Size(8, 16) : const Size(16, 8),
      painter: _ArrowPainter(color: color, shadowColor: shadowColor, direction: direction),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final Color? shadowColor;
  final TArrowDirection direction;

  const _ArrowPainter({required this.color, this.shadowColor, required this.direction});

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
      ..color = shadowColor ?? Colors.transparent
      ..style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw arrow
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
