import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TInputDecorationType { underline, filled, outline, none }

enum TLabelPosition { aboveField, floating }

typedef LabelBuilder = Widget Function(String? label, String? tag, bool isRequired, Widget? infoIcon);
typedef HelperTextBuilder = Widget Function(String? helperText);
typedef ErrorsBuilder = Widget Function(List<String>? errors);

const TInputSize defaultInputSize = TInputSize.md;
const TInputDecorationType defaultInputDecorationType = TInputDecorationType.filled;
const TLabelPosition defaultLabelPosition = TLabelPosition.floating;

@immutable
class TInputFieldTheme {
  // Core Configuration
  final TInputSize size;
  final TInputDecorationType decorationType;
  final TLabelPosition labelPosition;

  // State-based Properties
  final WidgetStateProperty<Color> color;
  final WidgetStateProperty<Color> backgroundColor;
  final WidgetStateProperty<Color> borderColor;
  final WidgetStateProperty<TextStyle> labelStyle;
  final WidgetStateProperty<TextStyle> helperTextStyle;
  final WidgetStateProperty<TextStyle> errorTextStyle;
  final WidgetStateProperty<TextStyle> tagStyle;
  final WidgetStateProperty<TextStyle> hintStyle;
  final WidgetStateProperty<double> borderWidth;
  final WidgetStateProperty<double> borderRadius;
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
    required this.hintStyle,
    required this.borderRadius,
    required this.borderWidth,
    required this.labelBuilder,
    required this.errorsBuilder,
    required this.helperTextBuilder,
    this.preWidget,
    this.postWidget,
    this.height,
    this.padding,
    this.fontSize,
    required this.size,
    required this.decorationType,
    required this.labelPosition,
  });

  TInputFieldTheme copyWith({
    TInputSize? size,
    Widget? preWidget,
    Widget? postWidget,
    double? height,
    EdgeInsets? padding,
    double? fontSize,
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
  }) {
    final newBackgroundColor = backgroundColor ?? this.backgroundColor;
    final newLabelStyle = labelStyle ?? this.labelStyle;
    final newHelperTextStyle = helperTextStyle ?? this.helperTextStyle;
    final newErrorTextStyle = errorTextStyle ?? this.errorTextStyle;
    final newTagStyle = tagStyle ?? this.tagStyle;
    final newPadding = padding ?? this.padding ?? size?.padding ?? fieldPadding;
    final shouldRebuildLabel = labelStyle != null || tagStyle != null || errorTextStyle != null || backgroundColor != null;

    return TInputFieldTheme(
      decorationType: decorationType ?? this.decorationType,
      labelPosition: labelPosition ?? this.labelPosition,
      backgroundColor: newBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      labelStyle: newLabelStyle,
      helperTextStyle: newHelperTextStyle,
      errorTextStyle: newErrorTextStyle,
      tagStyle: newTagStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      size: size ?? this.size,
      color: color ?? this.color,
      preWidget: preWidget ?? this.preWidget,
      postWidget: postWidget ?? this.postWidget,
      height: height ?? this.height,
      padding: newPadding,
      fontSize: fontSize ?? this.fontSize,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      labelBuilder: labelBuilder ??
          (shouldRebuildLabel ? _buildLabelBuilder(newLabelStyle, newTagStyle, newErrorTextStyle, newBackgroundColor) : this.labelBuilder),
      helperTextBuilder:
          helperTextBuilder ?? (helperTextStyle != null ? _buildHelperTextBuilder(newHelperTextStyle, newPadding) : this.helperTextBuilder),
      errorsBuilder: errorsBuilder ?? (errorTextStyle != null ? _buildErrorsBuilder(newErrorTextStyle, newPadding) : this.errorsBuilder),
    );
  }

  factory TInputFieldTheme.defaultTheme(
    ColorScheme colors, {
    TInputSize size = defaultInputSize,
    TInputDecorationType decorationType = defaultInputDecorationType,
    TLabelPosition labelPosition = defaultLabelPosition,
  }) {
    final color = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.error)) return colors.error;
      if (states.contains(WidgetState.focused)) return colors.primary;
      if (states.contains(WidgetState.disabled)) return colors.outlineVariant;
      return colors.outline;
    });

    final backgroundColor = WidgetStateProperty.resolveWith((states) {
      if (decorationType == TInputDecorationType.filled) {
        return states.contains(WidgetState.disabled)
            ? colors.surface
            : states.contains(WidgetState.error)
                ? colors.errorContainer
                : colors.surfaceContainerLowest;
      }
      return states.contains(WidgetState.disabled) ? colors.surfaceContainerLowest : colors.surface;
    });

    final borderColor = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.error)) return colors.error;
      if (states.contains(WidgetState.focused)) return colors.primary;
      if (states.contains(WidgetState.disabled)) return colors.outlineVariant;
      return colors.outline;
    });

    final labelStyle = WidgetStateProperty.resolveWith((states) {
      return TextStyle(
        fontSize: labelPosition == TLabelPosition.aboveField ? 12.0 : 14.0,
        fontWeight: FontWeight.w500,
        color: states.contains(WidgetState.disabled)
            ? colors.onSurfaceVariant
            : states.contains(WidgetState.error)
                ? colors.error
                : colors.onSurfaceVariant,
      );
    });

    final helperTextStyle =
        WidgetStateProperty.all(TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300, color: colors.onSurfaceVariant.withAlpha(200)));

    final errorTextStyle = WidgetStateProperty.all(TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300, color: colors.error));

    final borderWidth = WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.focused) ? 2.0 : 1.0);

    final borderRadius = WidgetStateProperty.resolveWith((states) {
      return switch (decorationType) {
        TInputDecorationType.outline => 8.0,
        TInputDecorationType.filled => 8.0,
        TInputDecorationType.underline => 0.0,
        TInputDecorationType.none => 0.0,
      };
    });

    return TInputFieldTheme(
      size: size,
      decorationType: decorationType,
      labelPosition: labelPosition,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      color: color,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      labelStyle: labelStyle,
      helperTextStyle: helperTextStyle,
      errorTextStyle: errorTextStyle,
      tagStyle: labelStyle,
      hintStyle: WidgetStateProperty.all(TextStyle(color: colors.onSurfaceVariant.withAlpha(150))),
      labelBuilder: _buildLabelBuilder(labelStyle, labelStyle, errorTextStyle, backgroundColor),
      helperTextBuilder: _buildHelperTextBuilder(helperTextStyle, size.padding),
      errorsBuilder: _buildErrorsBuilder(errorTextStyle, size.padding),
    );
  }

  InputBorder buildInputBorder(Set<WidgetState> states) {
    final rBorderSide = BorderSide(color: borderColor.resolve(states), width: borderWidth.resolve(states));
    final rBorderRadius = BorderRadius.circular(borderRadius.resolve(states));

    return switch (decorationType) {
      TInputDecorationType.underline => UnderlineInputBorder(borderSide: rBorderSide, borderRadius: rBorderRadius),
      TInputDecorationType.outline => OutlineInputBorder(borderSide: rBorderSide, borderRadius: rBorderRadius),
      TInputDecorationType.filled ||
      TInputDecorationType.none =>
        OutlineInputBorder(borderSide: BorderSide.none, borderRadius: rBorderRadius)
    };
  }

  InputDecoration buildInputDecoration(
    Set<WidgetState> states, {
    bool expands = false,
    Widget? beforePostWidget,
    Widget? beforePreWidget,
    String? label,
    String? placeholder,
    String? tag,
    String? helperText,
    List<String>? errors,
    bool isRequired = false,
    VoidCallback? onClear,
    Widget? infoIcon,
  }) {
    final inputBorder = buildInputBorder(states);

    final hasPrefix = beforePreWidget != null || preWidget != null;
    final hasSuffix = onClear != null || beforePostWidget != null || infoIcon != null || postWidget != null;

    return InputDecoration(
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedErrorBorder: inputBorder,
      disabledBorder: inputBorder,
      focusedBorder: inputBorder,
      errorBorder: inputBorder,
      contentPadding: fieldPadding,
      label: labelPosition == TLabelPosition.aboveField ? null : labelBuilder.resolve(states)(label, tag, isRequired, null),
      labelStyle: labelStyle.resolve(states),
      floatingLabelStyle: labelStyle.resolve(states),
      floatingLabelBehavior: switch (labelPosition) {
        TLabelPosition.aboveField => FloatingLabelBehavior.never,
        TLabelPosition.floating => FloatingLabelBehavior.auto,
      },
      isDense: true,
      visualDensity: VisualDensity.compact,
      hintText: placeholder,
      hintStyle: hintStyle.resolve(states),
      prefixIconConstraints: BoxConstraints(minHeight: fieldHeight, minWidth: hasPrefix ? 40 : 7.5),
      prefixIcon: _buildPreWidget(beforePreWidget),
      suffixIconConstraints: BoxConstraints(minHeight: fieldHeight, minWidth: hasSuffix ? 40 : 7.5),
      suffixIcon: _buildPostWidget(
          beforePostWidget: beforePostWidget, onClear: onClear, infoIcon: labelPosition == TLabelPosition.floating ? infoIcon : null),
      filled: decorationType == TInputDecorationType.filled,
      fillColor: backgroundColor.resolve(states),
    );
  }

  Widget? _buildPreWidget(Widget? beforePreWidget) {
    if (preWidget != null && beforePreWidget != null) {
      return Row(
          mainAxisSize: MainAxisSize.min,
          children: [_buildPaddedWidget(beforePreWidget, isPrefix: true), _buildPaddedWidget(preWidget!, isPrefix: true)]);
    } else if (preWidget != null) {
      return _buildPaddedWidget(preWidget!, isPrefix: true);
    } else if (beforePreWidget != null) {
      return _buildPaddedWidget(beforePreWidget, isPrefix: true);
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildInfoIcon(String info, ColorScheme colors) {
    return TTooltip(
      message: info,
      color: colors.onSurfaceVariant,
      triggerMode: TTooltipTriggerMode.adaptive,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(Icons.info_outline, size: 16, color: colors.onSurfaceVariant.withAlpha(200)),
      ),
    );
  }

  Widget? _buildPostWidget({Widget? beforePostWidget, VoidCallback? onClear, Widget? infoIcon}) {
    final children = [
      if (onClear != null)
        _buildPaddedWidget(
            TIcon.close(
              onTap: onClear,
              size: fieldFontSize + 3,
              padding: EdgeInsets.fromLTRB(6, 6, 2, 6),
            ),
            isPrefix: false),
      if (beforePostWidget != null) _buildPaddedWidget(beforePostWidget, isPrefix: false),
      if (infoIcon != null) _buildPaddedWidget(infoIcon, isPrefix: false),
      if (postWidget != null) _buildPaddedWidget(postWidget!, isPrefix: false)
    ];

    if (children.isEmpty) return SizedBox.shrink();
    if (children.length == 1) return children[0];

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildPaddedWidget(Widget widget, {required bool isPrefix}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isPrefix ? fieldPadding.left : 0,
        right: isPrefix ? 0 : fieldPadding.right,
      ),
      child: widget,
    );
  }

  static WidgetStateProperty<LabelBuilder> _buildLabelBuilder(
    WidgetStateProperty<TextStyle> labelStyle,
    WidgetStateProperty<TextStyle> tagStyle,
    WidgetStateProperty<TextStyle> errorTextStyle,
    WidgetStateProperty<Color> backgroundColor,
  ) {
    return WidgetStateProperty.resolveWith((states) {
      return (label, tag, isRequired, infoIcon) {
        final children = [
          if (label != null)
            RichText(
              text: TextSpan(
                text: label,
                style: labelStyle.resolve(states),
                children: isRequired ? [TextSpan(text: ' *', style: TextStyle(color: errorTextStyle.resolve(states).color))] : null,
              ),
            ),
          if (tag != null) Text(tag, style: tagStyle.resolve(states)),
          if (infoIcon != null) infoIcon,
        ];

        if (children.isEmpty) return SizedBox.shrink();
        if (children.length == 1) return children[0];

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      };
    });
  }

  static WidgetStateProperty<HelperTextBuilder> _buildHelperTextBuilder(
      WidgetStateProperty<TextStyle> helperTextStyle, EdgeInsets padding) {
    return WidgetStateProperty.resolveWith((states) {
      return (helperText) {
        if (helperText.isNullOrBlank || states.contains(WidgetState.error)) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: 4.0, left: padding.left),
          child: Text(
            helperText!,
            style: helperTextStyle.resolve(states),
          ),
        );
      };
    });
  }

  static WidgetStateProperty<ErrorsBuilder> _buildErrorsBuilder(WidgetStateProperty<TextStyle> errorTextStyle, EdgeInsets padding) {
    return WidgetStateProperty.resolveWith((states) {
      return (errors) {
        if (errors == null || errors.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: 2.0, left: padding.left),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2.0,
            children: errors.map((error) => Text('• $error', style: errorTextStyle.resolve(states))).toList(),
          ),
        );
      };
    });
  }
}
