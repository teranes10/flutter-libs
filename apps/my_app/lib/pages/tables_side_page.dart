import 'package:flutter/material.dart';
import 'package:my_app/models/demo_product.dart';
import 'package:te_widgets/te_widgets.dart';

class TablesSidePage extends StatefulWidget {
  const TablesSidePage({super.key});

  @override
  State<TablesSidePage> createState() => _TablesSidePageState();
}

class _TablesSidePageState extends State<TablesSidePage> {
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
    // The side panel needs the table to fill the page height, so this page lays out its own header instead of using a
    // scrolling TPageWrapper.
    return Padding(
      padding: const EdgeInsets.all(24),
      key: const ValueKey('tables_side_container'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TTile.h4(
            title: 'Row Expansion: Side Mode',
            subtitle:
                'Expands the row details into a dedicated side panel drawer. Ideal for desktop views when inspecting complex data objects with multiple tabs.',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TTable<DemoProduct, String>(
              headers: demoProductHeaders(context),
              controller: _controller,
              details: TTableDetails(
                mode: TTableExpansionMode.side,
                itemTitle: (x) => x.name,
                itemSubTitle: (x) => x.category,
                itemImageUrl: (x) => x.imageUrl,
                itemDescription: (x) => x.description,
                itemHighlights: (x) => [x.stockStatus.toChip(context, stock: x.stock)],
                builder: (ctx, item, index) {
                  final product = item.data;
                  return TRowExpandedBuilder.tabs(
                    ctx,
                    tabs: [
                      TTab(
                        value: 'overview',
                        text: 'Overview',
                        content: (ctx) => SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: TKeyValueSection(
                            values: [
                              TKeyValue.text('SKU Code', product.sku),
                              TKeyValue.text('Manufacturer', product.manufacturer),
                              TKeyValue.text('Weight', product.weight),
                            ],
                          ),
                        ),
                      ),
                      TTab(
                        value: 'specs',
                        text: 'Specs',
                        content: (ctx) => SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: TKeyValueSection(values: [TKeyValue.text('Warranty', product.warranty)]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
