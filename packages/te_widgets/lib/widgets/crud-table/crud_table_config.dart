import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TCrudConfig<T, K> {
  final Future<bool> Function(T)? canView;
  final Future<bool> Function(T)? canEdit;
  final Future<bool> Function(T)? canDelete;
  final Future<bool> Function(T)? canArchive;
  final Future<bool> Function(T)? canRestore;

  // UI Labels
  final String addButtonText;
  final List<TTab<int>> tabs;
  final List<TCrudTableContent<T, K>> tabContents;
  final String searchPlaceholder;

  // Action visibility
  final bool showActions;

  final int itemsPerPage;
  final List<int> itemsPerPageOptions;

  final List<TCrudCustomAction<T>> activeActions;
  final List<TCrudCustomAction<T>> archiveActions;

  final List<Widget> topBarActions;
  final TListInteraction<T>? interaction;

  const TCrudConfig({
    this.canView,
    this.canEdit,
    this.canDelete,
    this.canArchive,
    this.canRestore,
    this.addButtonText = 'Add New',
    this.tabs = const [TTab(text: "Active", value: 0), TTab(text: "Archive", value: 1)],
    this.tabContents = const [],
    this.searchPlaceholder = 'Search...',
    this.showActions = true,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions = const [5, 10, 15, 25, 50],
    this.activeActions = const [],
    this.archiveActions = const [],
    this.topBarActions = const [],
    this.interaction,
  });
}

class TCrudCustomAction<T> {
  final String tooltip;
  final IconData icon;
  final Color color;
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
