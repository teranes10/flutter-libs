import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/mixins/focus_mixin.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/mixins/input_validation_mixin.dart';
import 'package:te_widgets/mixins/input_value_mixin.dart';

class TTagsField extends StatefulWidget with TInputFieldMixin, TInputValueMixin<List<String>>, TFocusMixin, TInputValidationMixin<List<String>> {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool? isRequired, disabled;
  @override
  final TInputSize? size;
  @override
  final TInputColor? color;
  @override
  final BoxDecoration? boxDecoration;
  @override
  final Widget? preWidget, postWidget;
  @override
  final List<String? Function(List<String>?)>? rules;
  @override
  final List<String>? errors;
  @override
  final List<String>? value;
  @override
  final ValueNotifier<List<String>>? valueNotifier;
  @override
  final ValueChanged<List<String>>? onValueChanged;
  @override
  final Duration? validationDebounce;
  @override
  final bool? skipValidation;
  @override
  final FocusNode? focusNode;

  // TagsField specific properties
  final String? inputValue;
  final ValueChanged<String>? onInputChanged;
  final TextEditingController? controller;
  final bool addTagOnEnter;
  final int? maxTags;
  final bool allowDuplicates;
  final Widget Function(String tag, VoidCallback onRemove)? tagBuilder;
  final void Function(String)? onTagAdded;
  final void Function(String)? onTagRemoved;
  final bool? readOnly;

  const TTagsField({
    super.key,
    this.label,
    this.tag,
    this.placeholder,
    this.helperText,
    this.message,
    this.value,
    this.isRequired,
    this.disabled,
    this.size = TInputSize.md,
    this.color,
    this.boxDecoration,
    this.preWidget,
    this.postWidget,
    this.rules,
    this.errors,
    this.valueNotifier,
    this.onValueChanged,
    this.validationDebounce,
    this.inputValue,
    this.onInputChanged,
    this.addTagOnEnter = true,
    this.tagBuilder,
    this.maxTags,
    this.allowDuplicates = false,
    this.focusNode,
    this.skipValidation,
    this.controller,
    this.onTagAdded,
    this.onTagRemoved,
    this.readOnly,
  });

  @override
  State<TTagsField> createState() => _TTagsFieldState();
}

class _TTagsFieldState extends State<TTagsField>
    with TInputValueStateMixin<List<String>, TTagsField>, TFocusStateMixin<TTagsField>, TInputValidationStateMixin<List<String>, TTagsField> {
  late final TextEditingController _controller;
  late final bool _shouldDisposeController;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController(text: widget.inputValue ?? '');
    _shouldDisposeController = widget.controller == null;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TTagsField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.inputValue != oldWidget.inputValue) {
      _controller.text = widget.inputValue ?? '';
    }
  }

  @override
  void dispose() {
    if (_shouldDisposeController) _controller.dispose();
    super.dispose();
  }

  @override
  void onExternalValueChanged(List<String> value) {
    super.onExternalValueChanged(value);

    setState(() {});
  }

  void _onInputChanged(String value) {
    widget.onInputChanged?.call(value);
  }

  void _addTagFromInput() {
    final input = _controller.text.trim();
    if (input.isNotEmpty) {
      _addTag(input);
      _controller.clear();
      widget.onInputChanged?.call('');
    }
  }

  void _addTag(String tagText) {
    final trimmed = tagText.trim();
    if (trimmed.isEmpty) return;

    // Check max tags
    if (widget.maxTags != null && currentValue != null && currentValue!.length >= widget.maxTags!) return;

    // Check duplicates
    if (!widget.allowDuplicates && currentValue?.contains(trimmed) == true) return;

    currentValue?.add(trimmed);
    widget.onTagRemoved?.call(trimmed);

    setState(() {
      notifyValueChanged(List.from(currentValue ?? []));
    });
  }

  void _removeTag(String tag) {
    currentValue?.remove(tag);
    widget.onTagRemoved?.call(tag);
    setState(() {
      notifyValueChanged(List.from(currentValue ?? []));
    });
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter && widget.addTagOnEnter) {
        _addTagFromInput();
      } else if (event.logicalKey == LogicalKeyboardKey.backspace && _controller.text.isEmpty && currentValue?.isNotEmpty == true) {
        _removeTag(currentValue!.last);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.buildContainer(
      isMultiline: true,
      isFocused: isFocused,
      hasErrors: hasErrors,
      errorsNotifier: errorsNotifier,
      child: Wrap(
        spacing: 6.0,
        runSpacing: 6.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...(currentValue ?? []).map(_buildTagChip),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 150,
              maxWidth: double.infinity,
            ),
            child: IntrinsicWidth(
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: _onKeyEvent,
                child: TextField(
                  controller: _controller,
                  focusNode: focusNode,
                  enabled: widget.disabled != true,
                  cursorHeight: widget.fontSize + 2,
                  textInputAction: TextInputAction.unspecified,
                  textAlignVertical: TextAlignVertical.center,
                  style: widget.getTextStyle(),
                  decoration: widget.getInputDecoration(),
                  onChanged: _onInputChanged,
                  readOnly: widget.readOnly == true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    if (widget.tagBuilder != null) {
      return widget.tagBuilder!(tag, () => _removeTag(tag));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: AppColors.grey.shade50,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              color: AppColors.grey.shade500,
              fontSize: widget.fontSize,
            ),
          ),
          const SizedBox(width: 5.0),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: Icon(Icons.close, size: 12.0, color: AppColors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
