import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:te_widgets/te_widgets.dart';

import 'rich_text_field_mixin.dart';
import 'rich_text_field_theme.dart';

class TRichTextField extends StatefulWidget
    with TInputFieldMixin, TFocusMixin, TRichTextFieldMixin, TInputValueMixin<String>, TInputValidationMixin<String> {
  @override
  final String? label, tag, helperText, info;
  final String? placeholder;
  @override
  final bool isRequired, disabled, readOnly;
  final bool autoFocus;
  @override
  final bool clearable;
  @override
  final TRichTextFieldTheme? theme;
  @override
  final VoidCallback? onTap;
  @override
  final FocusNode? focusNode;
  @override
  final String? value;
  @override
  final ValueNotifier<String?>? valueNotifier;
  @override
  final ValueChanged<String?>? onValueChanged;
  @override
  final List<String? Function(String?)>? rules;
  @override
  final Duration? validationDebounce;

  const TRichTextField({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.placeholder,
    this.info,
    this.isRequired = false,
    this.disabled = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.clearable = false,
    this.theme,
    this.onTap,
    this.focusNode,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.rules,
    this.validationDebounce,
  });

  @override
  State<TRichTextField> createState() => _TRichTextFieldState();
}

class _TRichTextFieldState extends State<TRichTextField>
    with
        TInputFieldStateMixin<TRichTextField>,
        TFocusStateMixin<TRichTextField>,
        TInputValueStateMixin<String, TRichTextField>,
        TRichTextFieldStateMixin<TRichTextField>,
        TInputValidationStateMixin<String, TRichTextField> {
  @override
  Widget build(BuildContext context) {
    return buildContainer(
      expands: true,
      hasValue: !quillController.document.isEmpty(),
      onClear: () {
        quillController.clear();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.disabled && !widget.readOnly)
            QuillSimpleToolbar(
              controller: quillController,
              config: QuillSimpleToolbarConfig(
                showFontFamily: false,
                showFontSize: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: QuillEditor.basic(
              controller: quillController,
              focusNode: focusNode,
              config: QuillEditorConfig(
                padding: EdgeInsets.zero,
                placeholder: widget.placeholder,
                embedBuilders: kIsWeb ? FlutterQuillEmbeds.editorWebBuilders() : FlutterQuillEmbeds.editorBuilders(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
