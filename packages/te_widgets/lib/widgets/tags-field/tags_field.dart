import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/mixins/input_validation_mixin.dart';
import 'package:te_widgets/mixins/input_value_mixin.dart';

class TTagsField extends StatefulWidget with TInputFieldMixin, TInputValidationMixin<List<String>>, TInputValueMixin<List<String>> {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool? required, disabled;
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

  // TagsField specific properties
  final String? inputValue;
  final ValueChanged<String>? onInputChanged;
  final bool addTagOnEnter;
  final int? maxTags;
  final bool allowDuplicates;
  final Widget Function(String tag, VoidCallback onRemove)? tagBuilder;

  const TTagsField({
    super.key,
    this.label,
    this.tag,
    this.placeholder,
    this.helperText,
    this.message,
    this.value,
    this.required,
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
  });

  @override
  State<TTagsField> createState() => _TTagsFieldState();
}

class _TTagsFieldState extends State<TTagsField> with TInputValidationStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  List<String> _tags = [];
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.inputValue ?? '');
    _focusNode = FocusNode();
    _tags = List<String>.from(widget.value ?? []);
    _setupListeners();
  }

  void _setupListeners() {
    _focusNode.addListener(_onFocusChanged);
    widget.valueNotifier?.addListener(_onValueNotifierChanged);
  }

  void _onFocusChanged() {
    final wasFocused = _isFocused;
    _isFocused = _focusNode.hasFocus;

    if (wasFocused && !_isFocused) {
      _addTagFromInput();
      triggerValidation(_tags);
    }

    setState(() {});
  }

  void _onValueNotifierChanged() {
    final newValue = widget.valueNotifier?.value ?? <String>[];
    if (!_listEquals(_tags, newValue)) {
      setState(() {
        _tags = List<String>.from(newValue);
      });
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void didUpdateWidget(covariant TTagsField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      _tags = List<String>.from(widget.value ?? []);
    }

    if (widget.inputValue != oldWidget.inputValue) {
      _controller.text = widget.inputValue ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    widget.valueNotifier?.removeListener(_onValueNotifierChanged);
    _controller.dispose();
    _focusNode.dispose();
    disposeValidation();
    super.dispose();
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
    if (widget.maxTags != null && _tags.length >= widget.maxTags!) return;

    // Check duplicates
    if (!widget.allowDuplicates && _tags.contains(trimmed)) return;

    setState(() {
      _tags.add(trimmed);
    });

    widget.notifyValueChanged(_tags);
    triggerValidationWithDebounce(_tags);
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });

    widget.notifyValueChanged(_tags);
    triggerValidationWithDebounce(_tags);
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter && widget.addTagOnEnter) {
        _addTagFromInput();
      } else if (event.logicalKey == LogicalKeyboardKey.backspace && _controller.text.isEmpty && _tags.isNotEmpty) {
        _removeTag(_tags.last);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return widget.buildContainer(
      isMultiline: true,
      isFocused: _isFocused,
      hasErrors: hasErrors,
      errorsNotifier: errorsNotifier,
      child: Wrap(
        spacing: 6.0,
        runSpacing: 6.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ..._tags.map(_buildTagChip),
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
                  focusNode: _focusNode,
                  enabled: widget.disabled != true,
                  cursorHeight: widget.fontSize + 2,
                  textInputAction: TextInputAction.unspecified,
                  textAlignVertical: TextAlignVertical.center,
                  style: widget.getTextStyle(),
                  decoration: widget.getInputDecoration(),
                  onChanged: _onInputChanged,
                  onSubmitted: (_) => _addTagFromInput(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
