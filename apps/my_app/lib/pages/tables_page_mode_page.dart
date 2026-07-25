import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'tables_bottom_page.dart';

class TablesPageModePage extends StatefulWidget {
  const TablesPageModePage({super.key});

  @override
  State<TablesPageModePage> createState() => _TablesPageModePageState();
}

class _TablesPageModePageState extends State<TablesPageModePage> {
  late final TListController<DemoProduct, String> _controller;

  @override
  void initState() {
    super.initState();
    _controller = TListController<DemoProduct, String>(items: demoProducts, itemKey: (p) => p.id, expansionMode: TExpansionMode.single);
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
      TTableHeader<DemoProduct, String>.image("Image", (x) => x.imageUrl, width: 60),
      TTableHeader<DemoProduct, String>.map("Name", (x) => x.name),
      TTableHeader<DemoProduct, String>.map("Category", (x) => x.category),
      TTableHeader<DemoProduct, String>.rating("Rating", (x) => x.rating),
      TTableHeader<DemoProduct, String>.chip(
        "StockStatus",
        (x) => x.stock > 10 ? 'In Stock (${x.stock})' : 'Low Stock (${x.stock})',
        color: (x) => x.stock > 10 ? context.theme.success : context.theme.danger,
      ),
      TTableHeader<DemoProduct, String>.map("Price", (x) => '\$${x.price.toStringAsFixed(2)}'),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          key: const ValueKey('tables_page_mode_container'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Row Expansion: Page Mode',
                style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Expands the row details into a full page view by navigating to a new route. Best suited for mobile form factors or scenarios containing extensive lists, complex sub-components, or graphs.',
                style: context.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: colors.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colors.outlineVariant.o(0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TTable<DemoProduct, String>(
                    shrinkWrap: true,
                    headers: headers,
                    controller: _controller,
                    details: TTableDetails(
                      mode: TTableExpansionMode.page,
                      itemTitle: (x) => x.name,
                      itemSubTitle: (x) => x.category,
                      itemImageUrl: (x) => x.imageUrl,
                      itemDescription: (x) => x.description,
                      builder: (ctx, item, index) {
                        final product = item.data;
                        return TRowExpandedBuilder.tabs(
                          ctx,
                          tabs: [
                            TTab(
                              value: 'specification',
                              text: 'Specification',
                              content: (ctx) => SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: TKeyValueSection(
                                  values: [
                                    TKeyValue.text('SKU Code', product.sku),
                                    TKeyValue.text('Manufacturer', product.manufacturer),
                                    TKeyValue.text('Warranty', product.warranty),
                                    TKeyValue.text('Weight', product.weight),
                                    TKeyValue.text('Description', product.description),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
