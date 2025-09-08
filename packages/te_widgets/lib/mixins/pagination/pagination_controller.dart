part of 'pagination_mixin.dart';

class TPaginationController<T> {
  TPaginationNotifier<T>? _notifier;

  void _attach(TPaginationNotifier<T> notifier) {
    if (_notifier != null) {
      throw StateError('TPaginationController is already attached.');
    }

    _notifier = notifier;
  }

  void _detach(TPaginationNotifier<T> notifier) {
    if (_notifier != notifier) {
      throw StateError('Trying to detach a different widget.');
    }

    _notifier = null;
  }

  void addItem(T item, {TItemAddPosition position = TItemAddPosition.first}) {
    _notifier?.addItem(item, position: position);
  }

  void addItems(List<T> items, {TItemAddPosition position = TItemAddPosition.first}) {
    _notifier?.addItems(items, position: position);
  }

  void updateItem(T oldItem, T newItem) {
    _notifier?.updateItem(oldItem, newItem);
  }

  void removeItem(T item) {
    _notifier?.removeItem(item);
  }

  // Pagination controls
  void nextPage() => _notifier?.nextPage();
  void previousPage() => _notifier?.previousPage();
  void refresh() => _notifier?.refresh();

  TPaginationState<T>? get currentState => _notifier?.currentState;
}
