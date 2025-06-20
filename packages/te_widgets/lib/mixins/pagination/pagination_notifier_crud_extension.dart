part of 'pagination_notifier.dart';

extension TPaginationCrudExtension<T> on TPaginationNotifier<T> {
  void addItem(T item, {TItemAddPosition position = TItemAddPosition.first}) {
    final newState = currentState.copyWith(
      items: isServerSide ? currentState.items : _addToList(currentState.items, [item], position),
      paginatedItems: _addToList(currentState.paginatedItems, [item], position),
      totalItems: currentState.totalItems + 1,
    );

    updateState(newState);
  }

  void addItems(List<T> items, {TItemAddPosition position = TItemAddPosition.first}) {
    final newState = currentState.copyWith(
      items: isServerSide ? currentState.items : _addToList(currentState.items, items, position),
      paginatedItems: _addToList(currentState.paginatedItems, items, position),
      totalItems: currentState.totalItems + items.length,
    );

    updateState(newState);
  }

  void updateItem(T oldItem, T newItem) {
    final newState = currentState.copyWith(
      paginatedItems: _replaceInList(currentState.paginatedItems, oldItem, newItem),
      items: isServerSide ? currentState.items : _replaceInList(currentState.items, oldItem, newItem),
    );

    updateState(newState);
  }

  void removeItem(T item) {
    final newState = currentState.copyWith(
      items: isServerSide ? currentState.items : _removeFromList(currentState.items, item),
      paginatedItems: _removeFromList(currentState.paginatedItems, item),
      totalItems: currentState.totalItems - 1,
    );

    updateState(newState);
  }

  List<T> _addToList(List<T> currentItems, List<T> itemsToAdd, TItemAddPosition position) {
    final updatedItems = List<T>.from(currentItems);

    if (position == TItemAddPosition.first) {
      updatedItems.insertAll(0, itemsToAdd);
    } else {
      updatedItems.addAll(itemsToAdd);
    }

    return updatedItems;
  }

  List<T> _replaceInList(List<T> list, T oldItem, T newItem) {
    final newList = List<T>.from(list);
    final index = newList.indexOf(oldItem);
    if (index != -1) newList[index] = newItem;
    return newList;
  }

  List<T> _removeFromList(List<T> list, T item) {
    final newList = List<T>.from(list);
    newList.remove(item);
    return newList;
  }
}
