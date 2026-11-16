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

  /// Permissions (`String` or [TPermission]) for the three actions; see [TButton.permission].
  final Object? primaryPermission;
  final Object? secondaryPermission;
  final Object? tertiaryPermission;

  /// Overrides the denied behaviour for all three actions (default: disabled).
  final TAuthMode? onDenied;

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
    this.primaryPermission,
    this.secondaryPermission,
    this.tertiaryPermission,
    this.onDenied,
    this.leading,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final glassStyle = TGlassStyle.resolve(context);
    // Glass: a floating pane with slimmer buttons whose corners are concentric with the pane (pane radius - padding).
    const paneRadius = 26.0;
    const panePadding = 8.0;
    final primarySize = glassStyle == null ? TSize.xl.copyWith(minW: double.infinity) : TSize.lg.copyWith(minW: double.infinity, minH: 48);
    // TButton takes its corners from the shape, not TSize.radius.
    final buttonShape = glassStyle == null ? null : TButtonShape.custom(paneRadius - panePadding);
    final hasPrimaryAction = onPrimary != null || onPrimaryPressed != null;

    TButton buildPrimary(TSize size) => TButton(
          key: const ValueKey('t-action-bar-primary'),
          type: TButtonType.solid,
          size: size,
          shape: buttonShape,
          color: primaryColor,
          text: primaryText,
          icon: primaryIcon,
          loading: primaryLoading,
          onTap: hasPrimaryAction ? onPrimary : null,
          onPressed: onPrimaryPressed,
          permission: primaryPermission,
          onDenied: onDenied,
        );

    TButton buildSecondary(TSize size) => TButton(
          key: const ValueKey('t-action-bar-secondary'),
          // Glass: a frosted fill + visible edge instead of the opaque tonal surface (a dark slab over the backdrop).
          baseTheme: TGlassStyle.resolve(context) == null
              ? TWidgetTheme.surfaceTheme(context.colors)
              : TWidgetTheme.surfaceTheme(context.colors).copyWith(
                  container: Colors.white.withAlpha(context.colors.isDarkMode ? 14 : 150),
                  containerVariant: Colors.white.withAlpha(context.colors.isDarkMode ? 36 : 205),
                  // Quiet edge: Save stays the one clear action.
                  outline: TGlassStyle.resolve(context)!.edge.withAlpha(60),
                  outlineVariant: TGlassStyle.resolve(context)!.edge.withAlpha(60),
                ),
          size: size,
          shape: buttonShape,
          text: secondaryText,
          icon: secondaryIcon,
          onTap: onSecondary,
          permission: secondaryPermission,
          onDenied: onDenied,
        );

    final Widget buttons;
    if (secondaryText == null) {
      buttons = buildPrimary(primarySize);
    } else {
      buttons = LayoutBuilder(
        builder: (context, constraints) {
          final gap = glassStyle == null ? 10.0 : panePadding;
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
                SizedBox(width: gap),
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
              SizedBox(height: gap),
              buildSecondary(stackedSecondarySize),
            ],
          );
        },
      );
    }

    final glass = TGlassStyle.resolve(context) != null;
    final bar = DecoratedBox(
      decoration: BoxDecoration(
        // Glass: the blurred translucent bar below replaces the opaque fill and divider.
        color: glass ? null : colors.surface,
        border: glass ? null : Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        bottom: safeArea,
        child: Padding(
          padding: glass ? const EdgeInsets.all(panePadding) : const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                  permission: tertiaryPermission,
                  onDenied: onDenied,
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (glassStyle == null) return bar;
    // Floating glass pane inset from the edges (no hard divider); the bottom inset comes from the SafeArea.
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
      child: TGlassSurface(
        style: glassStyle,
        borderRadius: BorderRadius.circular(paneRadius),
        color: Colors.white,
        alpha: colors.isDarkMode ? 22 : null,
        child: bar,
      ),
    );
  }
}
