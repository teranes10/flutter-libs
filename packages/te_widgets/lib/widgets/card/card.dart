import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Edge of a [TCard] that carries the accent strip.
enum TCardAccentSide { start, top, end, bottom }

/// Backwards-compatible alias for [TShadow].
typedef TCardShadow = TShadow;

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
///       HugeIcon(icon: HugeIcons.strokeRoundedStar),
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
  /// Color of the accent strip along one edge of the card. No strip when null.
  final Color? accentColor;

  /// Which edge the accent strip sits on. Defaults to [TCardAccentSide.top].
  final TCardAccentSide accentSide;

  /// Thickness of the accent strip. Defaults to 3.
  final double accentWidth;

  /// The widget to display inside the card body.
  final Widget? child;

  /// Card header title text.
  final String? title;

  /// Card header subtitle text.
  final String? subtitle;

  /// Card header icon.
  final dynamic icon;

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
  /// Defaults to a vertical gradient from the theme's surface to surfaceContainerLow.
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

  /// Mouse cursor shown over the card. Defaults to InkWell's behavior.
  final MouseCursor? mouseCursor;
  final Color? splashColor;

  /// Overlay color when the card's InkWell has keyboard focus.
  final Color? focusColor;

  /// Overrides the InkWell overlay (hover/focus/pressed) colors entirely.
  final WidgetStateProperty<Color?>? overlayColor;
  final Color? highlightColor;

  final List<BoxShadow>? shadow;

  /// Preset shadow depth. Ignored when [shadow] is provided.
  final TCardShadow shadowLevel;
  final BoxBorder? border;

  /// The clip behavior of the card.
  final Clip? clipBehavior;

  /// Liquid-glass mode: true forces it, false disables it, null follows [TWidgetThemeExtension.glass].
  final bool? glass;

  /// Creates a Material Design card widget.
  const TCard({
    super.key,
    this.accentColor,
    this.accentSide = TCardAccentSide.top,
    this.accentWidth = 3,
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
    this.mouseCursor,
    this.splashColor,
    this.focusColor,
    this.overlayColor,
    this.highlightColor,
    this.shadow,
    this.shadowLevel = TCardShadow.none,
    this.border,
    this.clipBehavior,
    this.glass,
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

    return Padding(
      padding: EdgeInsets.only(bottom: headerGap),
      child: TTile.h5(
        title: title,
        titleWidget: titleWidget,
        subtitle: subtitle,
        subtitleWidget: subtitleWidget,
        icon: icon,
        leading: iconWidget,
        iconColor: iconColor ?? context.colors.primary,
        titleStyle: titleStyle,
        subtitleStyle: subtitleStyle,
        trailing: trailing,
        padding: EdgeInsets.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(12);
    final headerNode = _buildHeader(context);
    final resShadowColor = shadowColor ?? colors.shadow;
    // Dark mode cards always get the glass effect (over the app's drifting background), even with glass mode off;
    // `glass: false` still opts a card out.
    final glassStyle = TGlassStyle.resolve(context, glass) ?? (glass == null && colors.isDarkMode ? const TGlassStyle() : null);
    final surfaceColor = backgroundColor ?? colors.surface;

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

    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        border: border,
        // gradient: backgroundColor == null
        //     ? LinearGradient(
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter,
        //         colors: [colors.surface, colors.surface, colors.surfaceContainerLowest],
        //       )
        //     : null,
        // Glass: the shadow would be painted inside the glass clip and grey the pane out, so it is dropped.
        boxShadow: glassStyle != null ? null : (shadow ?? shadowLevel.resolve(resShadowColor)),
      ),
      child: Material(
        elevation: elevation ?? 0,
        color: glassStyle != null ? Colors.transparent : surfaceColor,
        shadowColor: resShadowColor,
        clipBehavior: clipBehavior ?? (accentColor != null ? Clip.antiAlias : Clip.none),
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
          side: glassStyle != null ? BorderSide.none : BorderSide(color: borderColor ?? colors.outlineVariant.withAlpha(60)),
        ),
        child: TBackgroundColorScope(
          backgroundColor: surfaceColor,
          child: Stack(
            // Pass the card's tight width down so the InkWell (hover/splash) spans the whole card, not just its content.
            fit: StackFit.passthrough,
            children: [
              InkWell(
                borderRadius: defaultBorderRadius,
                onTap: onTap,
                hoverColor: hoverColor,
                mouseCursor: mouseCursor,
                splashColor: splashColor,
                focusColor: focusColor,
                overlayColor: overlayColor,
                highlightColor: highlightColor,
                child: Padding(padding: padding, child: content),
              ),
              if (accentColor != null)
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  start: accentSide == TCardAccentSide.end ? null : 0,
                  end: accentSide == TCardAccentSide.start ? null : 0,
                  top: accentSide == TCardAccentSide.bottom ? null : 0,
                  bottom: accentSide == TCardAccentSide.top ? null : 0,
                  width: accentSide == TCardAccentSide.start || accentSide == TCardAccentSide.end ? accentWidth : null,
                  height: accentSide == TCardAccentSide.top || accentSide == TCardAccentSide.bottom ? accentWidth : null,
                  child: IgnorePointer(child: ColoredBox(color: accentColor!)),
                ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: 8),
      child:
          glassStyle == null ? card : TGlassSurface(style: glassStyle, borderRadius: defaultBorderRadius, color: surfaceColor, child: card),
    );
  }
}
