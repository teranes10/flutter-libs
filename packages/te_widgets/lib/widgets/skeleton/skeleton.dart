import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A customizable skeleton loader widget that displays animated pulse/shimmer
/// placeholders while content is loading.
///
/// `TSkeleton` can be used standalone to build custom loading layouts, or as
/// a wrapper around widgets to automatically show a placeholder when [loading] is true.
///
/// ## Named Constructors
/// - [TSkeleton.text] — For simulated lines of text.
/// - [TSkeleton.lines] — For multiple simulated paragraphs of text.
/// - [TSkeleton.circle] — For circular elements like avatars or icons.
/// - [TSkeleton.rect] — For rectangular content cards or images.
/// - [TSkeleton.card] — For full card shapes with avatar and text lines.
/// - [TSkeleton.tile] — For [TTile] list row placeholders.
/// - [TSkeleton.table] — For multi-row, multi-column table data skeletons.
///
/// ## Example Usage
///
/// ```dart
/// // 1. Standalone shapes
/// TSkeleton.text(width: 150)
/// TSkeleton.circle(size: 48)
/// TSkeleton.lines(count: 3)
///
/// // 2. Complex layout
/// TSkeleton.card()
/// TSkeleton.table(rows: 5, columns: 4)
///
/// // 3. Conditional wrapper
/// TSkeleton(
///   loading: isLoading,
///   child: UserProfileView(user: user),
/// )
/// ```
class TSkeleton extends StatefulWidget {
  /// The child widget to display when [loading] is false.
  final Widget? child;

  /// Whether the skeleton loading animation is active.
  ///
  /// If false and [child] is provided, [child] is rendered normally.
  final bool loading;

  /// Width of the skeleton placeholder.
  final double? width;

  /// Height of the skeleton placeholder.
  final double? height;

  /// Border radius of the skeleton placeholder.
  final BorderRadius? borderRadius;

  /// Shape of the placeholder (rectangle or circle).
  final BoxShape shape;

  /// Custom base color for the skeleton.
  final Color? color;

  /// Custom highlight color for the shimmer animation.
  final Color? highlightColor;

  /// Duration of one complete pulse animation cycle.
  final Duration duration;

  /// Optional padding around the skeleton.
  final EdgeInsetsGeometry? padding;

  /// Optional margin around the skeleton.
  final EdgeInsetsGeometry? margin;

  /// Creates a generic skeleton loader widget.
  const TSkeleton({
    super.key,
    this.child,
    this.loading = true,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.color,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.padding,
    this.margin,
  });

  /// Creates a text line placeholder.
  const TSkeleton.text({
    super.key,
    this.width,
    this.height = 14.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.color,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.padding,
    this.margin,
    this.loading = true,
  })  : child = null,
        shape = BoxShape.rectangle;

  /// Creates a circular skeleton placeholder (e.g. for avatars or circular icons).
  const TSkeleton.circle({
    super.key,
    double size = 40.0,
    this.color,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.padding,
    this.margin,
    this.loading = true,
  })  : width = size,
        height = size,
        shape = BoxShape.circle,
        borderRadius = null,
        child = null;

  /// Creates a rectangular skeleton placeholder.
  const TSkeleton.rect({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.color,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.padding,
    this.margin,
    this.loading = true,
  })  : child = null,
        shape = BoxShape.rectangle;

  /// Creates a multi-line paragraph placeholder.
  ///
  /// The last line can be rendered shorter using [lastLineWidthRatio] (default: 0.65).
  static Widget lines({
    Key? key,
    int count = 3,
    double spacing = 8.0,
    double lineHeight = 14.0,
    double lastLineWidthRatio = 0.65,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    Color? color,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
    bool loading = true,
  }) {
    if (!loading) return const SizedBox.shrink();

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(count, (index) {
        final isLast = index == count - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0.0 : spacing),
          child: FractionallySizedBox(
            widthFactor: isLast && count > 1 ? lastLineWidthRatio : 1.0,
            child: TSkeleton.text(
              height: lineHeight,
              borderRadius: borderRadius,
              color: color,
              highlightColor: highlightColor,
              duration: duration,
            ),
          ),
        );
      }),
    );
  }

  /// Creates a card skeleton with an optional avatar and text lines.
  static Widget card({
    Key? key,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    EdgeInsetsGeometry? margin = const EdgeInsets.only(bottom: 8.0),
    bool hasAvatar = true,
    double avatarSize = 40.0,
    int lines = 2,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(10.0)),
    Color? color,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
    bool loading = true,
  }) {
    if (!loading) return const SizedBox.shrink();

    return Container(
      key: key,
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: (color ?? Colors.grey).withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasAvatar)
            Row(
              children: [
                TSkeleton.circle(
                  size: avatarSize,
                  color: color,
                  highlightColor: highlightColor,
                  duration: duration,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TSkeleton.text(
                        width: 140.0,
                        height: 14.0,
                        color: color,
                        highlightColor: highlightColor,
                        duration: duration,
                      ),
                      const SizedBox(height: 6.0),
                      TSkeleton.text(
                        width: 90.0,
                        height: 11.0,
                        color: color,
                        highlightColor: highlightColor,
                        duration: duration,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (hasAvatar && lines > 0) const SizedBox(height: 16.0),
          if (lines > 0)
            TSkeleton.lines(
              count: lines,
              spacing: 8.0,
              lineHeight: 12.0,
              color: color,
              highlightColor: highlightColor,
              duration: duration,
            ),
        ],
      ),
    );
  }

  /// Creates a tile skeleton conforming to [TTile] geometry.
  static Widget tile({
    Key? key,
    TSize size = TTileSize.h5,
    bool hasLeading = true,
    bool hasSubtitle = true,
    bool hasTrailing = false,
    Color? color,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
    bool loading = true,
  }) {
    if (!loading) return const SizedBox.shrink();

    return Padding(
      key: key,
      padding: EdgeInsets.symmetric(horizontal: size.hPad, vertical: size.vPad),
      child: Row(
        children: [
          if (hasLeading) ...[
            TSkeleton.rect(
              width: size.icon + 12.0,
              height: size.icon + 12.0,
              borderRadius: BorderRadius.circular(size.radius),
              color: color,
              highlightColor: highlightColor,
              duration: duration,
            ),
            SizedBox(width: size.spacing + 6.0),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TSkeleton.text(
                  width: 130.0,
                  height: size.font,
                  color: color,
                  highlightColor: highlightColor,
                  duration: duration,
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: 4.0),
                  TSkeleton.text(
                    width: 80.0,
                    height: size.font * 0.8,
                    color: color,
                    highlightColor: highlightColor,
                    duration: duration,
                  ),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 12.0),
            TSkeleton.rect(
              width: 50.0,
              height: 22.0,
              borderRadius: BorderRadius.circular(4.0),
              color: color,
              highlightColor: highlightColor,
              duration: duration,
            ),
          ],
        ],
      ),
    );
  }

  /// Creates a tabular data grid skeleton.
  static Widget table({
    Key? key,
    int rows = 5,
    int columns = 4,
    double rowHeight = 44.0,
    bool hasHeader = true,
    Color? color,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
    bool loading = true,
  }) {
    if (!loading) return const SizedBox.shrink();

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasHeader)
          Container(
            height: rowHeight * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: List.generate(columns, (colIndex) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: TSkeleton.text(
                      height: 14.0,
                      borderRadius: BorderRadius.circular(4.0),
                      color: color,
                      highlightColor: highlightColor,
                      duration: duration,
                    ),
                  ),
                );
              }),
            ),
          ),
        if (hasHeader) const Divider(height: 1.0, thickness: 1.0),
        ...List.generate(rows, (rowIndex) {
          return Container(
            height: rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: (color ?? Colors.grey).withValues(alpha: 0.1),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: List.generate(columns, (colIndex) {
                // Vary line widths slightly for realism
                final widthFactor = (colIndex == 0) ? 0.75 : ((colIndex % 2 == 0) ? 0.55 : 0.85);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: widthFactor,
                      child: TSkeleton.text(
                        height: 12.0,
                        color: color,
                        highlightColor: highlightColor,
                        duration: duration,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  @override
  State<TSkeleton> createState() => _TSkeletonState();
}

class _TSkeletonState extends State<TSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.loading) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading != oldWidget.loading) {
      if (widget.loading) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.loading && widget.child != null) {
      return widget.child!;
    }

    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = widget.color ??
        (isDark
            ? colors.surfaceContainerHighest.withValues(alpha: 0.45)
            : colors.surfaceContainerHighest.withValues(alpha: 0.65));

    final highlightColor = widget.highlightColor ??
        (isDark
            ? colors.surfaceContainerHighest.withValues(alpha: 0.8)
            : colors.surfaceContainerLowest);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final currentColor = Color.lerp(baseColor, highlightColor, _animation.value) ?? baseColor;

        return Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: currentColor,
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle ? null : (widget.borderRadius ?? BorderRadius.circular(6.0)),
          ),
          child: widget.child != null
              ? Opacity(opacity: 0.0, child: widget.child)
              : null,
        );
      },
    );
  }
}
