import 'package:flutter/material.dart';
import 'package:my_app/pages/tables_tree_children_page.dart';
import 'package:te_widgets/te_widgets.dart';

int _categoryId = 100;

/// Desktop shows the tree inline; mobile cards drill down one level per page.
class CrudHierarchyPage extends StatelessWidget {
  const CrudHierarchyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final headers = [
      TTableHeader<CategoryTreeItem, String>.values(
        'Category',
        (x) => [TKeyValue('Category', value: x.name), TKeyValue('Code', value: x.code)],
      ),
      TTableHeader<CategoryTreeItem, String>.map('Total Items', (x) => '${x.itemCount} items'),
      TTableHeader<CategoryTreeItem, String>.chip('Status', (x) => x.status, color: (x) => context.theme.success),
    ];

    return TCrudTable<CategoryTreeItem, String, CategoryForm>(
      headers: headers,
      items: demoCategoryTree,
      itemKey: (x) => x.id,
      itemChildren: (x) => x.children,
      createForm: () => CategoryForm(),
      editForm: (item) => CategoryForm(item),
      onCreate: (form) async => CategoryTreeItem(
        id: 'cat-${_categoryId++}',
        name: form.name.value,
        code: form.code.value,
        itemCount: 0,
        status: 'Active',
      ),
      onEdit: (item, form) async => CategoryTreeItem(
        id: item.id,
        name: form.name.value,
        code: form.code.value,
        itemCount: item.itemCount,
        status: item.status,
        children: item.children,
      ),
      onDelete: (item) async => true,
      itemTitle: (item) => item.name,
      itemSubTitle: (item) => '${item.code} • ${item.itemCount} items',
      expansionMode: TTableExpansionMode.side,
    );
  }
}

class CategoryForm extends TFormBase {
  final name = TFieldProp('');
  final code = TFieldProp('');

  CategoryForm([CategoryTreeItem? category]) {
    if (category != null) {
      name.value = category.name;
      code.value = category.code;
    }
  }

  @override
  String get formTitle => name.value.isEmpty ? 'Add Category' : 'Edit Category: ${name.value}';

  @override
  String get formActionName => name.value.isEmpty ? 'Add Category' : 'Update Category';

  @override
  List<TFormField> get fields => [
    TFormField.text(name, 'Name', isRequired: true).size(6),
    TFormField.text(code, 'Code', isRequired: true).size(6),
  ];
}
