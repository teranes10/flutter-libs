import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/text-field/text_field_mixin.dart';
import 'package:te_widgets/widgets/text-field/validation_mixin.dart';

class TTextField extends StatefulWidget with TTextFieldMixin, TValidationMixin<String> {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool? required, disabled;
  @override
  final TTextFieldSize? size;
  @override
  final TTextFieldColor? color;
  @override
  final BoxDecoration? boxDecoration;
  @override
  final List<String Function(String?)>? rules;

  final String? value;
  final List<String>? tags;
  final bool? addTagOnEnter;
  final int? rows;
  final Widget? preWidget, postWidget;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String Function(String)? formatter;
  final ValueChanged<String>? onChanged;
  final ValueChanged<List<String>>? onTagsChanged;
  final List<String>? errors;

  const TTextField({
    super.key,
    this.label,
    this.tag,
    this.placeholder,
    this.helperText,
    this.message,
    this.value,
    this.tags,
    this.required,
    this.disabled,
    this.addTagOnEnter,
    this.rows,
    this.size = TTextFieldSize.md,
    this.color,
    this.boxDecoration,
    this.preWidget,
    this.postWidget,
    this.formatter,
    this.rules,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onTagsChanged,
    this.errors,
  });

  @override
  State<TTextField> createState() => _TTextFieldState();
}

class _TTextFieldState extends State<TTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final bool _shouldDisposeFocusNode;
  late List<String> _tags;
  final List<String> _internalErrors = [];
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.value ?? '');

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _shouldDisposeFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _shouldDisposeFocusNode = true;
    }

    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
    _tags = List.from(widget.tags ?? []);
  }

  @override
  void didUpdateWidget(covariant TTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) _controller.text = widget.value ?? '';
    if (widget.tags != oldWidget.tags) _tags = List.from(widget.tags ?? []);

    if (widget.focusNode != oldWidget.focusNode) {
      if (_shouldDisposeFocusNode && oldWidget.focusNode == null) {
        _focusNode.removeListener(() => setState(() => _isFocused = _focusNode.hasFocus));
        _focusNode.dispose();
      }

      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _shouldDisposeFocusNode = false;
      } else {
        _focusNode = FocusNode();
        _shouldDisposeFocusNode = true;
      }

      _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    if (_shouldDisposeFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    //todo
    // String processed = widget.formatter?.call(value) ?? value;

    // if (processed != value) {
    //   _controller
    //     ..text = processed
    //     ..selection = TextSelection.collapsed(offset: processed.length);
    // }

    // _internalErrors = widget.validate(processed);
    // widget.onChanged?.call(processed);
    // setState(() {});
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _tags.add(trimmed);
      _controller.clear();
    });

    widget.onTagsChanged?.call(_tags);
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
    widget.onTagsChanged?.call(_tags);
  }

  void _onKeyEvent(KeyEvent event) {
    var addTagOnEnter = widget.addTagOnEnter == true || widget.tags != null;
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter && addTagOnEnter && _controller.text.trim().isNotEmpty) {
      _addTag(_controller.text);
    }
  }

  Widget _buildTagChip(String tag) => Container(
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

  Widget _buildTextField() {
    final isMultiline = widget.rows != null && widget.rows! > 1;
    final addTagOnEnter = widget.addTagOnEnter == true || widget.tags != null;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.disabled != true,
      maxLines: isMultiline
          ? widget.rows
          : addTagOnEnter
              ? null
              : 1,
      cursorHeight: widget.fontSize + 2,
      textInputAction: isMultiline
          ? TextInputAction.newline
          : addTagOnEnter
              ? TextInputAction.unspecified
              : TextInputAction.next,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(fontSize: widget.fontSize, color: AppColors.grey.shade600),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: widget.placeholder ?? widget.label,
        hintStyle: TextStyle(fontWeight: FontWeight.w300, color: AppColors.grey.shade300),
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(vertical: 5),
      ),
      onChanged: _onTextChanged,
    );
  }

  List<String> get _combinedErrors {
    final combined = <String>[];
    combined.addAll(_internalErrors);
    if (widget.errors != null) {
      combined.addAll(widget.errors!);
    }
    return combined;
  }

  @override
  Widget build(BuildContext context) {
    final combinedErrors = _combinedErrors;
    final hasMultipleRows = widget.rows != null;
    final hasTags = _tags.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.buildLabel(),
        Container(
          constraints: BoxConstraints(
            minHeight: widget.fieldHeight,
            maxHeight: (hasMultipleRows || hasTags) ? double.infinity : widget.fieldHeight,
          ),
          decoration: widget.getBoxDecoration(
            isFocused: _isFocused,
            hasErrors: combinedErrors.isNotEmpty,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                if (widget.preWidget != null)
                  Padding(
                    padding: EdgeInsets.only(top: widget.fieldPadding.top, bottom: widget.fieldPadding.bottom, left: widget.fieldPadding.left),
                    child: Center(child: widget.preWidget!),
                  ),
                Expanded(
                  child: Padding(
                    padding: widget.fieldPadding,
                    child: _tags.isNotEmpty
                        ? Wrap(
                            spacing: 6.0,
                            runSpacing: 6.0,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              ..._tags.map(_buildTagChip),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 100,
                                  maxWidth: double.infinity,
                                ),
                                child: IntrinsicWidth(
                                  child: KeyboardListener(
                                    focusNode: FocusNode(),
                                    onKeyEvent: _onKeyEvent,
                                    child: _buildTextField(),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : KeyboardListener(
                            focusNode: FocusNode(),
                            onKeyEvent: _onKeyEvent,
                            child: _buildTextField(),
                          ),
                  ),
                ),
                if (widget.postWidget != null)
                  Padding(
                    padding: EdgeInsets.only(top: widget.fieldPadding.top, bottom: widget.fieldPadding.bottom, right: widget.fieldPadding.left),
                    child: Center(child: widget.postWidget!),
                  ),
              ],
            ),
          ),
        ),
        widget.buildHelperText(),
        widget.buildMessage(),
        widget.buildErrors(combinedErrors),
      ],
    );
  }
}
