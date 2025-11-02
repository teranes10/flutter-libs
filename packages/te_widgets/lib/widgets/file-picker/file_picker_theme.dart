import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

typedef FileTagBuilder = Widget Function(TFile file, VoidCallback onRemove);

class TFilePickerTheme extends TInputFieldTheme {
  final WidgetStateProperty<TextStyle> hintStyle;
  final FileTagBuilder fileTagBuilder;

  const TFilePickerTheme({
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
    required this.fileTagBuilder,
    required this.hintStyle,
    super.size = TInputSize.md,
    super.decorationType,
    super.preWidget,
    super.postWidget,
    super.height,
    super.padding,
    super.fontSize,
  });

  @override
  TFilePickerTheme copyWith({
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
    Widget? preWidget,
    Widget? postWidget,
    double? height,
    EdgeInsets? padding,
    double? fontSize,
    FileTagBuilder? fileTagBuilder,
    WidgetStateProperty<TextStyle>? hintStyle,
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
      preWidget: preWidget,
      postWidget: postWidget,
      height: height,
      padding: padding,
      fontSize: fontSize,
    );

    return TFilePickerTheme(
      // Base properties from parent
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

      // File picker-specific properties
      fileTagBuilder: fileTagBuilder ?? this.fileTagBuilder,
      hintStyle: hintStyle ?? this.hintStyle,
    );
  }

  factory TFilePickerTheme.defaultTheme(ColorScheme colors) {
    final baseTheme = TInputFieldTheme.defaultTheme(colors);

    return TFilePickerTheme(
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
      fileTagBuilder: (file, onRemove) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(5.0)),
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getFileIcon(file.extension, colors),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    file.name,
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: baseTheme.fieldFontSize, fontWeight: FontWeight.w400),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 5.0),
                InkWell(
                  onTap: onRemove,
                  child: Icon(Icons.close, size: 14, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
      hintStyle: WidgetStateProperty.all(TextStyle(fontSize: baseTheme.fieldFontSize, color: colors.onSurfaceVariant.withAlpha(150))),
    );
  }

  Widget buildFilesField(
      {required Set<WidgetState> states, required List<TFile> files, String? placeholder, ValueChanged<TFile>? onRemove}) {
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (files.isEmpty && placeholder != null && placeholder.isNotEmpty) Text(placeholder, style: hintStyle.resolve(states)),
        ...files.map((file) => fileTagBuilder(file, () => onRemove?.call(file))),
      ],
    );
  }

  static Widget _getFileIcon(String extension, ColorScheme colors) {
    final iconData = switch (extension.toLowerCase()) {
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
      color: colors.onSurfaceVariant.withAlpha(180),
    );
  }

  static bool isImageFile(String extension) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(extension.toLowerCase());
  }
}
