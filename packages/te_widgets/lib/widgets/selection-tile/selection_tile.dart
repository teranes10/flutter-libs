import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A selectable tile with an icon/image, label, and selected state.
///
/// Designed for option pickers such as package type or delivery type.
///
/// ## Basic Usage
///
/// ```dart
/// TSelectionTile(
///   label: 'Parcel',
///   icon: Icons.inventory_2_outlined,
///   isSelected: true,
///   onTap: () {},
/// )
/// ```
///
/// See also:
/// - [TSelectionGroup] for a group of selectable tiles
/// - [TCard] for a generic surface card
class TSelectionTile extends StatelessWidget {
  /// The label text displayed below the icon/image.
  final String label;

  /// Optional Material icon.
  final IconData? icon;

  /// Optional image/illustration widget.
  ///
  /// Takes precedence over [icon] when both are provided.
  final Widget? image;

  /// Whether this tile is currently selected.
  final bool isSelected;

  /// Whether this tile is disabled.
  final bool disabled;

  /// Callback fired when the tile is tapped.
  final VoidCallback? onTap;

  /// Accent color for selected border, tint, and checkmark.
  ///
  /// Defaults to the theme primary color.
  final Color? color;

  /// Border radius of the tile.
  ///
  /// Defaults to 12.
  final double borderRadius;

  /// Internal padding.
  final EdgeInsetsGeometry padding;

  /// Fixed height of the icon/image area.
  final double contentHeight;

  /// Size of the icon when [icon] is used.
  final double iconSize;

  /// Whether to show a checkmark badge when selected.
  final bool showCheckmark;

  /// Creates a selection tile.
  const TSelectionTile({
    super.key,
    required this.label,
    this.icon,
    this.image,
    this.isSelected = false,
    this.disabled = false,
    this.onTap,
    this.color,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    this.contentHeight = 56,
    this.iconSize = 32,
    this.showCheckmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = color ?? colors.primary;
    final borderColor = isSelected ? accent : colors.outlineVariant;
    final background = isSelected ? accent.withAlpha(20) : colors.surface;
    final labelColor = disabled
        ? colors.onSurfaceVariant.withAlpha(120)
        : (isSelected ? accent : colors.onSurface);

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              Padding(
                padding: padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: contentHeight,
                      width: double.infinity,
                      child: Center(
                        child: image ??
                            (icon != null
                                ? Icon(
                                    icon,
                                    size: iconSize,
                                    color: isSelected ? accent : colors.onSurfaceVariant,
                                  )
                                : const SizedBox.shrink()),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: labelColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected && showCheckmark)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
