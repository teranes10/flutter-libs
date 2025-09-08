part of 'table.dart';

class TTableController<T> {
  TTable<T>? _widget;
  ValueNotifier<Set<int>>? _expanded;
  ValueNotifier<Set<int>>? _selected;

  TTable<T> get widget {
    assert(_widget != null, 'TTableController is not attached.');
    return _widget!;
  }

  ValueNotifier<Set<int>> get expanded {
    assert(_expanded != null, 'TTableController not attached.');
    return _expanded!;
  }

  ValueNotifier<Set<int>> get selected {
    assert(_selected != null, 'TTableController not attached.');
    return _selected!;
  }

  void _attach(TTable<T> widget) {
    if (_widget != null) {
      throw StateError('TTableController is already attached.');
    }

    _widget = widget;
    _expanded = ValueNotifier(<int>{});
    _selected = ValueNotifier(<int>{});
  }

  void _update(TTable<T> widget) {
    _widget = widget;
  }

  void _detach(TTable<T> widget) {
    if (_widget != widget) {
      throw StateError('Trying to detach a different widget.');
    }

    _expanded?.dispose();
    _selected?.dispose();

    _expanded = null;
    _selected = null;
    _widget = null;
  }

  List<T> get items => widget.items;
  List<T> get selectedItems => selected.value.map((i) => items[i]).toList();
  List<T> get expandedItems => expanded.value.map((i) => items[i]).toList();

  // State management methods
  bool isExpanded(int index) => expanded.value.contains(index);
  bool isSelected(int index) => selected.value.contains(index);

  void toggleExpansion(int index) {
    final newExpanded = Set<int>.from(expanded.value);

    if (widget.singleExpand) {
      if (newExpanded.contains(index)) {
        newExpanded.clear();
      } else {
        newExpanded
          ..clear()
          ..add(index);
      }
    } else {
      if (newExpanded.contains(index)) {
        newExpanded.remove(index);
      } else {
        newExpanded.add(index);
      }
    }

    expanded.value = newExpanded;
  }

  void toggleSelection(int index) {
    final newSelected = Set<int>.from(selected.value);

    if (widget.singleSelect) {
      if (newSelected.contains(index)) {
        newSelected.clear();
      } else {
        newSelected
          ..clear()
          ..add(index);
      }
    } else {
      if (newSelected.contains(index)) {
        newSelected.remove(index);
      } else {
        newSelected.add(index);
      }
    }

    selected.value = newSelected;
  }

  void toggleSelectAll() {
    final newSelected = Set<int>.from(selected.value);

    if (newSelected.length == widget.items.length) {
      newSelected.clear();
    } else {
      newSelected.clear();
      for (int i = 0; i < widget.items.length; i++) {
        newSelected.add(i);
      }
    }

    selected.value = newSelected;
  }
}
