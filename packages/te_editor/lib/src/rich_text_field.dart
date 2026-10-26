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
  static const _tabs = ['Text', 'Paragraph', 'Insert'];
  static const _iconSize = 15.0;
  static const _minEditorHeight = 72.0; // ~3 lines

  int _tab = 0;

  QuillSimpleToolbarConfig _toolbarConfig() {
    final text = _tab == 0;
    final paragraph = _tab == 1;
    final insert = _tab == 2;
    return QuillSimpleToolbarConfig(
      multiRowsDisplay: false,
      toolbarRunSpacing: 0,
      toolbarSectionSpacing: 0,
      toolbarIconAlignment: WrapAlignment.start,
      buttonOptions: const QuillSimpleToolbarButtonOptions(
        base: QuillToolbarBaseButtonOptions(iconSize: _iconSize, iconButtonFactor: 1.5),
      ),
      showDividers: false,
      showFontFamily: false,
      showFontSize: false,
      showColorButton: false,
      showBackgroundColorButton: false,
      showUndo: text,
      showRedo: text,
      showBoldButton: text,
      showItalicButton: text,
      showUnderLineButton: text,
      showStrikeThrough: text,
      showClearFormat: text,
      showHeaderStyle: paragraph,
      showListNumbers: paragraph,
      showListBullets: paragraph,
      showListCheck: paragraph,
      showQuote: paragraph,
      showIndent: paragraph,
      showInlineCode: insert,
      showCodeBlock: insert,
      showSubscript: insert,
      showSuperscript: insert,
      showLink: insert,
      showSearchButton: insert,
      embedButtons: insert ? FlutterQuillEmbeds.toolbarButtons() : const [],
    );
  }

  Widget _buildTabs(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < _tabs.length; i++)
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => setState(() => _tab = i),
            child: Container(
              margin: const EdgeInsets.only(right: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: i == _tab ? colors.primary.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _tabs[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: i == _tab ? FontWeight.w600 : FontWeight.w400,
                  color: i == _tab ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }

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
          if (!widget.disabled && !widget.readOnly) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Align(alignment: Alignment.centerLeft, child: _buildTabs(context)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: QuillSimpleToolbar(controller: quillController, config: _toolbarConfig()),
            ),
          ],
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: QuillEditor.basic(
              controller: quillController,
              focusNode: focusNode,
              config: QuillEditorConfig(
                padding: EdgeInsets.zero,
                minHeight: _minEditorHeight,
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
