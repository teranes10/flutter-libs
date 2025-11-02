import 'package:flutter/widgets.dart';

class TagsEditingValue extends TextEditingValue {
  final List<String> tags;

  const TagsEditingValue({
    super.text = '',
    super.selection = const TextSelection.collapsed(offset: 0),
    super.composing = TextRange.empty,
    this.tags = const [],
  });

  @override
  TagsEditingValue copyWith({
    String? text,
    TextSelection? selection,
    TextRange? composing,
    List<String>? tags,
  }) {
    return TagsEditingValue(
      text: text ?? this.text,
      selection: selection ?? this.selection,
      composing: composing ?? this.composing,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() => 'TagsEditingValue(text: $text, selection: $selection, composing: $composing, tags: $tags)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TagsEditingValue) return false;

    return text == other.text && selection == other.selection && composing == other.composing && _listEquals(tags, other.tags);
  }

  @override
  int get hashCode => Object.hash(text, selection, composing, Object.hashAll(tags));

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class TTagsController extends TextEditingController {
  final bool allowDuplicates;
  final bool caseSensitive;
  final List<String> delimiters;
  final void Function(String)? onTagAdded;
  final void Function(String)? onTagRemoved;

  late TagsEditingValue _value;

  TTagsController({
    List<String>? tags,
    String? text,
    this.allowDuplicates = false,
    this.caseSensitive = true,
    this.delimiters = const [',', ';', '\n'],
    this.onTagAdded,
    this.onTagRemoved,
  }) : super(text: text) {
    _value = TagsEditingValue(
      text: text ?? '',
      selection: TextSelection.collapsed(offset: text?.length ?? 0),
      tags: tags ?? [],
    );
  }

  @override
  TagsEditingValue get value => _value;

  @override
  set value(TextEditingValue newValue) {
    if (newValue is TagsEditingValue) {
      _value = newValue;
    } else {
      _value = TagsEditingValue(
        text: newValue.text,
        selection: newValue.selection,
        composing: newValue.composing,
        tags: _value.tags,
      );
    }
    notifyListeners();
  }

  List<String> get tags => _value.tags;

  String get filterText => _value.text;

  String get trimmedFilterText => filterText.trim();

  bool get hasFilterText => trimmedFilterText.isNotEmpty;

  bool hasTag(String tag) {
    if (caseSensitive) {
      return tags.contains(tag);
    }
    final lowerTag = tag.toLowerCase();
    return tags.any((t) => t.toLowerCase() == lowerTag);
  }

  void addTagFromInput() {
    var input = trimmedFilterText;
    if (input.isEmpty) return;

    if (delimiters.any((d) => input.contains(d))) {
      for (final delimiter in delimiters) {
        input = input.replaceAll(delimiter, ',');
      }

      final extractedTags = input
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .where((tag) => allowDuplicates || !hasTag(tag))
          .toList();

      if (extractedTags.isEmpty) return;

      final updatedTags = [...tags, ...extractedTags];
      _value = _value.copyWith(
        tags: updatedTags,
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );

      if (onTagAdded != null) {
        for (var tag in extractedTags) {
          onTagAdded?.call(tag);
        }
      }
      notifyListeners();
    } else {
      if (allowDuplicates || !hasTag(input)) {
        final newTags = [...tags, input];
        _value = _value.copyWith(
          tags: newTags,
          text: '',
          selection: const TextSelection.collapsed(offset: 0),
        );

        onTagAdded?.call(input);
        notifyListeners();
      } else {
        _value = _value.copyWith(
          text: '',
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    }
  }

  bool addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return false;
    if (!allowDuplicates && hasTag(trimmed)) return false;

    final newTags = [...tags, trimmed];
    _value = _value.copyWith(tags: newTags);

    onTagAdded?.call(tag);
    notifyListeners();
    return true;
  }

  bool removeTag(String tag) {
    if (!hasTag(tag)) return false;

    final newTags = tags.where((t) => t != tag).toList();
    _value = _value.copyWith(tags: newTags);

    onTagRemoved?.call(tag);
    notifyListeners();
    return true;
  }

  String? removeLastTag() {
    if (tags.isEmpty) return null;

    final lastTag = tags.last;
    final newTags = tags.sublist(0, tags.length - 1);
    _value = _value.copyWith(tags: newTags);

    onTagRemoved?.call(lastTag);
    notifyListeners();
    return lastTag;
  }

  String? removeTagAt(int index) {
    if (index < 0 || index >= tags.length) return null;

    final removedTag = tags[index];
    final newTags = [...tags]..removeAt(index);
    _value = _value.copyWith(tags: newTags);

    onTagRemoved?.call(removedTag);
    notifyListeners();
    return removedTag;
  }

  void updateState({String? text, List<String>? tags}) {
    final resolvedText = text ?? value.text;

    _value = _value.copyWith(
      text: resolvedText,
      tags: tags ?? value.tags,
      selection: TextSelection.collapsed(offset: resolvedText.length),
    );
    notifyListeners();
  }

  void clearAll() {
    _value = TagsEditingValue(
      text: '',
      selection: const TextSelection.collapsed(offset: 0),
      composing: TextRange.empty,
      tags: const [],
    );
    notifyListeners();
  }
}
