import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Mixin for standard input field properties.
mixin TInputFieldMixin {
  /// The label text.
  String? get label;

  /// The tag text (optional).
  String? get tag;

  /// The helper text.
  String? get helperText;

  /// Whether the field is required.
  bool get isRequired;

  /// Whether the field is disabled.
  bool get disabled;

  /// Custom theme.
  TInputFieldTheme? get theme;

  /// Callback for tap events.
  VoidCallback? get onTap;
}

/// State mixin for building input field containers.
mixin TInputFieldStateMixin<W extends StatefulWidget> on State<W> {
  TInputFieldMixin get _widget => widget as TInputFieldMixin;
  TFocusStateMixin? get focusMixin => this is TFocusStateMixin ? this as TFocusStateMixin : null;
  TInputValidationStateMixin? get validationMixin => this is TInputValidationStateMixin ? this as TInputValidationStateMixin : null;
  
  /// Access to current color scheme.
  ColorScheme get colors => context.colors;
  
  /// Access to current widget theme.
  TInputFieldTheme get wTheme => _widget.theme ?? context.theme.inputFieldTheme;

  /// Current interactive states of the widget (focused, error, disabled).
  Set<WidgetState> get states {
    final isFocused = focusMixin?.isFocused ?? false;
    final hasErrors = validationMixin?.hasErrors ?? false;

    return <WidgetState>{if (isFocused) WidgetState.focused, if (hasErrors) WidgetState.error, if (_widget.disabled) WidgetState.disabled};
  }

  /// Builds the container structure for the input field.
  Widget buildContainer({
    bool isMultiline = false,
    Widget? child,
    Widget? postWidget,
    Widget? preWidget,
    VoidCallback? onTap,
    bool block = true,
    bool focusOnTap = true,
  }) {
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
        states,
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
