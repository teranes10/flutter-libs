import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

export 'badge_size.dart';

/// A versatile badge widget that displays status dots, counts, text pills,
/// or custom widget overlays on any widget.
///
/// `TBadge` is designed to be fully generic:
/// - It can wrap **any widget** ([Icon], [Text], [TAvatar], [TButton], [Container], [Card], etc.).
/// - It can display **any content** via the generic [badge] parameter (`int`, `num`, `String`, `bool`, or `Widget`),
///   or via dedicated parameters/constructors ([count], [label], [dot], [badgeWidget]).
/// - It can also be rendered standalone without a child widget via [TBadge.standalone].
///
/// ## Basic Usage (Wrapping an Icon or Avatar)
///
/// ```dart
/// TBadge(
///   count: 5,
///   child: Icon(Icons.notifications),
/// )
///
/// TBadge(
///   dot: true,
///   child: TAvatar(name: 'Jane Doe'),
/// )
/// ```
///
/// ## Generic / Dynamic Badge Content
///
/// ```dart
/// TBadge(
///   badge: 12, // int count
///   child: Icon(Icons.mail),
/// )
///
/// TBadge(
///   badge: 'NEW', // text pill
///   color: AppColors.primary,
///   child: Text('Dashboard'),
/// )
///
/// TBadge(
///   badge: true, // status dot
///   alignment: Alignment.bottomRight,
///   child: TAvatar(name: 'JD'),
/// )
/// ```
///
/// ## Named Constructors
///
/// - [TBadge.count] — for notification counts with auto overflow (e.g. `99+`).
/// - [TBadge.dot] — for status dots.
/// - [TBadge.label] — for text badges like "NEW", "HOT", "BETA".
/// - [TBadge.custom] — for arbitrary widget badge overlays.
/// - [TBadge.standalone] — renders the badge itself without a child wrapper.
class TBadge extends StatelessWidget {
  /// The target widget to display the badge on.
  ///
  /// If null, the badge itself is rendered standalone.
  final Widget? child;

  /// Dynamic badge content: supports [int]/[num] (count), [String] (label),
  /// [bool] (dot indicator when true), or a custom [Widget].
  final dynamic badge;

  /// The numerical value to display in the badge.
  final int? count;

  /// A custom text label to display in the badge.
  final String? label;

  /// Whether to display a small status dot instead of text/count.
  final bool dot;

  /// A custom widget to use as the badge overlay.
  final Widget? badgeWidget;

  /// The alignment position of the badge relative to [child].
  ///
  /// Defaults to [Alignment.topRight].
  final Alignment alignment;

  /// Optional fine-grained offset to adjust badge positioning.
  final Offset? offset;

  /// The background color of the badge.
  ///
  /// Defaults to [TTheme.danger].
  final Color? color;

  /// The text color of the badge.
  ///
  /// Defaults to [Colors.white].
  final Color? textColor;

  /// Custom text style for count or label badges.
  final TextStyle? textStyle;

  /// The border color surrounding the badge.
  ///
  /// Defaults to [TColors.surface].
  final Color? borderColor;

  /// The width of the border surrounding the badge.
  ///
  /// Defaults to `1.5`.
  final double borderWidth;

  /// Whether to render a border around the badge.
  ///
  /// Defaults to `true`.
  final bool showBorder;

  /// The maximum count to display before showing a '+' sign.
  ///
  /// Defaults to `99`.
  final int maxCount;

  /// Whether to hide the badge when numerical count is 0.
  ///
  /// Defaults to `true`.
  final bool hideZero;

  /// Whether the badge is completely hidden.
  ///
  /// Defaults to `false`.
  final bool hidden;

  /// The size configuration of the badge.
  ///
  /// Supports [TSize] presets (e.g. [TBadgeSize.sm], [TBadgeSize.xs], [TBadgeSize.xxs],
  /// [TBadgeSize.md], [TBadgeSize.lg], or standard [TSize] instances).
  final TSize? size;

  /// Padding applied inside count or label badges.
  final EdgeInsetsGeometry? padding;

  /// Border radius for rounded badges.
  final BorderRadiusGeometry? borderRadius;

  /// Shape of the badge container.
  final BoxShape? shape;

  /// Creates a versatile badge.
  const TBadge({
    super.key,
    this.child,
    this.badge,
    this.count,
    this.label,
    this.dot = false,
    this.badgeWidget,
    this.alignment = Alignment.topRight,
    this.offset,
    this.color,
    this.textColor,
    this.textStyle,
    this.borderColor,
    this.borderWidth = 1.5,
    this.showBorder = true,
    this.maxCount = 99,
    this.hideZero = true,
    this.hidden = false,
    this.size,
    this.padding,
    this.borderRadius,
    this.shape,
  });

  /// Creates a numerical count badge.
  const TBadge.count({
    super.key,
    this.child,
    required int this.count,
    this.alignment = Alignment.topRight,
    this.offset,
    this.color,
    this.textColor,
    this.textStyle,
    this.borderColor,
    this.borderWidth = 1.5,
    this.showBorder = true,
    this.maxCount = 99,
    this.hideZero = true,
    this.hidden = false,
    this.size,
    this.padding,
    this.borderRadius,
    this.shape,
  })  : badge = null,
        label = null,
        dot = false,
        badgeWidget = null;

  /// Creates a status dot badge.
  const TBadge.dot({
    super.key,
    this.child,
    this.alignment = Alignment.topRight,
    this.offset,
    this.color,
    this.borderColor,
    this.borderWidth = 1.5,
    this.showBorder = true,
    this.hidden = false,
    this.size,
  })  : dot = true,
        count = null,
        label = null,
        badge = null,
        badgeWidget = null,
        textColor = null,
        textStyle = null,
        maxCount = 99,
        hideZero = true,
        padding = null,
        borderRadius = null,
        shape = BoxShape.circle;

  /// Creates a text label badge (e.g. "NEW", "HOT", "SALE").
  const TBadge.label({
    super.key,
    this.child,
    required String this.label,
    this.alignment = Alignment.topRight,
    this.offset,
    this.color,
    this.textColor,
    this.textStyle,
    this.borderColor,
    this.borderWidth = 1.5,
    this.showBorder = true,
    this.hidden = false,
    this.size,
    this.padding,
    this.borderRadius,
    this.shape,
  })  : dot = false,
        count = null,
        badge = null,
        badgeWidget = null,
        maxCount = 99,
        hideZero = true;

  /// Creates a badge with a custom widget overlay.
  const TBadge.custom({
    super.key,
    this.child,
    required Widget this.badgeWidget,
    this.alignment = Alignment.topRight,
    this.offset,
    this.hidden = false,
  })  : dot = false,
        count = null,
        label = null,
        badge = null,
        color = null,
        textColor = null,
        textStyle = null,
        borderColor = null,
        borderWidth = 1.5,
        showBorder = false,
        maxCount = 99,
        hideZero = true,
        size = null,
        padding = null,
        borderRadius = null,
        shape = null;

  /// Creates a standalone badge widget without a child wrapper.
  const TBadge.standalone({
    Key? key,
    dynamic badge,
    int? count,
    String? label,
    bool dot = false,
    Widget? badgeWidget,
    Color? color,
    Color? textColor,
    TextStyle? textStyle,
    Color? borderColor,
    double borderWidth = 1.5,
    bool showBorder = true,
    int maxCount = 99,
    bool hideZero = true,
    bool hidden = false,
    TSize? size,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
    BoxShape? shape,
  }) : this(
          key: key,
          child: null,
          badge: badge,
          count: count,
          label: label,
          dot: dot,
          badgeWidget: badgeWidget,
          color: color,
          textColor: textColor,
          textStyle: textStyle,
          borderColor: borderColor,
          borderWidth: borderWidth,
          showBorder: showBorder,
          maxCount: maxCount,
          hideZero: hideZero,
          hidden: hidden,
          size: size,
          padding: padding,
          borderRadius: borderRadius,
          shape: shape,
        );

  @override
  Widget build(BuildContext context) {
    final badgeContent = _buildBadgeWidget(context);

    if (child == null) {
      return badgeContent ?? const SizedBox.shrink();
    }

    if (badgeContent == null) {
      return child!;
    }

    final isDot = _isDot();
    final defaultOffsetVal = isDot ? -2.0 : -4.0;

    final isTop = alignment.y < 0;
    final isBottom = alignment.y > 0;
    final isCenterY = alignment.y == 0;
    final isLeft = alignment.x < 0;
    final isRight = alignment.x > 0;
    final isCenterX = alignment.x == 0;

    final double? topVal = isTop
        ? (defaultOffsetVal + (offset?.dy ?? 0))
        : (isCenterY ? (offset?.dy ?? 0) : null);

    final double? bottomVal = isBottom
        ? (defaultOffsetVal - (offset?.dy ?? 0))
        : (isCenterY ? -(offset?.dy ?? 0) : null);

    final double? leftVal = isLeft
        ? (defaultOffsetVal + (offset?.dx ?? 0))
        : (isCenterX ? (offset?.dx ?? 0) : null);

    final double? rightVal = isRight
        ? (defaultOffsetVal - (offset?.dx ?? 0))
        : (isCenterX ? -(offset?.dx ?? 0) : null);

    final positionedBadge = Positioned(
      top: topVal,
      bottom: bottomVal,
      left: leftVal,
      right: rightVal,
      child: (isCenterX || isCenterY)
          ? Align(alignment: alignment, child: badgeContent)
          : badgeContent,
    );

    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        child!,
        positionedBadge,
      ],
    );
  }

  bool _isDot() {
    if (dot) return true;
    if (badge is bool && (badge as bool) == true) return true;
    return false;
  }

  Widget? _buildBadgeWidget(BuildContext context) {
    if (hidden) return null;

    if (badgeWidget != null) {
      return badgeWidget;
    }

    final effectiveColor = color ?? context.theme.danger;
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveBorderColor = borderColor ?? context.colors.surface;
    final border = (showBorder && borderWidth > 0)
        ? Border.all(color: effectiveBorderColor, width: borderWidth)
        : null;

    // 1. Generic badge parameter handling
    if (badge != null) {
      if (badge is bool) {
        if (!(badge as bool)) return null;
        return _buildDot(effectiveColor, border);
      }

      if (badge is Widget) {
        return badge as Widget;
      }

      if (badge is num) {
        final countNum = (badge as num).toInt();
        if (countNum == 0 && hideZero) return null;
        final text = countNum > maxCount ? '$maxCount+' : countNum.toString();
        return _buildPill(
          context,
          text: text,
          bgColor: effectiveColor,
          fgColor: effectiveTextColor,
          border: border,
          minSize: 18,
        );
      }

      if (badge is String) {
        final text = badge as String;
        if (text.isEmpty) return null;
        return _buildPill(
          context,
          text: text,
          bgColor: effectiveColor,
          fgColor: effectiveTextColor,
          border: border,
          minSize: 16,
        );
      }
    }

    // 2. Explicit dot
    if (dot) {
      return _buildDot(effectiveColor, border);
    }

    // 3. Explicit count
    if (count != null) {
      if (count == 0 && hideZero) return null;
      final text = count! > maxCount ? '$maxCount+' : count.toString();
      return _buildPill(
        context,
        text: text,
        bgColor: effectiveColor,
        fgColor: effectiveTextColor,
        border: border,
        minSize: 18,
      );
    }

    // 4. Explicit label
    if (label != null) {
      if (label!.isEmpty) return null;
      return _buildPill(
        context,
        text: label!,
        bgColor: effectiveColor,
        fgColor: effectiveTextColor,
        border: border,
        minSize: 16,
      );
    }

    return null;
  }

  Widget _buildDot(Color bgColor, BoxBorder? border) {
    final dotSize = size != null && size!.minW > 0 ? size!.minW : (size?.icon ?? 8.0);
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: border,
      ),
    );
  }

  Widget _buildPill(
    BuildContext context, {
    required String text,
    required Color bgColor,
    required Color fgColor,
    required BoxBorder? border,
    required double minSize,
  }) {
    final effectivePadding = padding ??
        (size != null
            ? EdgeInsets.symmetric(horizontal: size!.hPad, vertical: size!.vPad)
            : const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5));
    final effectiveRadius = borderRadius ??
        (size != null ? BorderRadius.circular(size!.radius) : BorderRadius.circular(10));
    final effectiveFontSize = size?.font ?? (text.length > 3 ? 9.5 : 10.0);
    final effectiveTextStyle = textStyle ??
        TextStyle(
          color: fgColor,
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.bold,
          height: 1.1,
        );

    final effectiveMinW = size != null && size!.minW > 0 ? size!.minW : minSize;
    final effectiveMinH = size != null && size!.minH > 0 ? size!.minH : minSize;

    return Container(
      padding: effectivePadding,
      constraints: BoxConstraints(
        minWidth: effectiveMinW,
        minHeight: effectiveMinH,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: shape == BoxShape.circle ? null : effectiveRadius,
        shape: shape ?? BoxShape.rectangle,
        border: border,
      ),
      child: Center(
        child: Text(
          text,
          style: effectiveTextStyle,
        ),
      ),
    );
  }
}
