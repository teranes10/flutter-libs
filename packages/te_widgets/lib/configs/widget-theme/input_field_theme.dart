import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TInputDecorationType { box, underline, filled, outline, none }

typedef LabelBuilder = Widget Function(String? label, String? tag, bool isRequired);
typedef HelperTextBuilder = Widget Function(String? helperText);
typedef ErrorsBuilder = Widget Function(List<String> errors);

@immutable
class TInputFieldTheme {
  // Core Configuration
  final TInputSize size;
  final TInputDecorationType decorationType;

  // State-based Properties
  final WidgetStateProperty<Color> color;
  final WidgetStateProperty<Color> backgroundColor;
  final WidgetStateProperty<Color> borderColor;
  final WidgetStateProperty<TextStyle> labelStyle;
  final WidgetStateProperty<TextStyle> helperTextStyle;
  final WidgetStateProperty<TextStyle> errorTextStyle;
  final WidgetStateProperty<TextStyle> tagStyle;
  final WidgetStateProperty<double> borderWidth;
  final WidgetStateProperty<double> borderRadius;
  final WidgetStateProperty<BoxDecoration> decoration;
  final WidgetStateProperty<LabelBuilder> labelBuilder;
  final WidgetStateProperty<HelperTextBuilder> helperTextBuilder;
  final WidgetStateProperty<ErrorsBuilder> errorsBuilder;

  // Static Widget Properties
  final Widget? preWidget;
  final Widget? postWidget;

  // Dimension Overrides
  final double? height;
  final EdgeInsets? padding;
  final double? fontSize;

  // Computed Properties
  double get fieldHeight => height ?? size.height;
  EdgeInsets get fieldPadding => padding ?? size.padding;
  double get fieldFontSize => fontSize ?? size.fontSize;

  const TInputFieldTheme({
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.labelStyle,
    required this.helperTextStyle,
    required this.errorTextStyle,
    required this.tagStyle,
    required this.decoration,
    required this.borderRadius,
    required this.borderWidth,
    required this.labelBuilder,
    required this.helperTextBuilder,
    required this.errorsBuilder,
    this.preWidget,
    this.postWidget,
    this.height,
    this.padding,
    this.fontSize,
    this.size = TInputSize.md,
    this.decorationType = TInputDecorationType.box,
  });

  TInputFieldTheme copyWith({
    TInputSize? size,
    Widget? preWidget,
    Widget? postWidget,
    double? height,
    EdgeInsets? padding,
    double? fontSize,
    TInputDecorationType? decorationType,
    WidgetStateProperty<Color>? color,
    WidgetStateProperty<Color>? backgroundColor,
    WidgetStateProperty<Color>? borderColor,
    WidgetStateProperty<TextStyle>? labelStyle,
    WidgetStateProperty<TextStyle>? helperTextStyle,
    WidgetStateProperty<TextStyle>? errorTextStyle,
    WidgetStateProperty<TextStyle>? tagStyle,
    WidgetStateProperty<double>? borderRadius,
    WidgetStateProperty<double>? borderWidth,
    WidgetStateProperty<BoxDecoration>? decoration,
    WidgetStateProperty<LabelBuilder>? labelBuilder,
    WidgetStateProperty<HelperTextBuilder>? helperTextBuilder,
    WidgetStateProperty<ErrorsBuilder>? errorsBuilder,
  }) {
    final newDecorationType = decorationType ?? this.decorationType;
    final newBackgroundColor = backgroundColor ?? this.backgroundColor;
    final newBorderColor = borderColor ?? this.borderColor;
    final newBorderWidth = borderWidth ?? this.borderWidth;
    final newBorderRadius = borderRadius ?? this.borderRadius;
    final newLabelStyle = labelStyle ?? this.labelStyle;
    final newHelperTextStyle = helperTextStyle ?? this.helperTextStyle;
    final newErrorTextStyle = errorTextStyle ?? this.errorTextStyle;
    final newTagStyle = tagStyle ?? this.tagStyle;

    final shouldRebuildDecoration =
        decorationType != null || borderWidth != null || borderRadius != null || backgroundColor != null || borderColor != null;

    final shouldRebuildLabel = labelStyle != null || tagStyle != null || errorTextStyle != null || backgroundColor != null;

    return TInputFieldTheme(
      decorationType: newDecorationType,
      backgroundColor: newBackgroundColor,
      borderColor: newBorderColor,
      labelStyle: newLabelStyle,
      helperTextStyle: newHelperTextStyle,
      errorTextStyle: newErrorTextStyle,
      tagStyle: newTagStyle,
      size: size ?? this.size,
      color: color ?? this.color,
      preWidget: preWidget ?? this.preWidget,
      postWidget: postWidget ?? this.postWidget,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      fontSize: fontSize ?? this.fontSize,
      borderRadius: newBorderRadius,
      borderWidth: newBorderWidth,
      decoration: decoration ??
          (shouldRebuildDecoration
              ? _createDecoration(newDecorationType, newBorderWidth, newBorderRadius, newBackgroundColor, newBorderColor)
              : this.decoration),
      labelBuilder: labelBuilder ??
          (shouldRebuildLabel ? _createLabelBuilder(newLabelStyle, newTagStyle, newErrorTextStyle, newBackgroundColor) : this.labelBuilder),
      helperTextBuilder:
          helperTextBuilder ?? (helperTextStyle != null ? _createHelperTextBuilder(newHelperTextStyle) : this.helperTextBuilder),
      errorsBuilder: errorsBuilder ?? (errorTextStyle != null ? _createErrorsBuilder(newErrorTextStyle) : this.errorsBuilder),
    );
  }

  factory TInputFieldTheme.defaultTheme(ColorScheme colors, {TInputDecorationType decorationType = TInputDecorationType.box}) {
    final color = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.error)) return colors.error;
      if (states.contains(WidgetState.focused)) return colors.primary;
      if (states.contains(WidgetState.disabled)) return colors.outlineVariant;
      return colors.outline;
    });

    final backgroundColor = WidgetStateProperty.resolveWith((states) {
      if (decorationType == TInputDecorationType.filled) {
        return states.contains(WidgetState.disabled) ? colors.surfaceDim.withAlpha(50) : colors.surfaceContainer;
      }
      return states.contains(WidgetState.disabled) ? colors.surfaceDim.withAlpha(50) : colors.surface;
    });

    final borderColor = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.error)) return colors.error;
      if (states.contains(WidgetState.focused)) return colors.primary;
      if (states.contains(WidgetState.disabled)) return colors.outlineVariant;
      return colors.outline;
    });

    final labelStyle = WidgetStateProperty.resolveWith((states) {
      final isDisabled = states.contains(WidgetState.disabled);
      return TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: isDisabled ? colors.onSurfaceVariant.withAlpha(100) : colors.onSurfaceVariant,
      );
    });

    final helperTextStyle = WidgetStateProperty.all(
      TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w300,
        color: colors.onSurfaceVariant.withAlpha(200),
      ),
    );

    final errorTextStyle = WidgetStateProperty.all(TextStyle(fontSize: 12.0, color: colors.error));

    final tagStyle = WidgetStateProperty.all(TextStyle(fontSize: 11.0, fontWeight: FontWeight.w300, color: colors.onSurfaceVariant));

    final borderWidth = WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.focused) ? 2.0 : 1.0);

    final borderRadius = WidgetStateProperty.resolveWith((states) {
      return switch (decorationType) {
        TInputDecorationType.outline => 12.0,
        TInputDecorationType.filled => 8.0,
        TInputDecorationType.underline => 0.0,
        TInputDecorationType.none => 0.0,
        TInputDecorationType.box => 6.0,
      };
    });

    return TInputFieldTheme(
      size: TInputSize.md,
      decorationType: decorationType,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      color: color,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      labelStyle: labelStyle,
      helperTextStyle: helperTextStyle,
      errorTextStyle: errorTextStyle,
      tagStyle: tagStyle,
      decoration: _createDecoration(decorationType, borderWidth, borderRadius, backgroundColor, borderColor),
      labelBuilder: _createLabelBuilder(labelStyle, tagStyle, errorTextStyle, backgroundColor),
      helperTextBuilder: _createHelperTextBuilder(helperTextStyle),
      errorsBuilder: _createErrorsBuilder(errorTextStyle),
    );
  }

  Widget buildContainer(
    Set<WidgetState> states, {
    required Widget? child,
    Widget? additionalPostWidget,
    Widget? additionalPreWidget,
    String? label,
    String? tag,
    String? helperText,
    List<String>? errors,
    bool isRequired = false,
    bool isMultiline = false,
    bool block = true,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelBuilder.resolve(states)(label, tag, isRequired),
        Container(
          constraints: BoxConstraints(minHeight: fieldHeight, maxHeight: isMultiline ? double.infinity : fieldHeight),
          decoration: decoration.resolve(states),
          child: Row(
            mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (preWidget != null) _buildPaddedWidget(preWidget!, isPrefix: true),
              if (additionalPreWidget != null) _buildPaddedWidget(additionalPreWidget, isPrefix: true),
              block ? Expanded(child: Padding(padding: fieldPadding, child: child)) : Padding(padding: fieldPadding, child: child),
              if (additionalPostWidget != null) _buildPaddedWidget(additionalPostWidget, isPrefix: false),
              if (postWidget != null) _buildPaddedWidget(postWidget!, isPrefix: false),
            ],
          ),
        ),
        helperTextBuilder.resolve(states)(helperText),
        if (errors != null && errors.isNotEmpty) errorsBuilder.resolve(states)(errors),
      ],
    );
  }

  Widget _buildPaddedWidget(Widget widget, {required bool isPrefix}) {
    return Padding(
      padding: EdgeInsets.only(
        top: fieldPadding.top,
        bottom: fieldPadding.bottom,
        left: isPrefix ? fieldPadding.left : 0,
        right: isPrefix ? 0 : fieldPadding.right,
      ),
      child: Center(child: widget),
    );
  }

  static WidgetStateProperty<BoxDecoration> _createDecoration(
    TInputDecorationType decorationType,
    WidgetStateProperty<double> borderWidth,
    WidgetStateProperty<double> borderRadius,
    WidgetStateProperty<Color> backgroundColor,
    WidgetStateProperty<Color> borderColor,
  ) {
    return WidgetStateProperty.resolveWith((states) {
      final isFocused = states.contains(WidgetState.focused);
      final bWidth = borderWidth.resolve(states);
      final bRadius = borderRadius.resolve(states);
      final bColor = borderColor.resolve(states);
      final bgColor = backgroundColor.resolve(states);

      final focusShadow = isFocused ? [BoxShadow(color: bColor.withAlpha(100), blurRadius: 4.0, offset: const Offset(0, 2))] : null;

      return switch (decorationType) {
        TInputDecorationType.underline => BoxDecoration(
            border: Border(bottom: BorderSide(color: bColor, width: bWidth)),
            color: bgColor,
          ),
        TInputDecorationType.filled => BoxDecoration(
            borderRadius: BorderRadius.circular(bRadius),
            color: bgColor,
            border: isFocused ? Border.all(color: bColor, width: bWidth) : null,
          ),
        TInputDecorationType.outline => BoxDecoration(
            border: Border.all(color: bColor, width: bWidth),
            borderRadius: BorderRadius.circular(bRadius),
            color: Colors.transparent,
            boxShadow: focusShadow,
          ),
        TInputDecorationType.none => BoxDecoration(color: bgColor),
        TInputDecorationType.box => BoxDecoration(
            border: Border.all(color: bColor, width: bWidth),
            borderRadius: BorderRadius.circular(bRadius),
            color: bgColor,
            boxShadow: focusShadow,
          ),
      };
    });
  }

  static WidgetStateProperty<LabelBuilder> _createLabelBuilder(
    WidgetStateProperty<TextStyle> labelStyle,
    WidgetStateProperty<TextStyle> tagStyle,
    WidgetStateProperty<TextStyle> errorTextStyle,
    WidgetStateProperty<Color> backgroundColor,
  ) {
    return WidgetStateProperty.resolveWith((states) {
      return (label, tag, isRequired) {
        if (label == null && tag == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      text: label,
                      style: labelStyle.resolve(states),
                      children: isRequired ? [TextSpan(text: ' *', style: TextStyle(color: errorTextStyle.resolve(states).color))] : null,
                    ),
                  ),
                ),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: backgroundColor.resolve(states),
                  ),
                  child: Text(tag, style: tagStyle.resolve(states)),
                ),
            ],
          ),
        );
      };
    });
  }

  static WidgetStateProperty<HelperTextBuilder> _createHelperTextBuilder(
    WidgetStateProperty<TextStyle> helperTextStyle,
  ) {
    return WidgetStateProperty.resolveWith((states) {
      return (helperText) {
        if (helperText == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(helperText, style: helperTextStyle.resolve(states)),
        );
      };
    });
  }

  static WidgetStateProperty<ErrorsBuilder> _createErrorsBuilder(
    WidgetStateProperty<TextStyle> errorTextStyle,
  ) {
    return WidgetStateProperty.resolveWith((states) {
      return (errors) {
        if (errors.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors
                .map(
                  (error) => Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text('• $error', style: errorTextStyle.resolve(states)),
                  ),
                )
                .toList(),
          ),
        );
      };
    });
  }
}
