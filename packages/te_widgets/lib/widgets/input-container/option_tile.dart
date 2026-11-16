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

    final glass = TGlassStyle.resolve(context);
    final dark = colors.isDarkMode;
    // Glass: idle tiles are a light frosted overlay (a dark translucent surface reads as a slab), selected ones carry
    // an accent wash, and disabled ones are flat and quiet: barely-there fill, faint edge, muted text.
    final glassFill = selected
        ? accent.withValues(alpha: dark ? 0.22 : 0.16)
        : disabled
            ? colors.onSurface.withAlpha(dark ? 8 : 10)
            : Colors.white.withAlpha(dark ? 22 : 140);
    final glassEdge = selected
        ? accent.withValues(alpha: 0.75)
        : disabled
            ? colors.onSurface.withAlpha(dark ? 40 : 45)
            : glass?.fieldEdge(context);

    return Opacity(
      opacity: disabled ? (glass != null ? 0.6 : 0.5) : 1,
      child: Material(
        color: glass != null ? glassFill : (selected ? accent.withValues(alpha: 0.06) : colors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: glass != null && glassEdge != null
                  ? glassEdge
                  : selected
                      ? accent.withValues(alpha: 0.5)
                      : (glassEdge ?? colors.outlineVariant.o(0.75)),
              width: 1),
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
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: TTile.h5(
                        title: label,
                        subtitle: description,
                        leading: leading,
                        iconColor: resolvedIconColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildIndicator(colors, accent),
                  ],
                ),
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
          width: 22,
          height: 22,
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
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: selected ? accent : Colors.transparent,
            border: Border.all(color: selected ? accent : colors.outline, width: 2),
          ),
          child: selected ? TIcon.raw(HugeIcons.strokeRoundedCheck, size: 18, color: colors.onPrimary) : null,
        );
      case TOptionIndicator.toggle:
        return IgnorePointer(
          child: TSwitch(
            value: selected,
            // onChanged: (_) {},
            // activeThumbColor: Colors.white,
            // activeTrackColor: accent,
            // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
    }
  }
}
