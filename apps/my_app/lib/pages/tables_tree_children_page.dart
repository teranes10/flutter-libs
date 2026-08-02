import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class CategoryTreeItem {
  final String id;
  final String name;
  final String code;
  final int itemCount;
  final String status;
  final List<CategoryTreeItem>? children;

  const CategoryTreeItem({
    required this.id,
    required this.name,
    required this.code,
    required this.itemCount,
    required this.status,
    this.children,
  });
}

final demoCategoryTree = [
  const CategoryTreeItem(
    id: 'cat-1',
    name: 'Electronics & Gadgets',
    code: 'ELEC-00',
    itemCount: 142,
    status: 'Active',
    children: [
      CategoryTreeItem(
        id: 'cat-1-1',
        name: 'Laptops & Computers',
        code: 'ELEC-10',
        itemCount: 58,
        status: 'Active',
        children: [
          CategoryTreeItem(id: 'cat-1-1-1', name: 'Gaming Laptops', code: 'ELEC-11', itemCount: 24, status: 'Active'),
          CategoryTreeItem(id: 'cat-1-1-2', name: 'Ultrabooks', code: 'ELEC-12', itemCount: 34, status: 'Active'),
        ],
      ),
      CategoryTreeItem(
        id: 'cat-1-2',
        name: 'Smartphones & Mobile',
        code: 'ELEC-20',
        itemCount: 84,
        status: 'Active',
        children: [CategoryTreeItem(id: 'cat-1-2-1', name: 'Flagship Phones', code: 'ELEC-21', itemCount: 40, status: 'Active')],
      ),
    ],
  ),
  const CategoryTreeItem(
    id: 'cat-2',
    name: 'Fashion & Apparel',
    code: 'FASH-00',
    itemCount: 210,
    status: 'Active',
    children: [
      CategoryTreeItem(id: 'cat-2-1', name: 'Men\'s Wear', code: 'FASH-10', itemCount: 110, status: 'Active'),
      CategoryTreeItem(id: 'cat-2-2', name: 'Women\'s Wear', code: 'FASH-20', itemCount: 100, status: 'Active'),
    ],
  ),
];

class TablesTreeChildrenPage extends StatefulWidget {
  const TablesTreeChildrenPage({super.key});

  @override
  State<TablesTreeChildrenPage> createState() => _TablesTreeChildrenPageState();
}

class _TablesTreeChildrenPageState extends State<TablesTreeChildrenPage> {
  late final TListController<CategoryTreeItem, String> _controller;

  @override
  void initState() {
    super.initState();
    _controller = TListController<CategoryTreeItem, String>(
      items: demoCategoryTree,
      itemKey: (cat) => cat.id,
      itemChildren: (cat) => cat.children,
      expansionMode: TExpansionMode.single,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final headers = [
      TTableHeader<CategoryTreeItem, String>.map("Category Name", (x) => x.name),
      TTableHeader<CategoryTreeItem, String>.map("Code", (x) => x.code),
      TTableHeader<CategoryTreeItem, String>.map("Total Items", (x) => '${x.itemCount} items'),
      TTableHeader<CategoryTreeItem, String>.chip("Status", (x) => x.status, color: (x) => context.theme.success),
      TTableHeader<CategoryTreeItem, String>.actions(
        (item) => [
          TButtonGroupItem(
            icon: Icons.edit_outlined,
            onPressed: (_) {
              if (_controller.editingItemKey == item.key) {
                _controller.cancelEditItem();
              } else {
                _controller.beginEditItem(item.data);
              }
            },
          ),
        ],
      ),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hierarchical Tree Table & Row Expanded Content',
              style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Demonstrates multi-level tree children (indented with expand icons & child count badges) '
              'and separated row detail content expansion with active key precedence.',
              style: context.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            TTable<CategoryTreeItem, String>(
              shrinkWrap: true,
              headers: headers,
              controller: _controller,

              details: TTableDetails(
                mode: TTableExpansionMode.side,
                itemTitle: (item) => item.name,
                itemSubTitle: (item) => item.code,
                builder: (ctx, item, index) {
                  final data = item.data;

                  return TRowExpandedBuilder.tabs(
                    ctx,
                    header: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.name, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                            'Code: ${data.code} • Total: ${data.itemCount} items',
                            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    tabs: [
                      TTab(
                        value: 'overview',
                        text: 'Category Overview',
                        content: (ctx) => TKeyValueSection(
                          values: [
                            TKeyValue.text('Category ID', data.id),
                            TKeyValue.text('Category Name', data.name),
                            TKeyValue.text('Category Code', data.code),
                            TKeyValue.text('Item Count', '${data.itemCount}'),
                            TKeyValue.text('Status', data.status),
                          ],
                        ),
                      ),
                      TTab(
                        value: 'subcategories',
                        text: 'Direct Children (${data.children?.length ?? 0})',
                        content: (ctx) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data.children == null || data.children!.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text('No sub-categories in this node.', style: TextStyle(color: colors.onSurfaceVariant)),
                              )
                            else
                              ...data.children!.map(
                                (c) => Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: colors.outlineVariant),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.folder_outlined, size: 18, color: colors.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      Text('${c.itemCount} items', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                createBuilder: (ctx, item, index) {
                  if (item == null) return const SizedBox.shrink();
                  final data = item.data;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.primary.withAlpha(120)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inline Edit Mode for "${data.name}"',
                          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TAlignedRow(
                          left: [Text('Code: ${data.code}', style: TextStyle(color: colors.onSurfaceVariant))],
                          right: [
                            TButton(type: TButtonType.softText, text: 'Cancel', onPressed: (_) => _controller.cancelEditItem()),
                            TButton(
                              text: 'Save Changes',
                              onPressed: (_) {
                                _controller.cancelEditItem();
                                TToastService.success(context, 'Category saved successfully.');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
