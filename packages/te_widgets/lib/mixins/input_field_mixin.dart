import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

mixin TInputFieldMixin {
  String? get label;
  String? get tag;
  String? get helperText;
  bool get isRequired;
  bool get disabled;
  TInputFieldTheme? get theme;
  VoidCallback? get onTap;
}

mixin TInputFieldStateMixin<W extends StatefulWidget> on State<W> {
  TInputFieldMixin get _widget => widget as TInputFieldMixin;
  ColorScheme get colors => context.colors;
  TWidgetThemeExtension get theme => context.theme;
  TInputFieldTheme get wTheme => _widget.theme ?? theme.inputFieldTheme;

  Widget buildContainer({
    bool isMultiline = false,
    Widget? child,
    Widget? postWidget,
    Widget? preWidget,
    VoidCallback? onTap,
    bool block = true,
    bool focusOnTap = true,
  }) {
    TFocusStateMixin? focusMixin = this is TFocusStateMixin ? this as TFocusStateMixin : null;
    TInputValidationStateMixin? validationMixin = this is TInputValidationStateMixin ? this as TInputValidationStateMixin : null;

    final isFocused = focusMixin?.isFocused ?? false;
    final hasErrors = validationMixin?.hasErrors ?? false;

    final ctx = TInputContext(
      colors: colors,
      theme: wTheme,
      states: <WidgetState>{
        if (isFocused) WidgetState.focused,
        if (hasErrors) WidgetState.error,
        if (_widget.disabled) WidgetState.disabled
      },
    );

    return InkWell(
      onTap: _widget.disabled
          ? null
          : () {
              onTap?.call();
              _widget.onTap?.call();

              if (focusOnTap) {
                focusMixin?.focusNode.requestFocus();
              }
            },
      child: wTheme.buildContainer(
        ctx,
        child: child,
        additionalPostWidget: postWidget,
        additionalPreWidget: preWidget,
        label: _widget.label,
        tag: _widget.tag,
        helperText: _widget.helperText,
        errors: validationMixin?.errorsNotifier.value,
        isRequired: _widget.isRequired,
        isMultiline: isMultiline,
        block: block,
      ),
    );
  }
}
