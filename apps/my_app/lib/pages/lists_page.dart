import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  final List<String> _items = List.generate(10, (index) => 'Item ${index + 1}');

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
          ],
        ),
      ),
    );
  }
}
