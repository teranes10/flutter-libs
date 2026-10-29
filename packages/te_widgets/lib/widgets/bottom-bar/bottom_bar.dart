import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// The position and visibility of the text labels in [TBottomBar].
enum TBottomBarTextPosition {
  /// Label on the right of icon, only when active.
  rightActive,

  /// Label below icon, always shown.
  bottomAlways,

  /// Label below icon, only when active.
  bottomActive,

  /// No label shown.
  none,
}

/// A highly customizable bottom navigation bar.
///
/// `TBottomBar` supports different text positions and visual variants
/// for the active item highlight.
///
/// ## Usage
///
/// ```dart
/// TBottomBar(
///   currentIndex: _index,
///   onTap: (index) => setState(() => _index = index),
///   items: [
///     TBottomBarItem(icon: Icons.home, label: 'Home'),
///     TBottomBarItem(icon: Icons.search, label: 'Search'),
///     TBottomBarItem(icon: Icons.person, label: 'Profile'),
///   ],
///   variant: TVariant.tonal,
///   textPosition: TBottomBarTextPosition.rightActive,
/// )
/// ```
class TBottomBar extends StatelessWidget {
  /// The list of items to display in the bottom bar.
  final List<TBottomBarItem> items;

  /// The index of the currently active item.
  final int currentIndex;

  /// Callback fired when an item is tapped.
  final ValueChanged<int>? onTap;

  /// The visual variant for the active item's highlight.
  final TVariant variant;

  /// The position and visibility of the labels.
  final TBottomBarTextPosition textPosition;

  /// The primary color used for the active item highlight.
  /// Defaults to the theme's primary color.
  final Color? color;

  /// The background color of the bottom bar.
  final Color? background;

  /// The padding around the bottom bar content.
  final EdgeInsets? padding;

  /// The margin around the bottom bar.
  final EdgeInsets? margin;

  /// The border radius of the active item highlight.
  final double? borderRadius;

  /// The height of the bottom bar.
  final double? height;

  final TextStyle? textStyle;
  final double iconSize;
  final EdgeInsets itemPadding;

  /// Plays a light selection haptic when an item is tapped. Defaults to true.
  final bool haptic;

  /// Creates a bottom bar.
  const TBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.variant = TVariant.tonal,
    this.textPosition = TBottomBarTextPosition.rightActive,
    this.color,
    this.background,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.margin,
    this.borderRadius,
    this.height,
    this.textStyle,
    this.iconSize = 24,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.haptic = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mBackground = background ?? colors.surface;
    final mBorderRadius =
        borderRadius ?? (textPosition == TBottomBarTextPosition.rightActive || textPosition == TBottomBarTextPosition.none ? 24 : 14);

    return Container(
      margin: margin,
      padding: padding,
      height: height,
      decoration: BoxDecoration(
        color: mBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (int index = 0; index < items.length; index++)
              if (!context.authResolve(items[index].permission, target: TAuthTarget.bottomBar, onDenied: items[index].onDenied).isHidden)
                _buildItem(context, index, mBorderRadius),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, double mBorderRadius) {
    final item = items[index];
    final disabled = context.authResolve(item.permission, target: TAuthTarget.bottomBar, onDenied: item.onDenied).isDisabled;
    final isActive = index == currentIndex;

    final child = _BottomBarItemWidget(
      item: item,
      isActive: isActive,
      variant: variant,
      textPosition: textPosition,
      color: color,
      borderRadius: mBorderRadius,
      onTap: () {
        if (haptic) TFeedback.selection();
        onTap?.call(index);
      },
      textStyle: textStyle,
      iconSize: iconSize,
      padding: itemPadding,
    );

    if (disabled) return IgnorePointer(child: Opacity(opacity: 0.45, child: child));

    return item.items != null && item.items!.isNotEmpty
        ? TDropdown(items: item.items ?? [], triggerMode: TDropdownTriggerMode.tap, child: child)
        : child;
  }
}

class _BottomBarItemWidget extends StatelessWidget {
  final TBottomBarItem item;
  final bool isActive;
  final TVariant variant;
  final TBottomBarTextPosition textPosition;
  final Color? color;
  final double borderRadius;
  final VoidCallback onTap;
  final TextStyle? textStyle;
  final double iconSize;
  final EdgeInsets padding;

  const _BottomBarItemWidget({
    required this.item,
    required this.isActive,
    required this.variant,
    required this.textPosition,
    this.color,
    required this.borderRadius,
    required this.onTap,
    this.textStyle,
    required this.iconSize,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mColor = color ?? colors.primary;
    final wTheme = context.getWidgetTheme(variant, mColor);

    final highlightColor = isActive ? wTheme.container : Colors.transparent;
    final contentColor = isActive ? wTheme.onContainer : colors.onSurfaceVariant;
    final icon = isActive ? (item.activeIcon ?? item.icon) : item.icon;
    final mTextStyle = textStyle ??
        TextStyle(
          color: contentColor,
          fontWeight: isActive ? FontWeight.w400 : FontWeight.w300,
          fontSize: 11,
        );
    final rawIcon = TIcon.raw(icon, color: contentColor, size: iconSize);
    final iconWidget = item.badge == null ? rawIcon : TBadge(badge: item.badge, child: rawIcon);

    if (item.emphasized) return _buildEmphasized(context, mColor, mTextStyle);

    Widget content;

    switch (textPosition) {
      case TBottomBarTextPosition.rightActive:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            if (isActive) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  item.label,
                  style: mTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        );
        break;
      case TBottomBarTextPosition.bottomAlways:
      case TBottomBarTextPosition.bottomActive:
        final showLabel = textPosition == TBottomBarTextPosition.bottomAlways || isActive;
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            if (showLabel) ...[
              const SizedBox(height: 4),
              Text(
                item.label,
                style: mTextStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
        break;
      case TBottomBarTextPosition.none:
        content = iconWidget;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: AnimatedContainer(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        duration: const Duration(milliseconds: 200),
        padding: padding,
        decoration: BoxDecoration(
          color: highlightColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: isActive && wTheme.outline != null ? Border.all(color: wTheme.outline!) : null,
        ),
        child: content,
      ),
    );
  }

  /// A raised circular primary action (e.g. the centre "Scan" button).
  Widget _buildEmphasized(BuildContext context, Color mColor, TextStyle labelStyle) {
    final colors = context.colors;
    final icon = isActive ? (item.activeIcon ?? item.icon) : item.icon;

    return Semantics(
      button: true,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Transform.translate(
          offset: const Offset(0, -10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mColor,
                  boxShadow: [
                    BoxShadow(color: mColor.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: TIcon.raw(icon, color: colors.onPrimary, size: iconSize + 2),
              ),
              const SizedBox(height: 2),
              Text(item.label, style: labelStyle.copyWith(color: mColor), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
