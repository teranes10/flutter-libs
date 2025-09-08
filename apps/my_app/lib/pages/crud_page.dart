import 'package:flutter/material.dart';
import 'package:my_app/clients/products_client.dart';
import 'package:my_app/models/product_dto.dart';
import 'package:te_widgets/te_widgets.dart';

class CrudPage extends StatelessWidget {
  const CrudPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final controller = TTableController<ProductDto>();

    return TCrudTable<ProductDto, ProductForm>(
      headers: [
        TTableHeader.image("Image", (x) => x.thumbnail),
        TTableHeader.map('SKU', (x) => x.sku),
        TTableHeader.map('Title', (x) => x.title),
        TTableHeader.map('Category', (x) => x.category),
        TTableHeader.map('Price', (x) => x.price),
        TTableHeader.map('Discount', (x) => x.discountPercentage),
        TTableHeader.map('Rating', (x) => x.rating),
        TTableHeader.chip('Stock', (x) => x.stock, color: AppColors.info)
      ],
      onLoad: ProductsClient().loadMore,
      onArchiveLoad: ProductsClient().loadMore,
      createForm: () => ProductForm(),
      editForm: (ProductDto item) => ProductForm(),
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
        return item;
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
      config: TCrudConfig(topBarActions: [
        TButton(
          type: TButtonType.outline,
          size: TButtonSize.lg,
          icon: Icons.upload_file,
          text: 'Upload File',
          onPressed: (_) => {},
        ),
        TButton(
          type: TButtonType.outline,
          size: TButtonSize.lg,
          icon: Icons.select_all_sharp,
          text: 'Selected',
          onPressed: (_) => {TToastService.info(context, 'Selected Items: ${controller.selectedItems.map((x) => x.title).join("\n")}')},
        ),
      ]),
      selectable: true,
      expandable: true,
      expandedBuilder: (item, index, isExpanded) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: theme.surfaceDim, borderRadius: BorderRadius.circular(8)),
        child: TKeyValueSection(values: [
          TKeyValue('QR Code', widget: item.meta?.qrCode != null ? Image.network(item.meta!.qrCode, width: 80) : SizedBox.shrink()),
          TKeyValue.text('Description', item.description),
          TKeyValue.text('Barcode', item.meta?.barcode),
          TKeyValue.text('Created At', item.meta?.createdAt),
          TKeyValue.text('Updated At', item.meta?.updatedAt),
        ]),
      ),
      tableController: controller,
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

  @override
  double get formWidth => 750;

  @override
  String get formTitle => 'Add New Product';

  @override
  String get formActionName => 'Add New Product';

  @override
  List<TFormField> get fields {
    return [
      TFormField.text(title, 'Title', isRequired: true).size(6),
      TFormField.number(price, 'Price').size(6),
      TFormField.select<ProductDto, String>(category, 'Category',
          onLoad: ProductsClient().loadMore, itemText: (x) => x.title, itemValue: (x) => x.sku),
      TFormField.date(date, "Date"),
      TFormField.text(description, 'Description', rows: 3),
    ];
  }
}
