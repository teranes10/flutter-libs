import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:te_widgets/enum/value_type.dart';
import 'package:te_widgets/widgets/tags-field/tags_controller.dart';
import 'package:te_widgets/widgets/tags-field/tags_field_mixin.dart';
import 'package:te_widgets/widgets/text-field/text_field_mixin.dart';

/// Mixin for widgets that hold a typed value.
mixin TInputValueMixin<T> {
  /// The initial value.
  T? get value;

  /// A ValueNotifier for two-way binding.
  ValueNotifier<T?>? get valueNotifier;

  /// Callback fired when the value changes.
  ValueChanged<T?>? get onValueChanged;
}

/// State mixin for managing widget value state.
///
/// Handles initialization from ValueNotifier or initial value,
/// and synchronizes state between internal value and external Notifier.
mixin TInputValueStateMixin<T, W extends StatefulWidget> on State<W> {
  TInputValueMixin<T> get _widget {
    assert(widget is TInputValueMixin<T>, 'Widget must mix in TInputValueMixin<$T>, but got ${widget.runtimeType}');
    return widget as TInputValueMixin<T>;
  }

  TTextFieldMixin? get _textFieldMixin => widget is TTextFieldMixin ? widget as TTextFieldMixin : null;
  TTagsFieldMixin? get _tagsFieldMixin => widget is TTagsFieldMixin ? widget as TTagsFieldMixin : null;

  T? _currentValue;

  /// The current value of the input.
  T? get currentValue => _currentValue;

  bool get hasValue => switch (currentValue) {
        String s => s.isNotEmpty,
        null => false,
        _ => true,
      };

  T? get _notifierValue => (_tagsFieldMixin != null
      ? _tagsFieldMixin?.textController?.value.tags
      : _textFieldMixin != null
          ? _textFieldMixin?.textController?.value.text
          : _widget.valueNotifier?.value) as T?;

  @override
  void initState() {
    super.initState();

    _currentValue = _notifierValue ?? _widget.value;

    _widget.valueNotifier?.addListener(_onValueNotifierChanged);

    if (_tagsFieldMixin != null) {
      _tagsFieldMixin?.textController?.addListener(_onTagsValueChanged);
    } else if (_textFieldMixin != null) {
      _textFieldMixin?.textController?.addListener(_onTextValueChanged);
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final initial = _notifierValue ?? _widget.value;
      if (initial != null) {
        _updateValue(initial, fromExternal: true, initial: true, force: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);

    //value notifier
    final oldMixin = oldWidget as TInputValueMixin<T>;
    final oldNotifier = oldMixin.valueNotifier;
    final newNotifier = _widget.valueNotifier;

    if (oldNotifier != newNotifier) {
      oldNotifier?.removeListener(_onValueNotifierChanged);
      newNotifier?.addListener(_onValueNotifierChanged);

      final newValue = newNotifier?.value;
      _updateValue(newValue, fromExternal: true);
    } else if (newNotifier == null) {
      final newValue = _widget.value;
      _updateValue(newValue, fromExternal: true);
    }

    if (_tagsFieldMixin != null) {
      // tags notifier
      final oldTagMixin = oldWidget is TTagsFieldMixin ? oldWidget as TTagsFieldMixin : null;
      final oldTagNotifier = oldTagMixin?.textController;
      final newTagNotifier = _tagsFieldMixin?.textController;

      if (oldTagNotifier != newTagNotifier) {
        oldTagNotifier?.removeListener(_onTagsValueChanged);
        newTagNotifier?.addListener(_onTagsValueChanged);

        final newValue = newTagNotifier?.value.tags;
        _updateValue(newValue as T?, fromExternal: true);
      }
    } else if (_textFieldMixin != null) {
      // text notifier
      final oldTextMixin = oldWidget is TTextFieldMixin ? oldWidget as TTextFieldMixin : null;
      final oldTextNotifier = oldTextMixin?.textController;
      final newTextNotifier = _textFieldMixin?.textController;

      if (oldTextNotifier != newTextNotifier) {
        oldTextNotifier?.removeListener(_onTextValueChanged);
        newTextNotifier?.addListener(_onTextValueChanged);

        final newValue = newTextNotifier?.value.text;
        _updateValue(newValue as T?, fromExternal: true);
      }
    }
  }

  @override
  void dispose() {
    _widget.valueNotifier?.removeListener(_onValueNotifierChanged);
    _tagsFieldMixin?.textController?.removeListener(_onTagsValueChanged);
    _textFieldMixin?.textController?.removeListener(_onTextValueChanged);
    super.dispose();
  }

  void _onValueNotifierChanged() {
    final newValue = _widget.valueNotifier!.value;
    _updateValue(newValue, fromExternal: true);
  }

  void _onTagsValueChanged() {
    final newValue = _tagsFieldMixin?.textController?.value.tags as T?;
    _updateValue(newValue, fromExternal: true);
  }

  void _onTextValueChanged() {
    final newValue = _textFieldMixin?.textController?.value.text as T?;
    _updateValue(newValue, fromExternal: true);
  }

  void _updateValue(T? newValue, {bool fromExternal = false, bool initial = false, bool force = false}) {
    if (force || newValue != currentValue) {
      final oldValue = _currentValue;
      _currentValue = newValue;
      onValueChanged(newValue, initial: initial, oldValue: oldValue);
      if (fromExternal) onExternalValueChanged(newValue);
    }
  }

  /// Updates the value and notifies listeners.
  void notifyValueChanged(T? newValue) {
    if (newValue != currentValue) {
      final oldValue = _currentValue;
      _currentValue = newValue;
      onValueChanged(newValue, oldValue: oldValue);
      _widget.onValueChanged?.call(newValue);
      _widget.valueNotifier?.value = newValue;

      if (_tagsFieldMixin != null) {
        _tagsFieldMixin?.textController?.value =
            _tagsFieldMixin?.textController?.value.copyWith(tags: (newValue ?? []) as List<String>) as TagsEditingValue;
      } else if (_textFieldMixin != null) {
        _textFieldMixin?.textController?.value =
            _textFieldMixin?.textController?.value.copyWith(text: (newValue ?? '') as String) as TextEditingValue;
      }
    }
  }

  /// Returns the type of the value being managed.
  ValueType getValueType() {
    return ValueType.from(T.toString());
  }

  @protected
  void onValueChanged(T? value, {bool initial = false, T? oldValue}) {
    final wasEmpty = switch (oldValue) {
      String s => s.isEmpty,
      null => true,
      _ => false,
    };

    final isEmpty = switch (value) {
      String s => s.isEmpty,
      null => true,
      _ => false,
    };

    if (wasEmpty != isEmpty) {
      setState(() {});
    }
  }

  @protected
  void onExternalValueChanged(T? value) {}
}
