import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

class TNumberFieldTheme extends TTextFieldTheme {
  final num increment, decrement;
  final int? decimals;
  final bool showSteppers;

  Widget buildStepperButton(ColorScheme colorScheme, IconData icon, VoidCallback onPressed, bool enabled) {
    return TButton(
      type: TButtonType.icon,
      size: TButtonSize.xs.copyWith(icon: 16),
      icon: icon,
      color: colorScheme.onSurfaceVariant,
      onTap: enabled ? onPressed : null,
    );
  }

  Widget? buildSteppers(ColorScheme colorScheme, bool canDecrease, bool canIncrease, ValueChanged<num> onValueChanged) {
    if (!showSteppers) return null;

    final steppers = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildStepperButton(colorScheme, Icons.remove, () => onValueChanged(-(decrement)), canDecrease),
        const SizedBox(width: 2),
        buildStepperButton(colorScheme, Icons.add, () => onValueChanged(increment), canIncrease),
      ],
    );

    return steppers;
  }

  String formatValue<T extends num>(T? value) {
    if (value == null || value == 0) return '';

    if (T == int) {
      return value.toInt().toString();
    } else {
      if (decimals != null) {
        return value.toStringAsFixed(decimals!);
      }
      return value.toString();
    }
  }

  T? parseValue<T>(String text) {
    if (text.trim().isEmpty) return null;

    try {
      if (T == int) {
        final parsed = int.tryParse(text);
        return parsed as T?;
      } else {
        final parsed = double.tryParse(text);
        return parsed as T?;
      }
    } catch (e) {
      return null;
    }
  }

  const TNumberFieldTheme({
    super.size = TInputSize.md,
    super.color,
    super.backgroundColor,
    super.borderColor,
    super.preWidget,
    super.postWidget,
    super.height,
    super.padding,
    super.fontSize,
    super.borderRadius,
    super.labelStyle,
    super.helperTextStyle,
    super.errorTextStyle,
    super.tagStyle,
    super.labelBuilder,
    super.helperTextBuilder,
    super.errorsBuilder,
    super.borderBuilder,
    super.boxShadowBuilder,
    super.decorationBuilder,
    super.inputFormatters,
    super.keyboardType,
    super.textCapitalization = TextCapitalization.none,
    super.autocorrect = false,
    super.enableSuggestions = false,
    super.maxLength,
    super.maxLengthEnforcement,
    super.textInputAction,
    super.obscureText = false,
    this.increment = 1,
    this.decrement = 1,
    this.decimals = 2,
    this.showSteppers = true,
  })  : assert(increment > 0, 'Increment must be positive'),
        assert(decrement > 0, 'Decrement must be positive'),
        assert(decimals == null || decimals >= 0, 'Decimals must be non-negative');

  @override
  TNumberFieldTheme copyWith({
    TInputSize? size,
    WidgetStateProperty<Color?>? color,
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? borderColor,
    Widget? preWidget,
    Widget? postWidget,
    double? height,
    EdgeInsets? padding,
    double? fontSize,
    double? borderRadius,
    WidgetStateProperty<TextStyle?>? labelStyle,
    WidgetStateProperty<TextStyle?>? helperTextStyle,
    WidgetStateProperty<TextStyle?>? errorTextStyle,
    WidgetStateProperty<TextStyle?>? tagStyle,
    LabelBuilder? labelBuilder,
    HelperTextBuilder? helperTextBuilder,
    ErrorsBuilder? errorsBuilder,
    BorderBuilder? borderBuilder,
    BoxShadowBuilder? boxShadowBuilder,
    DecorationBuilder? decorationBuilder,
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
    bool? showSteppers,
  }) {
    return TNumberFieldTheme(
      size: size ?? this.size,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      preWidget: preWidget ?? this.preWidget,
      postWidget: postWidget ?? this.postWidget,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      fontSize: fontSize ?? this.fontSize,
      borderRadius: borderRadius ?? this.borderRadius,
      labelStyle: labelStyle ?? this.labelStyle,
      helperTextStyle: helperTextStyle ?? this.helperTextStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      tagStyle: tagStyle ?? this.tagStyle,
      labelBuilder: labelBuilder ?? this.labelBuilder,
      helperTextBuilder: helperTextBuilder ?? this.helperTextBuilder,
      errorsBuilder: errorsBuilder ?? this.errorsBuilder,
      borderBuilder: borderBuilder ?? this.borderBuilder,
      boxShadowBuilder: boxShadowBuilder ?? this.boxShadowBuilder,
      decorationBuilder: decorationBuilder ?? this.decorationBuilder,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      keyboardType: keyboardType ?? this.keyboardType,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      autocorrect: autocorrect ?? this.autocorrect,
      enableSuggestions: enableSuggestions ?? this.enableSuggestions,
      maxLength: maxLength ?? this.maxLength,
      maxLengthEnforcement: maxLengthEnforcement ?? this.maxLengthEnforcement,
      textInputAction: textInputAction ?? this.textInputAction,
      obscureText: obscureText ?? this.obscureText,
      increment: increment ?? this.increment,
      decrement: decrement ?? this.decrement,
      decimals: decimals ?? this.decimals,
      showSteppers: showSteppers ?? this.showSteppers,
    );
  }
}
