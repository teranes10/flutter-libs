import 'package:flutter/material.dart';

enum TInputSize { sm, md, lg }

@immutable
class TInputContext {
  final ColorScheme colors;
  final TInputFieldTheme theme;
  final Set<WidgetState> states;

  const TInputContext({
    required this.colors,
    required this.theme,
    required this.states,
  });

  bool get isFocused => states.contains(WidgetState.focused);
  bool get isDisabled => states.contains(WidgetState.disabled);
  bool get isError => states.contains(WidgetState.error);
}

typedef LabelBuilder = Widget Function(TInputContext ctx, String? label, String? tag, bool isRequired);
typedef HelperTextBuilder = Widget Function(TInputContext ctx, String? helperText);
typedef ErrorsBuilder = Widget Function(TInputContext ctx, List<String> errors);
typedef BorderBuilder = Border Function(TInputContext ctx, Color color);
typedef BoxShadowBuilder = List<BoxShadow> Function(TInputContext ctx, Color color);
typedef DecorationBuilder = BoxDecoration Function(TInputContext state);

@immutable
class TInputFieldTheme {
  final TInputSize size;

  // Using WidgetStateProperty for state-dependent properties
  final WidgetStateProperty<Color?>? color;
  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? borderColor;

  // Static properties
  final Widget? preWidget;
  final Widget? postWidget;
  final double? height;
  final EdgeInsets? padding;
  final double? fontSize;
  final double? borderRadius;

  // Style properties for simple customization
  final WidgetStateProperty<TextStyle?>? labelStyle;
  final WidgetStateProperty<TextStyle?>? helperTextStyle;
  final WidgetStateProperty<TextStyle?>? errorTextStyle;
  final WidgetStateProperty<TextStyle?>? tagStyle;

  // Builders - only when you need custom logic
  final LabelBuilder? labelBuilder;
  final HelperTextBuilder? helperTextBuilder;
  final ErrorsBuilder? errorsBuilder;
  final BorderBuilder? borderBuilder;
  final BoxShadowBuilder? boxShadowBuilder;
  final DecorationBuilder? decorationBuilder;

  double get fieldHeight => height ?? size.height;
  EdgeInsets get fieldPadding => padding ?? size.padding;
  double get fieldFontSize => fontSize ?? size.fontSize;

  T? _resolve<T>(WidgetStateProperty<T>? property, Set<WidgetState> states) {
    return property?.resolve(states);
  }

  Widget buildLabel(TInputContext ctx, String? label, String? tag, bool isRequired) {
    if (labelBuilder != null) {
      return labelBuilder!(ctx, label, tag, isRequired);
    }

    if (label == null && tag == null) return const SizedBox.shrink();

    final resolvedLabelStyle = _resolve(labelStyle, ctx.states);
    final resolvedTagStyle = _resolve(tagStyle, ctx.states);

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
                  style: resolvedLabelStyle ??
                      TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: !ctx.isDisabled ? ctx.colors.onSurfaceVariant : ctx.colors.onSurfaceVariant.withAlpha(100)),
                  children: isRequired ? [TextSpan(text: ' *', style: TextStyle(color: ctx.colors.error))] : null,
                ),
              ),
            ),
          if (tag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: ctx.colors.surfaceContainer),
              child: Text(tag,
                  style: resolvedTagStyle ?? TextStyle(fontSize: 11.0, fontWeight: FontWeight.w300, color: ctx.colors.onSurfaceVariant)),
            ),
        ],
      ),
    );
  }

  Widget buildHelperText(TInputContext ctx, String? helperText) {
    if (helperTextBuilder != null) {
      return helperTextBuilder!(ctx, helperText);
    }

    if (helperText == null) return const SizedBox.shrink();

    final resolvedHelperStyle = _resolve(helperTextStyle, ctx.states);

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        helperText,
        style: resolvedHelperStyle ??
            TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300, color: ctx.colors.onSurfaceVariant.withAlpha(200)),
      ),
    );
  }

  Widget buildErrors(TInputContext ctx, List<String> errors) {
    if (errorsBuilder != null) {
      return errorsBuilder!(ctx, errors);
    }

    if (errors.isEmpty) return const SizedBox.shrink();

    final resolvedErrorStyle = _resolve(errorTextStyle, ctx.states);

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: errors
            .map(
              (error) => Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text('• $error', style: resolvedErrorStyle ?? TextStyle(fontSize: 12.0, color: ctx.colors.error))),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Border buildBorder(TInputContext ctx, Color color) {
    if (borderBuilder != null) {
      return borderBuilder!(ctx, color);
    }

    return Border.all(color: color, width: ctx.isFocused ? 2.0 : 1.0);
  }

  List<BoxShadow>? buildBoxShadow(TInputContext ctx, Color color) {
    if (boxShadowBuilder != null) {
      return boxShadowBuilder!(ctx, color);
    }

    return ctx.isFocused ? [BoxShadow(color: color.withAlpha(100), blurRadius: 4.0, offset: const Offset(0, 2))] : null;
  }

  BoxDecoration buildDecoration(TInputContext ctx) {
    if (decorationBuilder != null) {
      return decorationBuilder!(ctx);
    }

    final resolvedBorderColor = _resolve(borderColor, ctx.states);
    final resolvedBackgroundColor = _resolve(backgroundColor, ctx.states);
    final resolvedColor = _resolve(color, ctx.states);

    final currentBorderColor = resolvedBorderColor ??
        switch (ctx.states) {
          _ when ctx.isDisabled => ctx.colors.outlineVariant,
          _ when ctx.isError => ctx.colors.error,
          _ when ctx.isFocused => resolvedColor ?? ctx.colors.primary,
          _ => resolvedColor ?? ctx.colors.outline,
        };

    final currentBackgroundColor = resolvedBackgroundColor ?? (ctx.isDisabled ? ctx.colors.surfaceDim.withAlpha(50) : ctx.colors.surface);

    return BoxDecoration(
      border: buildBorder(ctx, currentBorderColor),
      borderRadius: BorderRadius.circular(borderRadius ?? 6.0),
      color: currentBackgroundColor,
      boxShadow: buildBoxShadow(ctx, currentBorderColor),
    );
  }

  Widget buildContainer(
    TInputContext ctx, {
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
        buildLabel(ctx, label, tag, isRequired),
        Container(
          constraints: BoxConstraints(
            minHeight: fieldHeight,
            maxHeight: isMultiline ? double.infinity : fieldHeight,
          ),
          decoration: buildDecoration(ctx),
          child: Row(
            mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (preWidget != null)
                Padding(
                  padding: EdgeInsets.only(
                    top: fieldPadding.top,
                    bottom: fieldPadding.bottom,
                    left: fieldPadding.left,
                  ),
                  child: Center(child: preWidget!),
                ),
              if (additionalPreWidget != null)
                Padding(
                  padding: EdgeInsets.only(
                    top: fieldPadding.top,
                    bottom: fieldPadding.bottom,
                    left: fieldPadding.left,
                  ),
                  child: Center(child: additionalPreWidget),
                ),
              block ? Expanded(child: Padding(padding: fieldPadding, child: child)) : Padding(padding: fieldPadding, child: child),
              if (additionalPostWidget != null)
                Padding(
                  padding: EdgeInsets.only(
                    top: fieldPadding.top,
                    bottom: fieldPadding.bottom,
                    right: fieldPadding.right,
                  ),
                  child: Center(child: additionalPostWidget),
                ),
              if (postWidget != null)
                Padding(
                  padding: EdgeInsets.only(
                    top: fieldPadding.top,
                    bottom: fieldPadding.bottom,
                    right: fieldPadding.right,
                  ),
                  child: Center(child: postWidget!),
                ),
            ],
          ),
        ),
        buildHelperText(ctx, helperText),
        if (errors != null && errors.isNotEmpty) buildErrors(ctx, errors),
      ],
    );
  }

  const TInputFieldTheme({
    this.size = TInputSize.md,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.preWidget,
    this.postWidget,
    this.height,
    this.padding,
    this.fontSize,
    this.borderRadius,
    this.labelStyle,
    this.helperTextStyle,
    this.errorTextStyle,
    this.tagStyle,
    this.labelBuilder,
    this.helperTextBuilder,
    this.errorsBuilder,
    this.borderBuilder,
    this.boxShadowBuilder,
    this.decorationBuilder,
  });

  TInputFieldTheme copyWith({
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
  }) {
    return TInputFieldTheme(
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
    );
  }
}

extension TInputSizeX on TInputSize? {
  double get height {
    return switch (this) {
      TInputSize.sm => 34.0,
      TInputSize.lg => 42.0,
      _ => 38.0,
    };
  }

  double get fontSize {
    return switch (this) {
      TInputSize.sm => 12.0,
      TInputSize.lg => 16.0,
      _ => 14.0,
    };
  }

  EdgeInsets get padding {
    return switch (this) {
      TInputSize.sm => const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      TInputSize.lg => const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
      _ => const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
    };
  }
}
