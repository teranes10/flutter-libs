import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation and showcase page for the [TEmptyState] widget.
class EmptyStatePage extends StatefulWidget {
  const EmptyStatePage({super.key});

  @override
  State<EmptyStatePage> createState() => _EmptyStatePageState();
}

class _EmptyStatePageState extends State<EmptyStatePage> {
  String _searchQuery = 'Quantum Ledger';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Empty States',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Standardized placeholders for zero-data views, search misses, 404s, and empty tables.',
            style: TextStyle(
              fontSize: 16,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // 1. Standard No Data
          WidgetDocCard(
            title: 'Standard No Data (TEmptyState.noData)',
            description: 'Default initial state when a dataset or list contains zero items',
            icon: Icons.inbox_outlined,
            preview: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: TEmptyState.noData(
                title: 'No Customers Yet',
                description: 'You have not added any customer records yet. Add your first customer to get started.',
                action: TButton(
                  text: 'Add Customer',
                  icon: Icons.add,
                  type: TButtonType.solid,
                  size: TButtonSize.sm,
                  onTap: () {},
                ),
                secondaryAction: TButton(
                  text: 'Import CSV',
                  icon: Icons.upload_file_rounded,
                  type: TButtonType.tonal,
                  size: TButtonSize.sm,
                  onTap: () {},
                ),
              ),
            ),
            code: '''TEmptyState.noData(
  title: 'No Customers Yet',
  description: 'Add your first customer to get started.',
  action: TButton(
    text: 'Add Customer',
    icon: Icons.add,
    type: TButtonType.solid,
    size: TButtonSize.sm,
    onTap: () => openAddCustomer(),
  ),
  secondaryAction: TButton(
    text: 'Import CSV',
    type: TButtonType.tonal,
    size: TButtonSize.sm,
    onTap: () => openImport(),
  ),
)''',
          ),
          const SizedBox(height: 24),

          // 2. Search Miss
          WidgetDocCard(
            title: 'Search Results Empty State (TEmptyState.search)',
            description: 'Contextual feedback when user query returns 0 matches with clear button',
            icon: Icons.search_off_rounded,
            preview: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: TEmptyState.search(
                query: _searchQuery,
                onClear: () {
                  setState(() => _searchQuery = '');
                },
              ),
            ),
            code: '''TEmptyState.search(
  query: 'Quantum Ledger',
  onClear: () => searchController.clear(),
)''',
          ),
          const SizedBox(height: 24),

          // 3. 404 / Missing Entity
          WidgetDocCard(
            title: 'Not Found / 404 (TEmptyState.notFound)',
            description: 'Used when viewing details for an entity that was deleted or doesn’t exist',
            icon: Icons.find_in_page_outlined,
            preview: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: TEmptyState.notFound(
                title: 'Invoice Not Found',
                description: 'The invoice `#INV-2026-9042` could not be located in your database.',
                action: TButton(
                  text: 'Back to Invoices',
                  icon: Icons.arrow_back_rounded,
                  type: TButtonType.tonal,
                  size: TButtonSize.sm,
                  onTap: () {},
                ),
              ),
            ),
            code: '''TEmptyState.notFound(
  title: 'Invoice Not Found',
  description: 'The invoice `#INV-2026-9042` could not be located.',
  action: TButton(
    text: 'Back to Invoices',
    icon: Icons.arrow_back_rounded,
    type: TButtonType.tonal,
    size: TButtonSize.sm,
    onTap: () => context.pop(),
  ),
)''',
          ),
          const SizedBox(height: 24),

          // 4. Failure / Error with Retry
          WidgetDocCard(
            title: 'Error State with Retry (TEmptyState.error)',
            description: 'Graceful failure state with retry trigger for failed network calls',
            icon: Icons.error_outline_rounded,
            preview: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: TEmptyState.error(
                title: 'Unable to Load Analytics',
                description: 'The analytics server timed out while aggregating monthly revenue metrics.',
                onRetry: () {},
              ),
            ),
            code: '''TEmptyState.error(
  title: 'Unable to Load Analytics',
  description: 'The analytics server timed out while aggregating metrics.',
  onRetry: () => ref.refresh(analyticsProvider),
)''',
          ),
          const SizedBox(height: 24),

          // 5. Compact Mode (for dropdowns, filter menus, or small panels)
          WidgetDocCard(
            title: 'Compact Mode (TEmptyState.compact)',
            description: 'Low-profile single-line empty state ideal for select menus and compact cards',
            icon: Icons.vertical_align_center_rounded,
            preview: Container(
              width: 380,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: TEmptyState.compact(
                icon: Icons.filter_list_off_rounded,
                message: 'No active filters applied',
                action: TButton(
                  text: 'Reset',
                  type: TButtonType.softText,
                  size: TButtonSize.xxs,
                  onTap: () {},
                ),
              ),
            ),
            code: '''TEmptyState.compact(
  icon: Icons.filter_list_off_rounded,
  message: 'No active filters applied',
  action: TButton(
    text: 'Reset',
    type: TButtonType.softText,
    size: TButtonSize.xxs,
    onTap: () => resetFilters(),
  ),
)''',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
