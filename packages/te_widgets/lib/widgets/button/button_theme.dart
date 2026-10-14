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
  final Gradient? gradient;
  final double? elevation;
  final Color? shadowColor;

  const TButtonTheme({
    required this.baseTheme,
    required this.size,
    required this.shape,
    required this.buttonStyle,
    this.scaleOnPress = 0.96,
    this.gradient,
    this.elevation,
    this.shadowColor,
  });

  TButtonTheme copyWith({
    TWidgetTheme? baseTheme,
    TSize? size,
    TButtonShape? shape,
    ButtonStyle? buttonStyle,
    double? scaleOnPress,
    Gradient? gradient,
    double? elevation,
    Color? shadowColor,
  }) {
    final effectiveBaseTheme = baseTheme ?? this.baseTheme;
    final effectiveSize = size ?? this.size;
    final effectiveShape = shape ?? this.shape;
    final effectiveElevation = elevation ?? this.elevation;
    final effectiveShadowColor = shadowColor ?? this.shadowColor;

    return TButtonTheme(
      baseTheme: effectiveBaseTheme,
      size: effectiveSize,
      shape: effectiveShape,
      buttonStyle: buttonStyle ??
          buildButtonStyle(
            effectiveBaseTheme,
            effectiveShape,
            effectiveSize,
            elevation: effectiveElevation,
            shadowColor: effectiveShadowColor,
          ),
      scaleOnPress: scaleOnPress ?? this.scaleOnPress,
      gradient: gradient ?? this.gradient,
      elevation: effectiveElevation,
      shadowColor: effectiveShadowColor,
    );
  }

  factory TButtonTheme.defaultTheme(
    ColorScheme colors, {
    TVariant type = TVariant.solid,
    TButtonShape shape = TButtonShape.normal,
    TSize size = TSize.md,
    Gradient? gradient,
    double? elevation,
    Color? shadowColor,
  }) {
    final baseTheme = TWidgetTheme.from(colors.isDarkMode, colors.primary, type);

    return TButtonTheme(
      baseTheme: baseTheme,
      shape: shape,
      size: size,
      buttonStyle: buildButtonStyle(
        baseTheme,
        shape,
        size,
        elevation: elevation,
        shadowColor: shadowColor,
      ),
      gradient: gradient,
      elevation: elevation,
      shadowColor: shadowColor,
    );
  }

  static ButtonStyle buildButtonStyle(
    TWidgetTheme baseTheme,
    TButtonShape shape,
    TSize size, {
    double? elevation,
    Color? shadowColor,
  }) {
    final padding = switch (shape) {
      TButtonShape.tile => size.tilePaddingState,
      _ => size.paddingState,
    };

    final isFill = baseTheme.type == TVariant.solid ||
        (!baseTheme.container.isTransparent &&
            baseTheme.type != TVariant.outline &&
            baseTheme.type != TVariant.text);

    final defaultElevation = isFill ? (baseTheme.type == TVariant.solid ? 1.0 : 0.5) : 0.0;
    final effectiveElevation = elevation ?? defaultElevation;

    return ButtonStyle(
      backgroundColor: baseTheme.backgroundState,
      foregroundColor: baseTheme.foregroundState,
      iconColor: baseTheme.foregroundState,
      side: baseTheme.borderSideState,
      padding: padding,
      minimumSize: size.minimumSizeState,
      visualDensity: VisualDensity.standard,
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.transparent;
        if (states.contains(WidgetState.pressed)) {
          return Colors.black.withValues(alpha: baseTheme.isDarkMode ? 0.10 : 0.06);
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.white.withValues(alpha: baseTheme.isDarkMode ? 0.08 : 0.10);
        }
        return Colors.transparent;
      }),
      elevation: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return 0.0;
        if (!isFill && elevation == null) return 0.0;
        if (states.contains(WidgetState.pressed)) return (effectiveElevation * 0.5).clamp(0.0, 1.0);
        if (states.contains(WidgetState.hovered)) return effectiveElevation + 1.0;
        return effectiveElevation;
      }),
      shadowColor: WidgetStateProperty.resolveWith((states) {
        if (!isFill && shadowColor == null) return Colors.transparent;
        final shadow = shadowColor ?? baseTheme.shadow ?? baseTheme.color.shade(900);
        return shadow.withValues(alpha: 0.18);
      }),
      textStyle: WidgetStateProperty.all(TextStyle(fontSize: size.font, fontWeight: baseTheme.type.fontWeight, letterSpacing: 0.65)),
      shape: WidgetStateProperty.all(shape.border),
    );
  }
}
