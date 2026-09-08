part of 'button.dart';

/// Defines the visual variant of a button.
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

  /// Maps the button type to a [TVariant] color scheme.
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

/// Defines the shape of a button.
class TButtonShape {
  final OutlinedBorder border;
  final bool vertical;

  const TButtonShape({
    required this.border,
    this.vertical = false,
  });

  /// Standard rounded rectangle (radius 6.0).
  static const TButtonShape normal = TButtonShape(border: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))));

  /// Pill shape (stadium border).
  static const TButtonShape pill = TButtonShape(border: StadiumBorder());

  /// Circular shape.
  static const TButtonShape circle = TButtonShape(border: CircleBorder());

  /// Tile shape (icon above text, radius 12.0).
  static const TButtonShape tile =
      TButtonShape(border: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))), vertical: true);

  /// Custom rounded rectangle with defined radius.
  static TButtonShape custom(double radius, {bool vertical = false}) =>
      TButtonShape(border: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius))), vertical: vertical);

  TButtonShape copyWith({
    OutlinedBorder? border,
    bool? vertical,
  }) {
    return TButtonShape(
      border: border ?? this.border,
      vertical: vertical ?? this.vertical,
    );
  }
}

/// Theme configuration for [TButton].
@immutable
class TButtonTheme {
  final TWidgetTheme baseTheme;
  final TSize size;
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
    TSize? size,
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
    TSize size = TSize.md,
  }) {
    final baseTheme = TWidgetTheme.from(colors.isDarkMode, colors.primary, type);

    return TButtonTheme(
      baseTheme: baseTheme,
      shape: shape,
      size: size,
      buttonStyle: buildButtonStyle(baseTheme, shape, size),
    );
  }

  static ButtonStyle buildButtonStyle(TWidgetTheme baseTheme, TButtonShape shape, TSize size) {
    final padding = switch (shape) {
      TButtonShape.tile => size.tilePaddingState,
      _ => size.paddingState,
    };

    return ButtonStyle(
      backgroundColor: baseTheme.backgroundState,
      foregroundColor: baseTheme.foregroundState,
      iconColor: baseTheme.foregroundState,
      side: baseTheme.borderSideState,
      padding: padding,
      minimumSize: size.minimumSizeState,
      visualDensity: VisualDensity.standard,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(0.0),
      textStyle: WidgetStateProperty.all(TextStyle(fontSize: size.font, fontWeight: baseTheme.type.fontWeight, letterSpacing: 0.65)),
      shape: WidgetStateProperty.all(shape.border),
    );
  }
}
