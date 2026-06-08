import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/tags-field/tags_field_mixin.dart';

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

  /// The info text (optional).
  String? get info;

  /// Whether the field shows a clear button when it has a value.
  ///
  /// Defaults to false.
  bool get clearable;

  /// Custom theme.
  TInputFieldTheme? get theme;

  /// Callback for tap events.
  VoidCallback? get onTap;
}

/// State mixin for building input field containers.
mixin TInputFieldStateMixin<W extends StatefulWidget> on State<W> {
  TInputFieldMixin get _widget => widget as TInputFieldMixin;
  TTextFieldMixin? get _textFieldMixin => widget is TTextFieldMixin ? widget as TTextFieldMixin : null;
  TTextFieldMixin? get _tagsFieldMixin => widget is TTagsFieldMixin ? widget as TTagsFieldMixin : null;
  TFocusStateMixin? get focusMixin => this is TFocusStateMixin ? this as TFocusStateMixin : null;
  TInputValueStateMixin? get valueMixin => this is TInputValueStateMixin ? this as TInputValueStateMixin : null;
  TInputValidationStateMixin? get validationMixin => this is TInputValidationStateMixin ? this as TInputValidationStateMixin : null;

  /// Access to current color scheme.
  ColorScheme get colors => context.colors;

  /// Access to current widget theme.
  TInputFieldTheme get wTheme => _widget.theme ?? context.theme.inputFieldTheme;

  /// Current interactive states of the widget (focused, error, disabled).
  Set<WidgetState> get states {
    final isFocused = focusMixin?.isFocused ?? false;
    final hasErrors = validationMixin?.hasErrors ?? false;

    return <WidgetState>{
      if (isFocused) WidgetState.focused,
      if (hasErrors) WidgetState.error,
      if (_widget.disabled) WidgetState.disabled,
      if (valueMixin?.hasValue ?? false) WidgetState.selected,
    };
  }

  InputDecoration buildInputDecoration({
    Widget? beforePostWidget,
    Widget? beforePreWidget,
    bool hasValue = false,
    VoidCallback? onClear,
    String? placeholder,
    bool expands = false,
  }) {
    final infoIcon = _widget.info != null ? wTheme.buildInfoIcon(_widget.info!, colors) : null;

    return wTheme.buildInputDecoration(
      states,
      expands: expands,
      beforePreWidget: beforePreWidget,
      beforePostWidget: beforePostWidget,
      label: _widget.label,
      placeholder: _tagsFieldMixin != null ? null : placeholder ?? _textFieldMixin?.placeholder,
      tag: _widget.tag,
      helperText: _widget.helperText,
      errors: validationMixin?.errorsNotifier.value,
      isRequired: _widget.isRequired,
      onClear: _widget.clearable && hasValue && !_widget.disabled && onClear != null ? onClear : null,
      infoIcon: infoIcon,
    );
  }

  Widget buildWrapper({required Widget child}) {
    final infoIcon = _widget.info != null ? wTheme.buildInfoIcon(_widget.info!, colors) : null;

    return switch (wTheme.labelPosition) {
      TLabelPosition.aboveField => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            wTheme.labelBuilder.resolve(states)(_widget.label, _widget.tag, _widget.isRequired, infoIcon),
            const SizedBox(height: 8),
            child,
            wTheme.helperTextBuilder.resolve(states)(_widget.helperText),
            wTheme.errorsBuilder.resolve(states)(validationMixin?.errorsNotifier.value),
          ],
        ),
      TLabelPosition.floating => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
            wTheme.helperTextBuilder.resolve(states)(_widget.helperText),
            wTheme.errorsBuilder.resolve(states)(validationMixin?.errorsNotifier.value),
          ],
        ),
    };
  }

  /// Builds the container structure for the input field.
  Widget buildContainer({
    bool expands = false,
    Widget? child,
    Widget? beforePreWidget,
    Widget? beforePostWidget,
    VoidCallback? onTap,
    VoidCallback? onClear,
    bool hasValue = false,
    bool block = true,
    bool focusOnTap = true,
    String? placeholder,
    bool floatingLabelAlways = false,
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
      child: buildWrapper(
        child: InputDecorator(
          isFocused: states.contains(WidgetState.focused),
          isEmpty: floatingLabelAlways ? false : !states.contains(WidgetState.selected),
          decoration: buildInputDecoration(
            beforePreWidget: beforePreWidget,
            beforePostWidget: beforePostWidget,
            hasValue: hasValue,
            onClear: onClear,
            placeholder: placeholder,
            expands: expands,
          ),
          child: Container(
            constraints: BoxConstraints(
              minHeight: wTheme.fieldHeight - wTheme.fieldPadding.top,
              minWidth: block ? double.infinity : 0,
            ),
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ),
      ),
    );
  }
}
