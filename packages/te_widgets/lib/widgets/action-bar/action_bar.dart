import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A bottom-docked action bar for mobile / handheld task screens.
///
/// Holds the **one primary action** of a screen (56dp, full width) and an
/// optional secondary action, above the system navigation inset. Put it in
/// [TPageWrapper.footer] (or `Scaffold.bottomNavigationBar`) so the primary
/// action always sits in the thumb zone.
///
/// When [secondaryText] is provided, the actions render side-by-side (1:2 flex)
/// if there is sufficient space based on estimated button widths. If space is
/// constrained, the layout stacks onto two lines with the primary action first
/// (kept at the full 56dp touch target) and the secondary action below (scaled to 0.75 height)
/// so both actions receive full width without clipping.
///
/// ```dart
/// TPageWrapper(
///   title: 'Confirm quantity',
///   footer: TActionBar(
///     primaryText: 'Confirm',
///     onPrimary: confirm,
///     secondaryText: 'Skip',
///     onSecondary: skip,
///   ),
///   child: ...,
/// )
/// ```
class TActionBar extends StatelessWidget {
  /// Label of the primary action.
  final String primaryText;

  /// Optional icon of the primary action (see [TButton.icon]).
  final dynamic primaryIcon;

  /// Simple tap handler of the primary action. `null` (together with a null
  /// [onPrimaryPressed]) renders the action disabled.
  final VoidCallback? onPrimary;

  /// Async handler of the primary action with loading control
  /// (see [TButton.onPressed]).
  final Function(TButtonPressOptions)? onPrimaryPressed;

  /// Colour of the primary action (e.g. success green, danger red).
  final Color? primaryColor;

  /// Shows a loading indicator on the primary action.
  final bool primaryLoading;

  /// Label of the optional secondary action.
  final String? secondaryText;

  /// Optional icon of the secondary action.
  final dynamic secondaryIcon;

  /// Tap handler of the secondary action.
  final VoidCallback? onSecondary;

  /// Label of the optional third action (e.g. "Done"), rendered full width
  /// below the primary/secondary row as a text button.
  final String? tertiaryText;

  /// Optional icon of the third action.
  final dynamic tertiaryIcon;

  /// Tap handler of the third action.
  final VoidCallback? onTertiary;

  /// Optional content above the buttons (e.g. a progress line or hint).
  final Widget? leading;

  /// Whether to pad for the bottom system inset. Defaults to true.
  final bool safeArea;

  /// Creates a bottom action bar.
  const TActionBar({
    super.key,
    required this.primaryText,
    this.primaryIcon,
    this.onPrimary,
    this.onPrimaryPressed,
    this.primaryColor,
    this.primaryLoading = false,
    this.secondaryText,
    this.secondaryIcon,
    this.onSecondary,
    this.tertiaryText,
    this.tertiaryIcon,
    this.onTertiary,
    this.leading,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primarySize = TSize.xl.copyWith(minW: double.infinity);
    final hasPrimaryAction = onPrimary != null || onPrimaryPressed != null;

    TButton buildPrimary(TSize size) => TButton(
          key: const ValueKey('t-action-bar-primary'),
          type: TButtonType.solid,
          size: size,
          color: primaryColor,
          text: primaryText,
          icon: primaryIcon,
          loading: primaryLoading,
          onTap: hasPrimaryAction ? onPrimary : null,
          onPressed: onPrimaryPressed,
        );

    TButton buildSecondary(TSize size) => TButton(
          key: const ValueKey('t-action-bar-secondary'),
          baseTheme: TWidgetTheme.surfaceTheme(context.colors),
          size: size,
          text: secondaryText,
          icon: secondaryIcon,
          onTap: onSecondary,
        );

    final Widget buttons;
    if (secondaryText == null) {
      buttons = buildPrimary(primarySize);
    } else {
      buttons = LayoutBuilder(
        builder: (context, constraints) {
          const gap = 10.0;
          final availableWidth = constraints.hasBoundedWidth ? constraints.maxWidth : MediaQuery.sizeOf(context).width - 32;

          final rowPrimary = buildPrimary(primarySize);
          final rowSecondary = buildSecondary(primarySize);

          final secondaryWidth = rowSecondary.estimateWidth(context);
          final primaryWidth = rowPrimary.estimateWidth(context);

          final fitsInRow = availableWidth >= (secondaryWidth + primaryWidth + gap);

          if (fitsInRow) {
            final allocatedSecondaryWidth = (availableWidth - gap) / 3;
            final allocatedPrimaryWidth = (availableWidth - gap) * 2 / 3;

            final int secondaryFlex;
            final int primaryFlex;

            if (secondaryWidth <= allocatedSecondaryWidth && primaryWidth <= allocatedPrimaryWidth) {
              secondaryFlex = 1;
              primaryFlex = 2;
            } else {
              final totalRequired = secondaryWidth + primaryWidth;
              secondaryFlex = totalRequired > 0 ? (secondaryWidth / totalRequired * 1000).round() : 1;
              primaryFlex = totalRequired > 0 ? (primaryWidth / totalRequired * 1000).round() : 1;
            }

            return Row(
              children: [
                Expanded(flex: secondaryFlex, child: rowSecondary),
                const SizedBox(width: gap),
                Expanded(flex: primaryFlex, child: rowPrimary),
              ],
            );
          }

          final stackedSecondarySize = primarySize.copyWith(
            minH: primarySize.minH * 0.75,
            vPad: primarySize.vPad * 0.75,
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildPrimary(primarySize),
              const SizedBox(height: gap),
              buildSecondary(stackedSecondarySize),
            ],
          );
        },
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        bottom: safeArea,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (leading != null) ...[leading!, const SizedBox(height: 10)],
              buttons,
              if (tertiaryText != null) ...[
                const SizedBox(height: 8),
                TButton(
                  key: const ValueKey('t-action-bar-tertiary'),
                  type: TButtonType.outline,
                  size: TSize.lg.copyWith(minW: double.infinity),
                  text: tertiaryText,
                  icon: tertiaryIcon,
                  onTap: onTertiary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
