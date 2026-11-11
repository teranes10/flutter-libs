import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

extension WidgetX on Widget {
  /// Returns this widget if [condition] is true, otherwise returns [SizedBox.shrink()].
  /// Usage: Text('Hello').when(isVisible)
  Widget when(bool condition) {
    if (condition) return this;
    return const SizedBox.shrink();
  }

  /// Wraps this widget in a [Padding] with flexible edge control.
  Widget padding([double left = 0.0, double top = 0.0, double right = 0.0, double bottom = 0.0]) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: this,
    );
  }

  /// Wraps this widget in a [Padding] with symmetric horizontal and vertical spacing.
  Widget paddingSymmetric({double h = 0.0, double v = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
      child: this,
    );
  }

  /// Wraps this widget in a [Visibility] widget.
  Widget visible(bool visible, {bool maintainState = false}) {
    return Visibility(
      visible: visible,
      maintainState: maintainState,
      child: this,
    );
  }

  /// Wraps this widget in an [Expanded] widget.
  Widget expanded({int flex = 1}) {
    return Expanded(
      flex: flex,
      child: this,
    );
  }

  /// Wraps this widget in a [Center] widget.
  Widget center({bool when = true}) {
    return when ? Center(child: this) : this;
  }

  /// Wraps this widget in a [SizedBox] to apply fixed width and/or height.
  Widget size({double? w, double? h}) {
    return SizedBox(width: w, height: h, child: this);
  }

  /// Wraps this widget in a [ConstrainedBox] to apply layout constraints.
  Widget box({
    double minW = 0.0,
    double minH = 0.0,
    double maxW = double.infinity,
    double maxH = double.infinity,
  }) {
    return ConstrainedBox(constraints: BoxConstraints(minWidth: minW, minHeight: minH, maxWidth: maxW, maxHeight: maxH), child: this);
  }

  /// Wraps this widget in a [TCard] with a preset [shadow] depth.
  ///
  /// Unlike a bare [TCard], the margin defaults to zero and the padding to
  /// `EdgeInsets.all(12)` so it can be dropped around any tile or block.
  /// Usage: `TTile(title: 'Hello').card(shadow: TCardShadow.md)`
  Widget card({
    TCardShadow shadow = TCardShadow.none,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return TCard(
      shadowLevel: shadow,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      onTap: onTap,
      child: this,
    );
  }

  /// [card] with a subtle [TCardShadow.sm] shadow.
  Widget cardSm({EdgeInsetsGeometry padding = const EdgeInsets.all(12), VoidCallback? onTap}) =>
      card(shadow: TCardShadow.sm, padding: padding, onTap: onTap);

  /// [card] with a standard [TCardShadow.md] shadow.
  Widget cardMd({EdgeInsetsGeometry padding = const EdgeInsets.all(12), VoidCallback? onTap}) =>
      card(shadow: TCardShadow.md, padding: padding, onTap: onTap);

  /// [card] with a prominent [TCardShadow.lg] shadow.
  Widget cardLg({EdgeInsetsGeometry padding = const EdgeInsets.all(12), VoidCallback? onTap}) =>
      card(shadow: TCardShadow.lg, padding: padding, onTap: onTap);

  /// Uses this widget as the header of an expandable [TTreeCard] whose [children]
  /// hang off a tree connector line. Nest `.treeCard(...)` for deeper levels.
  /// Usage: `TTile(title: 'Parent').treeCard(children: [TTile(title: 'Child').card()])`
  Widget treeCard({
    required List<Widget> children,
    bool initiallyExpanded = false,
    bool? isExpanded,
    ValueChanged<bool>? onExpansionChanged,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double? lineInset,
    double? elbowWidth,
    double? gap,
    double? elbowY,
    bool showDots = false,
    Color? lineColor,
  }) {
    return TTreeCard(
      header: this,
      initiallyExpanded: initiallyExpanded,
      isExpanded: isExpanded,
      onExpansionChanged: onExpansionChanged,
      padding: padding,
      lineInset: lineInset,
      elbowWidth: elbowWidth,
      gap: gap,
      elbowY: elbowY,
      showDots: showDots,
      lineColor: lineColor,
      children: children,
    );
  }
}
