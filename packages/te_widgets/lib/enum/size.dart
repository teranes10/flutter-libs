import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Defines the unified size metrics and geometry for widgets such as
/// [TButton], [TChip], and [TBadge].
@immutable
class TSize {
  /// Minimum width of the element.
  final double minW;

  /// Minimum height of the element.
  final double minH;

  /// Horizontal padding.
  final double hPad;

  /// Vertical padding.
  final double vPad;

  /// Font size for text.
  final double font;

  /// Primary icon size.
  final double icon;

  /// Corner border radius.
  final double radius;

  /// Horizontal or vertical spacing between elements.
  final double spacing;

  // ── Convenience Aliases ──────────────────────────────────────────────────
  double get fontSize => font;
  double get iconSize => icon;
  double get height => minH;
  double get width => minW;

  // ── Geometry Helpers ─────────────────────────────────────────────────────
  EdgeInsets get padding => EdgeInsets.symmetric(horizontal: hPad, vertical: vPad);
  BorderRadius get borderRadius => BorderRadius.circular(radius);

  // ── Button State Properties ──────────────────────────────────────────────
  WidgetStateProperty<EdgeInsets> get paddingState =>
      WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: hPad, vertical: vPad));

  WidgetStateProperty<EdgeInsets> get tilePaddingState =>
      WidgetStateProperty.all(EdgeInsets.only(top: vPad * 1.75, bottom: vPad * 1.25, left: hPad, right: hPad));

  WidgetStateProperty<Size> get minimumSizeState => WidgetStateProperty.all(Size(minW, minH));

  /// Creates a custom [TSize] definition.
  const TSize({
    this.minW = 0,
    this.minH = 0,
    this.hPad = 0,
    this.vPad = 0,
    this.font = 12,
    this.icon = 16,
    this.radius = 6,
    this.spacing = 4,
  });

  /// Zero size configuration.
  static const TSize zero = TSize(
    minW: 0,
    minH: 0,
    hPad: 0,
    vPad: 0,
    font: 0,
    icon: 0,
    radius: 0,
    spacing: 0,
  );

  /// Extra extra small size (minH: 22, font: 10, icon: 12).
  static const TSize xxs = TSize(
    minW: 22,
    minH: 22,
    hPad: 2,
    vPad: 2,
    font: 10,
    icon: 12,
    radius: 3,
    spacing: 3,
  );

  /// Extra small size (minH: 28, font: 11, icon: 14).
  static const TSize xs = TSize(
    minW: 28,
    minH: 28,
    hPad: 6,
    vPad: 2,
    font: 11,
    icon: 14,
    radius: 4,
    spacing: 4,
  );

  /// Small size (minH: 32, font: 12, icon: 16).
  static const TSize sm = TSize(
    minW: 32,
    minH: 32,
    hPad: 10,
    vPad: 4,
    font: 12,
    icon: 16,
    radius: 5,
    spacing: 5,
  );

  /// Medium standard size (minH: 38, font: 13, icon: 18).
  static const TSize md = TSize(
    minW: 38,
    minH: 38,
    hPad: 12,
    vPad: 6,
    font: 13,
    icon: 18,
    radius: 6,
    spacing: 6,
  );

  /// Large prominent size (minH: 45, font: 16, icon: 22).
  static const TSize lg = TSize(
    minW: 45,
    minH: 45,
    hPad: 16,
    vPad: 8,
    font: 16,
    icon: 22,
    radius: 8,
    spacing: 8,
  );

  /// Full-width block size with medium height.
  static const TSize block = TSize(
    minW: double.infinity,
    minH: 38,
    hPad: 12,
    vPad: 6,
    font: 13,
    icon: 18,
    radius: 6,
    spacing: 6,
  );

  /// Creates a size configuration from a [TInputSize].
  factory TSize.fromInputSize(TInputSize size) {
    return TSize(
      minW: size.height,
      minH: size.height,
      hPad: 3,
      vPad: 3,
      font: size.fontSize,
      icon: size.fontSize + 6,
      spacing: size.padding.right,
    );
  }

  /// Creates a copy with updated metrics.
  TSize copyWith({
    double? minW,
    double? minH,
    double? hPad,
    double? vPad,
    double? font,
    double? icon,
    double? radius,
    double? spacing,
  }) {
    return TSize(
      minW: minW ?? this.minW,
      minH: minH ?? this.minH,
      hPad: hPad ?? this.hPad,
      vPad: vPad ?? this.vPad,
      font: font ?? this.font,
      icon: icon ?? this.icon,
      radius: radius ?? this.radius,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TSize &&
          runtimeType == other.runtimeType &&
          minW == other.minW &&
          minH == other.minH &&
          hPad == other.hPad &&
          vPad == other.vPad &&
          font == other.font &&
          icon == other.icon &&
          radius == other.radius &&
          spacing == other.spacing;

  @override
  int get hashCode => Object.hash(
        minW,
        minH,
        hPad,
        vPad,
        font,
        icon,
        radius,
        spacing,
      );
}

/// Backward compatibility typedef for [TButtonSize].
typedef TButtonSize = TSize;
