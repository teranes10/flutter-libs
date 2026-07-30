import 'package:flutter/material.dart';
import 'package:my_app/clients/products_client.dart';
import 'package:my_app/models/product_dto.dart';
import 'package:te_widgets/te_widgets.dart';

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
      TTableHeader.image("Image", (x) => x.thumbnail, forceCache: true),
      TTableHeader.map('SKU', (x) => x.sku),
      TTableHeader.map('Title', (x) => x.title),
      TTableHeader.map('Category', (x) => x.category),
      TTableHeader.map('Price', (x) => x.price),
      TTableHeader.map('Discount', (x) => x.discountPercentage),
      TTableHeader.rating('Rating', (x) => x.rating.toDouble()),
      TTableHeader.chip('Stock', (x) => x.stock, color: (_) => context.theme.info),
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
      config: TCrudConfig<ProductDto, int>(
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
      itemTitle: (item) => item.title,
      itemSubTitle: (item) => item.sku,
      itemImageUrl: (item) => item.thumbnail,
      itemDescription: (item) => item.description,
      itemInfo: (item) => [
        TKeyValue.text('SKU', item.sku),
        TKeyValue.text('Category', item.category),
        TKeyValue.text('Stock', '${item.stock} units'),
        TKeyValue.text('Price', '\$${item.price.toStringAsFixed(2)}'),
        TKeyValue.text('Rating', '${item.rating} / 5.0'),
      ],
      expansionMode: TTableExpansionMode.side,
      expandedBuilder: (ctx, item, index) {
        final data = item.data;

        return TRowExpandedBuilder.tabs(
          ctx,
          tabs: [
            TTab(
              value: 'info',
              text: 'Info',
              content: (ctx) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: TKeyValueSection(
                  values: [
                    TKeyValue(
                      'QR Code',
                      widget: data.meta?.qrCode != null ? TImage(url: data.meta!.qrCode, size: 60) : const SizedBox.shrink(),
                    ),
                    ...TKeyValue.mapHeaders(ctx, headers, item, index),
                    TKeyValue.text('Barcode', data.meta?.barcode),
                    TKeyValue.datetime('Created At', data.meta?.createdAt),
                    TKeyValue.datetime('Updated At', data.meta?.updatedAt),
                    TKeyValue.text('Description', data.description),
                  ],
                ),
              ),
            ),
            TTab(
              value: 'stock',
              text: 'Stock',
              content: (ctx) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: TKeyValueSection(
                  values: [
                    TKeyValue.text('Total Stock', '${data.stock} units'),
                    TKeyValue.text('SKU', data.sku),
                    TKeyValue.text('Warehouse A', '${(data.stock * 0.6).round()} units'),
                    TKeyValue.text('Warehouse B', '${(data.stock * 0.4).round()} units'),
                  ],
                ),
              ),
            ),

            TTab(
              value: 'images',
              text: 'Images',
              content: (ctx) => data.images == null || data.images!.isEmpty
                  ? const Center(child: Text('No images available'))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: data.images!.length,
                      itemBuilder: (context, i) => TImage(
                        url: data.images![i],
                        size: 150,
                        border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
            ),
            TTab(
              value: 'reviews',
              text: 'Reviews',
              content: (ctx) {
                final mockReviews = [
                  const _Review('John Doe', 5, 'Excellent product, highly recommended!'),
                  const _Review('Jane Smith', 4, 'Very good quality, but shipping took a while.'),
                  const _Review('Bob Johnson', 3, 'Decent, but a bit overpriced.'),
                ];

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TDataTable<_Review, int>(
                    shrinkWrap: true,
                    headers: [
                      TTableHeader('Reviewer', map: (r) => r.reviewer),
                      TTableHeader.rating('Rating', (r) => r.rating.toDouble()),
                      TTableHeader('Comment', map: (r) => r.comment),
                    ],
                    items: mockReviews,
                  ),
                );
              },
            ),
          ],
        );
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

class _Review {
  final String reviewer;
  final int rating;
  final String comment;
  const _Review(this.reviewer, this.rating, this.comment);
}
