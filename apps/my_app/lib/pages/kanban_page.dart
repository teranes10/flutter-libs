import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class KanbanPage extends StatefulWidget {
  const KanbanPage({super.key});

  @override
  State<KanbanPage> createState() => _KanbanPageState();
}

class _KanbanPageState extends State<KanbanPage> {
  late List<TKanbanColumn<String>> _columns;
  String _lastEvent = 'Drag any card to another column to test.';

  @override
  void initState() {
    super.initState();
    _resetBoard();
  }

  void _resetBoard() {
    setState(() {
      _columns = [
        TKanbanColumn<String>(
          id: 'backlog',
          title: 'Backlog',
          color: Colors.blueGrey,
          items: [
            TKanbanCardItem(
              id: 'task_1',
              title: 'Migrate to Flutter 3.29',
              description: 'Update pubspec dependencies and verify Impeller rendering.',
              tags: const ['Framework', 'Tech Debt'],
              assignee: 'Alex',
              color: Colors.blue,
              dueDate: DateTime.now().add(const Duration(days: 4)),
            ),
            TKanbanCardItem(
              id: 'task_2',
              title: 'OAuth2 Refresh Token Interceptor',
              description: 'Handle 401 token expiry retry loop in Dio client adapter.',
              tags: const ['Security'],
              assignee: 'Elena',
              color: Colors.red,
            ),
          ],
        ),
        TKanbanColumn<String>(
          id: 'in_progress',
          title: 'In Progress',
          color: Colors.blue,
          maxItems: 4,
          items: [
            TKanbanCardItem(
              id: 'task_3',
              title: 'Virtual Table Auto-Scroll',
              description: 'Fix sticky header coordinate alignment during rapid scroll physics.',
              tags: const ['Performance', 'Bug'],
              assignee: 'David',
              color: Colors.amber.shade800,
              dueDate: DateTime.now().add(const Duration(days: 2)),
            ),
            TKanbanCardItem(
              id: 'task_4',
              title: 'Audit Log Export to Parquet',
              description: 'Stream BigQuery schema rows into compressed storage buckets.',
              tags: const ['Data', 'GCP'],
              assignee: 'Sarah',
              color: Colors.teal,
            ),
          ],
        ),
        TKanbanColumn<String>(
          id: 'review',
          title: 'In Review',
          color: Colors.purple,
          items: [
            TKanbanCardItem(
              id: 'task_5',
              title: 'Security Watermark Overlay',
              description: 'Non-intrusive diagonal text watermark on confidential dashboards.',
              tags: const ['Security', 'UI'],
              assignee: 'Marcus',
              color: Colors.green,
            ),
          ],
        ),
        TKanbanColumn<String>(
          id: 'done',
          title: 'Completed',
          color: Colors.green,
          items: [
            TKanbanCardItem(
              id: 'task_6',
              title: 'Context Menu Coordinate Drift',
              description: 'Solved OverlayPortal coordinate mapping in nested shell navigator.',
              tags: const ['Bug', 'Web'],
              assignee: 'Sarah',
              color: Colors.green,
            ),
            TKanbanCardItem(
              id: 'task_7',
              title: 'PIN / OTP Segmented Field',
              description: 'Added auto-advance keyboard and paste parsing.',
              tags: const ['Feature'],
              assignee: 'Alex',
              color: Colors.green,
            ),
          ],
        ),
      ];
    });
  }

  void _handleCardMoved(TKanbanCardItem<String> item, String sourceColId, String targetColId, int targetIndex) {
    setState(() {
      // Find source column and remove
      final sourceCol = _columns.firstWhere((c) => c.id == sourceColId);
      final newSourceItems = List<TKanbanCardItem<String>>.from(sourceCol.items)..remove(item);

      // Find target column and insert
      final targetCol = _columns.firstWhere((c) => c.id == targetColId);
      final newTargetItems = List<TKanbanCardItem<String>>.from(targetCol.items);

      final insertAt = targetIndex.clamp(0, newTargetItems.length);
      newTargetItems.insert(insertAt, item);

      // Rebuild column list
      _columns = _columns.map((c) {
        if (c.id == sourceColId && sourceColId == targetColId) {
          // Reordering inside the same column
          final items = List<TKanbanCardItem<String>>.from(c.items)..remove(item);
          items.insert(insertAt.clamp(0, items.length), item);
          return TKanbanColumn<String>(
            id: c.id,
            title: c.title,
            color: c.color,
            maxItems: c.maxItems,
            items: items,
          );
        } else if (c.id == sourceColId) {
          return TKanbanColumn<String>(
            id: c.id,
            title: c.title,
            color: c.color,
            maxItems: c.maxItems,
            items: newSourceItems,
          );
        } else if (c.id == targetColId) {
          return TKanbanColumn<String>(
            id: c.id,
            title: c.title,
            color: c.color,
            maxItems: c.maxItems,
            items: newTargetItems,
          );
        }
        return c;
      }).toList();

      _lastEvent = 'Moved "${item.title}" from [${sourceCol.title}] to [${targetCol.title}]';
    });
  }

  void _addNewCard(String colId) {
    final col = _columns.firstWhere((c) => c.id == colId);
    final newId = 'task_${DateTime.now().millisecondsSinceEpoch}';
    final newCard = TKanbanCardItem<String>(
      id: newId,
      title: 'New Task (${col.items.length + 1})',
      description: 'Newly created agile card.',
      tags: const ['Quick Add'],
      assignee: 'Operator',
      color: Colors.blue,
    );

    setState(() {
      _columns = _columns.map((c) {
        if (c.id == colId) {
          return TKanbanColumn<String>(
            id: c.id,
            title: c.title,
            color: c.color,
            maxItems: c.maxItems,
            items: [...c.items, newCard],
          );
        }
        return c;
      }).toList();

      _lastEvent = 'Added "${newCard.title}" to [${col.title}]';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'TKanbanBoard Showcase',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Drag-and-drop workflow status board for sprint planning, ticketing pipelines, '
            'and fulfillment stages. Includes column limits, tag chips, assignee avatars, and event callbacks.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Action Toolbar Card
          TCard(
            title: 'Board Controls',
            child: Row(
              children: [
                TButton(
                  text: 'Reset Tasks',
                  icon: Icons.refresh_rounded,
                  type: TButtonType.outline,
                  size: TSize.sm,
                  onTap: _resetBoard,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Live Event: $_lastEvent',
                      style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Kanban Board Card
          TCard(
            title: 'Sprint 42 Agile Board',
            child: Container(
              height: 540,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: TKanbanBoard<String>(
                columns: _columns,
                columnWidth: 290,
                onCardMoved: _handleCardMoved,
                onAddCard: _addNewCard,
                onCardTap: (item) => setState(() => _lastEvent = 'Tapped card: "${item.title}"'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
