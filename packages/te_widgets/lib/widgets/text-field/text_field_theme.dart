import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

/// Theme configuration for [TTextField].
///
/// `TTextFieldTheme` extends [TInputFieldTheme] with specific properties for
/// text input, including:
/// - Text styles (input, hint)
/// - Keyboard configuration (type, action)
/// - Input formatters and behavior (autocorrect, suggestions, obscure)
class TTextFieldTheme extends TInputFieldTheme {
  // Text Styling
  /// Style for the input text.
  final WidgetStateProperty<TextStyle> textStyle;

  // Input Configuration
  /// Input formatters to apply.
  final List<TextInputFormatter>? inputFormatters;

  /// The keyboard type to use.
  final TextInputType? keyboardType;

  /// Text capitalization behavior.
  final TextCapitalization textCapitalization;

  /// The text input action (e.g., done, next).
  final TextInputAction? textInputAction;

  // Input Behavior
  /// Whether to enable autocorrect.
  final bool autocorrect;

  /// Whether to show suggestions.
  final bool enableSuggestions;

  /// Whether to obscure the text (for passwords).
  final bool obscureText;

  /// Maximum character length.
  final int? maxLength;

  /// Policy for enforcing max length.
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// Creates a text field theme.
  const TTextFieldTheme({
    required super.color,
    required super.backgroundColor,
    required super.borderColor,
    required super.labelStyle,
    required super.helperTextStyle,
    required super.errorTextStyle,
    required super.tagStyle,
    required super.borderRadius,
    required super.borderWidth,
    required super.labelBuilder,
    required super.helperTextBuilder,
    required super.errorsBuilder,
    required super.hintStyle,
    required this.textStyle,
    required super.size,
    required super.decorationType,
    required super.labelPosition,
    super.preWidget,
    super.postWidget,
    super.height,
    super.padding,
    super.fontSize,
    this.inputFormatters,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLength,
    this.maxLengthEnforcement,
    this.textInputAction,
    this.obscureText = false,
  });

  @override
  TTextFieldTheme copyWith({
    TInputSize? size,
    TInputDecorationType? decorationType,
    TLabelPosition? labelPosition,
    WidgetStateProperty<Color>? color,
    WidgetStateProperty<Color>? backgroundColor,
    WidgetStateProperty<Color>? borderColor,
    WidgetStateProperty<TextStyle>? labelStyle,
    WidgetStateProperty<TextStyle>? helperTextStyle,
    WidgetStateProperty<TextStyle>? errorTextStyle,
    WidgetStateProperty<TextStyle>? tagStyle,
    WidgetStateProperty<TextStyle>? hintStyle,
    WidgetStateProperty<double>? borderRadius,
    WidgetStateProperty<double>? borderWidth,
    WidgetStateProperty<LabelBuilder>? labelBuilder,
    WidgetStateProperty<HelperTextBuilder>? helperTextBuilder,
    WidgetStateProperty<ErrorsBuilder>? errorsBuilder,
    WidgetStateProperty<TextStyle>? textStyle,
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
  }) {
    final baseTheme = super.copyWith(
      size: size,
      decorationType: decorationType,
      labelPosition: labelPosition,
      color: color,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      labelStyle: labelStyle,
      helperTextStyle: helperTextStyle,
      errorTextStyle: errorTextStyle,
      tagStyle: tagStyle,
      hintStyle: hintStyle,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      labelBuilder: labelBuilder,
      helperTextBuilder: helperTextBuilder,
      errorsBuilder: errorsBuilder,
      preWidget: preWidget,
      postWidget: postWidget,
      height: height,
      padding: padding,
      fontSize: fontSize,
    );

    return TTextFieldTheme(
      // Base theme properties from parent
      size: baseTheme.size,
      decorationType: baseTheme.decorationType,
      labelPosition: baseTheme.labelPosition,
      color: baseTheme.color,
      backgroundColor: baseTheme.backgroundColor,
      borderColor: baseTheme.borderColor,
      labelStyle: baseTheme.labelStyle,
      helperTextStyle: baseTheme.helperTextStyle,
      errorTextStyle: baseTheme.errorTextStyle,
      tagStyle: baseTheme.tagStyle,
      hintStyle: baseTheme.hintStyle,
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

      // Text-specific properties
      textStyle: textStyle ?? this.textStyle,
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

  /// Creates a default theme derived from the context colors.
  factory TTextFieldTheme.defaultTheme(ColorScheme colors) {
    final baseTheme = TInputFieldTheme.defaultTheme(colors);

    return TTextFieldTheme(
      size: baseTheme.size,
      decorationType: baseTheme.decorationType,
      labelPosition: baseTheme.labelPosition,
      color: baseTheme.color,
      backgroundColor: baseTheme.backgroundColor,
      borderColor: baseTheme.borderColor,
      labelStyle: baseTheme.labelStyle,
      helperTextStyle: baseTheme.helperTextStyle,
      errorTextStyle: baseTheme.errorTextStyle,
      tagStyle: baseTheme.tagStyle,
      hintStyle: baseTheme.hintStyle,
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
      textStyle: WidgetStateProperty.resolveWith((states) {
        final isDisabled = states.contains(WidgetState.disabled);
        return TextStyle(
          fontSize: baseTheme.fieldFontSize,
          color: isDisabled ? colors.onSurfaceVariant : colors.onSurface,
        );
      }),
    );
  }

  /// Builds a raw [TextField] with the theme applied.
  Widget buildTextField(
    Set<WidgetState> states, {
    bool autoFocus = false,
    bool readOnly = false,
    int maxLines = 1,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    TextEditingController? controller,
    ValueChanged<String>? onValueChanged,
    VoidCallback? onTap,
    required InputDecoration inputDecoration,
  }) {
    final isDisabled = states.contains(WidgetState.disabled);
    final isMultiline = maxLines > 1;
    final style = textStyle.resolve(states).copyWith(fontSize: fieldFontSize);

    return TextField(
      controller: controller,
      readOnly: readOnly,
      enableInteractiveSelection: !readOnly,
      autofocus: autoFocus,
      focusNode: focusNode,
      enabled: !isDisabled,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
      cursorHeight: fieldFontSize + 2,
      style: style,
      decoration: inputDecoration,
      expands: maxLines == 1,
      minLines: maxLines > 1 ? maxLines : null,
      maxLines: null,
      scrollPhysics: const BouncingScrollPhysics(),
      scrollPadding: const EdgeInsets.all(8),
      obscureText: obscureText,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      keyboardType: _resolveKeyboardType(isDisabled, readOnly, isMultiline, keyboardType),
      textInputAction: _resolveTextInputAction(isMultiline, textInputAction),
      onChanged: onValueChanged,
      onTap: onTap,
    );
  }

  TextInputType _resolveKeyboardType(bool isDisabled, bool readOnly, bool isMultiline, TextInputType? overrideKeyboardType) {
    if (isDisabled || readOnly) return TextInputType.none;
    if (isMultiline) return TextInputType.multiline;
    return keyboardType ?? overrideKeyboardType ?? TextInputType.text;
  }

  TextInputAction _resolveTextInputAction(bool isMultiline, TextInputAction? overrideAction) {
    return textInputAction ?? (isMultiline ? TextInputAction.newline : overrideAction ?? TextInputAction.next);
  }
}
