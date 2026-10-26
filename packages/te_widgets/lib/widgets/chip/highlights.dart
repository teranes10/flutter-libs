import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Supplies a reference font size to descendant [TChip]s and standalone
/// [TBadge]s that have no explicit `size`.
///
/// Those widgets pick the closest preset ([TChipSize.forFont] /
/// [TBadgeSize.forFont]) so they match the surrounding text without the
/// caller having to pass a size.
class THighlightScope extends InheritedWidget {
  /// The font size (usually the subtitle font size) chips should match.
  final double fontSize;

  const THighlightScope({super.key, required this.fontSize, required super.child});

  /// The nearest scope, or null when the widget is not inside one.
  static THighlightScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<THighlightScope>();

  @override
  bool updateShouldNotify(THighlightScope oldWidget) => fontSize != oldWidget.fontSize;
}

/// A wrapping row of status/attribute chips ([TChip], [TBadge]) shown under an
/// entity's subtitle, e.g. `ACTIVE`, `TAX EXCL`.
///
/// Children without an explicit `size` are sized from [fontSize].
class THighlights extends StatelessWidget {
  /// The chips or badges to show.
  final List<Widget> items;

  /// Reference font size that unsized children match (the subtitle font size).
  final double fontSize;

  /// Space between chips.
  final double spacing;

  /// Space between wrapped lines.
  final double runSpacing;

  const THighlights({super.key, required this.items, required this.fontSize, this.spacing = 6, this.runSpacing = 4});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return THighlightScope(
      fontSize: fontSize,
      child: Wrap(spacing: spacing, runSpacing: runSpacing, crossAxisAlignment: WrapCrossAlignment.center, children: items),
    );
  }
}
