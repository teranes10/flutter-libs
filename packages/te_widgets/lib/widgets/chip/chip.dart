import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

export 'chip_size.dart';

/// A compact element that represents an attribute, text, entity, or action.
///
/// `TChip` displays information in a compact, rounded container. It can include
/// text, icons, trailing widgets (such as [TIcon] for deletion), and supports different
/// visual variants through theming.
///
/// ## Basic Usage
///
/// ```dart
/// TChip(
///   text: 'Active',
///   icon: Icons.check_circle,
///   color: AppColors.success,
/// )
/// ```
///
/// ## Sizing
///
/// ```dart
/// TChip(size: TChipSize.sm, text: 'Small Chip')
/// TChip(size: TChipSize.md, text: 'Medium Chip')
/// TChip(size: TChipSize.lg, text: 'Large Chip')
/// ```
///
/// ## With Trailing Action
///
/// ```dart
/// TChip(
///   text: 'Electronics',
///   trailing: TIcon(
///     icon: Icons.close,
///     size: 11,
///     padding: EdgeInsets.zero,
///     onTap: () => print('Removed'),
///   ),
/// )
/// ```
///
/// See also:
/// - [TVariant] for available visual variants
/// - [TWidgetTheme] for theming options
/// - [TChipSize] for available size metrics
class TChip extends StatelessWidget {
  /// The text to display in the chip.
  final String? text;

  /// The icon to display before the text. Supports [IconData], HugeIcon data, or [Widget].
  final dynamic icon;

  /// Optional trailing widget, e.g. [TIcon] with `onTap` for removals.
  final Widget? trailing;

  /// The primary color of the chip.
  ///
  /// This affects the chip's appearance based on the [type] variant.
  /// Defaults to the theme's primary color.
  final Color? color;

  /// The background color of the chip.
  ///
  /// If null, uses the color from the widget theme based on [type].
  final Color? background;

  /// The color of the text and icon.
  ///
  /// If null, uses the color from the widget theme.
  final Color? textColor;

  /// Callback fired when the chip is tapped.
  final VoidCallback? onTap;

  /// The internal padding of the chip.
  ///
  /// If null, uses [size.padding].
  final EdgeInsets? padding;

  /// The border radius of the chip.
  ///
  /// If null, uses [size.borderRadius].
  final BorderRadius? borderRadius;

  /// The visual variant of the chip (solid, tonal, outline, etc.).
  ///
  /// Defaults to the theme's default chip type.
  final TVariant? type;

  /// The size configuration of the chip. Defaults to [TChipSize.md].
  final TSize size;

  /// Creates a chip widget.
  const TChip({
    super.key,
    this.text,
    this.icon,
    this.trailing,
    this.color,
    this.background,
    this.textColor,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.type,
    this.size = TChipSize.sm,
  });

  /// Creates a solid filled chip.
  const TChip.solid({
    super.key,
    this.text,
    this.icon,
    this.trailing,
    this.color,
    this.background,
    this.textColor,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.size = TChipSize.md,
  }) : type = TVariant.solid;

  /// Creates a tonal (tinted background) chip.
  const TChip.tonal({
    super.key,
    this.text,
    this.icon,
    this.trailing,
    this.color,
    this.background,
    this.textColor,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.size = TChipSize.md,
  }) : type = TVariant.tonal;

  /// Creates an outlined chip with transparent background.
  const TChip.outline({
    super.key,
    this.text,
    this.icon,
    this.trailing,
    this.color,
    this.background,
    this.textColor,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.size = TChipSize.md,
  }) : type = TVariant.outline;

  /// Creates a soft outline chip with subtle background tint and border.
  const TChip.softOutline({
    super.key,
    this.text,
    this.icon,
    this.trailing,
    this.color,
    this.background,
    this.textColor,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.size = TChipSize.md,
  }) : type = TVariant.softOutline;

  /// Creates a text-only/ghost variant chip without background or border.
  const TChip.text({
    super.key,
    this.text,
    this.icon,
    this.trailing,
    this.color,
    this.background,
    this.textColor,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.size = TChipSize.md,
  }) : type = TVariant.text;

  /// Creates a list of [TChip]s from a list of string labels.
  static List<TChip> fromStrings(
    List<String> strings, {
    Color? color,
    dynamic icon,
    TVariant? type,
    TSize size = TChipSize.sm,
    VoidCallback? onTap,
  }) {
    return strings
        .map((s) => TChip(
              text: s,
              color: color,
              icon: icon,
              type: type,
              size: size,
              onTap: onTap,
            ))
        .toList();
  }

  /// Creates a copy of this chip with the given fields replaced with new values.
  TChip copyWith({
    String? text,
    dynamic icon,
    Widget? trailing,
    Color? color,
    Color? background,
    Color? textColor,
    VoidCallback? onTap,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TVariant? type,
    TSize? size,
  }) {
    return TChip(
      key: key,
      text: text ?? this.text,
      icon: icon ?? this.icon,
      trailing: trailing ?? this.trailing,
      color: color ?? this.color,
      background: background ?? this.background,
      textColor: textColor ?? this.textColor,
      onTap: onTap ?? this.onTap,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      type: type ?? this.type,
      size: size ?? this.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final mColor = color ?? theme.primary;
    final effectiveVariant = type ?? theme.chipType;
    final wTheme = context.getWidgetTheme(effectiveVariant, mColor);
    final mBackgroundColor = background ?? wTheme.container;
    final mTextColor = textColor ?? wTheme.onContainer;

    final effectivePadding = padding ?? size.padding;
    final effectiveBorderRadius = borderRadius ?? size.borderRadius;
    final effectiveFontSize = size.fontSize;
    final effectiveIconSize = size.iconSize;
    final effectiveSpacing = size.spacing;

    return InkWell(
      onTap: onTap,
      borderRadius: effectiveBorderRadius,
      child: Container(
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: mBackgroundColor,
          borderRadius: effectiveBorderRadius,
          border: Border.all(color: wTheme.outline ?? Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              TIcon.raw(icon, size: effectiveIconSize, color: mTextColor),
              if (text != null) SizedBox(width: effectiveSpacing),
            ],
            if (text != null)
              Text(
                text!,
                style: TextStyle(
                  color: mTextColor,
                  fontSize: effectiveFontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            if (trailing != null) ...[
              SizedBox(width: effectiveSpacing),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
