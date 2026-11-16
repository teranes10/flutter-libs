import 'package:flutter/material.dart';
import 'package:my_app/models/product_dto.dart';
import 'package:te_widgets/te_widgets.dart';

/// Side-overlay panel of a product row in the CRUD page.
///
/// The table already draws the header (image, title, SKU, description and the key facts), so the panel only
/// shows what the header does not: pricing detail, stock distribution, gallery and reviews.
class ProductDetailPanel extends StatelessWidget {
  final ProductDto product;

  const ProductDetailPanel({super.key, required this.product});

  static const _reviews = [
    _Review('John Doe', 5, 'Excellent product, highly recommended!'),
    _Review('Jane Smith', 4, 'Very good quality, but shipping took a while.'),
    _Review('Bob Johnson', 3, 'Decent, but a bit overpriced.'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final images = product.images ?? const <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          TCard(
            title: 'Product Information',
            icon: HugeIcons.strokeRoundedInformationCircle,
            trailing: TChip(text: product.category.toUpperCase(), type: TVariant.tonal),
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TKeyValueSection.columnsInline(
                  gap: 12,
                  hSpacing: 20,
                  vSpacing: 10,
                  values: [
                    TKeyValue.text('Discount', '${product.discountPercentage}%'),
                    TKeyValue.text('Barcode', product.meta?.barcode),
                    TKeyValue.datetime('Created At', product.meta?.createdAt),
                    TKeyValue.datetime('Updated At', product.meta?.updatedAt),
                  ],
                ),
                if (product.meta?.qrCode != null) ...[
                  const TDivider(space: 24),
                  Text(
                    'QR Code',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  TImage(
                    url: product.meta!.qrCode,
                    size: 64,
                    border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ],
              ],
            ),
          ),
          TCard(
            title: 'Stock & Warehouses',
            icon: HugeIcons.strokeRoundedWarehouse,
            trailing: TChip(text: '${product.stock} Units', type: TVariant.tonal, color: product.stock > 0 ? colors.primary : colors.error),
            margin: EdgeInsets.zero,
            child: TKeyValueSection.columnsInline(
              values: [
                TKeyValue.text('Warehouse A (60%)', '${(product.stock * 0.6).round()} units'),
                TKeyValue.text('Warehouse B (40%)', '${(product.stock * 0.4).round()} units'),
              ],
            ),
          ),
          TCard(
            title: 'Product Gallery',
            subtitle: images.isEmpty ? 'No images available' : '${images.length} images',
            icon: HugeIcons.strokeRoundedLibrary,
            margin: EdgeInsets.zero,
            child: images.isEmpty
                ? const TEmptyState(title: 'No images available')
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final img in images)
                        TImage(
                          url: img,
                          size: 100,
                          border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                    ],
                  ),
          ),
          TCard(
            title: 'Customer Reviews',
            subtitle: '${_reviews.length} reviews',
            icon: HugeIcons.strokeRoundedChatPreview,
            margin: EdgeInsets.zero,
            child: TDataTable<_Review, int>(
              shrinkWrap: true,
              headers: [
                TTableHeader<_Review, int>.map('Reviewer', (r) => r.reviewer),
                TTableHeader<_Review, int>.rating('Rating', (r) => r.rating.toDouble()),
                TTableHeader<_Review, int>.map('Comment', (r) => r.comment),
              ],
              items: _reviews,
            ),
          ),
        ],
      ),
    );
  }
}

class _Review {
  final String reviewer;
  final int rating;
  final String comment;
  const _Review(this.reviewer, this.rating, this.comment);
}
