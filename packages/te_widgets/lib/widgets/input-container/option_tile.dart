import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// The selection indicator drawn at the end of a [TOptionTile].
enum TOptionIndicator {
  /// A round radio indicator (single choice).
  radio,

  /// A rounded check box indicator (multiple choice).
  check,

  /// A switch (on/off).
  toggle,
}

/// A full-width, touch-friendly selectable row (at least 56dp tall).
///
/// Used by the `tile` mode of [TRadioGroup], [TCheckboxGroup] and [TSwitch],
/// and directly for reason pickers and checklists on handheld screens where
/// the small inline radio/check controls are too hard to hit.
///
/// ```dart
/// TOptionTile(
///   label: 'Customer unavailable',
///   description: 'Nobody at the address',
///   indicator: TOptionIndicator.radio,
///   selected: reason == 'unavailable',
///   onTap: () => setState(() => reason = 'unavailable'),
/// )
/// ```
class TOptionTile extends StatelessWidget {
  /// Primary text.
  final String label;

  /// Optional secondary text under the [label].
  final String? description;

  /// Optional leading widget or icon.
  final dynamic leading;

  /// Whether the option is currently selected / checked / on.
  final bool selected;

  /// The kind of indicator drawn on the right.
  final TOptionIndicator indicator;

  /// Accent colour. Defaults to the theme primary colour.
  final Color? color;

  /// Whether the tile is disabled.
  final bool disabled;

  /// Called when the tile is tapped. A selection haptic is played first.
  final VoidCallback? onTap;

  /// Optional focus node (keyboard navigation).
  final FocusNode? focusNode;

  /// Creates an option tile.
  const TOptionTile({
    super.key,
    required this.label,
    this.description,
    this.leading,
    required this.selected,
    this.indicator = TOptionIndicator.radio,
    this.color,
    this.disabled = false,
    this.onTap,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = color ?? context.theme.primary;
    final enabled = !disabled && onTap != null;

    final resolvedIconColor = selected ? accent : colors.onSurfaceVariant;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: selected ? accent.withValues(alpha: 0.06) : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? accent.withValues(alpha: 0.5) : colors.outlineVariant.o(0.75), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          focusNode: focusNode,
          onTap: enabled
              ? () {
                  TFeedback.selection();
                  onTap!();
                }
              : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TTile(
                title: label,
                subtitle: description,
                leading: leading,
                iconColor: resolvedIconColor,
                trailing: _buildIndicator(colors, accent),
                size: TTileSize.h5,
                titleStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(ColorScheme colors, Color accent) {
    switch (indicator) {
      case TOptionIndicator.radio:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? accent : colors.outline, width: 2),
          ),
          child: selected
              ? Center(
                  child: Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: accent)),
                )
              : null,
        );
      case TOptionIndicator.check:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: selected ? accent : Colors.transparent,
            border: Border.all(color: selected ? accent : colors.outline, width: 2),
          ),
          child: selected ? TIcon.raw(HugeIcons.strokeRoundedCheck, size: 18, color: colors.onPrimary) : null,
        );
      case TOptionIndicator.toggle:
        return IgnorePointer(
          child: Switch(
            value: selected,
            onChanged: (_) {},
            activeThumbColor: Colors.white,
            activeTrackColor: accent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
    }
  }
}
