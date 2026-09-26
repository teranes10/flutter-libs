import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A dual-list transfer shuttle component for moving items between source and target lists.
///
/// Ideal for admin scenarios such as role/permission assignment, user group management,
/// column picker configurations, and batch multi-select workflows.
class TTransferList<T> extends StatefulWidget {
  /// The collection of available items in the source pool.
  final List<T> sourceItems;

  /// The collection of assigned / selected items in the target pool.
  final List<T> targetItems;

  /// Callback fired when the target items list changes (items transferred or reordered).
  final ValueChanged<List<T>> onTargetChanged;

  /// Optional callback fired when the source items list changes.
  final ValueChanged<List<T>>? onSourceChanged;

  /// Function to extract the display string for an item. Defaults to `item.toString()`.
  final String Function(T item)? itemLabel;

  /// Function to extract an optional secondary subtitle/description for an item.
  final String Function(T item)? itemSubtitle;

  /// Custom builder for item rows.
  final Widget Function(BuildContext context, T item, bool isChecked)? itemBuilder;

  /// Function to determine if an item is disabled from transfer.
  final bool Function(T item)? itemDisabled;

  /// Title for the source list card. Defaults to "Available".
  final String sourceTitle;

  /// Title for the target list card. Defaults to "Selected".
  final String targetTitle;

  /// Whether to show search filter fields at the top of each list. Defaults to true.
  final bool showSearch;

  /// Whether to show "Select All" checkboxes in the list headers. Defaults to true.
  final bool showSelectAll;

  /// Whether to display Up / Down buttons to allow reordering the target list. Defaults to false.
  final bool allowReordering;

  /// Fixed height of the transfer list containers. Defaults to 360.0.
  final double height;

  /// Width of each list card. Defaults to 260.0.
  final double boxWidth;

  const TTransferList({
    super.key,
    required this.sourceItems,
    required this.targetItems,
    required this.onTargetChanged,
    this.onSourceChanged,
    this.itemLabel,
    this.itemSubtitle,
    this.itemBuilder,
    this.itemDisabled,
    this.sourceTitle = 'Available',
    this.targetTitle = 'Selected',
    this.showSearch = true,
    this.showSelectAll = true,
    this.allowReordering = false,
    this.height = 360.0,
    this.boxWidth = 260.0,
  });

  @override
  State<TTransferList<T>> createState() => _TTransferListState<T>();
}

class _TTransferListState<T> extends State<TTransferList<T>> {
  final Set<T> _checkedSource = <T>{};
  final Set<T> _checkedTarget = <T>{};

  String _sourceSearch = '';
  String _targetSearch = '';

  late final TextEditingController _sourceSearchCtrl;
  late final TextEditingController _targetSearchCtrl;

  @override
  void initState() {
    super.initState();
    _sourceSearchCtrl = TextEditingController();
    _targetSearchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _sourceSearchCtrl.dispose();
    _targetSearchCtrl.dispose();
    super.dispose();
  }

  String _getItemText(T item) {
    if (widget.itemLabel != null) return widget.itemLabel!(item);
    return item.toString();
  }

  bool _isItemDisabled(T item) {
    return widget.itemDisabled?.call(item) ?? false;
  }

  List<T> _filteredSource() {
    if (_sourceSearch.trim().isEmpty) return widget.sourceItems;
    final q = _sourceSearch.trim().toLowerCase();
    return widget.sourceItems.where((i) => _getItemText(i).toLowerCase().contains(q)).toList();
  }

  List<T> _filteredTarget() {
    if (_targetSearch.trim().isEmpty) return widget.targetItems;
    final q = _targetSearch.trim().toLowerCase();
    return widget.targetItems.where((i) => _getItemText(i).toLowerCase().contains(q)).toList();
  }

  void _transferToTarget() {
    if (_checkedSource.isEmpty) return;
    final itemsToMove = _checkedSource.where((i) => !_isItemDisabled(i)).toList();
    if (itemsToMove.isEmpty) return;

    final newTarget = List<T>.from(widget.targetItems)..addAll(itemsToMove);
    final newSource = List<T>.from(widget.sourceItems)..removeWhere((i) => itemsToMove.contains(i));

    setState(() {
      _checkedSource.clear();
    });

    widget.onTargetChanged(newTarget);
    widget.onSourceChanged?.call(newSource);
  }

  void _transferAllToTarget() {
    final available = widget.sourceItems.where((i) => !_isItemDisabled(i)).toList();
    if (available.isEmpty) return;

    final newTarget = List<T>.from(widget.targetItems)..addAll(available);
    final newSource = List<T>.from(widget.sourceItems)..removeWhere((i) => available.contains(i));

    setState(() {
      _checkedSource.clear();
    });

    widget.onTargetChanged(newTarget);
    widget.onSourceChanged?.call(newSource);
  }

  void _transferToSource() {
    if (_checkedTarget.isEmpty) return;
    final itemsToMove = _checkedTarget.where((i) => !_isItemDisabled(i)).toList();
    if (itemsToMove.isEmpty) return;

    final newSource = List<T>.from(widget.sourceItems)..addAll(itemsToMove);
    final newTarget = List<T>.from(widget.targetItems)..removeWhere((i) => itemsToMove.contains(i));

    setState(() {
      _checkedTarget.clear();
    });

    widget.onTargetChanged(newTarget);
    widget.onSourceChanged?.call(newSource);
  }

  void _transferAllToSource() {
    final available = widget.targetItems.where((i) => !_isItemDisabled(i)).toList();
    if (available.isEmpty) return;

    final newSource = List<T>.from(widget.sourceItems)..addAll(available);
    final newTarget = List<T>.from(widget.targetItems)..removeWhere((i) => available.contains(i));

    setState(() {
      _checkedTarget.clear();
    });

    widget.onTargetChanged(newTarget);
    widget.onSourceChanged?.call(newSource);
  }

  void _moveTargetItemUp() {
    if (_checkedTarget.length != 1) return;
    final item = _checkedTarget.first;
    final index = widget.targetItems.indexOf(item);
    if (index > 0) {
      final updated = List<T>.from(widget.targetItems);
      updated.removeAt(index);
      updated.insert(index - 1, item);
      widget.onTargetChanged(updated);
    }
  }

  void _moveTargetItemDown() {
    if (_checkedTarget.length != 1) return;
    final item = _checkedTarget.first;
    final index = widget.targetItems.indexOf(item);
    if (index >= 0 && index < widget.targetItems.length - 1) {
      final updated = List<T>.from(widget.targetItems);
      updated.removeAt(index);
      updated.insert(index + 1, item);
      widget.onTargetChanged(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Source List Box
          SizedBox(
            width: widget.boxWidth,
            child: _buildListBox(
              title: widget.sourceTitle,
              items: _filteredSource(),
              totalItemsCount: widget.sourceItems.length,
              checkedSet: _checkedSource,
              searchController: _sourceSearchCtrl,
              onSearchChanged: (val) => setState(() => _sourceSearch = val),
              onToggleAll: (select) {
                setState(() {
                  if (select) {
                    final valid = _filteredSource().where((i) => !_isItemDisabled(i));
                    _checkedSource.addAll(valid);
                  } else {
                    _checkedSource.removeAll(_filteredSource());
                  }
                });
              },
            ),
          ),

          // Central Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildActionButtons(),
          ),

          // Target List Box
          SizedBox(
            width: widget.boxWidth,
            child: _buildListBox(
              title: widget.targetTitle,
              items: _filteredTarget(),
              totalItemsCount: widget.targetItems.length,
              checkedSet: _checkedTarget,
              searchController: _targetSearchCtrl,
              onSearchChanged: (val) => setState(() => _targetSearch = val),
              onToggleAll: (select) {
                setState(() {
                  if (select) {
                    final valid = _filteredTarget().where((i) => !_isItemDisabled(i));
                    _checkedTarget.addAll(valid);
                  } else {
                    _checkedTarget.removeAll(_filteredTarget());
                  }
                });
              },
            ),
          ),

          // Optional Reordering Controls
          if (widget.allowReordering) ...[
            const SizedBox(width: 8),
            _buildReorderButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildListBox({
    required String title,
    required List<T> items,
    required int totalItemsCount,
    required Set<T> checkedSet,
    required TextEditingController searchController,
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<bool> onToggleAll,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    final enabledFiltered = items.where((i) => !_isItemDisabled(i)).toList();
    final allChecked = enabledFiltered.isNotEmpty && enabledFiltered.every(checkedSet.contains);
    final someChecked = enabledFiltered.any(checkedSet.contains) && !allChecked;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Row(
              children: [
                if (widget.showSelectAll)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: allChecked ? true : (someChecked ? null : false),
                        tristate: true,
                        onChanged: (val) => onToggleAll(val ?? false),
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TBadge.standalone(
                  count: checkedSet.isNotEmpty ? checkedSet.length : items.length,
                  color: checkedSet.isNotEmpty ? theme.colorScheme.primary : Colors.grey.shade400,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),

          // Search Field
          if (widget.showSearch)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: SizedBox(
                height: 32,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: TextStyle(fontSize: 12, color: theme.hintColor),
                    prefixIcon: const Icon(Icons.search, size: 16),
                    prefixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    suffixIcon: searchController.text.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                            child: const Icon(Icons.clear, size: 14),
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: borderColor),
                    ),
                  ),
                ),
              ),
            ),

          // Item List
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        totalItemsCount == 0 ? 'No items' : 'No matching items',
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isChecked = checkedSet.contains(item);
                      final isDisabled = _isItemDisabled(item);

                      if (widget.itemBuilder != null) {
                        return InkWell(
                          onTap: isDisabled
                              ? null
                              : () {
                                  setState(() {
                                    if (isChecked) {
                                      checkedSet.remove(item);
                                    } else {
                                      checkedSet.add(item);
                                    }
                                  });
                                },
                          child: widget.itemBuilder!(context, item, isChecked),
                        );
                      }

                      return InkWell(
                        onTap: isDisabled
                            ? null
                            : () {
                                setState(() {
                                  if (isChecked) {
                                    checkedSet.remove(item);
                                  } else {
                                    checkedSet.add(item);
                                  }
                                });
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: isChecked,
                                  onChanged: isDisabled
                                      ? null
                                      : (val) {
                                          setState(() {
                                            if (val == true) {
                                              checkedSet.add(item);
                                            } else {
                                              checkedSet.remove(item);
                                            }
                                          });
                                        },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getItemText(item),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDisabled ? theme.disabledColor : null,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (widget.itemSubtitle != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.itemSubtitle!(item),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.hintColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canMoveRight = _checkedSource.isNotEmpty;
    final canMoveAllRight = widget.sourceItems.isNotEmpty;
    final canMoveLeft = _checkedTarget.isNotEmpty;
    final canMoveAllLeft = widget.targetItems.isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTransferBtn(
          icon: Icons.chevron_right,
          tooltip: 'Transfer Selected to Right',
          enabled: canMoveRight,
          onPressed: _transferToTarget,
        ),
        const SizedBox(height: 6),
        _buildTransferBtn(
          icon: Icons.keyboard_double_arrow_right,
          tooltip: 'Transfer All to Right',
          enabled: canMoveAllRight,
          onPressed: _transferAllToTarget,
        ),
        const SizedBox(height: 12),
        _buildTransferBtn(
          icon: Icons.chevron_left,
          tooltip: 'Transfer Selected to Left',
          enabled: canMoveLeft,
          onPressed: _transferToSource,
        ),
        const SizedBox(height: 6),
        _buildTransferBtn(
          icon: Icons.keyboard_double_arrow_left,
          tooltip: 'Transfer All to Left',
          enabled: canMoveAllLeft,
          onPressed: _transferAllToSource,
        ),
      ],
    );
  }

  Widget _buildReorderButtons() {
    final canReorder = _checkedTarget.length == 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTransferBtn(
          icon: Icons.arrow_upward,
          tooltip: 'Move Up',
          enabled: canReorder,
          onPressed: _moveTargetItemUp,
        ),
        const SizedBox(height: 6),
        _buildTransferBtn(
          icon: Icons.arrow_downward,
          tooltip: 'Move Down',
          enabled: canReorder,
          onPressed: _moveTargetItemDown,
        ),
      ],
    );
  }

  Widget _buildTransferBtn({
    required IconData icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: TButton(
        icon: icon,
        onTap: enabled ? onPressed : null,
        size: TSize.sm,
        type: TButtonType.outline,
      ),
    );
  }
}
