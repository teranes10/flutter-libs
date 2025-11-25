import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TButtonShape {
  normal,
  pill,
  circle;
}

enum TButtonType {
  solid,
  tonal,
  outline,
  softOutline,
  filledOutline,
  text,
  softText,
  filledText,
  icon;

  FontWeight get fontWeight {
    return switch (this) {
      solid || tonal || text || softText || filledText || icon => FontWeight.w400,
      outline || softOutline || filledOutline => FontWeight.w300,
    };
  }

  TVariant get colorType {
    return switch (this) {
      TButtonType.solid => TVariant.solid,
      TButtonType.tonal => TVariant.tonal,
      TButtonType.outline => TVariant.outline,
      TButtonType.softOutline => TVariant.softOutline,
      TButtonType.filledOutline => TVariant.filledOutline,
      TButtonType.softText => TVariant.softText,
      TButtonType.filledText => TVariant.filledText,
      TButtonType.text || TButtonType.icon => TVariant.text,
    };
  }
}

@immutable
class TButtonSize {
  final double minW, minH, hPad, vPad, font, icon, spacing;

  WidgetStateProperty<EdgeInsets> get paddingState => WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: hPad, vertical: vPad));
  WidgetStateProperty<Size> get minimumSizeState => WidgetStateProperty.all(Size(minW, minH));

  const TButtonSize._({
    required this.minW,
    required this.minH,
    required this.hPad,
    required this.vPad,
    required this.font,
    required this.icon,
    required this.spacing,
  });

  TButtonSize copyWith({
    double? minW,
    double? minH,
    double? hPad,
    double? vPad,
    double? font,
    double? icon,
    double? spacing,
  }) {
    return TButtonSize._(
      minW: minW ?? this.minW,
      minH: minH ?? this.minH,
      hPad: hPad ?? this.hPad,
      vPad: vPad ?? this.vPad,
      font: font ?? this.font,
      icon: icon ?? this.icon,
      spacing: spacing ?? this.spacing,
    );
  }

  static const TButtonSize xxs = TButtonSize._(minW: 22, minH: 22, hPad: 2, vPad: 2, font: 10, icon: 12, spacing: 3);
  static const TButtonSize xs = TButtonSize._(minW: 28, minH: 28, hPad: 6, vPad: 2, font: 11, icon: 14, spacing: 4);
  static const TButtonSize sm = TButtonSize._(minW: 32, minH: 32, hPad: 10, vPad: 4, font: 12, icon: 16, spacing: 5);
  static const TButtonSize md = TButtonSize._(minW: 38, minH: 38, hPad: 12, vPad: 6, font: 13, icon: 18, spacing: 6);
  static const TButtonSize lg = TButtonSize._(minW: 45, minH: 45, hPad: 16, vPad: 8, font: 14, icon: 20, spacing: 8);
  static const TButtonSize block = TButtonSize._(minW: double.infinity, minH: 38, hPad: 12, vPad: 6, font: 13, icon: 18, spacing: 6);
}

@immutable
class TButtonTheme {
  final TWidgetTheme baseTheme;
  final TButtonType type;
  final TButtonSize size;
  final TButtonShape shape;
  final Color color;
  final ButtonStyle buttonStyle;
  final double? scaleOnPress;

  const TButtonTheme({
    this.type = TButtonType.solid,
    required this.baseTheme,
    required this.size,
    required this.shape,
    required this.buttonStyle,
    required this.color,
    this.scaleOnPress = 0.95,
  });

  TButtonTheme copyWith({
    TWidgetTheme? baseTheme,
    TButtonType? type,
    TButtonSize? size,
    TButtonShape? shape,
    Color? color,
    ButtonStyle? buttonStyle,
    double? scaleOnPress,
  }) {
    final effectiveType = type ?? this.type;
    final effectiveColor = color ?? this.color;
    final effectiveBaseTheme = baseTheme ?? this.baseTheme.copyWidth(type: effectiveType.colorType, color: effectiveColor);
    final effectiveSize = size ?? this.size;
    final effectiveShape = shape ?? this.shape;

    return TButtonTheme(
      type: effectiveType,
      baseTheme: effectiveBaseTheme,
      size: effectiveSize,
      shape: effectiveShape,
      color: effectiveColor,
      buttonStyle: buttonStyle ?? buildButtonStyle(effectiveBaseTheme, effectiveType, effectiveShape, effectiveSize),
      scaleOnPress: scaleOnPress ?? this.scaleOnPress,
    );
  }

  factory TButtonTheme.defaultTheme(
    ColorScheme colors, {
    TButtonType type = TButtonType.solid,
    TButtonShape shape = TButtonShape.normal,
    TButtonSize size = TButtonSize.md,
  }) {
    final color = colors.primary;
    final baseTheme = TWidgetTheme.from(colors.isDarkMode, color, type.colorType);

    return TButtonTheme(
      baseTheme: baseTheme,
      shape: shape,
      size: size,
      color: color,
      buttonStyle: buildButtonStyle(baseTheme, type, shape, size),
    );
  }

  static ButtonStyle buildButtonStyle(TWidgetTheme baseTheme, TButtonType type, TButtonShape shape, TButtonSize size) {
    return ButtonStyle(
      backgroundColor: baseTheme.backgroundState,
      foregroundColor: baseTheme.foregroundState,
      iconColor: baseTheme.foregroundState,
      side: baseTheme.borderSideState,
      padding: shape == TButtonShape.circle ? WidgetStateProperty.all(EdgeInsets.zero) : size.paddingState,
      minimumSize: size.minimumSizeState,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(0.0),
      textStyle: WidgetStateProperty.all(TextStyle(fontSize: size.font, fontWeight: type.fontWeight, letterSpacing: 0.65)),
      shape: WidgetStateProperty.all(switch (shape) {
        TButtonShape.normal => RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        TButtonShape.pill => RoundedRectangleBorder(borderRadius: BorderRadius.circular(size.minH / 2)),
        TButtonShape.circle => const CircleBorder(),
      }),
    );
  }
}
