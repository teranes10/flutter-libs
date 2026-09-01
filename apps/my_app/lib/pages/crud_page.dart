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
        flatActions: false,
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
        final mockReviews = const [
          _Review('John Doe', 5, 'Excellent product, highly recommended!'),
          _Review('Jane Smith', 4, 'Very good quality, but shipping took a while.'),
          _Review('Bob Johnson', 3, 'Decent, but a bit overpriced.'),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. General Product Information Card
              TCard(
                title: 'Product Information',
                icon: Icons.info_outline_rounded,
                trailing: TChip(
                  text: data.category.toUpperCase(),
                  type: TVariant.tonal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TKeyValueSection.columnsInline(
                      gap: 12,
                      hSpacing: 20,
                      vSpacing: 10,
                      values: [
                        TKeyValue.text('Title', data.title),
                        TKeyValue.text('SKU', data.sku),
                        TKeyValue.text('Category', data.category),
                        TKeyValue.text('Price', '\$${data.price.toStringAsFixed(2)}'),
                        TKeyValue.text('Discount', '${data.discountPercentage}%'),
                        TKeyValue.text('Rating', '${data.rating} / 5.0'),
                        TKeyValue.text('Barcode', data.meta?.barcode),
                        TKeyValue.datetime('Created At', data.meta?.createdAt),
                        TKeyValue.datetime('Updated At', data.meta?.updatedAt),
                      ],
                    ),
                    if (data.description.isNotEmpty || data.meta?.qrCode != null) ...[
                      const SizedBox(height: 12),
                      Divider(height: 1, color: ctx.colors.outlineVariant.withAlpha(80)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data.meta?.qrCode != null) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QR Code',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ctx.colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TImage(
                                  url: data.meta!.qrCode,
                                  size: 64,
                                  border: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                          ],
                          if (data.description.isNotEmpty)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: ctx.colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    data.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: ctx.colors.onSurface,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Inventory & Stock Distribution Card
              TCard(
                title: 'Stock & Warehouses',
                icon: Icons.warehouse_outlined,
                trailing: TChip(
                  text: '${data.stock} Units',
                  type: TVariant.tonal,
                  color: data.stock > 0 ? ctx.colors.primary : ctx.colors.error,
                ),
                child: TKeyValueSection.columnsInline(
                  values: [
                    TKeyValue.text('Total Stock', '${data.stock} units'),
                    TKeyValue.text('SKU', data.sku),
                    TKeyValue.text('Warehouse A (60%)', '${(data.stock * 0.6).round()} units'),
                    TKeyValue.text('Warehouse B (40%)', '${(data.stock * 0.4).round()} units'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Product Gallery Card
              TCard(
                title: 'Product Gallery',
                subtitle: (data.images != null && data.images!.isNotEmpty)
                    ? '${data.images!.length} images'
                    : 'No images available',
                icon: Icons.photo_library_outlined,
                child: data.images == null || data.images!.isEmpty
                    ? Text(
                        'No images available',
                        style: TextStyle(color: ctx.colors.onSurfaceVariant),
                      )
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: data.images!
                            .map(
                              (img) => TImage(
                                url: img,
                                size: 100,
                                border: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
              const SizedBox(height: 16),

              // 4. Customer Reviews Card
              TCard(
                title: 'Customer Reviews',
                subtitle: '${mockReviews.length} reviews',
                icon: Icons.rate_review_outlined,
                child: TDataTable<_Review, int>(
                  shrinkWrap: true,
                  headers: [
                    TTableHeader('Reviewer', map: (r) => r.reviewer),
                    TTableHeader.rating('Rating', (r) => r.rating.toDouble()),
                    TTableHeader('Comment', map: (r) => r.comment),
                  ],
                  items: mockReviews,
                ),
              ),
            ],
          ),
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
