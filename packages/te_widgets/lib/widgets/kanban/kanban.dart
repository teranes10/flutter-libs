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
    return LayoutBuilder(
      builder: (context, constraints) {
        // With a bounded height each column scrolls its own cards instead of overflowing.
        final bounded = constraints.hasBoundedHeight;
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
                  child: _buildColumn(column, bounded),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildColumn(TKanbanColumn<T> column, bool bounded) {
    final theme = Theme.of(context);
    final isHovered = _hoveredColId == column.id;
    final accent = column.color ?? theme.colorScheme.primary;
    final atLimit = column.maxItems != null && column.items.length >= column.maxItems!;

    return DragTarget<_DragPayload<T>>(
      onAcceptWithDetails: (details) {
        setState(() => _hoveredColId = null);
        widget.onCardMoved?.call(details.data.item, details.data.columnId, column.id, column.items.length);
      },
      onMove: (_) {
        if (_hoveredColId != column.id) setState(() => _hoveredColId = column.id);
      },
      onLeave: (_) {
        if (_hoveredColId == column.id) setState(() => _hoveredColId = null);
      },
      builder: (context, candidateData, rejectedData) {
        final cards = Padding(
          padding: const EdgeInsets.all(10),
          child: column.items.isEmpty
              ? const TEmptyState.compact(message: 'Drag cards here')
              : Column(
                  children: [
                    for (final (index, item) in column.items.indexed) _buildDraggableCard(item, column.id, index),
                  ],
                ),
        );

        return TCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          accentColor: accent,
          shadowLevel: TCardShadow.sm,
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          borderColor: isHovered ? accent : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(160))),
                ),
                child: TAlignedRow(
                  left: [
                    Text(column.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                  right: [
                    TChip.tonal(
                      text: column.maxItems != null ? '${column.items.length} / ${column.maxItems}' : '${column.items.length}',
                      color: atLimit ? Colors.orange : null,
                      size: TChipSize.xs,
                    ),
                    if (column.canAdd && widget.onAddCard != null)
                      TButton(
                        icon: HugeIcons.strokeRoundedAdd01,
                        type: TButtonType.softText,
                        size: TButtonSize.xs,
                        tooltip: 'Add card',
                        onTap: () => widget.onAddCard!(column.id),
                      ),
                  ],
                ),
              ),
              if (bounded) Flexible(child: SingleChildScrollView(child: cards)) else cards,
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
        widget.onCardMoved?.call(details.data.item, details.data.columnId, columnId, index);
      },
      builder: (context, candidateData, rejectedData) {
        return Column(
          children: [
            if (candidateData.isNotEmpty)
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Draggable<_DragPayload<T>>(
                data: payload,
                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: widget.columnWidth - 16,
                    child: Transform.rotate(angle: 0.04, child: cardWidget),
                  ),
                ),
                childWhenDragging: Opacity(opacity: 0.35, child: cardWidget),
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onCardTap == null ? null : () => widget.onCardTap!(item),
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
    if (widget.cardBuilder != null) return widget.cardBuilder!(context, item);

    final hint = Theme.of(context).hintColor;
    final due = item.dueDate;

    return TCard(
      padding: const EdgeInsets.all(12),
      borderColor: context.colors.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.tags.isNotEmpty || item.color != null) ...[
            Wrap(
              spacing: 4,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (item.color != null)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                  ),
                for (final tag in item.tags) TChip.tonal(text: tag, size: TChipSize.xs),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          if (item.description != null) ...[
            const SizedBox(height: 4),
            Text(
              item.description!,
              style: TextStyle(fontSize: 11, color: hint),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (item.assignee != null || due != null) ...[
            const SizedBox(height: 8),
            TAlignedRow(
              left: [
                if (item.assignee != null) TAvatar(name: item.assignee, title: item.assignee, size: TInputSize.xs),
              ],
              right: [
                if (due != null)
                  TTooltip(
                    message: 'Due date',
                    child: TChip.tonal(
                      icon: HugeIcons.strokeRoundedCalendar01,
                      text: '${due.month}/${due.day}',
                      size: TChipSize.xs,
                    ),
                  ),
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
