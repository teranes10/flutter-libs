import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A card item displayed inside a [TKanbanColumn].
class TKanbanCardItem<T> {
  /// Unique identifier for this card.
  final String id;

  /// Card headline title.
  final String title;

  /// Optional description or subtitle.
  final String? description;

  /// Optional underlying domain data model.
  final T? data;

  /// Category or status tags.
  final List<String> tags;

  /// Optional assignee name or initials.
  final String? assignee;

  /// Priority or category accent color.
  final Color? color;

  /// Optional due date.
  final DateTime? dueDate;

  const TKanbanCardItem({
    required this.id,
    required this.title,
    this.description,
    this.data,
    this.tags = const [],
    this.assignee,
    this.color,
    this.dueDate,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is TKanbanCardItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A status column containing cards in a [TKanbanBoard].
class TKanbanColumn<T> {
  /// Unique column identifier (e.g. 'todo', 'in_progress', 'done').
  final String id;

  /// Display title for the column.
  final String title;

  /// Cards contained within this column.
  final List<TKanbanCardItem<T>> items;

  /// Optional column accent color.
  final Color? color;

  /// Optional Work-In-Progress (WIP) limit.
  final int? maxItems;

  /// Whether an "Add Card" button should be displayed in the header. Defaults to true.
  final bool canAdd;

  const TKanbanColumn({
    required this.id,
    required this.title,
    required this.items,
    this.color,
    this.maxItems,
    this.canAdd = true,
  });
}

/// An interactive, drag-and-drop workflow status board for issue tracking, order fulfillment,
/// agile tasks, and pipeline stages.
class TKanbanBoard<T> extends StatefulWidget {
  /// The collection of columns in this board.
  final List<TKanbanColumn<T>> columns;

  /// Callback fired when a card is dragged and dropped to a new column or index.
  final void Function(TKanbanCardItem<T> item, String sourceColId, String targetColId, int targetIndex)? onCardMoved;

  /// Callback fired when the "Add Card" button in a column header is clicked.
  final void Function(String columnId)? onAddCard;

  /// Callback fired when a card is tapped.
  final void Function(TKanbanCardItem<T> item)? onCardTap;

  /// Optional custom builder for card contents.
  final Widget Function(BuildContext context, TKanbanCardItem<T> item)? cardBuilder;

  /// Width of each column. Defaults to 280.0.
  final double columnWidth;

  /// Padding around the board. Defaults to `EdgeInsets.all(16.0)`.
  final EdgeInsets padding;

  const TKanbanBoard({
    super.key,
    required this.columns,
    this.onCardMoved,
    this.onAddCard,
    this.onCardTap,
    this.cardBuilder,
    this.columnWidth = 280.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  State<TKanbanBoard<T>> createState() => _TKanbanBoardState<T>();
}

class _TKanbanBoardState<T> extends State<TKanbanBoard<T>> {
  String? _hoveredColId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.columns.map((column) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              width: widget.columnWidth,
              child: _buildColumn(column),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColumn(TKanbanColumn<T> column) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;
    final isHovered = _hoveredColId == column.id;

    final headerColor = column.color ?? colors.primary;

    return DragTarget<_DragPayload<T>>(
      onWillAcceptWithDetails: (details) => details.data.columnId != column.id || true,
      onAcceptWithDetails: (details) {
        setState(() => _hoveredColId = null);
        widget.onCardMoved?.call(
          details.data.item,
          details.data.columnId,
          column.id,
          column.items.length,
        );
      },
      onMove: (_) {
        if (_hoveredColId != column.id) {
          setState(() => _hoveredColId = column.id);
        }
      },
      onLeave: (_) {
        if (_hoveredColId == column.id) {
          setState(() => _hoveredColId = null);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHovered ? headerColor : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
              width: isHovered ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Column Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: headerColor, width: 3),
                    bottom: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        column.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Item Count Badge
                    TBadge.standalone(
                      label: column.maxItems != null
                          ? '${column.items.length} / ${column.maxItems}'
                          : '${column.items.length}',
                      color: column.maxItems != null && column.items.length >= column.maxItems!
                          ? Colors.orange.shade700
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                      textColor: isDark ? Colors.white : Colors.black87,
                    ),
                    if (column.canAdd && widget.onAddCard != null) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => widget.onAddCard!(column.id),
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(Icons.add, size: 18),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Cards List
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    if (column.items.isEmpty)
                      Container(
                        height: 90,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.dividerColor,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Drag cards here',
                          style: TextStyle(fontSize: 12, color: theme.hintColor),
                        ),
                      )
                    else
                      ...column.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _buildDraggableCard(item, column.id, index);
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableCard(TKanbanCardItem<T> item, String columnId, int index) {
    final payload = _DragPayload<T>(item: item, columnId: columnId, index: index);

    final cardWidget = _buildCardBody(item);

    return DragTarget<_DragPayload<T>>(
      onWillAcceptWithDetails: (details) => details.data.item.id != item.id,
      onAcceptWithDetails: (details) {
        widget.onCardMoved?.call(
          details.data.item,
          details.data.columnId,
          columnId,
          index,
        );
      },
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;

        return Column(
          children: [
            if (isDropTarget)
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Draggable<_DragPayload<T>>(
                data: payload,
                feedback: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: widget.columnWidth - 16,
                    child: Transform.rotate(
                      angle: 0.04,
                      child: cardWidget,
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.35,
                  child: cardWidget,
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: InkWell(
                    onTap: () => widget.onCardTap?.call(item),
                    borderRadius: BorderRadius.circular(8),
                    child: cardWidget,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardBody(TKanbanCardItem<T> item) {
    if (widget.cardBuilder != null) {
      return widget.cardBuilder!(context, item);
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tags Row
          if (item.tags.isNotEmpty || item.color != null) ...[
            Row(
              children: [
                if (item.color != null)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ...item.tags.map(
                  (tag) => Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Title
          Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),

          // Description
          if (item.description != null) ...[
            const SizedBox(height: 4),
            Text(
              item.description!,
              style: TextStyle(fontSize: 11, color: theme.hintColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Footer: Assignee & Due Date
          if (item.assignee != null || item.dueDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (item.assignee != null) ...[
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      item.assignee!.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(item.assignee!, style: const TextStyle(fontSize: 11)),
                ],
                const Spacer(),
                if (item.dueDate != null) ...[
                  Icon(Icons.calendar_today_outlined, size: 12, color: theme.hintColor),
                  const SizedBox(width: 4),
                  Text(
                    '${item.dueDate!.month}/${item.dueDate!.day}',
                    style: TextStyle(fontSize: 10, color: theme.hintColor),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DragPayload<T> {
  final TKanbanCardItem<T> item;
  final String columnId;
  final int index;

  _DragPayload({required this.item, required this.columnId, required this.index});
}
