import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/configs/widget-theme/input_field_theme.dart';
import 'package:te_widgets/enum/value_type.dart';
import 'package:te_widgets/formatters/decimal_input_formatter.dart';
import 'package:te_widgets/formatters/integer_input_formatter.dart';

class TTextFieldTheme extends TInputFieldTheme {
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final TextInputAction? textInputAction;
  final bool obscureText;

  TextStyle getTextStyle(ColorScheme colors, bool disabled) {
    return TextStyle(fontSize: fontSize, color: disabled ? colors.onSurfaceVariant : colors.onSurface);
  }

  InputDecoration getInputDecoration(ColorScheme colors, String? label, String? placeholder) {
    return InputDecoration(
      border: InputBorder.none,
      hintText: placeholder ?? label,
      hintStyle: getHintStyle(colors),
      isCollapsed: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
    );
  }

  TextInputType getKeyboardType(BaseValueType? type) {
    return switch (type) {
      BaseValueType.integer => TextInputType.number,
      BaseValueType.floating || BaseValueType.numeric => TextInputType.numberWithOptions(decimal: true),
      BaseValueType.dateTime || BaseValueType.timeOfDay => TextInputType.datetime,
      _ => TextInputType.text,
    };
  }

  List<TextInputFormatter> getInputFormatters(BaseValueType? type, int? decimals) {
    return switch (type) {
      BaseValueType.integer => [IntegerInputFormatter()],
      BaseValueType.floating || BaseValueType.numeric => [DecimalInputFormatter(decimals: decimals)],
      _ => [],
    };
  }

  TextField buildTextField(
    ColorScheme colors, {
    String? label,
    String? placeholder,
    bool autoFocus = false,
    bool readOnly = false,
    bool disabled = false,
    int maxLines = 1,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    TextEditingController? controller,
    ValueChanged<String>? onValueChanged,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      autofocus: autoFocus,
      focusNode: focusNode,
      enabled: !disabled,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
      cursorHeight: fieldFontSize + 2,
      style: getTextStyle(colors, disabled),
      decoration: getInputDecoration(colors, label, placeholder),
      maxLines: maxLines,
      scrollPhysics: const BouncingScrollPhysics(),
      scrollPadding: const EdgeInsets.all(8),
      obscureText: obscureText,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      keyboardType: disabled || readOnly
          ? TextInputType.none
          : (maxLines > 1 ? TextInputType.multiline : this.keyboardType ?? keyboardType ?? TextInputType.text),
      textInputAction: this.textInputAction ?? (maxLines > 1 ? TextInputAction.newline : textInputAction ?? TextInputAction.next),
      textAlignVertical: maxLines > 1 ? TextAlignVertical.top : TextAlignVertical.center,
      onChanged: onValueChanged,
    );
  }

  const TTextFieldTheme({
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
    this.inputFormatters,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.textInputAction,
    this.obscureText = false,
  });

  @override
  TTextFieldTheme copyWith({
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
  }) {
    return TTextFieldTheme(
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
    );
  }
}
