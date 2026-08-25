part of 'list_controller.dart';

/// Table-specific extensions for [TListController] to manage column visibility and ordering.
extension TTableListControllerExt<T, K> on TListController<T, K> {
  /// The order of table headers/columns.
  List<String> get headerOrder => List<String>.from(value.additional['headerOrder'] ?? const <String>[]);

  /// The visibility status of each table header/column.
  Map<String, bool> get headerVisibility => Map<String, bool>.from(value.additional['headerVisibility'] ?? const <String, bool>{});

  /// Updates the header visibility state reactively.
  void updateHeaderVisibility(String text, bool visible) {
    final newVisibility = Map<String, bool>.from(headerVisibility)..[text] = visible;
    final newAdditional = Map<String, dynamic>.from(value.additional)
      ..['headerVisibility'] = newVisibility;
    updateState(
      who: 'updateHeaderVisibility',
      additional: newAdditional,
    );
  }

  /// Updates the header order state reactively.
  void updateHeaderOrder(List<String> newOrder) {
    final newAdditional = Map<String, dynamic>.from(value.additional)
      ..['headerOrder'] = List<String>.from(newOrder);
    updateState(
      who: 'updateHeaderOrder',
      additional: newAdditional,
    );
  }

  /// Updates both header order and visibility reactively.
  void updateColumns(List<String> order, Map<String, bool> visibility) {
    final newAdditional = Map<String, dynamic>.from(value.additional)
      ..['headerOrder'] = List<String>.from(order)
      ..['headerVisibility'] = Map<String, bool>.from(visibility);
    updateState(
      who: 'updateColumns',
      additional: newAdditional,
    );
  }
}
