import 'package:flutter/material.dart';

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
}
