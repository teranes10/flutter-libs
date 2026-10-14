import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _Node {
  final String name;
  final List<_Node>? children;
  const _Node(this.name, [this.children]);
}

class _ListsPageState extends State<ListsPage> {
  final List<String> _items = List.generate(10, (index) => 'Item ${index + 1}');

  late final List<TListItem<String, String>> _cardItems = List.generate(
    5,
    (i) => TListItem<String, String>(key: 'task-$i', data: 'Task ${i + 1}'),
  );

  late final TListController<_Node, String> _treeController = TListController<_Node, String>(
    items: const [
      _Node('Electronics', [
        _Node('Phones', [_Node('Android'), _Node('iOS')]),
        _Node('Laptops'),
      ]),
      _Node('Clothing', [_Node('Shirts'), _Node('Shoes')]),
      _Node('Books'),
    ],
    itemKey: (n) => n.name,
    itemChildren: (n) => n.children,
    expansionMode: TExpansionMode.multiple,
  );

  @override
  void dispose() {
    _treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lists',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'List components for displaying collections of data with support for reordering.',
              style: TextStyle(fontSize: 16, color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            WidgetDocCard(
              title: 'Reorderable List',
              description: 'A list that allows users to reorder items using drag and drop.',
              icon: Icons.reorder,
              preview: TList<String, String>(
                shrinkWrap: true,
                controller: TListController<String, String>(items: _items, reorderable: true),
                itemBuilder: (context, item, index) {
                  return ListTile(key: ValueKey(item.key), title: Text(item.data), leading: const Icon(Icons.drag_handle));
                },
              ),
              code: '''
final List<String> _items = List.generate(10, (index) => 'Item \${index + 1}');

TList<String, String>(
  shrinkWrap: true,
  controller: TListController<String, String>(
    items: _items,
    reorderable: true,
    onReorder: (oldIndex, newIndex) {
      setState(() {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final String item = _items.removeAt(oldIndex);
        _items.insert(newIndex, item);
      });
    },
  ),
  itemBuilder: (context, item, index) {
    return ListTile(
      key: ValueKey(item.key),
      title: Text(item.data),
      leading: const Icon(Icons.drag_handle),
    );
  },
)''',
              properties: const [
                PropertyDoc(name: 'reorderable', type: 'bool', defaultValue: 'false', description: 'Whether items can be reordered'),
                PropertyDoc(name: 'onReorder', type: 'void Function(int, int)?', description: 'Callback fired when items are reordered'),
              ],
            ),
            const SizedBox(height: 24),
            WidgetDocCard(
              title: 'List View with Card Tiles',
              description: 'TListView rendering each item as a TTile wrapped in a card.',
              icon: Icons.view_agenda_outlined,
              preview: TListView<String, String>(
                shrinkWrap: true,
                items: _cardItems,
                listSeparatorBuilder: (context, index) => const SizedBox(height: 2),
                itemBuilder: (context, item, index) {
                  return TTile(
                    key: ValueKey(item.key),
                    title: item.data,
                    subtitle: 'Subtitle for ${item.data}',
                    icon: Icons.task_alt,
                    trailing: const Icon(Icons.chevron_right),
                  ).card(onTap: () {});
                },
              ),
              code: '''
TListView<String, String>(
  shrinkWrap: true,
  items: [
    for (var i = 0; i < 5; i++) TListItem(key: 'task-\$i', data: 'Task \${i + 1}'),
  ],
  listSeparatorBuilder: (context, index) => const SizedBox(height: 2),
  itemBuilder: (context, item, index) {
    return TTile(
      title: item.data,
      subtitle: 'Subtitle for \${item.data}',
      icon: Icons.task_alt,
      trailing: const Icon(Icons.chevron_right),
    ).card(borderColor: Colors.transparent, onTap: () {});
  },
)''',
              properties: const [
                PropertyDoc(name: 'items', type: 'List<TListItem<T, K>>', description: 'Items to render'),
                PropertyDoc(name: 'itemBuilder', type: 'ListItemBuilder<T, K>', description: 'Builds each row; wrap a TTile with .card()'),
                PropertyDoc(name: 'listSeparatorBuilder', type: 'TListSeparatorBuilder?', description: 'Builds the gap between items'),
              ],
            ),
            const SizedBox(height: 24),
            WidgetDocCard(
              title: 'Hierarchical List',
              description: 'Nested items resolved through itemChildren; tap a parent to expand or collapse.',
              icon: Icons.account_tree_outlined,
              preview: TList<_Node, String>(
                theme: context.theme.listTheme.copyWith(
                  shrinkWrap: true,
                  listSeparatorBuilder: (context, index) => const SizedBox(height: 2),
                ),
                controller: _treeController,
                itemBuilder: (context, item, index) {
                  final hasChildren = item.hasChildren;
                  final expanded = _treeController.isExpanded(item.key);
                  return TTile(
                    key: ValueKey(item.key),
                    title: item.data.name,
                    subtitle: hasChildren ? '${item.childCount} items' : null,
                    icon: hasChildren ? Icons.folder_outlined : Icons.label_outline,
                    trailing: hasChildren ? Icon(expanded ? Icons.expand_less : Icons.expand_more) : null,
                  ).card(
                    margin: EdgeInsets.only(left: item.level * 24.0),
                    onTap: hasChildren ? () => _treeController.toggleExpansion(item.key) : null,
                  );
                },
              ),
              code: '''
class Node {
  final String name;
  final List<Node>? children;
  const Node(this.name, [this.children]);
}

final controller = TListController<Node, String>(
  items: const [
    Node('Electronics', [
      Node('Phones', [Node('Android'), Node('iOS')]),
      Node('Laptops'),
    ]),
    Node('Books'),
  ],
  itemKey: (n) => n.name,
  itemChildren: (n) => n.children,
  expansionMode: TExpansionMode.multiple,
);

TList<Node, String>(
  theme: context.theme.listTheme.copyWith(
    shrinkWrap: true,
    listSeparatorBuilder: (context, index) => const SizedBox(height: 2),
  ),
  controller: controller,
  itemBuilder: (context, item, index) {
    final hasChildren = item.hasChildren;
    return Padding(
      padding: EdgeInsets.only(left: item.level * 24.0),
      child: TTile(
        title: item.data.name,
        icon: hasChildren ? Icons.folder_outlined : Icons.label_outline,
      ).card(
        borderColor: Colors.transparent,
        onTap: hasChildren ? () => controller.toggleExpansion(item.key) : null,
      ),
    );
  },
)''',
              properties: const [
                PropertyDoc(
                  name: 'itemChildren',
                  type: 'List<T>? Function(T)?',
                  description: 'Returns the children of an item, enabling hierarchy',
                ),
                PropertyDoc(
                  name: 'expansionMode',
                  type: 'TExpansionMode',
                  defaultValue: 'none',
                  description: 'none, single, multiple or auto',
                ),
                PropertyDoc(name: 'item.level', type: 'int', description: 'Nesting depth, used for indentation'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
