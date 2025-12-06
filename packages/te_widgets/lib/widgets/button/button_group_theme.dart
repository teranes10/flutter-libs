part of 'button.dart';

/// Defines the display type of a button group.
enum TButtonGroupType {
  solid,
  tonal,
  outline,
  softOutline,
  filledOutline,
  text,
  softText,
  filledText,
  icon,
  boxed;

  /// Maps the group type to an individual [TButtonType].
  TButtonType get buttonType {
    return switch (this) {
      TButtonGroupType.solid => TButtonType.solid,
      TButtonGroupType.tonal => TButtonType.tonal,
      TButtonGroupType.outline => TButtonType.outline,
      TButtonGroupType.softOutline => TButtonType.softOutline,
      TButtonGroupType.filledOutline => TButtonType.filledOutline,
      TButtonGroupType.softText => TButtonType.softText,
      TButtonGroupType.filledText || TButtonGroupType.boxed => TButtonType.filledText,
      TButtonGroupType.text => TButtonType.text,
      TButtonGroupType.icon => TButtonType.icon,
    };
  }
}

/// Theme configuration for [TButtonGroup].
///
/// `TButtonGroupTheme` styles a group of buttons, including:
/// - Group type (solid, outline, etc.)
/// - Button size and shape
/// - Spacing and separators
/// - Boxed mode decoration
@immutable
class TButtonGroupTheme {
  final TButtonGroupType type;
  final TButtonSize? size;
  final TButtonShape shape;
  final Color? color;
  final double spacing;
  final double borderRadius;
  final bool enableBoxedMode;
  final EdgeInsetsGeometry? boxedPadding;
  final BoxDecoration? boxedDecoration;
  final double? separatorWidth;
  final Color? separatorColor;

  /// Creates a button group theme.
  const TButtonGroupTheme({
    this.type = TButtonGroupType.solid,
    this.size = TButtonSize.md,
    this.shape = TButtonShape.normal,
    this.color,
    this.spacing = 0,
    this.borderRadius = 6.0,
    this.enableBoxedMode = false,
    this.boxedPadding,
    this.boxedDecoration,
    this.separatorWidth,
    this.separatorColor,
  });

  /// Creates a theme from the base context.
  factory TButtonGroupTheme.fromBaseTheme({
    required BuildContext context,
    TButtonGroupType type = TButtonGroupType.solid,
    TButtonSize? size,
    Color? color,
    double spacing = 0,
    double borderRadius = 6.0,
    bool enableBoxedMode = false,
  }) {
    final colors = context.colors;

    return TButtonGroupTheme(
      type: type,
      size: size,
      color: color,
      spacing: spacing,
      borderRadius: borderRadius,
      enableBoxedMode: enableBoxedMode || type == TButtonGroupType.boxed,
      boxedPadding: const EdgeInsets.all(2),
      boxedDecoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(borderRadius + 2),
      ),
      separatorWidth: 0.25,
      separatorColor: colors.outline,
    );
  }

  /// Whether separators should be shown based on the group type.
  bool needsSeparator() {
    return type == TButtonGroupType.text ||
        type == TButtonGroupType.softText ||
        type == TButtonGroupType.filledText ||
        type == TButtonGroupType.boxed;
  }

  /// Builds a visual separator widget.
  Widget buildSeparator() {
    return Container(
      width: separatorWidth,
      height: 24,
      color: separatorColor,
    );
  }

  /// Creates a copy of the theme with updated properties.
  TButtonGroupTheme copyWith({
    TButtonGroupType? type,
    TButtonSize? size,
    Color? color,
    double? spacing,
    double? borderRadius,
    bool? enableBoxedMode,
    EdgeInsetsGeometry? boxedPadding,
    BoxDecoration? boxedDecoration,
    double? separatorWidth,
    Color? separatorColor,
  }) {
    return TButtonGroupTheme(
      type: type ?? this.type,
      size: size ?? this.size,
      color: color ?? this.color,
      spacing: spacing ?? this.spacing,
      borderRadius: borderRadius ?? this.borderRadius,
      enableBoxedMode: enableBoxedMode ?? this.enableBoxedMode,
      boxedPadding: boxedPadding ?? this.boxedPadding,
      boxedDecoration: boxedDecoration ?? this.boxedDecoration,
      separatorWidth: separatorWidth ?? this.separatorWidth,
      separatorColor: separatorColor ?? this.separatorColor,
    );
  }
}
