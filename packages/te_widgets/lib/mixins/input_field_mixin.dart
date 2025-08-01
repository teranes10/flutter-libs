import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TInputSize { sm, md, lg }

mixin TInputFieldMixin {
  String? get label;
  String? get tag;
  String? get placeholder;
  String? get helperText;
  String? get message;
  bool get isRequired;
  bool get disabled;
  TInputSize? get size;
  Color? get color;
  BoxDecoration? get boxDecoration;
  Widget? get preWidget;
  Widget? get postWidget;
  VoidCallback? get onTap;

  double get fieldHeight {
    switch (size) {
      case TInputSize.sm:
        return 34.0;
      case TInputSize.lg:
        return 42.0;
      case TInputSize.md:
      case null:
        return 38.0;
    }
  }

  EdgeInsets get fieldPadding {
    switch (size) {
      case TInputSize.sm:
        return const EdgeInsets.symmetric(vertical: 5, horizontal: 8);
      case TInputSize.lg:
        return const EdgeInsets.symmetric(vertical: 10, horizontal: 12);
      case TInputSize.md:
      default:
        return const EdgeInsets.symmetric(vertical: 8, horizontal: 10);
    }
  }

  double get fontSize {
    switch (size) {
      case TInputSize.sm:
        return 12.0;
      case TInputSize.lg:
        return 16.0;
      case TInputSize.md:
      case null:
        return 14.0;
    }
  }
}

mixin TInputFieldStateMixin<W extends StatefulWidget> on State<W> {
  TInputFieldMixin get _widget => widget as TInputFieldMixin;

  Widget buildLabel(ColorScheme theme) {
    if (_widget.label == null && _widget.tag == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_widget.label != null)
            RichText(
              text: TextSpan(
                text: _widget.label!,
                style: TextStyle(
                  fontSize: 12.0,
                  letterSpacing: 0.9,
                  fontWeight: FontWeight.w500,
                  color: theme.onSurfaceVariant,
                ),
                children: _widget.isRequired ? [TextSpan(text: ' *', style: TextStyle(color: theme.error))] : null,
              ),
            ),
          if (_widget.tag != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: theme.surfaceContainer,
              ),
              child: Text(
                _widget.tag!,
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w300,
                  color: theme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  TextStyle getTextStyle(ColorScheme theme) {
    return TextStyle(
      fontSize: _widget.fontSize,
      color: _widget.disabled ? theme.onSurfaceVariant : theme.onSurface,
    );
  }

  Color getMessageColor(ColorScheme theme) {
    return _widget.color ?? theme.onSurfaceVariant;
  }

  InputDecoration getInputDecoration(ColorScheme theme) {
    return InputDecoration(
      border: InputBorder.none,
      hintText: _widget.placeholder ?? _widget.label,
      hintStyle: TextStyle(fontWeight: FontWeight.w300, color: theme.onSurfaceVariant),
      isCollapsed: true,
      contentPadding: EdgeInsets.symmetric(vertical: 5),
    );
  }

  Widget buildHelperText(ColorScheme theme) {
    if (_widget.helperText == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(_widget.helperText!, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300, color: theme.onSurfaceVariant)),
    );
  }

  Widget buildMessage(ColorScheme theme, TColorScheme exTheme) {
    if (_widget.message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(_widget.message!, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300, color: getMessageColor(theme))),
    );
  }

  BoxDecoration getBoxDecoration(ColorScheme theme, TColorScheme exTheme, bool isFocused, bool hasErrors) {
    return BoxDecoration(
      border: Border.all(color: getBorderColor(theme, exTheme, isFocused, hasErrors), width: 1.0),
      borderRadius: BorderRadius.circular(6.0),
      color: _widget.boxDecoration?.color ?? (_widget.disabled == true ? theme.surfaceDim : theme.surface),
      boxShadow: isFocused ? [BoxShadow(color: theme.shadow, blurRadius: 4.0, spreadRadius: 1.5, offset: Offset(0, 0))] : null,
    );
  }

  Color getBorderColor(ColorScheme theme, TColorScheme exTheme, bool isFocused, bool hasErrors) {
    if (_widget.disabled) return theme.outlineVariant;
    if (hasErrors) return theme.error;
    return _widget.color ?? (isFocused ? theme.primary : theme.outline);
  }

  Widget buildValidationErrors(ColorScheme theme, ValueNotifier<List<String>> errorsNotifier) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: errorsNotifier,
      builder: (context, validationErrors, child) {
        if (validationErrors.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: validationErrors.map((error) => Text('• $error', style: TextStyle(fontSize: 12.0, color: theme.error))).toList(),
          ),
        );
      },
    );
  }

  Widget buildContainer(
    ColorScheme theme,
    TColorScheme exTheme, {
    bool? isMultiline,
    Widget? child,
    Widget? postWidget,
    Widget? preWidget,
    VoidCallback? onTap,
  }) {
    TFocusStateMixin? focusWidget = this is TFocusStateMixin ? this as TFocusStateMixin : null;
    TInputValidationStateMixin? validationMixin = this is TInputValidationStateMixin ? this as TInputValidationStateMixin : null;

    final container = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(theme),
        Container(
          constraints: BoxConstraints(
            minHeight: _widget.fieldHeight,
            maxHeight: isMultiline == true ? double.infinity : _widget.fieldHeight,
          ),
          decoration: getBoxDecoration(theme, exTheme, focusWidget?.isFocused == true, validationMixin?.hasErrors == true),
          child: IntrinsicHeight(
            child: Row(
              children: [
                if (_widget.preWidget != null)
                  Padding(
                      padding: EdgeInsets.only(
                          top: _widget.fieldPadding.top, bottom: _widget.fieldPadding.bottom, left: _widget.fieldPadding.left),
                      child: Center(child: _widget.preWidget!)),
                if (preWidget != null)
                  Padding(
                      padding: EdgeInsets.only(
                          top: _widget.fieldPadding.top, bottom: _widget.fieldPadding.bottom, left: _widget.fieldPadding.left),
                      child: Center(child: preWidget)),
                Expanded(child: Padding(padding: _widget.fieldPadding, child: child)),
                if (postWidget != null)
                  Padding(
                      padding: EdgeInsets.only(
                          top: _widget.fieldPadding.top, bottom: _widget.fieldPadding.bottom, right: _widget.fieldPadding.right),
                      child: Center(child: postWidget)),
                if (_widget.postWidget != null)
                  Padding(
                      padding: EdgeInsets.only(
                          top: _widget.fieldPadding.top, bottom: _widget.fieldPadding.bottom, right: _widget.fieldPadding.right),
                      child: Center(child: _widget.postWidget!)),
              ],
            ),
          ),
        ),
        buildHelperText(theme),
        buildMessage(theme, exTheme),
        if (validationMixin?.errorsNotifier != null) buildValidationErrors(theme, validationMixin!.errorsNotifier),
      ],
    );

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        _widget.onTap?.call();
        onTap?.call();
        focusWidget?.focusNode.requestFocus();
      },
      child: container,
    );
  }
}
