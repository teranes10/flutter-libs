import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

typedef StepperButtonBuilder = Widget Function(VoidCallback onTap, bool enabled);
typedef StepperBuilder = Widget Function(BuildContext ctx, ValueChanged<num> onValueChanged, bool canIncrease, bool canDecrease);

/// Theme configuration for [TNumberField].
///
/// `TNumberFieldTheme` extends [TTextFieldTheme] with numeric specific
/// properties like:
/// - Increment/Decrement values
/// - Decimal precision
/// - Stepper buttons (plus/minus) builders
/// - Custom numeric formatting/parsing
class TNumberFieldTheme extends TTextFieldTheme {
  // Numeric Configuration
  /// The amount to increase the value by.
  final num increment;

  /// The amount to decrease the value by.
  final num decrement;

  /// The number of decimal places to allow (null for infinite).
  final int? decimals;

  /// Builder for the decrease (-) button.
  final StepperButtonBuilder? decreaseButtonBuilder;

  /// Builder for the increase (+) button.
  final StepperButtonBuilder? increaseButtonBuilder;

  /// Builder for the entire stepper widget (grouping buttons).
  final StepperBuilder? stepperBuilder;

  /// Creates a number field theme.
  const TNumberFieldTheme({
    required super.color,
    required super.backgroundColor,
    required super.borderColor,
    required super.labelStyle,
    required super.helperTextStyle,
    required super.errorTextStyle,
    required super.tagStyle,
    required super.decoration,
    required super.borderRadius,
    required super.borderWidth,
    required super.labelBuilder,
    required super.helperTextBuilder,
    required super.errorsBuilder,
    required super.textStyle,
    required super.hintStyle,
    super.size = TInputSize.md,
    super.decorationType,
    super.preWidget,
    super.postWidget,
    super.height,
    super.padding,
    super.fontSize,
    super.inputFormatters,
    super.keyboardType,
    super.textCapitalization = TextCapitalization.none,
    super.autocorrect = false,
    super.enableSuggestions = false,
    super.maxLength,
    super.maxLengthEnforcement,
    super.textInputAction,
    super.obscureText = false,
    required this.increment,
    required this.decrement,
    required this.decimals,
    this.increaseButtonBuilder,
    this.decreaseButtonBuilder,
    this.stepperBuilder,
  })  : assert(increment > 0, 'Increment must be positive'),
        assert(decrement > 0, 'Decrement must be positive'),
        assert(decimals == null || decimals >= 0, 'Decimals must be non-negative');

  @override
  TNumberFieldTheme copyWith({
    TInputSize? size,
    TInputDecorationType? decorationType,
    WidgetStateProperty<Color>? color,
    WidgetStateProperty<Color>? backgroundColor,
    WidgetStateProperty<Color>? borderColor,
    WidgetStateProperty<TextStyle>? labelStyle,
    WidgetStateProperty<TextStyle>? helperTextStyle,
    WidgetStateProperty<TextStyle>? errorTextStyle,
    WidgetStateProperty<TextStyle>? tagStyle,
    WidgetStateProperty<BoxDecoration>? decoration,
    WidgetStateProperty<double>? borderRadius,
    WidgetStateProperty<double>? borderWidth,
    WidgetStateProperty<LabelBuilder>? labelBuilder,
    WidgetStateProperty<HelperTextBuilder>? helperTextBuilder,
    WidgetStateProperty<ErrorsBuilder>? errorsBuilder,
    WidgetStateProperty<TextStyle>? textStyle,
    WidgetStateProperty<TextStyle>? hintStyle,
    Widget? preWidget,
    Widget? postWidget,
    double? height,
    EdgeInsets? padding,
    double? fontSize,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    bool? autocorrect,
    bool? enableSuggestions,
    int? maxLength,
    MaxLengthEnforcement? maxLengthEnforcement,
    TextInputAction? textInputAction,
    bool? obscureText,
    num? increment,
    num? decrement,
    int? decimals,
    StepperButtonBuilder? decreaseButtonBuilder,
    StepperButtonBuilder? increaseButtonBuilder,
    StepperBuilder? stepperBuilder,
  }) {
    final baseTheme = super.copyWith(
      size: size,
      decorationType: decorationType,
      color: color,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      labelStyle: labelStyle,
      helperTextStyle: helperTextStyle,
      errorTextStyle: errorTextStyle,
      tagStyle: tagStyle,
      decoration: decoration,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      labelBuilder: labelBuilder,
      helperTextBuilder: helperTextBuilder,
      errorsBuilder: errorsBuilder,
      textStyle: textStyle,
      hintStyle: hintStyle,
      preWidget: preWidget,
      postWidget: postWidget,
      height: height,
      padding: padding,
      fontSize: fontSize,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
      textInputAction: textInputAction,
      obscureText: obscureText,
    );

    return TNumberFieldTheme(
      // Text field properties from parent
      size: baseTheme.size,
      decorationType: baseTheme.decorationType,
      color: baseTheme.color,
      backgroundColor: baseTheme.backgroundColor,
      borderColor: baseTheme.borderColor,
      labelStyle: baseTheme.labelStyle,
      helperTextStyle: baseTheme.helperTextStyle,
      errorTextStyle: baseTheme.errorTextStyle,
      tagStyle: baseTheme.tagStyle,
      decoration: baseTheme.decoration,
      borderRadius: baseTheme.borderRadius,
      borderWidth: baseTheme.borderWidth,
      labelBuilder: baseTheme.labelBuilder,
      helperTextBuilder: baseTheme.helperTextBuilder,
      errorsBuilder: baseTheme.errorsBuilder,
      textStyle: baseTheme.textStyle,
      hintStyle: baseTheme.hintStyle,
      preWidget: baseTheme.preWidget,
      postWidget: baseTheme.postWidget,
      height: baseTheme.height,
      padding: baseTheme.padding,
      fontSize: baseTheme.fontSize,
      inputFormatters: baseTheme.inputFormatters,
      keyboardType: baseTheme.keyboardType,
      textCapitalization: baseTheme.textCapitalization,
      autocorrect: baseTheme.autocorrect,
      enableSuggestions: baseTheme.enableSuggestions,
      maxLength: baseTheme.maxLength,
      maxLengthEnforcement: baseTheme.maxLengthEnforcement,
      textInputAction: baseTheme.textInputAction,
      obscureText: baseTheme.obscureText,

      // Number-specific properties
      increment: increment ?? this.increment,
      decrement: decrement ?? this.decrement,
      decimals: decimals ?? this.decimals,
      increaseButtonBuilder: increaseButtonBuilder ?? this.increaseButtonBuilder,
      decreaseButtonBuilder: decreaseButtonBuilder ?? this.decreaseButtonBuilder,
      stepperBuilder: stepperBuilder ?? this.stepperBuilder,
    );
  }

  /// Creates a default theme derived from the context colors.
  factory TNumberFieldTheme.defaultTheme(ColorScheme colors) {
    final baseTheme = TTextFieldTheme.defaultTheme(colors);
    final increment = 1;
    final decrement = 2;

    Widget decreaseButtonBuilder(onTap, enabled) {
      return TButton(
        type: TButtonType.icon,
        size: TButtonSize.xxs.copyWith(minW: baseTheme.fieldHeight + 3, minH: baseTheme.fieldHeight, icon: baseTheme.fieldFontSize + 3),
        icon: Icons.remove,
        color: colors.onSurfaceVariant,
        onTap: enabled ? onTap : null,
      );
    }

    Widget increaseButtonBuilder(onTap, enabled) {
      return TButton(
        type: TButtonType.icon,
        size: TButtonSize.xxs.copyWith(minW: baseTheme.fieldHeight + 3, minH: baseTheme.fieldHeight, icon: baseTheme.fieldFontSize + 3),
        icon: Icons.add,
        color: colors.onSurfaceVariant,
        onTap: enabled ? onTap : null,
      );
    }

    return TNumberFieldTheme(
      size: baseTheme.size,
      decorationType: baseTheme.decorationType,
      color: baseTheme.color,
      backgroundColor: baseTheme.backgroundColor,
      borderColor: baseTheme.borderColor,
      labelStyle: baseTheme.labelStyle,
      helperTextStyle: baseTheme.helperTextStyle,
      errorTextStyle: baseTheme.errorTextStyle,
      tagStyle: baseTheme.tagStyle,
      decoration: baseTheme.decoration,
      borderRadius: baseTheme.borderRadius,
      borderWidth: baseTheme.borderWidth,
      labelBuilder: baseTheme.labelBuilder,
      helperTextBuilder: baseTheme.helperTextBuilder,
      errorsBuilder: baseTheme.errorsBuilder,
      preWidget: baseTheme.preWidget,
      postWidget: baseTheme.postWidget,
      height: baseTheme.height,
      padding: baseTheme.padding,
      fontSize: baseTheme.fontSize,
      textStyle: baseTheme.textStyle,
      hintStyle: baseTheme.hintStyle,
      increment: increment,
      decrement: decrement,
      decimals: 2,
      increaseButtonBuilder: increaseButtonBuilder,
      decreaseButtonBuilder: decreaseButtonBuilder,
      stepperBuilder: (ctx, onValueChanged, canIncrease, canDecrease) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            decreaseButtonBuilder(() => onValueChanged(-decrement), canDecrease),
            increaseButtonBuilder(() => onValueChanged(increment), canIncrease),
          ],
        );
      },
    );
  }

  /// Formats a number to a string based on the theme properties.
  String formatValue<T extends num>(T? value) {
    if (value == null || value == 0) return '';

    if (T == int) {
      return value.toInt().toString();
    }

    return decimals != null ? value.toStringAsFixed(decimals!) : value.toString();
  }

  /// Parses a string to a number.
  T? parseValue<T extends num>(String text) {
    if (text.trim().isEmpty) return null;

    try {
      if (T == int) {
        return int.tryParse(text) as T?;
      } else {
        return double.tryParse(text) as T?;
      }
    } catch (e) {
      return null;
    }
  }
}
