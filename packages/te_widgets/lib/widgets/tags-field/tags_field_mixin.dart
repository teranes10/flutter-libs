import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

mixin TTagsFieldMixin on TTextFieldMixin, TInputFieldMixin, TFocusMixin {
  @override
  TTagsFieldTheme? get theme;

  bool get addTagOnEnter;
  bool get allowDuplicates;
  List<String> get delimiters;
  ValueChanged<String>? get onInputChanged;
}

mixin TTagsFieldStateMixin<W extends StatefulWidget> on State<W>, TTextFieldStateMixin<W>, TInputFieldStateMixin<W>, TFocusStateMixin<W> {
  TTagsFieldMixin get _widget {
    assert(widget is TTagsFieldMixin, 'Widget must mix in TTagsFieldMixin');
    return widget as TTagsFieldMixin;
  }

  TTagsController get tagsController => textController as TTagsController;

  @override
  TTagsFieldTheme get wTheme => _widget.theme ?? context.theme.tagsFieldTheme;

  @override
  TTagsController buildTextController() {
    return TTagsController(
      tags: [],
      text: '',
      allowDuplicates: _widget.allowDuplicates,
      delimiters: _widget.delimiters,
    );
  }

  Widget buildTagsField({KeyEventResult Function(FocusNode, KeyEvent)? onKeyEvent, ValueChanged<String>? onInputChanged}) {
    final textField = IgnorePointer(
      ignoring: onInputChanged == null,
      child: buildTextField(
        textInputAction: TextInputAction.unspecified,
        onValueChanged: (String input) {
          onInputChanged?.call(input);
          _widget.onInputChanged?.call(input);
        },
      ),
    );

    return wTheme.buildTagsField(
      controller: tagsController,
      canRemove: !_widget.disabled && !_widget.readOnly,
      child: onKeyEvent != null ? Focus(onKeyEvent: onKeyEvent, child: textField) : textField,
    );
  }
}
