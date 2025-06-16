import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/mixins/popup_mixin.dart';
import 'package:te_widgets/widgets/select/select_dropdown.dart';
import 'package:te_widgets/widgets/select/select_notifier.dart';
import 'select_configs.dart';

mixin TSelectMixin<T, V> on TInputFieldMixin, TPopupMixin {
  List<T> get items;
  bool get multiLevel;
  bool get filterable;
  String? get footerMessage;

  ItemTextAccessor<T>? get itemText;
  ItemValueAccessor<T, V>? get itemValue;
  ItemKeyAccessor<T>? get itemKey;
  ItemChildrenAccessor<T>? get itemChildren;
  IconData? get selectedIcon;
}

mixin TSelectStateMixin<T, V, W extends StatefulWidget> on State<W>, TPopupStateMixin<W> {
  TSelectMixin<T, V> get _widget => widget as TSelectMixin<T, V>;

  late TSelectStateNotifier<T, V> stateNotifier;

  bool get isMultiple;

  @override
  void initState() {
    super.initState();
    stateNotifier = TSelectStateNotifier<T, V>(
      items: _widget.items,
      isMultiple: isMultiple,
      itemText: _widget.itemText,
      itemValue: _widget.itemValue,
      itemKey: _widget.itemKey,
      itemChildren: _widget.itemChildren,
      label: _widget.label,
    );

    updateSelectedStates();
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSelectWidget = oldWidget as TSelectMixin<T, V>;
    if (_widget.items != oldSelectWidget.items) {
      stateNotifier.updateItems(_widget.items);
      updateSelectedStates();
    }
  }

  @override
  void dispose() {
    stateNotifier.dispose();
    super.dispose();
  }

  @override
  double getContentHeight() {
    const double itemHeight = 50.0;
    const double padding = 16.0;
    const double footerHeight = 24.0;

    int visibleItemCount = stateNotifier.countVisibleItems(stateNotifier.filteredItems);
    double estimatedHeight = visibleItemCount * itemHeight + padding;

    if (_widget.footerMessage?.isNotEmpty == true) {
      estimatedHeight += footerHeight;
    }

    return math.min(estimatedHeight, _widget.dropdownMaxHeight ?? 200);
  }

  @override
  Widget getContentWidget() {
    return TSelectDropdown<T, V>(
      stateNotifier: stateNotifier,
      footerMessage: _widget.footerMessage,
      multiple: isMultiple,
      selectedIcon: _widget.selectedIcon,
      onItemTapped: onItemTapped,
    );
  }

  void onSearchChanged(String value) {
    stateNotifier.onSearchChanged(value);
  }

  void updateSelectedStates();
  void onItemTapped(TSelectItem<V> item);
}
