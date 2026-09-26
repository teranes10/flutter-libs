import 'dart:async';
import 'package:flutter/material.dart';
import 'package:te_widgets/extensions/build_context_x.dart';
import 'package:te_widgets/widgets/icon/icon.dart';

/// Selection mode for [TTreeView].
enum TTreeSelectionMode {
  /// Nodes are not selectable.
  none,

  /// Only one node can be selected at a time.
  single,

  /// Multiple nodes can be selected simultaneously with checkboxes.
  multi,
}

/// A node in a [TTreeView].
class TTreeNode<T> {
  /// Unique key identifying this node.
  final String key;

  /// Display text label.
  final String label;

  /// Optional underlying model/data payload.
  final T? data;

  /// Optional icon when collapsed or if leaf.
  final dynamic icon;

  /// Optional icon when expanded.
  final dynamic expandedIcon;

  /// Child nodes nested under this node.
  final List<TTreeNode<T>> children;

  /// Explicit flag whether this node is a terminal leaf.
  final bool? isLeaf;

  /// Whether this node has no children and is a leaf.
  bool get isLeafNode => isLeaf ?? children.isEmpty;

  /// Whether this node is currently loading children asynchronously.
  final bool isLoading;

  /// Optional badge string shown beside label.
  final String? badge;

  /// Optional trailing widget (e.g. actions, counter).
  final Widget? trailing;

  /// Whether this node can be selected.
  final bool isSelectable;

  /// Whether this node is disabled.
  final bool isDisabled;

  const TTreeNode({
    required this.key,
    required this.label,
    this.data,
    this.icon,
    this.expandedIcon,
    this.children = const [],
    this.isLeaf,
    this.isLoading = false,
    this.badge,
    this.trailing,
    this.isSelectable = true,
    this.isDisabled = false,
  });

  /// Creates a copy of this node with updated attributes.
  TTreeNode<T> copyWith({
    String? key,
    String? label,
    T? data,
    dynamic icon,
    dynamic expandedIcon,
    List<TTreeNode<T>>? children,
    bool? isLeaf,
    bool? isLoading,
    String? badge,
    Widget? trailing,
    bool? isSelectable,
    bool? isDisabled,
  }) {
    return TTreeNode<T>(
      key: key ?? this.key,
      label: label ?? this.label,
      data: data ?? this.data,
      icon: icon ?? this.icon,
      expandedIcon: expandedIcon ?? this.expandedIcon,
      children: children ?? this.children,
      isLeaf: isLeaf ?? this.isLeaf,
      isLoading: isLoading ?? this.isLoading,
      badge: badge ?? this.badge,
      trailing: trailing ?? this.trailing,
      isSelectable: isSelectable ?? this.isSelectable,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }
}

/// An interactive hierarchical tree widget supporting single/multi-selection,
/// tri-state checkboxes, search filtering with auto-expansion, connecting lines,
/// and async child node loading.
class TTreeView<T> extends StatefulWidget {
  /// Root nodes to display.
  final List<TTreeNode<T>> nodes;

  /// Selection mode (none, single, or multi).
  final TTreeSelectionMode selectionMode;

  /// Currently selected keys.
  final Set<String>? selectedKeys;

  /// Currently expanded keys.
  final Set<String>? expandedKeys;

  /// Callback fired when node selection changes.
  final ValueChanged<Set<String>>? onSelectionChanged;

  /// Callback fired when a node is clicked.
  final ValueChanged<TTreeNode<T>>? onNodeTap;

  /// Callback fired when a node is expanded or collapsed.
  final void Function(TTreeNode<T> node, bool isExpanded)? onNodeExpanded;

  /// Async callback to load child nodes on expand.
  final FutureOr<List<TTreeNode<T>>> Function(TTreeNode<T> node)? onLoadChildren;

  /// Whether to render connecting tree branch lines.
  final bool showConnectingLines;

  /// Optional query to filter nodes by label. Matches auto-expand parent branches.
  final String? searchQuery;

  /// Indentation width per tree depth level.
  final double indentWidth;

  /// Custom node content builder.
  final Widget Function(BuildContext context, TTreeNode<T> node, bool isExpanded, bool isSelected)? nodeBuilder;

  const TTreeView({
    super.key,
    required this.nodes,
    this.selectionMode = TTreeSelectionMode.single,
    this.selectedKeys,
    this.expandedKeys,
    this.onSelectionChanged,
    this.onNodeTap,
    this.onNodeExpanded,
    this.onLoadChildren,
    this.showConnectingLines = true,
    this.searchQuery,
    this.indentWidth = 24.0,
    this.nodeBuilder,
  });

  @override
  State<TTreeView<T>> createState() => _TTreeViewState<T>();
}

class _TTreeViewState<T> extends State<TTreeView<T>> {
  late Set<String> _selectedKeys;
  late Set<String> _expandedKeys;
  final Set<String> _loadingKeys = {};
  final Map<String, List<TTreeNode<T>>> _dynamicChildren = {};

  @override
  void initState() {
    super.initState();
    _selectedKeys = Set<String>.from(widget.selectedKeys ?? {});
    _expandedKeys = Set<String>.from(widget.expandedKeys ?? {});
  }

  @override
  void didUpdateWidget(TTreeView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedKeys != null && widget.selectedKeys != oldWidget.selectedKeys) {
      _selectedKeys = Set<String>.from(widget.selectedKeys!);
    }
    if (widget.expandedKeys != null && widget.expandedKeys != oldWidget.expandedKeys) {
      _expandedKeys = Set<String>.from(widget.expandedKeys!);
    }
  }

  void _toggleExpanded(TTreeNode<T> node) async {
    final isExpanded = _expandedKeys.contains(node.key);
    setState(() {
      if (isExpanded) {
        _expandedKeys.remove(node.key);
      } else {
        _expandedKeys.add(node.key);
      }
    });

    widget.onNodeExpanded?.call(node, !isExpanded);

    // Handle lazy child loading
    if (!isExpanded &&
        widget.onLoadChildren != null &&
        node.children.isEmpty &&
        !node.isLeafNode &&
        !_dynamicChildren.containsKey(node.key)) {
      setState(() => _loadingKeys.add(node.key));
      try {
        final loaded = await widget.onLoadChildren!(node);
        if (mounted) {
          setState(() {
            _dynamicChildren[node.key] = loaded;
            _loadingKeys.remove(node.key);
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _loadingKeys.remove(node.key));
        }
      }
    }
  }

  void _handleNodeSelect(TTreeNode<T> node) {
    if (node.isDisabled || !node.isSelectable) return;

    if (widget.selectionMode == TTreeSelectionMode.single) {
      setState(() {
        _selectedKeys = {node.key};
      });
      widget.onSelectionChanged?.call(_selectedKeys);
    } else if (widget.selectionMode == TTreeSelectionMode.multi) {
      final isSelected = _selectedKeys.contains(node.key);
      final newSelection = Set<String>.from(_selectedKeys);

      // Select / deselect node and all its descendants recursively
      void toggleDescendants(TTreeNode<T> n, bool select) {
        if (!n.isDisabled && n.isSelectable) {
          if (select) {
            newSelection.add(n.key);
          } else {
            newSelection.remove(n.key);
          }
        }
        final children = _dynamicChildren[n.key] ?? n.children;
        for (final child in children) {
          toggleDescendants(child, select);
        }
      }

      toggleDescendants(node, !isSelected);

      setState(() {
        _selectedKeys = newSelection;
      });
      widget.onSelectionChanged?.call(_selectedKeys);
    }

    widget.onNodeTap?.call(node);
  }

  /// Calculates checkbox state: checked (true), unchecked (false), or indeterminate (null).
  bool? _getCheckboxState(TTreeNode<T> node) {
    final children = _dynamicChildren[node.key] ?? node.children;
    if (children.isEmpty) {
      return _selectedKeys.contains(node.key);
    }

    int selectedCount = 0;
    int totalCount = 0;

    void countSelected(TTreeNode<T> n) {
      totalCount++;
      if (_selectedKeys.contains(n.key)) {
        selectedCount++;
      }
      final subs = _dynamicChildren[n.key] ?? n.children;
      for (final sub in subs) {
        countSelected(sub);
      }
    }

    for (final child in children) {
      countSelected(child);
    }

    if (selectedCount == 0) {
      return _selectedKeys.contains(node.key) ? null : false;
    } else if (selectedCount == totalCount && _selectedKeys.contains(node.key)) {
      return true;
    } else {
      return null; // Indeterminate
    }
  }

  /// Determines if a node or any of its descendants matches the search query.
  bool _nodeMatchesSearch(TTreeNode<T> node, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    if (node.label.toLowerCase().contains(q)) return true;
    final children = _dynamicChildren[node.key] ?? node.children;
    for (final child in children) {
      if (_nodeMatchesSearch(child, query)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final query = (widget.searchQuery ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: widget.nodes
          .where((node) => _nodeMatchesSearch(node, query))
          .map((node) => _buildNode(node, 0, query))
          .toList(),
    );
  }

  Widget _buildNode(TTreeNode<T> node, int depth, String query) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final children = _dynamicChildren[node.key] ?? node.children;
    final hasChildren = children.isNotEmpty || (!node.isLeafNode && widget.onLoadChildren != null);
    final isLoading = _loadingKeys.contains(node.key) || node.isLoading;

    // Auto-expand path if search query matches descendants
    final shouldAutoExpand = query.isNotEmpty && _nodeMatchesSearch(node, query);
    final isExpanded = _expandedKeys.contains(node.key) || shouldAutoExpand;
    final isSelected = _selectedKeys.contains(node.key);
    final checkboxState = _getCheckboxState(node);

    final defaultIcon = hasChildren
        ? (isExpanded ? Icons.folder_open_rounded : Icons.folder_rounded)
        : Icons.insert_drive_file_outlined;

    final effectiveIcon = (isExpanded ? (node.expandedIcon ?? node.icon) : node.icon) ?? defaultIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Node Row
        InkWell(
          onTap: node.isDisabled
              ? null
              : () {
                  if (hasChildren && widget.selectionMode == TTreeSelectionMode.none) {
                    _toggleExpanded(node);
                  } else {
                    _handleNodeSelect(node);
                  }
                },
          borderRadius: BorderRadius.circular(6.0),
          child: Container(
            padding: EdgeInsets.only(left: depth * widget.indentWidth, right: 8.0, top: 4.0, bottom: 4.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? (colors.primaryContainer.withValues(alpha: isDark ? 0.35 : 0.5))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Row(
              children: [
                // Expand / Collapse Chevron or Spacer
                if (hasChildren)
                  InkWell(
                    onTap: () => _toggleExpanded(node),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: isLoading
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                            )
                          : AnimatedRotation(
                              turns: isExpanded ? 0.25 : 0.0,
                              duration: const Duration(milliseconds: 150),
                              child: Icon(Icons.chevron_right_rounded, size: 16, color: colors.onSurfaceVariant),
                            ),
                    ),
                  )
                else
                  const SizedBox(width: 24),

                // Multi-select Checkbox
                if (widget.selectionMode == TTreeSelectionMode.multi) ...[
                  InkWell(
                    onTap: node.isDisabled ? null : () => _handleNodeSelect(node),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: checkboxState == true
                              ? colors.primary
                              : (checkboxState == null ? colors.primary.withValues(alpha: 0.2) : Colors.transparent),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: checkboxState != false ? colors.primary : colors.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                        child: checkboxState == true
                            ? Icon(Icons.check, size: 12, color: colors.onPrimary)
                            : (checkboxState == null
                                ? Icon(Icons.remove, size: 12, color: colors.primary)
                                : null),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],

                // Node Icon
                TIcon(
                  icon: effectiveIcon,
                  size: 16,
                  color: isSelected
                      ? colors.primary
                      : (node.isDisabled ? colors.onSurfaceVariant.withValues(alpha: 0.4) : colors.primary),
                ),
                const SizedBox(width: 8),

                // Label
                Expanded(
                  child: Text(
                    node.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: node.isDisabled
                          ? colors.onSurfaceVariant.withValues(alpha: 0.4)
                          : (isSelected ? colors.primary : colors.onSurface),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Badge
                if (node.badge != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      node.badge!,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant),
                    ),
                  ),
                ],

                // Trailing
                if (node.trailing != null) ...[
                  const SizedBox(width: 6),
                  node.trailing!,
                ],
              ],
            ),
          ),
        ),

        // Children subtree
        if (hasChildren && isExpanded)
          Stack(
            children: [
              // Connecting line
              if (widget.showConnectingLines && depth >= 0)
                Positioned(
                  left: (depth * widget.indentWidth) + 11.0,
                  top: 0,
                  bottom: 4,
                  child: Container(
                    width: 1.0,
                    color: colors.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),

              // Render children
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: children
                    .where((child) => _nodeMatchesSearch(child, query))
                    .map((child) => _buildNode(child, depth + 1, query))
                    .toList(),
              ),
            ],
          ),
      ],
    );
  }
}
