import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A dual-list transfer shuttle component for moving items between source and target lists.
///
/// Ideal for admin scenarios such as role/permission assignment, user group management,
/// column picker configurations, and batch multi-select workflows.
///
/// Each row has a quick action icon: `+` (turns green on hover) in the source list and
/// `x` (turns red on hover) in the target list. When [allowReordering] is enabled the
/// target list can be reordered by dragging the grip handle.
///
/// On narrow screens the two lists stack vertically and the transfer buttons become a
/// horizontal row between them.
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

  /// Custom builder for the item content (replaces the title/subtitle).
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

  /// Whether the target list can be reordered by dragging. Defaults to false.
  ///
  /// Dragging is disabled while the target search field is not empty.
  final bool allowReordering;

  /// Height of the scrollable area of each list. Defaults to 300.0.
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
    this.height = 300.0,
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

  String _label(T item) => widget.itemLabel?.call(item) ?? item.toString();

  bool _isDisabled(T item) => widget.itemDisabled?.call(item) ?? false;

  List<T> _filter(List<T> items, String search) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((i) => _label(i).toLowerCase().contains(q)).toList();
  }

  /// Moves [moving] from one pool to the other and notifies the parent.
  void _move(Iterable<T> moving, {required bool toTarget}) {
    final items = moving.where((i) => !_isDisabled(i)).toList();
    if (items.isEmpty) return;

    final newTarget = List<T>.from(widget.targetItems);
    final newSource = List<T>.from(widget.sourceItems);
    if (toTarget) {
      newSource.removeWhere(items.contains);
      newTarget.addAll(items);
    } else {
      newTarget.removeWhere(items.contains);
      newSource.addAll(items);
    }

    setState(() {
      _checkedSource.removeAll(items);
      _checkedTarget.removeAll(items);
    });

    widget.onTargetChanged(newTarget);
    widget.onSourceChanged?.call(newSource);
  }

  void _reorderTarget(int oldIndex, int newIndex) {
    final updated = List<T>.from(widget.targetItems);
    updated.insert(newIndex, updated.removeAt(oldIndex));
    widget.onTargetChanged(updated);
  }

  void _toggleAll(Set<T> checked, List<T> visible, bool select) {
    setState(() {
      if (select) {
        checked.addAll(visible.where((i) => !_isDisabled(i)));
      } else {
        checked.removeAll(visible);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final source = _buildPanel(isTarget: false);
    final target = _buildPanel(isTarget: true);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < widget.boxWidth * 2 + 72;

        if (stacked) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              source,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildActions(vertical: false),
              ),
              target,
            ],
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: widget.boxWidth, child: source),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildActions(vertical: true),
            ),
            SizedBox(width: widget.boxWidth, child: target),
          ],
        );
      },
    );
  }

  Widget _buildPanel({required bool isTarget}) {
    final colors = context.colors;
    final all = isTarget ? widget.targetItems : widget.sourceItems;
    final search = isTarget ? _targetSearch : _sourceSearch;
    final checked = isTarget ? _checkedTarget : _checkedSource;
    final visible = _filter(all, search);

    final enabled = visible.where((i) => !_isDisabled(i)).toList();
    final allChecked = enabled.isNotEmpty && enabled.every(checked.contains);
    final someChecked = enabled.any(checked.contains) && !allChecked;

    final reorderable = isTarget && widget.allowReordering && search.trim().isEmpty;

    return TCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      shadowLevel: TCardShadow.md,
      title: isTarget ? widget.targetTitle : widget.sourceTitle,
      iconWidget: widget.showSelectAll
          ? TCheckbox(
              size: TInputSize.sm,
              tristate: true,
              disabled: enabled.isEmpty,
              value: allChecked ? true : (someChecked ? null : false),
              onValueChanged: (v) => _toggleAll(checked, visible, v ?? false),
            )
          : null,
      trailing: TChip(
        text: '${checked.isNotEmpty ? checked.length : visible.length}',
        color: checked.isNotEmpty ? colors.primary : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showSearch)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TTextField<String>(
                size: TInputSize.sm,
                placeholder: 'Search items...',
                clearable: true,
                preWidget: TIcon.raw(HugeIcons.strokeRoundedSearch01, size: 16),
                onValueChanged: (v) => setState(() {
                  if (isTarget) {
                    _targetSearch = v ?? '';
                  } else {
                    _sourceSearch = v ?? '';
                  }
                }),
              ),
            ),
          SizedBox(
            height: widget.height,
            child: visible.isEmpty
                ? (all.isEmpty
                    ? const TEmptyState(compact: true, icon: HugeIcons.strokeRoundedInbox, title: 'No items')
                    : TEmptyState.search(compact: true, query: search.trim()))
                : reorderable
                    ? ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        itemCount: visible.length,
                        onReorderItem: _reorderTarget,
                        proxyDecorator: TListTheme.buildDragProxy,
                        itemBuilder: (context, index) => _buildRow(visible[index], index, checked, isTarget: true, reorderable: true),
                      )
                    : ListView.builder(
                        itemCount: visible.length,
                        itemBuilder: (context, index) => _buildRow(visible[index], index, checked, isTarget: isTarget),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    T item,
    int index,
    Set<T> checked, {
    required bool isTarget,
    bool reorderable = false,
  }) {
    final colors = context.colors;
    final isChecked = checked.contains(item);
    final disabled = _isDisabled(item);

    void toggle() => setState(() => isChecked ? checked.remove(item) : checked.add(item));

    return KeyedSubtree(
      key: ValueKey(item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TTile(
              size: TTileSize.h6,
              padding: EdgeInsets.zero,
              crossAxisAlignment: CrossAxisAlignment.center,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  if (reorderable) TDragHandle(index: index, size: 14, padding: const EdgeInsets.all(4)),
                  TCheckbox(
                    size: TInputSize.sm,
                    disabled: disabled,
                    value: isChecked,
                    onValueChanged: (_) => toggle(),
                  ),
                ],
              ),
              title: widget.itemBuilder == null ? _label(item) : null,
              titleWidget: widget.itemBuilder?.call(context, item, isChecked),
              subtitle: widget.itemBuilder == null ? widget.itemSubtitle?.call(item) : null,
            ),
          ),
          TTooltip(
            message: isTarget ? 'Remove' : 'Add',
            child: TIcon(
              icon: isTarget ? HugeIcons.strokeRoundedCancel01 : HugeIcons.strokeRoundedAdd01,
              size: 16,
              padding: const EdgeInsets.fromLTRB(6, 6, 3, 6),
              themeType: isTarget ? TThemeType.error : TThemeType.success,
              onTap: disabled ? null : () => _move([item], toTarget: !isTarget),
            ),
          ),
        ],
      ).card(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(bottom: 6),
        backgroundColor: isChecked ? colors.primary.withAlpha(18) : null,
        onTap: disabled ? null : toggle,
      ),
    );
  }

  Widget _buildActions({required bool vertical}) {
    final buttons = [
      _actionButton(
        icon: vertical ? HugeIcons.strokeRoundedArrowRight01 : HugeIcons.strokeRoundedArrowDown01,
        tooltip: 'Transfer Selected to Right',
        enabled: _checkedSource.isNotEmpty,
        onTap: () => _move(_checkedSource.toList(), toTarget: true),
      ),
      _actionButton(
        icon: vertical ? HugeIcons.strokeRoundedSquareArrowRightDouble : HugeIcons.strokeRoundedSquareArrowDownDouble,
        tooltip: 'Transfer All to Right',
        enabled: widget.sourceItems.isNotEmpty,
        onTap: () => _move(widget.sourceItems.toList(), toTarget: true),
      ),
      _actionButton(
        icon: vertical ? HugeIcons.strokeRoundedArrowLeft01 : HugeIcons.strokeRoundedArrowUp01,
        tooltip: 'Transfer Selected to Left',
        enabled: _checkedTarget.isNotEmpty,
        onTap: () => _move(_checkedTarget.toList(), toTarget: false),
      ),
      _actionButton(
        icon: vertical ? HugeIcons.strokeRoundedSquareArrowLeftDouble : HugeIcons.strokeRoundedSquareArrowUpDouble,
        tooltip: 'Transfer All to Left',
        enabled: widget.targetItems.isNotEmpty,
        onTap: () => _move(widget.targetItems.toList(), toTarget: false),
      ),
    ];

    if (!vertical) return TAlignedRow(left: buttons);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (i, b) in buttons.indexed) ...[
          if (i > 0) SizedBox(height: i == 2 ? 12 : 6),
          b,
        ],
      ],
    );
  }

  Widget _actionButton({
    required List<List<dynamic>> icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return TButton(
      icon: icon,
      tooltip: tooltip,
      onTap: enabled ? onTap : null,
      size: TSize.sm,
      type: TButtonType.outline,
    );
  }
}
