part of 'list_controller.dart';

/// Extension providing error handling, item editing/creation, and additional state actions for [TListController].
extension TListControllerActions<T, K> on TListController<T, K> {
  /// Clears any error state.
  void clearError() {
    if (value.error != null) {
      updateState(who: 'clearError', error: null);
    }
  }

  /// Sets an error state on the list.
  void handleError(TListError error) {
    updateState(who: 'handleError', error: error);
  }

  /// Helper to wrap exception and stacktrace into a [TListError].
  void updateError(Object e, StackTrace st) {
    handleError(TListError(message: e.toString(), error: e, stackTrace: st));
  }

  /// Puts the list into a loading state.
  void updateLoading() {
    updateState(who: 'handleLoading', loading: true);
  }

  /// Cancels all pending debouncer timers and network requests.
  void cancelPendingOperations() {
    _debouncer.cancel();
    _activeRequests.clear();
  }

  /// Puts the list into a state ready to create a new item.
  void beginCreateItem({bool clearEditingItem = true}) {
    updateState(
      who: 'beginCreateItem',
      isCreatingItem: true,
      clearEditingItem: clearEditingItem,
    );
  }

  /// Cancels the create item state.
  void cancelCreateItem() {
    updateState(who: 'cancelCreateItem', isCreatingItem: false);
  }

  /// Puts the list into a state ready to edit an item key.
  void beginEditItemKey(K key) {
    updateState(
      who: 'beginEditItem',
      editingItemKey: key,
    );
  }

  /// Puts the list into a state ready to edit an item.
  void beginEditItem(T item) => beginEditItemKey(itemKey(item));

  /// Cancels the edit item state.
  void cancelEditItem() {
    updateState(who: 'cancelEditItem', clearEditingItem: true);
  }

  /// Sets a value in the additional state and notifies listeners if it changed.
  void setAdditionalState(String key, dynamic value) {
    final map = Map<String, dynamic>.from(this.value.additional);
    if (map[key] != value) {
      map[key] = value;
      updateState(who: 'setAdditionalState', additional: map);
    }
  }

  /// Clears the additional state and notifies listeners.
  void clearAdditionalState() {
    if (value.additional.isNotEmpty) {
      updateState(who: 'clearAdditionalState', additional: const {});
    }
  }
}
