part of 'button.dart';

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

class TButtonShape {
  final OutlinedBorder border;

  const TButtonShape({
    required this.border,
  });

  static const TButtonShape normal = TButtonShape(border: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))));
  static const TButtonShape pill = TButtonShape(border: StadiumBorder());
  static const TButtonShape circle = TButtonShape(border: CircleBorder());
  static TButtonShape custom(double radius) =>
      TButtonShape(border: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius))));
}

@immutable
class TButtonSize {
  final double minW, minH, hPad, vPad, font, icon, spacing;

  WidgetStateProperty<EdgeInsets> get paddingState => WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: hPad, vertical: vPad));
  WidgetStateProperty<EdgeInsets> get pillPaddingState =>
      WidgetStateProperty.all(EdgeInsets.only(top: vPad, bottom: vPad, left: hPad, right: hPad + spacing));

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

  static const TButtonSize zero = TButtonSize._(minW: 0, minH: 0, hPad: 0, vPad: 0, font: 0, icon: 0, spacing: 0);
  static const TButtonSize xxs = TButtonSize._(minW: 22, minH: 22, hPad: 2, vPad: 2, font: 10, icon: 12, spacing: 3);
  static const TButtonSize xs = TButtonSize._(minW: 28, minH: 28, hPad: 6, vPad: 2, font: 11, icon: 14, spacing: 4);
  static const TButtonSize sm = TButtonSize._(minW: 32, minH: 32, hPad: 10, vPad: 4, font: 12, icon: 16, spacing: 5);
  static const TButtonSize md = TButtonSize._(minW: 38, minH: 38, hPad: 12, vPad: 6, font: 13, icon: 18, spacing: 6);
  static const TButtonSize lg = TButtonSize._(minW: 45, minH: 45, hPad: 16, vPad: 8, font: 16, icon: 22, spacing: 8);
  static const TButtonSize block = TButtonSize._(minW: double.infinity, minH: 38, hPad: 12, vPad: 6, font: 13, icon: 18, spacing: 6);

  TButtonSize.fromInputSize(TInputSize size)
      : minW = size.height,
        minH = size.height,
        hPad = size.padding.vertical,
        vPad = size.padding.vertical,
        font = size.fontSize,
        icon = size.fontSize + 6,
        spacing = size.padding.right;
}

@immutable
class TButtonTheme {
  final TWidgetTheme baseTheme;
  final TButtonSize size;
  final TButtonShape shape;
  final ButtonStyle buttonStyle;
  final double? scaleOnPress;

  const TButtonTheme({
    required this.baseTheme,
    required this.size,
    required this.shape,
    required this.buttonStyle,
    this.scaleOnPress = 0.95,
  });

  TButtonTheme copyWith({
    TWidgetTheme? baseTheme,
    TButtonSize? size,
    TButtonShape? shape,
    ButtonStyle? buttonStyle,
    double? scaleOnPress,
  }) {
    final effectiveBaseTheme = baseTheme ?? this.baseTheme;
    final effectiveSize = size ?? this.size;
    final effectiveShape = shape ?? this.shape;

    return TButtonTheme(
      baseTheme: effectiveBaseTheme,
      size: effectiveSize,
      shape: effectiveShape,
      buttonStyle: buttonStyle ?? buildButtonStyle(effectiveBaseTheme, effectiveShape, effectiveSize),
      scaleOnPress: scaleOnPress ?? this.scaleOnPress,
    );
  }

  factory TButtonTheme.defaultTheme(
    ColorScheme colors, {
    TVariant type = TVariant.solid,
    TButtonShape shape = TButtonShape.normal,
    TButtonSize size = TButtonSize.sm,
  }) {
    final color = colors.primary;
    final baseTheme = TWidgetTheme.from(colors.isDarkMode, color, type);

    return TButtonTheme(
      baseTheme: baseTheme,
      shape: shape,
      size: size,
      buttonStyle: buildButtonStyle(baseTheme, shape, size),
    );
  }

  static ButtonStyle buildButtonStyle(TWidgetTheme baseTheme, TButtonShape shape, TButtonSize size) {
    return ButtonStyle(
      backgroundColor: baseTheme.backgroundState,
      foregroundColor: baseTheme.foregroundState,
      iconColor: baseTheme.foregroundState,
      side: baseTheme.borderSideState,
      padding: shape == TButtonShape.pill ? size.pillPaddingState : size.paddingState,
      minimumSize: size.minimumSizeState,
      visualDensity: VisualDensity.standard,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(0.0),
      textStyle: WidgetStateProperty.all(TextStyle(fontSize: size.font, fontWeight: baseTheme.type.fontWeight, letterSpacing: 0.65)),
      shape: WidgetStateProperty.all(shape.border),
    );
  }
}
