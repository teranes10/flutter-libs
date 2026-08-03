part of 'list_controller.dart';

/// Extension providing row detail expanded content functionality for [TListController].
///
/// Manages row detail view expansion (`expandedContentKey`), active editing item key (`editingItemKey`),
/// and the associated [additional] state map for custom expanded content tabs/views.
extension TListControllerDetailExpansion<T, K> on TListController<T, K> {
  /// Key of the currently expanded detail content item.
  K? get expandedDetailKey => value.expandedDetailKey;

  /// Key of the item currently being edited.
  K? get editingItemKey => value.editingItemKey;

  /// Whether any row detail content is currently expanded.
  bool get hasExpandedContent => expandedDetailKey != null;

  bool isDetailExpanded(K key) => expandedDetailKey == key;

  /// Expands detail content for a specific item key.
  /// Automatically clears any active edit item key, ensuring only one view/edit mode is active.
  void expandDetail(K key, {Map<String, dynamic>? additional, bool clearEditingItem = true}) {
    final Map<String, dynamic>? mergedAdditional = additional != null ? {...value.additional, ...additional} : null;

    updateState(
      who: 'expandDetail',
      expandedDetailKey: key,
      clearEditingItem: clearEditingItem,
      additional: mergedAdditional,
    );
  }

  /// Collapses expanded detail content.
  void collapseDetail() {
    updateState(
      who: 'collapseDetail',
      clearExpandedDetail: true,
    );
  }

  /// Toggles detail content expansion for a specific item key.
  void toggleContentKey(K key, {Map<String, dynamic>? additional}) {
    if (expandedDetailKey == key) {
      collapseDetail();
    } else {
      expandDetail(key, additional: additional);
    }
  }
}
