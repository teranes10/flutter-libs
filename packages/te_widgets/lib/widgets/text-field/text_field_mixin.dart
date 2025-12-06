import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

/// Mixin for text field configuration properties.
mixin TTextFieldMixin on TInputFieldMixin, TFocusMixin {
  @override
  TTextFieldTheme? get theme;

  @override
  FocusNode? get focusNode;

  /// Whether the field should autofocus.
  bool get autoFocus;

  /// Whether the field is read-only.
  bool get readOnly;

  /// Placeholder text.
  String? get placeholder;

  /// Custom text controller.
  TextEditingController? get textController;
}

/// State mixin for building text field widgets.
mixin TTextFieldStateMixin<W extends StatefulWidget> on State<W>, TInputFieldStateMixin<W>, TFocusStateMixin<W> {
  TTextFieldMixin get _widget {
    assert(widget is TTextFieldMixin, 'Widget must mix in TTextFieldMixin');
    return widget as TTextFieldMixin;
  }

  /// The active text controller.
  TextEditingController get textController => _textController;

  @override
  TTextFieldTheme get wTheme => _widget.theme ?? context.theme.textFieldTheme;

  late final TextEditingController _textController;
  late final bool _shouldDisposeController;

  @override
  void initState() {
    super.initState();
    _textController = _widget.textController ?? buildTextController();
    _shouldDisposeController = _widget.textController == null;
  }

  @override
  void dispose() {
    if (_shouldDisposeController) _textController.dispose();
    super.dispose();
  }

  /// Creates specific controller for the text field.
  ///
  /// Override this to provide a custom controller (e.g. validatable).
  TextEditingController buildTextController() {
    return TextEditingController();
  }

  /// Builds the text field widget.
  TextField buildTextField({
    int maxLines = 1,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onValueChanged,
  }) {
    return wTheme.buildTextField(
      states,
      label: _widget.label,
      placeholder: _widget.placeholder,
      autoFocus: _widget.autoFocus,
      readOnly: _widget.readOnly,
      focusNode: focusNode,
      controller: _textController,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onValueChanged: onValueChanged,
    );
  }
}
