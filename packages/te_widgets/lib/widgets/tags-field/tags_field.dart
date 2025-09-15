import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/tags-field/tags_field_theme.dart';

class TTagsField extends StatefulWidget
    with TInputFieldMixin, TFocusMixin, TTextFieldMixin, TInputValueMixin<List<String>>, TInputValidationMixin<List<String>> {
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
  final TextEditingController? textController;
  @override
  final List<String>? value;
  @override
  final ValueNotifier<List<String>>? valueNotifier;
  @override
  final ValueChanged<List<String>>? onValueChanged;
  @override
  final List<String? Function(List<String>?)>? rules;
  @override
  final Duration? validationDebounce;

  // TagsField specific properties
  final String? inputValue;
  final ValueChanged<String>? onInputChanged;
  final bool addTagOnEnter;
  final void Function(String)? onTagAdded;
  final void Function(String)? onTagRemoved;

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
    this.inputValue,
    this.onInputChanged,
    this.addTagOnEnter = true,
    this.onTagAdded,
    this.onTagRemoved,
  });

  @override
  State<TTagsField> createState() => _TTagsFieldState();
}

class _TTagsFieldState extends State<TTagsField>
    with
        TInputFieldStateMixin<TTagsField>,
        TFocusStateMixin<TTagsField>,
        TTextFieldStateMixin<TTagsField>,
        TInputValueStateMixin<List<String>, TTagsField>,
        TInputValidationStateMixin<List<String>, TTagsField> {
  @override
  TTagsFieldTheme get wTheme => widget.theme ?? theme.tagsFieldTheme;

  @override
  void initState() {
    super.initState();
    controller.text = widget.inputValue ?? '';
  }

  @override
  void didUpdateWidget(covariant TTagsField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.inputValue != oldWidget.inputValue) {
      controller.text = widget.inputValue ?? '';
    }
  }

  @override
  void onExternalValueChanged(List<String>? value) {
    super.onExternalValueChanged(value);
    setState(() {});
  }

  void _onInputChanged(String value) {
    widget.onInputChanged?.call(value);
  }

  void _addTagFromInput() {
    final input = controller.text.trim();
    if (input.isNotEmpty) {
      _addTag(input);
      controller.clear();
      widget.onInputChanged?.call('');
    }
  }

  void _addTag(String tagText) {
    final trimmed = tagText.trim();
    if (trimmed.isEmpty) return;
    if (currentValue?.contains(trimmed) == true) return;

    widget.onTagRemoved?.call(trimmed);
    final newValue = List<String>.from(currentValue ?? [])..add(trimmed);

    setState(() => notifyValueChanged(newValue));
  }

  void _removeTag(String tag) {
    widget.onTagRemoved?.call(tag);
    final newValue = List<String>.from(currentValue ?? [])..remove(tag);

    setState(() => notifyValueChanged(newValue));
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter && widget.addTagOnEnter) {
        _addTagFromInput();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.backspace && controller.text.isEmpty && currentValue?.isNotEmpty == true) {
        _removeTag(currentValue!.last);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return buildContainer(
      isMultiline: true,
      child: wTheme.buildTagsField(
        colors,
        tags: currentValue ?? [],
        onRemove: _removeTag,
        child: Focus(
          onKeyEvent: _onKeyEvent,
          child: IgnorePointer(
            child: buildTextField(
              textInputAction: TextInputAction.unspecified,
              onValueChanged: _onInputChanged,
            ),
          ),
        ),
      ),
    );
  }
}
