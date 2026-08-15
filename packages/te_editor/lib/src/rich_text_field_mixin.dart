import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:te_widgets/te_widgets.dart';
import 'rich_text_field_theme.dart';

/// Mixin for rich text field widget configuration.
mixin TRichTextFieldMixin on TInputFieldMixin, TFocusMixin {
  @override
  TRichTextFieldTheme? get theme;
  bool get readOnly;
}

/// State mixin for the rich text field widget.
mixin TRichTextFieldStateMixin<W extends StatefulWidget>
    on State<W>, TInputFieldStateMixin<W>, TFocusStateMixin<W>, TInputValueStateMixin<String, W> {
  TRichTextFieldMixin get _widget {
    assert(widget is TRichTextFieldMixin, 'Widget must mix in TRichTextFieldMixin');
    return widget as TRichTextFieldMixin;
  }

  @override
  TRichTextFieldTheme get wTheme => _widget.theme ?? TRichTextFieldTheme.defaultTheme(context.colors);

  late final QuillController quillController;
  late final bool _isLocalController;

  @override
  void initState() {
    super.initState();
    _isLocalController = true;

    // Initialize controller with empty document or provided string
    final initialString = _widget is TInputValueMixin<String>
        ? ((_widget as TInputValueMixin<String>).valueNotifier?.value ?? (_widget as TInputValueMixin<String>).value)
        : null;

    Document doc;
    if (initialString != null && initialString.isNotEmpty) {
      try {
        final decoded = jsonDecode(initialString);
        doc = Document.fromJson(decoded);
      } catch (_) {
        doc = Document();
      }
    } else {
      doc = Document();
    }

    quillController = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: _widget.readOnly || _widget.disabled,
    );

    quillController.addListener(_onQuillChanged);
  }

  void _onQuillChanged() {
    final jsonDelta = jsonEncode(quillController.document.toDelta().toJson());
    if (_widget is TInputValueMixin<String>) {
      notifyValueChanged(jsonDelta);
    }
  }

  @override
  void dispose() {
    quillController.removeListener(_onQuillChanged);
    if (_isLocalController) {
      quillController.dispose();
    }
    super.dispose();
  }

  @override
  void onExternalValueChanged(String? value) {
    if (value == null || value.isEmpty) {
      quillController.clear();
      return;
    }

    try {
      final decoded = jsonDecode(value);
      final newDoc = Document.fromJson(decoded);
      if (jsonEncode(newDoc.toDelta().toJson()) != jsonEncode(quillController.document.toDelta().toJson())) {
        quillController.document = newDoc;
      }
    } catch (_) {}
  }
}
