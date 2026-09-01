import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A Material Design card widget with customizable styling and tap interaction.
///
/// `TCard` provides a container with elevation, rounded corners, and optional
/// tap interaction. It follows Material Design principles and integrates with
/// the app's theme system.
///
/// ## Basic Usage
///
/// ```dart
/// TCard(
///   child: Text('Card Content'),
/// )
/// ```
///
/// ## With Custom Styling
///
/// ```dart
/// TCard(
///   backgroundColor: Colors.blue.shade50,
///   borderRadius: BorderRadius.circular(16),
///   elevation: 4,
///   padding: EdgeInsets.all(24),
///   onTap: () => print('Card tapped'),
///   child: Column(
///     children: [
///       Icon(Icons.star),
///       Text('Featured Item'),
///     ],
///   ),
/// )
/// ```
///
/// See also:
/// - [Material] for the underlying Material widget
/// - [InkWell] for tap interaction
class TCard extends StatelessWidget {
  /// The widget to display inside the card body.
  final Widget? child;

  /// Card header title text.
  final String? title;

  /// Card header subtitle text.
  final String? subtitle;

  /// Card header icon.
  final IconData? icon;

  /// Custom widget to use as title instead of [title] text.
  final Widget? titleWidget;

  /// Custom widget to use as subtitle instead of [subtitle] text.
  final Widget? subtitleWidget;

  /// Custom widget to use as icon/leading instead of [icon] IconData.
  final Widget? iconWidget;

  /// Trailing widget displayed on the far right of the card header.
  final Widget? trailing;

  /// Custom header widget replacing the default title/subtitle/icon header.
  final Widget? header;

  /// Spacing between the header and the [child] body content.
  ///
  /// Defaults to 14.
  final double headerGap;

  /// Custom text style for the header [title].
  final TextStyle? titleStyle;

  /// Custom text style for the header [subtitle].
  final TextStyle? subtitleStyle;

  /// Color for the header [icon].
  final Color? iconColor;

  /// The external margin around the card.
  ///
  /// Defaults to `EdgeInsets.only(bottom: 8)`.
  final EdgeInsetsGeometry? margin;

  /// The elevation of the card (shadow depth).
  ///
  /// Defaults to 0.
  final double? elevation;

  /// The border radius of the card corners.
  ///
  /// Defaults to `BorderRadius.circular(8)`.
  final BorderRadius? borderRadius;

  /// The background color of the card.
  ///
  /// Defaults to the theme's surface color.
  final Color? backgroundColor;

  /// The internal padding inside the card.
  ///
  /// Defaults to `EdgeInsets.symmetric(vertical: 12, horizontal: 16)`.
  final EdgeInsetsGeometry padding;

  /// Callback fired when the card is tapped.
  ///
  /// If null, the card will not be interactive.
  final VoidCallback? onTap;

  final Color? shadowColor;
  final Color? borderColor;
  final Color? hoverColor;
  final Color? splashColor;
  final Color? highlightColor;

  final List<BoxShadow>? shadow;

  /// The clip behavior of the card.
  final Clip? clipBehavior;

  /// Creates a Material Design card widget.
  const TCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.titleWidget,
    this.subtitleWidget,
    this.iconWidget,
    this.trailing,
    this.header,
    this.headerGap = 14,
    this.titleStyle,
    this.subtitleStyle,
    this.iconColor,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.onTap,
    this.shadowColor,
    this.borderColor,
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
    this.shadow,
    this.clipBehavior,
  });

  Widget? _buildHeader(BuildContext context) {
    if (header != null) return header;

    final hasTitle = title != null || titleWidget != null;
    final hasSubtitle = subtitle != null || subtitleWidget != null;
    final hasIcon = icon != null || iconWidget != null;
    final hasTrailing = trailing != null;

    if (!hasTitle && !hasSubtitle && !hasIcon && !hasTrailing) {
      return null;
    }

    final colors = context.colors;
    final effectiveIconColor = iconColor ?? colors.primary;

    Widget? leadingNode;
    if (iconWidget != null) {
      leadingNode = iconWidget;
    } else if (icon != null) {
      leadingNode = Icon(icon, size: 18, color: effectiveIconColor);
    }

    Widget? titleNode;
    if (titleWidget != null) {
      titleNode = titleWidget;
    } else if (title != null) {
      titleNode = Text(
        title!,
        style: titleStyle ??
            TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
      );
    }

    Widget? subtitleNode;
    if (subtitleWidget != null) {
      subtitleNode = subtitleWidget;
    } else if (subtitle != null) {
      subtitleNode = Text(
        subtitle!,
        style: subtitleStyle ??
            TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
      );
    }

    final titleColumn = (hasTitle || hasSubtitle)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (titleNode != null) titleNode,
              if (subtitleNode != null) ...[
                const SizedBox(height: 2),
                subtitleNode,
              ],
            ],
          )
        : null;

    return Padding(
      padding: EdgeInsets.only(bottom: headerGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingNode != null) ...[
            leadingNode,
            const SizedBox(width: 8),
          ],
          if (titleColumn != null) Expanded(child: titleColumn),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(8);
    final headerNode = _buildHeader(context);

    Widget content;
    if (headerNode != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerNode,
          if (child != null) child!,
        ],
      );
    } else {
      content = child ?? const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        boxShadow: shadow ?? [BoxShadow(color: colors.shadow, offset: const Offset(0, 1), blurRadius: 0, spreadRadius: 0)],
      ),
      child: Material(
        elevation: elevation ?? 0,
        color: backgroundColor ?? colors.surface,
        shadowColor: shadowColor ?? colors.shadow,
        clipBehavior: clipBehavior ?? Clip.none,
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
          side: BorderSide(color: borderColor ?? colors.outlineVariant.withAlpha(75)),
        ),
        child: TBackgroundColorScope(
          backgroundColor: backgroundColor ?? colors.surface,
          child: InkWell(
            borderRadius: defaultBorderRadius,
            onTap: onTap,
            hoverColor: hoverColor,
            splashColor: splashColor,
            highlightColor: highlightColor,
            child: Padding(padding: padding, child: content),
          ),
        ),
      ),
    );
  }
}
