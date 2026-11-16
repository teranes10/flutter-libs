import 'package:flutter/material.dart';

/// Preset shadow depths (used by [TCard] and the `Widget.card()` extension).
enum TShadow {
  /// Flat card with the default 1px hairline shadow.
  none,

  /// Barely-there lift, for compact controls and chips.
  xxs,

  /// Very light lift, for small buttons and inputs.
  xs,

  /// Subtle lift, for list rows and dense groups.
  sm,

  /// Standard raised card.
  md,

  /// Prominent card, for hero blocks and floating panels.
  lg;

  /// Neutral base colour for [xxs]..[lg]; the theme's `shadow` colour is a
  /// light, low-alpha grey that is too faint to differentiate levels.
  static const Color baseColor = Color(0xFF0F172A);

  /// Resolves the layered [BoxShadow]s for this level using [color] (only its
  /// RGB is used for [xxs]..[lg]).
  List<BoxShadow> resolve(Color color) => switch (this) {
        none => [BoxShadow(color: color.withAlpha(15), offset: const Offset(0, 1))],
        xxs => [
            BoxShadow(color: color.withAlpha(12), offset: const Offset(0, 1), blurRadius: 2),
          ],
        xs => [
            BoxShadow(color: color.withAlpha(12), offset: const Offset(0, 1), blurRadius: 4, spreadRadius: -1),
            BoxShadow(color: color.withAlpha(20), offset: const Offset(0, 1), blurRadius: 2, spreadRadius: -1),
          ],
        sm => [
            BoxShadow(color: color.withAlpha(15), offset: const Offset(0, 2), blurRadius: 8, spreadRadius: -1),
            BoxShadow(color: color.withAlpha(30), offset: const Offset(0, 1), blurRadius: 3, spreadRadius: -1),
          ],
        md => [
            BoxShadow(color: color.withAlpha(15), offset: const Offset(0, 4), blurRadius: 14, spreadRadius: -2),
            BoxShadow(color: color.withAlpha(30), offset: const Offset(0, 2), blurRadius: 5, spreadRadius: -1),
          ],
        lg => [
            BoxShadow(color: color.withAlpha(15), offset: const Offset(0, 8), blurRadius: 20, spreadRadius: -4),
            BoxShadow(color: color.withAlpha(30), offset: const Offset(0, 4), blurRadius: 9, spreadRadius: -2),
          ],
      };
}
