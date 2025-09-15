import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

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
  final Color color;
  final OutlinedBorder? shape;
  final double? borderRadius;
  final double? elevation;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final double? scaleOnPress;

  final WidgetStateProperty<TextStyle?>? textStyle;
  final WidgetStateProperty<Color?>? shadowColor;

  ButtonStyle getButtonStyle() {
    return ButtonStyle(
      backgroundColor: baseTheme.backgroundState,
      foregroundColor: baseTheme.foregroundState,
      iconColor: baseTheme.foregroundState,
      side: baseTheme.borderSideState,
      padding: size.paddingState,
      minimumSize: size.minimumSizeState,
      shadowColor: shadowColor,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(elevation ?? 0.0),
      shape: WidgetStateProperty.all(shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 6.0))),
      textStyle: textStyle ?? WidgetStateProperty.all(TextStyle(fontSize: size.font, fontWeight: type.fontWeight, letterSpacing: 0.65)),
    );
  }

  Widget buildButtonContent({
    IconData? icon,
    String? text,
    bool isLoading = false,
    String loadingText = 'Loading...',
    Widget? child,
    Set<WidgetState> states = const {},
  }) {
    final resolvedFgColor = baseTheme.foregroundState.resolve(states);

    return Row(
      mainAxisSize: size.minW.isInfinite ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
              width: size.icon,
              height: size.icon,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(resolvedFgColor)))
        else if (icon != null)
          Icon(icon, size: size.icon),
        if (text?.isNotEmpty ?? false) ...[
          if (icon != null || isLoading) SizedBox(width: size.spacing),
          Text(isLoading ? loadingText : text!),
        ],
        if (child != null) child,
      ],
    );
  }

  const TButtonTheme({
    required this.baseTheme,
    required this.type,
    required this.size,
    required this.color,
    this.shape,
    this.borderRadius = 6.0,
    this.elevation = 0.0,
    this.animationDuration = const Duration(milliseconds: 100),
    this.animationCurve = Curves.easeInOut,
    this.scaleOnPress = 0.95,
    this.textStyle,
    this.shadowColor,
  });

  factory TButtonTheme.create(
    BuildContext context, {
    TButtonType? type,
    TButtonSize? size,
    Color? color,
    OutlinedBorder? shape,
  }) {
    final theme = context.theme;
    final mColor = color ?? theme.primary;
    final mType = type ?? TButtonType.solid;
    final mSize = size ?? (type == TButtonType.icon ? TButtonSize.xs.copyWith(icon: 18) : TButtonSize.md);
    final baseTheme = context.getWidgetTheme(mType.colorType, mColor);

    return TButtonTheme(baseTheme: baseTheme, type: mType, size: mSize, color: mColor, shape: shape);
  }

  TButtonTheme copyWith({
    TWidgetTheme? baseTheme,
    TButtonType? type,
    TButtonSize? size,
    Color? color,
    OutlinedBorder? shape,
    double? borderRadius,
    double? elevation,
    Duration? animationDuration,
    Curve? animationCurve,
    double? scaleOnPress,
    WidgetStateProperty<TextStyle?>? textStyle,
    WidgetStateProperty<Color?>? shadowColor,
  }) {
    return TButtonTheme(
      baseTheme: baseTheme ?? this.baseTheme,
      type: type ?? this.type,
      size: size ?? this.size,
      color: color ?? this.color,
      shape: shape ?? this.shape,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      scaleOnPress: scaleOnPress ?? this.scaleOnPress,
      textStyle: textStyle ?? this.textStyle,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }
}
