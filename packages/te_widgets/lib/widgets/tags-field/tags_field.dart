import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/tags-field/tags_field_mixin.dart';

/// A tags input field for managing string lists.
///
/// `TTagsField` provides tag management with:
/// - Add tags by typing and pressing Enter
/// - Remove tags by clicking
/// - Delimiter support (comma, semicolon, newline)
/// - Duplicate prevention
/// - Validation support
///
/// ## Basic Usage
///
/// ```dart
/// TTagsField(
///   label: 'Tags',
///   placeholder: 'Add tags...',
///   onValueChanged: (tags) => print('Tags: \$tags'),
/// )
/// ```
///
/// ## With Initial Values
///
/// ```dart
/// TTagsField(
///   label: 'Skills',
///   value: ['Flutter', 'Dart', 'Firebase'],
///   onValueChanged: (tags) => saveTags(tags),
/// )
/// ```
///
/// ## With Validation
///
/// ```dart
/// TTagsField(
///   label: 'Keywords',
///   isRequired: true,
///   rules: [
///     (tags) => tags == null || tags.isEmpty
///         ? 'At least one tag is required'
///         : null,
///   ],
/// )
/// ```
///
/// See also:
/// - [TTextField] for single-line text input
/// - [TMultiSelect] for predefined options
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
  final bool clearable;
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

  /// Creates a tags field.
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
    this.clearable = false,
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
      showClearButton: tagsController.tags.isNotEmpty,
      onClear: () {
        setState(() {
          tagsController.updateState(tags: []);
          notifyValueChanged([]);
        });
      },
      child: buildTagsField(onKeyEvent: _onKeyEvent),
    );
  }
}
