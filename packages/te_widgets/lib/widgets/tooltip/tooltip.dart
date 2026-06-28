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
    final wTheme = color != null ? context.getWidgetTheme(mType, color) : TWidgetTheme.surfaceTheme(context.colors, variant: mType);

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
            position: position,
            preferBelow: preferBelow,
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
  final Widget child;
  final Rect targetRect;
  final TTooltipPosition position;
  final bool preferBelow;
  final double verticalOffset;
  final EdgeInsetsGeometry margin;
  final bool showArrow;
  final Color backgroundColor;
  final Color? shadowColor;
  final double maxWidth;

  const _PositionedTooltip({
    required this.child,
    required this.targetRect,
    required this.position,
    required this.preferBelow,
    required this.verticalOffset,
    required this.margin,
    required this.showArrow,
    required this.backgroundColor,
    this.shadowColor,
    required this.maxWidth,
  });

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

    // Determine position with better logic
    TTooltipPosition actualPosition = widget.position;
    TArrowDirection arrowDirection = TArrowDirection.up;

    final minRequiredHorizontalSpace = tooltipWidth + widget.verticalOffset + 10; // Extra margin

    if (actualPosition == TTooltipPosition.auto) {
      // Enhanced auto-positioning logic
      if (widget.preferBelow && spaceBelow >= tooltipHeight + widget.verticalOffset) {
        actualPosition = TTooltipPosition.bottom;
      } else if (spaceAbove >= tooltipHeight + widget.verticalOffset) {
        actualPosition = TTooltipPosition.top;
      } else if (spaceRight >= minRequiredHorizontalSpace) {
        actualPosition = TTooltipPosition.right;
      } else if (spaceLeft >= minRequiredHorizontalSpace) {
        actualPosition = TTooltipPosition.left;
      } else {
        // Force vertical positioning if horizontal won't fit
        actualPosition = spaceBelow > spaceAbove ? TTooltipPosition.bottom : TTooltipPosition.top;
      }
    } else {
      // Flip logic for explicit positions if there's no space
      switch (actualPosition) {
        case TTooltipPosition.top:
          if (spaceAbove < tooltipHeight + widget.verticalOffset && spaceBelow >= tooltipHeight + widget.verticalOffset) {
            actualPosition = TTooltipPosition.bottom;
          }
          break;
        case TTooltipPosition.bottom:
          if (spaceBelow < tooltipHeight + widget.verticalOffset && spaceAbove >= tooltipHeight + widget.verticalOffset) {
            actualPosition = TTooltipPosition.top;
          }
          break;
        case TTooltipPosition.left:
          if (spaceLeft < minRequiredHorizontalSpace && spaceRight >= minRequiredHorizontalSpace) {
            actualPosition = TTooltipPosition.right;
          }
          break;
        case TTooltipPosition.right:
          if (spaceRight < minRequiredHorizontalSpace && spaceLeft >= minRequiredHorizontalSpace) {
            actualPosition = TTooltipPosition.left;
          }
          break;
        case TTooltipPosition.auto:
          break;
      }
    }

    double tooltipX = 0;
    double tooltipY = 0;

    // Calculate effective max width for horizontal positioning
    double effectiveMaxWidth = widget.maxWidth;

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
        // Adjust max width based on available space
        final availableLeftSpace = widget.targetRect.left - widget.verticalOffset - marginInsets.left;
        effectiveMaxWidth = (availableLeftSpace - 10).clamp(100.0, widget.maxWidth); // Minimum 100px
        tooltipWidth = tooltipSize.width.clamp(0.0, effectiveMaxWidth);

        tooltipX = widget.targetRect.left - widget.verticalOffset - tooltipWidth;
        tooltipY = widget.targetRect.center.dy - tooltipHeight / 2;
        arrowDirection = TArrowDirection.right;
        break;
      case TTooltipPosition.right:
        // Adjust max width based on available space
        final availableRightSpace = screenSize.width - widget.targetRect.right - widget.verticalOffset - marginInsets.right;
        effectiveMaxWidth = (availableRightSpace - 10).clamp(100.0, widget.maxWidth); // Minimum 100px
        tooltipWidth = tooltipSize.width.clamp(0.0, effectiveMaxWidth);

        tooltipX = widget.targetRect.right + widget.verticalOffset;
        tooltipY = widget.targetRect.center.dy - tooltipHeight / 2;
        arrowDirection = TArrowDirection.left;
        break;
      case TTooltipPosition.auto:
        tooltipX = widget.targetRect.center.dx - tooltipWidth / 2;
        tooltipY = widget.targetRect.bottom + widget.verticalOffset;
        arrowDirection = TArrowDirection.up;
        break;
    }

    // Enhanced boundary checking
    final minX = marginInsets.left;
    final maxX = screenSize.width - tooltipWidth - marginInsets.right;
    final minY = marginInsets.top;
    final maxY = screenSize.height - tooltipHeight - marginInsets.bottom;

    // For horizontal positioning, be more strict about boundaries
    if (actualPosition == TTooltipPosition.left || actualPosition == TTooltipPosition.right) {
      tooltipX = tooltipX.clamp(minX, maxX);
      tooltipY = tooltipY.clamp(minY, maxY);
    } else {
      // For vertical positioning, allow more flexibility
      tooltipX = tooltipX.clamp(minX, maxX);
      tooltipY = tooltipY.clamp(minY, maxY);
    }

    return ClipRect(
      child: Stack(
        children: [
          Positioned(
            left: tooltipX,
            top: tooltipY,
            child: Container(
              margin: marginInsets,
              constraints: BoxConstraints(
                maxWidth: effectiveMaxWidth,
                minWidth: 50.0, // Minimum width to prevent too narrow tooltips
              ),
              child: MeasureSize(
                onChange: (size) {
                  if (tooltipSize != size) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        tooltipSize = size;
                      });
                    });
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showArrow && arrowDirection == TArrowDirection.up)
                      _TooltipArrow(color: widget.backgroundColor, shadowColor: widget.shadowColor, direction: TArrowDirection.up),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showArrow && arrowDirection == TArrowDirection.left)
                          _TooltipArrow(color: widget.backgroundColor, shadowColor: widget.shadowColor, direction: TArrowDirection.left),
                        Flexible(child: widget.child), // Wrap in Flexible to prevent overflow
                        if (widget.showArrow && arrowDirection == TArrowDirection.right)
                          _TooltipArrow(color: widget.backgroundColor, shadowColor: widget.shadowColor, direction: TArrowDirection.right),
                      ],
                    ),
                    if (widget.showArrow && arrowDirection == TArrowDirection.down)
                      _TooltipArrow(color: widget.backgroundColor, shadowColor: widget.shadowColor, direction: TArrowDirection.down),
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
