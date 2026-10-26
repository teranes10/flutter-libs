import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

import '../widgets/mobile_device_frame.dart';

const _productImage = 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=100&h=100&fit=crop';

enum _VarianceKind { shortage, overage }

extension _VarianceKindExt on _VarianceKind {
  String get label => switch (this) {
    _VarianceKind.shortage => 'Shortage',
    _VarianceKind.overage => 'Overage',
  };

  Color color(BuildContext context) => switch (this) {
    _VarianceKind.shortage => context.theme.danger,
    _VarianceKind.overage => context.theme.warning,
  };
}

class _Item {
  final String code;
  final String name;
  final String location;
  final int counted;
  final int variance;

  const _Item(this.code, this.name, this.location, this.counted, {this.variance = 0});

  _VarianceKind get kind => variance < 0 ? _VarianceKind.shortage : _VarianceKind.overage;

  /// Sample batch split of the counted quantity (mfg - exp with count).
  List<({String batch, String mfg, String exp, int qty})> get batches => [
    (batch: 'BATCH-001', mfg: 'Jan 2026', exp: 'Dec 2027', qty: counted - counted ~/ 3),
    (batch: 'BATCH-002', mfg: 'Feb 2026', exp: 'Jan 2028', qty: counted ~/ 3),
  ];
}

const _items = [
  _Item('TFA-001', 'Tofacitinib 5mg', 'Aisle A1 - Bin 03', 12),
  _Item('PAR-001', 'Paracetamol 500mg', 'Aisle A1 - Bin 03', 24, variance: -3),
  _Item('AMX-001', 'Amoxicillin 500mg', 'Aisle A1 - Bin 03', 16, variance: 2),
  _Item('VIT-001', 'Vitamin D3 1000IU', 'Aisle A2 - Bin 01', 10, variance: -1),
  _Item('IBU-001', 'Ibuprofen 400mg', 'Aisle A2 - Bin 01', 8, variance: 4),
  _Item('MET-001', 'Metformin 500mg', 'Aisle A2 - Bin 01', 6, variance: -2),
];

const _locationTypes = ['Zone', 'Aisle', 'Rack', 'Shelf', 'Bin'];
const _reasons = ['Miscount', 'Damaged', 'Expired', 'Missing', 'Other'];

/// Stock Take v2 flow sample, built from the "MainHub -> Final" design reference.
///
/// Home -> list -> create -> select location -> items -> item details & batches
/// -> stock count -> new stock -> summary -> completed. Built only
/// from te_widgets handheld widgets (see te-widgets skill references 08-11).
class StocktakeV2Page extends StatefulWidget {
  const StocktakeV2Page({super.key});

  @override
  State<StocktakeV2Page> createState() => _StocktakeV2PageState();
}

class _StocktakeV2PageState extends State<StocktakeV2Page> {
  String _listFilter = 'all';
  String _summaryTab = 'all';
  int _count = 12;
  int _varCount = 9;
  String? _reason = 'Miscount';
  DateTime? _expiry;
  final _currentWarehouse = ValueNotifier<String?>('Main Warehouse');
  final _locationType = ValueNotifier<String?>('Rack');

  @override
  void dispose() {
    _locationType.dispose();
    super.dispose();
  }

  Widget _frame(Widget child, {List<TBottomBarItem> bar = const []}) {
    return TMobileDeviceFrame(height: 700, bottomBarItems: bar, child: child);
  }

  Widget _page({
    required String title,
    String? subTitle,
    String? imageUrl,
    List<TKeyValue>? itemInfo,
    List<Widget>? actions,
    Widget? footer,
    bool back = true,
    required Widget child,
  }) {
    return TPageWrapper(
      title: title,
      subTitle: subTitle,
      imageUrl: imageUrl,
      itemInfo: itemInfo,
      actions: actions,
      footer: footer,
      onBackPressed: back ? () {} : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      contentPadding: const EdgeInsets.all(16),
      child: child,
    );
  }

  /// Page whose app bar carries the product (image, SKU, name, location).
  Widget _itemPage({required _Item item, List<Widget>? actions, Widget? footer, required Widget child}) {
    return _page(
      title: item.code,
      subTitle: item.name,
      imageUrl: _productImage,
      itemInfo: [TKeyValue(icon: HugeIcons.strokeRoundedLocation01, '', value: item.location)],
      actions: actions,
      footer: footer,
      child: child,
    );
  }

  Widget _addAction() => TButton(type: TButtonType.text, icon: Icons.add, onTap: () {});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Take Flow v2',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'MainHub -> stock take list -> create -> select location -> items -> item details & batches -> stock count '
            '-> new stock -> summary -> completed. Built only from te_widgets handheld widgets: '
            'TTile.task, TTreeView, TTextField.scan, TNumberField(quantity), TAccordion, TMetricTile, TActionBar, TBanner, TResult.',
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _frame(_mainHub(), bar: _bar()),
              _frame(_list()),
              _frame(_create()),
              _frame(_selectLocation()),
              _frame(_createLocation()),
              _frame(_itemsScreen()),
              _frame(_itemDetails()),
              _frame(_newStock()),
              _frame(_stockCount()),
              _frame(_stockCountVariance()),
              _frame(_summary()),
              _frame(_completed()),
            ],
          ),
        ],
      ),
    );
  }

  List<TBottomBarItem> _bar() => const [
    TBottomBarItem(icon: Icons.home_outlined, label: 'Home'),
    TBottomBarItem(icon: Icons.inventory_2_outlined, label: 'Inventory'),
    TBottomBarItem(icon: Icons.swap_horiz_rounded, label: 'Transfers'),
    TBottomBarItem(icon: Icons.bar_chart_rounded, label: 'Reports'),
  ];

  Widget _hubTile(String title, IconData icon, {bool primary = false}) {
    return TTile(
      title: title,
      icon: icon,
      iconBackgroundColor: Colors.transparent,
      size: TSize.md,
      iconOnTop: true,
      iconColor: primary ? context.colors.primary : null,
    ).card(shadow: TCardShadow.sm, onTap: () {});
  }

  // 1. MainHub
  Widget _mainHub() {
    return _page(
      title: 'MainHub',
      back: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TImage.profile(name: 'Teranes Ranjith', role: 'Warehouse Operator'),
          const SizedBox(height: 15),
          TSelect<String, String, String>(label: 'Warehouse', items: ['Main Warehouse'], valueNotifier: _currentWarehouse),
          const SizedBox(height: 10),
          TGrid(
            columns: 2,
            children: [
              _hubTile('Stocktake', Icons.inventory_rounded, primary: true),
              _hubTile('Orders', Icons.shopping_bag_outlined),
              _hubTile('Transfers', Icons.swap_horiz_rounded),
              _hubTile('Reports', Icons.assessment_outlined),
              _hubTile('Settings', Icons.settings_outlined),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Today's Activity",
            style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.onSurface),
          ),
          const SizedBox(height: 12),
          const TGrid(
            columns: 2,
            children: [
              TMetricTile(label: 'Open Stocktakes', value: '2'),
              TMetricTile(label: 'Completed', value: '0'),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Stocktake list
  Widget _list() {
    return _page(
      title: 'Stocktake',
      subTitle: _currentWarehouse.value,
      actions: [_addAction()],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TTextField.scan(label: null, placeholder: 'Search stocktake no...', onScan: (_) {}, onCameraTap: () {}),
          const SizedBox(height: 8),
          TTabs<String>(
            selectedValue: _listFilter,
            onTabChanged: (v) => setState(() => _listFilter = v),
            tabs: const [
              TTab(value: 'all', text: 'All', count: 12),
              TTab(value: 'progress', text: 'In Progress', count: 1),
              TTab(value: 'pending', text: 'Pending', count: 3),
              TTab(value: 'done', text: 'Completed', count: 8),
            ],
          ),
          const SizedBox(height: 8),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _stocktakeTile('STK-006', 'Oct 14, 2026 · 10:24 AM', 'Pending', context.theme.warning),
              const SizedBox(height: 8),
              _stocktakeTile('STK-005', 'Oct 14, 2026 · 09:12 AM', 'Pending', context.theme.warning),
              const SizedBox(height: 8),
              _stocktakeTile('STK-004', 'Oct 13, 2026 · 04:20 PM', 'In Progress', context.theme.info, done: 45, total: 100),
              const SizedBox(height: 8),
              _stocktakeTile('STK-003', 'Oct 12, 2026 · 11:05 AM', 'Completed', context.theme.success),
              const SizedBox(height: 8),
              _stocktakeTile('STK-002', 'Oct 10, 2026 · 02:30 PM', 'Completed', context.theme.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stocktakeTile(String no, String date, String status, Color color, {int? done, int? total}) {
    return TTile.task(
      title: no,
      meta: date,
      status: status,
      statusColor: color,
      done: done,
      total: total,
      icon: Icons.location_on_outlined,
      onTap: () {},
    );
  }

  // 3. Create stocktake
  Widget _create() {
    return _page(
      title: 'Create Stocktake',
      subTitle: _currentWarehouse.value,
      footer: TActionBar(primaryText: 'Save', onPrimary: () {}, secondaryText: 'Cancel', onSecondary: () {}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TTextField.scan(
            label: 'Stocktake No.',
            helperText: 'Auto generated: STK-< Warehouse Code >-< Datetime >',
            value: 'STK-MW-2610101230',
            readOnly: true,
            onScan: (_) {},
            onCameraTap: () {},
          ),
          const SizedBox(height: 16),
          const TTextField(label: 'Notes (optional)', placeholder: 'Add any notes...', rows: 5),
        ],
      ),
    );
  }

  // 4. Select location
  Widget _selectLocation() {
    Widget addChild() => TButton(type: TButtonType.text, size: TSize.sm, icon: Icons.add, onTap: () {});

    return _page(
      title: 'Select Location',
      subTitle: _currentWarehouse.value,
      actions: [_addAction()],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TTextField.scan(label: null, placeholder: 'Search location...', onScan: (_) {}, onCameraTap: () {}),
          const SizedBox(height: 16),
          TTreeView<String>(
            selectionMode: TTreeSelectionMode.single,
            expandedKeys: const {'zone-a', 'aisle-a1', 'rack-r1'},
            onSelectionChanged: (_) {},
            nodes: [
              TTreeNode(
                key: 'zone-a',
                label: 'Zone A',
                icon: Icons.hexagon_outlined,
                trailing: addChild(),
                children: [
                  TTreeNode(
                    key: 'aisle-a1',
                    label: 'Aisle A1',
                    icon: Icons.location_on_outlined,
                    trailing: addChild(),
                    children: [
                      TTreeNode(
                        key: 'rack-r1',
                        label: 'Rack R1',
                        icon: Icons.location_on_outlined,
                        trailing: addChild(),
                        children: [
                          TTreeNode(key: 'bin-b1', label: 'Bin B1', icon: Icons.circle_outlined, isLeaf: true),
                          TTreeNode(key: 'bin-b2', label: 'Bin B2', icon: Icons.circle_outlined, isLeaf: true),
                        ],
                      ),
                      TTreeNode(
                        key: 'rack-r2',
                        label: 'Rack R2',
                        icon: Icons.location_on_outlined,
                        trailing: addChild(),
                        children: const [],
                      ),
                    ],
                  ),
                  TTreeNode(key: 'rack-a2', label: 'Rack A2', icon: Icons.location_on_outlined, trailing: addChild(), children: const []),
                  TTreeNode(key: 'aisle-a3', label: 'Aisle A3', icon: Icons.location_on_outlined, trailing: addChild(), children: const []),
                ],
              ),
              TTreeNode(key: 'zone-b', label: 'Zone B', icon: Icons.hexagon_outlined, trailing: addChild(), children: const []),
              TTreeNode(key: 'zone-c', label: 'Zone C', icon: Icons.hexagon_outlined, trailing: addChild(), children: const []),
            ],
          ),
        ],
      ),
    );
  }

  // 4b. Create location (parent chosen -> shown as app bar subtitle)
  Widget _createLocation() {
    return _page(
      title: 'Create Location',
      subTitle: '${_currentWarehouse.value ?? ''} › Zone A › Aisle A1',
      footer: TActionBar(primaryText: 'Save', onPrimary: () {}, secondaryText: 'Cancel', onSecondary: () {}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TSelect<String, String, String>(
            label: 'Category / Type',
            placeholder: 'Select type',
            items: _locationTypes,
            valueNotifier: _locationType,
          ),
          const SizedBox(height: 16),
          TTextField.scan(label: 'Code', placeholder: 'e.g. A1-R3', onScan: (_) {}, onCameraTap: () {}),
          const SizedBox(height: 16),
          const TTextField(label: 'Name', placeholder: 'e.g. Rack R3'),
          const SizedBox(height: 16),
          TTextField.scan(label: 'Barcode (optional)', placeholder: 'Scan or enter barcode', onScan: (_) {}, onCameraTap: () {}),
          const SizedBox(height: 16),
          const TTextField(label: 'Description (optional)', placeholder: 'Add a description...', rows: 4),
        ],
      ),
    );
  }

  // 5. Items at this location
  Widget _itemsScreen() {
    return _page(
      title: 'Items',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TTextField.scan(placeholder: 'Search item or scan', onScan: (_) {}, onCameraTap: () {}),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item = _items[i];
              return TTile(
                title: item.code,
                subtitle: item.name,
                icon: Icons.inventory_2_outlined,
                trailing: TChip(text: '${item.counted}'),
              ).card(onTap: () {});
            },
          ),
        ],
      ),
    );
  }

  // 6. Item details & stock list
  Widget _itemDetails() {
    final item = _items.first;
    return _itemPage(
      item: item,
      actions: [_addAction()],
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: item.batches.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final b = item.batches[i];
          return TTile(
            title: b.batch,
            subtitle: 'Mfg: ${b.mfg} · Exp: ${b.exp}',
            icon: Icons.inventory_2_outlined,
            trailing: TChip(text: '${b.qty}'),
          ).card(onTap: () {});
        },
      ),
    );
  }

  Widget _countFooter() {
    return TActionBar(
      primaryText: 'Next Item',
      onPrimary: () {},
      secondaryText: 'Next Location',
      onSecondary: () {},
      tertiaryText: 'Done',
      onTertiary: () {},
    );
  }

  // 7. Stock count
  Widget _stockCount() {
    final variance = _count - 12;
    return _itemPage(
      item: _items.first,
      footer: _countFooter(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TGrid(
            columns: 1,
            children: [TMetricTile(label: 'System Count', value: '12')],
          ),
          const SizedBox(height: 16),
          TNumberField<int>(
            variant: TNumberFieldVariant.quantity,
            label: 'Actual Count',
            value: _count,
            min: 0,
            onValueChanged: (v) => setState(() => _count = v ?? 0),
          ),
          const SizedBox(height: 12),
          if (variance == 0)
            const TBanner.success(title: 'No variance', message: 'System and actual count match.')
          else
            TBanner.warning(title: 'Variance $variance', message: 'System: 12, counted: 9.'),
        ],
      ),
    );
  }

  // 7b. Stock count with variance: reasons + notes
  Widget _stockCountVariance() {
    final variance = _varCount - 12;
    return _itemPage(
      item: _items.first,
      footer: _countFooter(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TGrid(
            columns: 1,
            children: [TMetricTile(label: 'System Count', value: '12')],
          ),
          const SizedBox(height: 16),
          TNumberField<int>(
            variant: TNumberFieldVariant.quantity,
            label: 'Actual Count',
            value: _varCount,
            min: 0,
            onValueChanged: (v) => setState(() => _varCount = v ?? 0),
          ),
          const SizedBox(height: 12),
          if (variance == 0)
            const TBanner.success(title: 'No variance', message: 'System and actual count match.')
          else ...[
            TBanner.warning(title: 'Variance $variance', message: 'System: 12, counted: 9.'),
            const SizedBox(height: 16),
            Text(
              'Reason',
              style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.onSurface),
            ),
            const SizedBox(height: 8),
            for (final r in _reasons) ...[
              TOptionTile(label: r, selected: _reason == r, onTap: () => setState(() => _reason = r)),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            const TTextField(label: 'Notes (optional)', placeholder: 'Add any notes...', rows: 3),
          ],
        ],
      ),
    );
  }

  // 8. New stock
  Widget _newStock() {
    return _itemPage(
      item: _items.first,
      footer: TActionBar(primaryText: 'Create Stock', onPrimary: () {}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TTextField(label: 'Batch / Lot No. (optional)', placeholder: 'e.g. BATCH-001'),
          const SizedBox(height: 12),
          const TTextField(label: 'Manufacturer (optional)', placeholder: 'e.g. Pfizer'),
          const SizedBox(height: 12),
          TDatePicker(
            label: 'Expiry Date (optional)',
            placeholder: 'Select date',
            value: _expiry,
            onValueChanged: (v) => setState(() => _expiry = v),
          ),
          const SizedBox(height: 12),
          const TTextField(label: 'Serial No. (optional)', placeholder: 'e.g. SN123456'),
          const SizedBox(height: 12),
          TNumberField<int>(
            variant: TNumberFieldVariant.quantity,
            label: 'Count',
            value: _count,
            min: 0,
            onValueChanged: (v) => setState(() => _count = v ?? 0),
          ),
        ],
      ),
    );
  }

  // 9. Summary (All / Exceptions share one screen)
  Widget _summary() {
    final exceptions = _items.where((i) => i.variance != 0).toList();
    final exceptionsOnly = _summaryTab == 'exceptions';
    final shown = exceptionsOnly ? exceptions : _items;
    final locations = <String, List<_Item>>{};
    for (final i in shown) {
      locations.putIfAbsent(i.location, () => []).add(i);
    }

    return _page(
      title: 'Stocktake Summary',
      footer: TActionBar(primaryText: 'Next Location', onPrimary: () {}, secondaryText: 'Done', onSecondary: () {}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TGrid(
            columns: 3,
            children: [
              _summaryMetric('Locations', '4', context.theme.success),
              _summaryMetric('Items Counted', '62', context.theme.success),
              _summaryMetric('Units Counted', '357', context.theme.success),
              _summaryMetric('Variances', '8', context.theme.warning),
              _summaryMetric('Exceptions', '5', context.theme.danger),
            ],
          ),
          const SizedBox(height: 12),
          TTabs<String>(
            selectedValue: _summaryTab,
            onTabChanged: (v) => setState(() => _summaryTab = v),
            tabs: [
              const TTab(value: 'all', text: 'All', count: 62),
              TTab(value: 'exceptions', text: 'Exceptions', count: exceptions.length),
            ],
          ),
          const SizedBox(height: 12),
          // One location open at a time, and one product open at a time within it.
          TAccordionGroup(
            key: ValueKey('loc_$_summaryTab'),
            spacing: 8,
            initiallyExpandedIndex: 0,
            children: [
              for (final e in locations.entries)
                TAccordion(
                  title: e.key,
                  size: TTileSize.h6,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  subtitle: '${e.value.length} items',
                  icon: Icons.location_on_outlined,
                  trailing: _countText(e.value.fold(0, (s, i) => s + i.counted)),
                  content: TAccordionGroup(spacing: 4, children: [for (final item in e.value) _summaryItem(item, exceptionsOnly)]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric(String label, String value, Color color) {
    return TMetricTile(label: label, value: value, compact: true, color: color, type: TVariant.tonal);
  }

  Widget _countText(int n) {
    return Text(
      '$n',
      style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.onSurface),
    );
  }

  TAccordion _summaryItem(_Item item, bool exceptionsOnly) {
    final ok = item.variance == 0;
    final kind = item.kind;
    return TAccordion(
      title: item.code,
      subtitle: item.name,
      size: TTileSize.h5,
      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      icon: Icons.inventory_2_outlined,
      iconColor: ok ? null : kind.color(context),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (exceptionsOnly) ...[TChip(text: kind.label, color: kind.color(context)), const SizedBox(width: 8)],
          _countText(item.counted),
          const SizedBox(width: 8),
          HugeIcon(
            icon: ok ? HugeIcons.strokeRoundedCheckmarkCircle02 : HugeIcons.strokeRoundedAlert02,
            color: ok ? context.theme.success : context.theme.danger,
            size: 22,
          ),
        ],
      ),
      content: Column(
        children: [
          for (final b in item.batches)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
              child: TTile(size: TTileSize.h7, title: b.batch, subtitle: 'Mfg: ${b.mfg} · Exp: ${b.exp}', trailing: _countText(b.qty)),
            ),
        ],
      ),
    );
  }

  // 10. Final
  Widget _completed() {
    return _page(
      title: 'Stocktake',
      back: false,
      footer: TActionBar(primaryText: 'View Details', onPrimary: () {}, secondaryText: 'Back to MainHub', onSecondary: () {}),
      child: SizedBox(
        height: 520,
        child: TResult.success(title: 'Stocktake Completed', subtitle: 'STK-001 · Oct 13, 2026 · 09:40 AM'),
      ),
    );
  }
}
