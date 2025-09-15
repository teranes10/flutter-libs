import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

class TTagsFieldTheme extends TTextFieldTheme {
  final double tagSpacing;
  final double tagRunSpacing;
  final EdgeInsets tagPadding;
  final double tagBorderRadius;
  final Color? tagBackgroundColor;
  final Color? tagTextColor;
  final double? tagFontSize;
  final FontWeight? tagFontWeight;
  final Color? tagIconColor;
  final double tagIconSize;
  final double minInputWidth;
  final double maxInputWidth;
  final Widget Function(String tag, VoidCallback onRemove)? tagBuilder;

  Widget buildTagChip(ColorScheme colors, String tag, VoidCallback onRemove) {
    if (tagBuilder != null) {
      return tagBuilder!(tag, onRemove);
    }

    return Container(
      padding: tagPadding,
      decoration: BoxDecoration(
        color: tagBackgroundColor ?? colors.surfaceContainer,
        borderRadius: BorderRadius.circular(tagBorderRadius),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                tag,
                style: TextStyle(
                  color: tagTextColor ?? colors.onSurfaceVariant,
                  fontSize: tagFontSize ?? fontSize ?? super.fontSize,
                  fontWeight: tagFontWeight,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 5.0),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: tagIconSize, color: tagIconColor ?? colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTagsField(ColorScheme colors, {List<String> tags = const [], Function(String)? onRemove, Widget? child}) {
    return Wrap(
      spacing: tagSpacing,
      runSpacing: tagRunSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...tags.map((tag) => buildTagChip(colors, tag, () => onRemove?.call(tag))),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 150, maxWidth: double.infinity),
          child: IntrinsicWidth(child: child),
        ),
      ],
    );
  }

  const TTagsFieldTheme({
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

    // Tag-specific properties
    this.tagSpacing = 6.0,
    this.tagRunSpacing = 6.0,
    this.tagPadding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
    this.tagBorderRadius = 5.0,
    this.tagBackgroundColor,
    this.tagTextColor,
    this.tagFontSize,
    this.tagFontWeight,
    this.tagIconColor,
    this.tagIconSize = 14.0,
    this.minInputWidth = 150.0,
    this.maxInputWidth = double.infinity,
    this.tagBuilder,
  });

  @override
  TTagsFieldTheme copyWith({
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

    // Tag-specific properties
    double? tagSpacing,
    double? tagRunSpacing,
    EdgeInsets? tagPadding,
    double? tagBorderRadius,
    Color? tagBackgroundColor,
    Color? tagTextColor,
    double? tagFontSize,
    FontWeight? tagFontWeight,
    Color? tagIconColor,
    double? tagIconSize,
    double? minInputWidth,
    double? maxInputWidth,
    Widget Function(String tag, VoidCallback onRemove)? tagBuilder,
  }) {
    return TTagsFieldTheme(
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

      // Tag-specific properties
      tagSpacing: tagSpacing ?? this.tagSpacing,
      tagRunSpacing: tagRunSpacing ?? this.tagRunSpacing,
      tagPadding: tagPadding ?? this.tagPadding,
      tagBorderRadius: tagBorderRadius ?? this.tagBorderRadius,
      tagBackgroundColor: tagBackgroundColor ?? this.tagBackgroundColor,
      tagTextColor: tagTextColor ?? this.tagTextColor,
      tagFontSize: tagFontSize ?? this.tagFontSize,
      tagFontWeight: tagFontWeight ?? this.tagFontWeight,
      tagIconColor: tagIconColor ?? this.tagIconColor,
      tagIconSize: tagIconSize ?? this.tagIconSize,
      minInputWidth: minInputWidth ?? this.minInputWidth,
      maxInputWidth: maxInputWidth ?? this.maxInputWidth,
      tagBuilder: tagBuilder ?? this.tagBuilder,
    );
  }
}
