import 'package:flutter/material.dart';
import 'package:my_app/clients/products_client.dart';
import 'package:my_app/models/product_dto.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/table/row_expand.dart';

class CrudPage extends StatelessWidget {
  const CrudPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TListController<ProductDto, int>(
      selectionMode: TSelectionMode.multiple,
      expansionMode: TExpansionMode.single,
      onLoad: ProductsClient().loadMore,
    );

    final archiveController = TListController<ProductDto, int>(onLoad: ProductsClient().loadMore);

    final otherController = TListController<ProductDto, int>(
      selectionMode: TSelectionMode.multiple,
      expansionMode: TExpansionMode.single,
      items: [
        ProductDto(
          id: 1,
          title: "title",
          description: 'description',
          price: 10,
          discountPercentage: 10,
          rating: 2.34,
          stock: 100,
          category: 'category',
          sku: 'sku',
        ),
      ],
    );

    List<TTableHeader<ProductDto, int>> headers = [
      TTableHeader.image("Image", (x) => x.thumbnail),
      TTableHeader.map('SKU', (x) => x.sku),
      TTableHeader.map('Title', (x) => x.title),
      TTableHeader.map('Category', (x) => x.category),
      TTableHeader.map('Price', (x) => x.price),
      TTableHeader.map('Discount', (x) => x.discountPercentage),
      TTableHeader.map('Rating', (x) => x.rating),
      TTableHeader.chip('Stock', (x) => x.stock, color: (_) => AppColors.info),
    ];

    return TCrudTable<ProductDto, int, ProductForm>(
      headers: headers,
      createForm: () => ProductForm(),
      editForm: (ProductDto item) => ProductForm(item),
      onCreate: (input) async {
        return ProductDto(
          id: productId++,
          title: input.title.value,
          description: input.description.value,
          price: input.price.value,
          discountPercentage: 1,
          rating: 1,
          stock: 1,
          category: 'category',
          sku: 'sku',
        );
      },
      onEdit: (item, form) async {
        return item.copyWith(title: form.title.value, description: form.description.value, price: form.price.value);
      },
      onArchive: (item) async {
        return true;
      },
      onRestore: (item) async {
        return true;
      },
      onDelete: (item) async {
        return true;
      },
      config: TCrudConfig(
        tabs: [
          TTab(text: "Active", value: 0),
          TTab(text: "Others", value: 2),
          TTab(text: "Archive", value: 1),
        ],
        // Tab values: Active = 0, Archive = 1, Others = 2
        // Note: The order of [tabContents] follows the order of this list,
        tabContents: [TCrudTableContent(headers: headers, controller: otherController)],
        topBarActions: [
          TButton(type: TButtonType.tonal, icon: Icons.upload_file, text: 'Upload File', onPressed: (_) => {}),
          TButton(
            type: TButtonType.tonal,
            icon: Icons.select_all_sharp,
            text: 'Selected',
            onPressed: (_) => {TToastService.info(context, 'Selected Items: ${controller.selectedItems.map((x) => x.title).join("\n")}')},
          ),
        ],
      ),
      expandedBuilder: (ctx, item, index) {
        final data = item.data;

        return TRowExpandedBuilder.keyValue(ctx, [
          TKeyValue('QR Code', widget: data.meta?.qrCode != null ? Image.network(data.meta!.qrCode, width: 80) : SizedBox.shrink()),
          TKeyValue.text('Description', data.description),
          TKeyValue.text('Barcode', data.meta?.barcode),
          TKeyValue.text('Created At', data.meta?.createdAt),
          TKeyValue.text('Updated At', data.meta?.updatedAt),
        ]);
      },
      rowColorBuilder: (item, index) {
        if (item.data.stock < 5) return Colors.red.withAlpha(15);
        if (item.data.stock < 10) return Colors.orange.withAlpha(15);
        return null; // Use default background color
      },
      controller: controller,
      archiveController: archiveController,
    );
  }
}

var productId = 1000;
var categories = ['Category 1', 'Category 2', 'Category 3'];

class ProductForm extends TFormBase {
  final title = TFieldProp('');
  final description = TFieldProp('');
  final price = TFieldProp(0.0);
  final date = TFieldProp(DateTime.now());
  final category = TFieldProp('Category 1');

  ProductForm([ProductDto? product]) {
    if (product != null) {
      title.value = product.title;
      description.value = product.description;
      price.value = product.price.toDouble();
      category.value = product.category;

      final createdAt = product.meta?.createdAt;
      if (createdAt != null) {
        date.value = DateTime.tryParse(createdAt) ?? DateTime.now();
      }
    }
  }

  @override
  double get formWidth => 750;

  @override
  String get formTitle => title.value.isEmpty ? 'Add New Product' : 'Edit Product: ${title.value}';

  @override
  String get formActionName => title.value.isEmpty ? 'Add New Product' : 'Update Product';

  @override
  List<TFormField> get fields {
    return [
      TFormField.text(title, 'Title', isRequired: true).size(6),
      TFormField.number(price, 'Price').size(6),
      TFormField.date(date, "Date"),
      TFormField.text(description, 'Description', rows: 3),
    ];
  }
}
