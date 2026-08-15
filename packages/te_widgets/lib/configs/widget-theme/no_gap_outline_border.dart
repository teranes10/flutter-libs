import 'package:flutter/material.dart';

/// An outline-styled border that never cuts a gap for the floating label and
/// reports isOutline=false, so InputDecorator keeps the floating label
/// docked inside the box instead of centering it on the border line.
class TNoGapOutlineBorder extends InputBorder {
  final BorderRadius borderRadius;

  const TNoGapOutlineBorder({required super.borderSide, required this.borderRadius});

  @override
  bool get isOutline => false;

  @override
  TNoGapOutlineBorder copyWith({BorderSide? borderSide, BorderRadius? borderRadius}) =>
      TNoGapOutlineBorder(borderSide: borderSide ?? this.borderSide, borderRadius: borderRadius ?? this.borderRadius);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  TNoGapOutlineBorder scale(double t) => TNoGapOutlineBorder(borderSide: borderSide.scale(t), borderRadius: borderRadius * t);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect).deflate(borderSide.width));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) => a is TNoGapOutlineBorder
      ? TNoGapOutlineBorder(
          borderSide: BorderSide.lerp(a.borderSide, borderSide, t), borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!)
      : super.lerpFrom(a, t);

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) => b is TNoGapOutlineBorder
      ? TNoGapOutlineBorder(
          borderSide: BorderSide.lerp(borderSide, b.borderSide, t), borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!)
      : super.lerpTo(b, t);

  // gapStart/gapExtent are intentionally ignored — this is what stops the
  // border line from being cut open where the label floats through it.
  @override
  void paint(Canvas canvas, Rect rect,
      {double? gapStart, double gapExtent = 0.0, double gapPercentage = 0.0, TextDirection? textDirection}) {
    final paint = borderSide.toPaint();
    canvas.drawRRect(borderRadius.toRRect(rect).deflate(borderSide.width / 2.0), paint);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is TNoGapOutlineBorder && other.borderSide == borderSide && other.borderRadius == borderRadius);

  @override
  int get hashCode => Object.hash(borderSide, borderRadius);
}
