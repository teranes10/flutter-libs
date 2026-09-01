import 'package:flutter/material.dart';
import 'package:te_widgets/configs/widget-theme/no_gap_outline_border.dart';
import 'package:te_widgets/te_widgets.dart';

enum TInputDecorationType { underline, filled, outline, none }

enum TLabelPosition { aboveField, floating, inlineFloating }

typedef LabelBuilder = Widget Function(String? label, String? tag, bool isRequired, Widget? infoIcon);
typedef HelperTextBuilder = Widget Function(String? helperText);
typedef ErrorsBuilder = Widget Function(List<String>? errors);

const TInputSize defaultInputSize = TInputSize.md;
const TInputDecorationType defaultInputDecorationType = TInputDecorationType.outline;
const TLabelPosition defaultLabelPosition = TLabelPosition.inlineFloating;

@immutable
class TInputFieldTheme {
  // Core Configuration
  final TInputSize size;
  final TInputDecorationType decorationType;
  final TLabelPosition labelPosition;

  // State-based Properties
  final WidgetStateProperty<Color> color;
  final WidgetStateProperty<Color>? backgroundColor;
  final WidgetStateProperty<Color> borderColor;
  final WidgetStateProperty<TextStyle> labelStyle;
  final WidgetStateProperty<TextStyle> floatingLabelStyle;
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

  EdgeInsets get fieldPadding {
    final v = padding ?? size.padding;
    return decorationType == TInputDecorationType.underline
        ? v.copyWith(
            top: 0,
            bottom: v.bottom,
          )
        : labelPosition == TLabelPosition.inlineFloating
            ? v.copyWith(
                top: v.top / 1.2,
                bottom: v.bottom / 1.2,
              )
            : v;
  }

  double get fieldFontSize => fontSize ?? size.fontSize;

  const TInputFieldTheme({
    required this.color,
    this.backgroundColor,
    required this.borderColor,
    required this.labelStyle,
    required this.floatingLabelStyle,
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
    WidgetStateProperty<TextStyle>? floatingLabelStyle,
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
    final newLabelStyle = labelStyle ?? this.labelStyle;
    final newFloatingLabelStyle = floatingLabelStyle ?? this.floatingLabelStyle;
    final newHelperTextStyle = helperTextStyle ?? this.helperTextStyle;
    final newErrorTextStyle = errorTextStyle ?? this.errorTextStyle;
    final newTagStyle = tagStyle ?? this.tagStyle;
    final newPadding = padding ?? this.padding ?? size?.padding ?? fieldPadding;
    final shouldRebuildLabel = labelStyle != null || tagStyle != null || errorTextStyle != null || backgroundColor != null;

    return TInputFieldTheme(
      decorationType: decorationType ?? this.decorationType,
      labelPosition: labelPosition ?? this.labelPosition,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      labelStyle: newLabelStyle,
      floatingLabelStyle: newFloatingLabelStyle,
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
          (shouldRebuildLabel ? buildDefaultLabelBuilder(newLabelStyle, newTagStyle, newErrorTextStyle) : this.labelBuilder),
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

    final borderColor = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.error)) return colors.error;
      if (states.contains(WidgetState.focused)) return colors.primary;
      if (states.contains(WidgetState.disabled)) return colors.outlineVariant;
      return colors.outline;
    });

    final labelStyle = WidgetStateProperty.resolveWith((states) {
      return TextStyle(
        fontSize: labelPosition == TLabelPosition.aboveField ? 12.0 : size.fontSize,
        fontWeight: FontWeight.w500,
        color: states.contains(WidgetState.disabled)
            ? colors.onSurfaceVariant
            : states.contains(WidgetState.error)
                ? colors.error
                : colors.onSurfaceVariant,
      );
    });

    final floatingLabelStyle = WidgetStateProperty.resolveWith((states) {
      final baseFontSize = labelPosition == TLabelPosition.aboveField ? 12.0 : size.fontSize;
      return TextStyle(
        fontSize: labelPosition == TLabelPosition.inlineFloating ? baseFontSize * 1.25 : baseFontSize,
        fontWeight: FontWeight.w500,
        color: states.contains(WidgetState.disabled)
            ? colors.onSurfaceVariant
            : states.contains(WidgetState.error)
                ? colors.error
                : states.contains(WidgetState.focused)
                    ? colors.primary
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
      borderColor: borderColor,
      labelStyle: labelStyle,
      floatingLabelStyle: floatingLabelStyle,
      helperTextStyle: helperTextStyle,
      errorTextStyle: errorTextStyle,
      tagStyle: labelStyle,
      hintStyle: WidgetStateProperty.all(TextStyle(color: colors.onSurfaceVariant.withAlpha(150))),
      labelBuilder: buildDefaultLabelBuilder(labelStyle, labelStyle, errorTextStyle),
      helperTextBuilder: _buildHelperTextBuilder(helperTextStyle, size.padding),
      errorsBuilder: _buildErrorsBuilder(errorTextStyle, size.padding),
    );
  }

  static Color _defaultBackgroundColor(TInputDecorationType decorationType, Set<WidgetState> states, BuildContext context) {
    final colors = context.colors;
    final parentColor = context.getBackgroundColor(colors.surface);

    if (decorationType == TInputDecorationType.filled) {
      return states.contains(WidgetState.disabled)
          ? parentColor
          : states.contains(WidgetState.error)
              ? colors.errorContainer
              : parentColor.adaptiveContrast(context, 0.025);
    }

    return states.contains(WidgetState.disabled) ? parentColor.adaptiveContrast(context, 0.025) : parentColor;
  }

  InputBorder buildInputBorder(Set<WidgetState> states) {
    final rBorderSide = BorderSide(color: borderColor.resolve(states), width: borderWidth.resolve(states));
    final rBorderRadius = BorderRadius.circular(borderRadius.resolve(states));

    if (labelPosition == TLabelPosition.inlineFloating && decorationType == TInputDecorationType.outline) {
      return TNoGapOutlineBorder(borderSide: rBorderSide, borderRadius: rBorderRadius);
    }

    if (labelPosition == TLabelPosition.inlineFloating && decorationType == TInputDecorationType.filled) {
      return TNoGapOutlineBorder(borderSide: BorderSide.none, borderRadius: rBorderRadius);
    }

    return switch (decorationType) {
      TInputDecorationType.underline => UnderlineInputBorder(borderSide: rBorderSide, borderRadius: BorderRadius.zero),
      TInputDecorationType.outline => OutlineInputBorder(borderSide: rBorderSide, borderRadius: rBorderRadius),
      TInputDecorationType.filled ||
      TInputDecorationType.none =>
        OutlineInputBorder(borderSide: BorderSide.none, borderRadius: rBorderRadius)
    };
  }

  InputDecoration buildInputDecoration(
    BuildContext context,
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
    FloatingLabelAlignment? labelAlignment,
  }) {
    final inputBorder = buildInputBorder(states);

    final isFilled = decorationType == TInputDecorationType.filled;

    final fillColor = backgroundColor != null ? backgroundColor!.resolve(states) : _defaultBackgroundColor(decorationType, states, context);

    return InputDecoration(
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedErrorBorder: inputBorder,
      disabledBorder: inputBorder,
      focusedBorder: inputBorder,
      errorBorder: inputBorder,
      contentPadding: fieldPadding,
      constraints: BoxConstraints(
        minHeight: fieldHeight,
        maxHeight: expands ? double.infinity : fieldHeight,
      ),
      label: labelPosition == TLabelPosition.aboveField ? null : labelBuilder.resolve(states)(label, tag, isRequired, null),
      labelStyle: labelStyle.resolve(states),
      floatingLabelStyle: floatingLabelStyle.resolve(states),
      floatingLabelAlignment: labelAlignment,
      floatingLabelBehavior: switch (labelPosition) {
        TLabelPosition.aboveField => FloatingLabelBehavior.never,
        TLabelPosition.floating || TLabelPosition.inlineFloating => FloatingLabelBehavior.auto,
      },
      isDense: true,
      visualDensity: VisualDensity.compact,
      hintText: placeholder,
      hintStyle: hintStyle.resolve(states),
      prefixIconConstraints: BoxConstraints(minHeight: fieldHeight - fieldPadding.vertical, minWidth: fieldPadding.left),
      prefixIcon: _buildPreWidget(beforePreWidget),
      suffixIconConstraints: BoxConstraints(minHeight: fieldHeight - fieldPadding.vertical, minWidth: fieldPadding.right),
      suffixIcon: _buildPostWidget(
        beforePostWidget: beforePostWidget,
        onClear: onClear,
        infoIcon: labelPosition == TLabelPosition.floating || labelPosition == TLabelPosition.inlineFloating ? infoIcon : null,
      ),
      filled: isFilled,
      fillColor: fillColor,
      focusColor: fillColor,
      hoverColor: fillColor,
    );
  }

  Widget? _buildPreWidget(Widget? beforePreWidget) {
    final children = [
      if (beforePreWidget != null) _buildPaddedWidget(beforePreWidget, isPrefix: true),
      if (preWidget != null) _buildPaddedWidget(preWidget!, isPrefix: true),
    ];

    if (children.isEmpty) return null;

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget buildInfoIcon(String info, ColorScheme colors) {
    return TTooltip(
      message: info,
      color: colors.onSurfaceVariant,
      triggerMode: TTooltipTriggerMode.adaptive,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: TIcon.raw(HugeIcons.strokeRoundedInformationCircle, size: 14, color: colors.onSurfaceVariant.withAlpha(200)),
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

    if (children.isEmpty) return null;

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildPaddedWidget(Widget widget, {required bool isPrefix}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isPrefix ? fieldPadding.left : fieldPadding.left * 0.5,
        right: isPrefix ? fieldPadding.right * 0.5 : fieldPadding.right,
      ),
      child: widget,
    );
  }

  static WidgetStateProperty<LabelBuilder> buildDefaultLabelBuilder(
    WidgetStateProperty<TextStyle> labelStyle,
    WidgetStateProperty<TextStyle> tagStyle,
    WidgetStateProperty<TextStyle> errorTextStyle,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 3,
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
          padding: EdgeInsets.only(top: 4.0),
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
