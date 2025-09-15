import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

mixin TTextFieldMixin on TInputFieldMixin, TFocusMixin {
  @override
  TTextFieldTheme? get theme;
  @override
  FocusNode? get focusNode;

  bool get autoFocus;
  bool get readOnly;
  String? get placeholder;
  TextEditingController? get textController;
}

mixin TTextFieldStateMixin<W extends StatefulWidget> on State<W>, TInputFieldStateMixin<W>, TFocusStateMixin<W> {
  TTextFieldMixin get _widget {
    assert(widget is TTextFieldMixin, 'Widget must mix in TTextFieldMixin');
    return widget as TTextFieldMixin;
  }

  @override
  TTextFieldTheme get wTheme => _widget.theme ?? context.theme.textFieldTheme;

  late final TextEditingController controller;
  late final bool _shouldDisposeController;

  @override
  void initState() {
    super.initState();
    controller = _widget.textController ?? TextEditingController();
    _shouldDisposeController = _widget.textController == null;
  }

  @override
  void dispose() {
    if (_shouldDisposeController) controller.dispose();
    super.dispose();
  }

  TextField buildTextField({
    int maxLines = 1,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onValueChanged,
  }) {
    return wTheme.buildTextField(
      colors,
      label: _widget.label,
      placeholder: _widget.placeholder,
      autoFocus: _widget.autoFocus,
      readOnly: _widget.readOnly,
      disabled: _widget.disabled,
      focusNode: focusNode,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onValueChanged: onValueChanged,
    );
  }
}
