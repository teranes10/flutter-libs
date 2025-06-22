import 'package:flutter/material.dart';

class TCrudConfig<T> {
  final Future<bool> Function(T)? canView;
  final Future<bool> Function(T)? canEdit;
  final Future<bool> Function(T)? canDelete;
  final Future<bool> Function(T)? canArchive;
  final Future<bool> Function(T)? canRestore;

  // UI Labels
  final String addButtonText;
  final String activeTabText;
  final String archiveTabText;
  final String searchPlaceholder;

  // Action visibility
  final bool showActions;

  final int itemsPerPage;
  final List<int> itemsPerPageOptions;

  final List<TCrudCustomAction<T>> activeActions;
  final List<TCrudCustomAction<T>> archiveActions;

  final List<Widget> topBarActions;

  const TCrudConfig({
    this.canView,
    this.canEdit,
    this.canDelete,
    this.canArchive,
    this.canRestore,
    this.addButtonText = 'Add New',
    this.activeTabText = 'Active',
    this.archiveTabText = 'Archive',
    this.searchPlaceholder = 'Search...',
    this.showActions = true,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions = const [5, 10, 15, 25, 50],
    this.activeActions = const [],
    this.archiveActions = const [],
    this.topBarActions = const [],
  });
}

class TCrudCustomAction<T> {
  final String tooltip;
  final IconData icon;
  final MaterialColor color;
  final Future<void> Function(T item) onPressed;
  final Future<bool> Function(T item)? canPerform;

  const TCrudCustomAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.canPerform,
  });
}
