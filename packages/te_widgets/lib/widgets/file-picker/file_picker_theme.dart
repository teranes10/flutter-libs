import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/configs/widget-theme/input_field_theme.dart';
import 'package:te_widgets/widgets/file-picker/file_picker_config.dart';

class TFilePickerTheme extends TInputFieldTheme {
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
  final Widget Function(TFile file, VoidCallback onRemove)? tagBuilder;

  Widget buildTagChip(ColorScheme colors, TFile file, VoidCallback onRemove) {
    if (tagBuilder != null) {
      return tagBuilder!(file, onRemove);
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
            getFileIcon(file.extension, colors),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                file.name,
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

  Widget getFileIcon(String extension, ColorScheme colorScheme) {
    Color iconColor = Colors.grey;

    IconData iconData = switch (extension.toLowerCase()) {
      'pdf' => Icons.picture_as_pdf,
      'doc' || 'docx' => Icons.description,
      'xls' || 'xlsx' => Icons.table_chart,
      'ppt' || 'pptx' => Icons.slideshow,
      'jpg' || 'jpeg' || 'png' || 'gif' || 'bmp' || 'webp' => Icons.image,
      'mp4' || 'avi' || 'mov' || 'wmv' => Icons.video_file,
      'mp3' || 'wav' || 'aac' => Icons.audio_file,
      'zip' || 'rar' || '7z' => Icons.archive,
      'txt' => Icons.text_snippet,
      'json' => Icons.code,
      _ => Icons.insert_drive_file,
    };

    return Icon(
      iconData,
      size: 16.0,
      color: iconColor,
    );
  }

  bool isImageFile(String extension) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(extension.toLowerCase());
  }

  const TFilePickerTheme({
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
  TFilePickerTheme copyWith({
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
    Widget Function(TFile file, VoidCallback onRemove)? tagBuilder,
  }) {
    return TFilePickerTheme(
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
