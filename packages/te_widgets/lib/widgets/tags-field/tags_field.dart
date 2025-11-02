import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/tags-field/tags_field_mixin.dart';

class TTagsField extends StatefulWidget
    with
        TInputFieldMixin,
        TFocusMixin,
        TTextFieldMixin,
        TTagsFieldMixin,
        TInputValueMixin<List<String>>,
        TInputValidationMixin<List<String>> {
  @override
  final String? label, tag, helperText, placeholder;
  @override
  final bool isRequired, disabled, autoFocus, readOnly;
  @override
  final TTagsFieldTheme? theme;
  @override
  final VoidCallback? onTap;
  @override
  final FocusNode? focusNode;
  @override
  final TTagsController? textController;
  @override
  final List<String>? value;
  @override
  final ValueNotifier<List<String>?>? valueNotifier;
  @override
  final ValueChanged<List<String>?>? onValueChanged;
  @override
  final List<String? Function(List<String>?)>? rules;
  @override
  final Duration? validationDebounce;
  @override
  final bool addTagOnEnter;
  @override
  final bool allowDuplicates;
  @override
  final List<String> delimiters;
  @override
  final ValueChanged<String>? onInputChanged;

  const TTagsField({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.placeholder,
    this.isRequired = false,
    this.disabled = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.theme,
    this.onTap,
    this.focusNode,
    this.textController,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.rules,
    this.validationDebounce,
    this.addTagOnEnter = true,
    this.allowDuplicates = false,
    this.delimiters = const [',', ';', '\n'],
    this.onInputChanged,
  });

  @override
  State<TTagsField> createState() => _TTagsFieldState();
}

class _TTagsFieldState extends State<TTagsField>
    with
        TInputFieldStateMixin<TTagsField>,
        TFocusStateMixin<TTagsField>,
        TTextFieldStateMixin<TTagsField>,
        TTagsFieldStateMixin<TTagsField>,
        TInputValueStateMixin<List<String>, TTagsField>,
        TInputValidationStateMixin<List<String>, TTagsField> {
  @override
  void onExternalValueChanged(List<String>? value) {
    super.onExternalValueChanged(value);
    final tags = currentValue ?? [];
    if (!tagsController.tags.equalsEach(tags)) {
      tagsController.updateState(tags: tags);
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Handle Enter key
    if (event.logicalKey == LogicalKeyboardKey.enter && widget.addTagOnEnter) {
      tagsController.addTagFromInput();
      return KeyEventResult.handled;
    }

    // Handle Backspace key
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (!tagsController.hasFilterText && tagsController.tags.isNotEmpty) {
        tagsController.removeLastTag();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return buildContainer(
      isMultiline: true,
      child: buildTagsField(onKeyEvent: _onKeyEvent),
    );
  }
}
