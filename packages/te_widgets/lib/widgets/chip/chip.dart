import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A compact element that represents an attribute, text, entity, or action.
///
/// `TChip` displays information in a compact, rounded container. It can include
/// text, icons, and supports different visual variants through theming.
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
/// ## With Custom Styling
///
/// ```dart
/// TChip(
///   text: 'Premium',
///   icon: Icons.star,
///   color: Colors.amber,
///   background: Colors.amber.shade50,
///   textColor: Colors.amber.shade900,
///   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
///   borderRadius: BorderRadius.circular(12),
///   onTap: () => print('Chip tapped'),
/// )
/// ```
///
/// See also:
/// - [TVariant] for available visual variants
/// - [TWidgetTheme] for theming options
class TChip extends StatelessWidget {
  /// The text to display in the chip.
  final String? text;

  /// The icon to display before the text.
  final IconData? icon;

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
  /// Defaults to `EdgeInsets.symmetric(horizontal: 10, vertical: 5)`.
  final EdgeInsets? padding;

  /// The border radius of the chip.
  ///
  /// Defaults to `BorderRadius.circular(8)`.
  final BorderRadius? borderRadius;

  /// The visual variant of the chip (solid, tonal, outline, etc.).
  ///
  /// Defaults to the theme's default chip type.
  final TVariant? type;

  /// Creates a chip widget.
  const TChip({
    super.key,
    this.text,
    this.icon,
    this.color,
    this.background,
    this.textColor,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final mColor = color ?? theme.primary;
    final wTheme = context.getWidgetTheme(type ?? theme.chipType, mColor);
    final mBackgroundColor = background ?? wTheme.container;
    final mTextColor = textColor ?? wTheme.onContainer;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: mBackgroundColor,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            border: Border.all(color: wTheme.outline ?? Colors.transparent, width: 1)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: mTextColor),
              if (text != null) const SizedBox(width: 4),
            ],
            if (text != null) Text(text!, style: TextStyle(color: mTextColor, fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
