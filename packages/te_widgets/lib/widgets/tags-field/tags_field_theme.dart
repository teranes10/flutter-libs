import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

typedef TagBuilder = Widget Function(String tag, VoidCallback onRemove);

/// Theme configuration for [TTagsField].
///
/// `TTagsFieldTheme` extends [TTextFieldTheme] to include:
/// - A custom `tagBuilder` for rendering tags (chips) inside the field.
/// - Inherited text field styling.
class TTagsFieldTheme extends TTextFieldTheme {
  // Custom Builder
  /// Builder for individual tags.
  final TagBuilder tagBuilder;

  /// Creates a tags field theme.
  const TTagsFieldTheme({
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
    required this.tagBuilder,
  });

  @override
  TTagsFieldTheme copyWith({
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
    double? minInputWidth,
    double? maxInputWidth,
    TagBuilder? tagBuilder,
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

    return TTagsFieldTheme(
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

      // Tag-specific properties
      tagBuilder: tagBuilder ?? this.tagBuilder,
    );
  }

  /// Creates a default theme derived from the context colors.
  factory TTagsFieldTheme.defaultTheme(ColorScheme colors) {
    final baseTheme = TTextFieldTheme.defaultTheme(colors);

    return TTagsFieldTheme(
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
      tagBuilder: (tag, onRemove) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(5.0)),
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    tag,
                    style: TextStyle(color: colors.onSurface, fontSize: baseTheme.fieldFontSize, fontWeight: FontWeight.w400),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 5.0),
                InkWell(onTap: onRemove, child: Icon(Icons.close, size: 14, color: colors.onSurface)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the tag list widget.
  Widget buildTagsField({
    required Widget child,
    required TTagsController controller,
    required bool canRemove,
  }) {
    void removeTag(String tag) {
      if (canRemove) {
        controller.removeTag(tag);
      }
    }

    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        final tags = (value as TagsEditingValue).tags;

        return Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...tags.map((tag) => tagBuilder(tag, () => removeTag(tag))),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 150, maxWidth: double.infinity),
              child: IntrinsicWidth(child: child),
            ),
          ],
        );
      },
    );
  }
}
