import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

import '../widgets/mobile_device_frame.dart';

const _productImage = 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=100&h=100&fit=crop';

enum _ExceptionReason { differentLocation, wrongItem, wrongBatch, damaged, other }

extension _ExceptionReasonExt on _ExceptionReason {
  String get label => switch (this) {
    _ExceptionReason.differentLocation => 'Item in different location',
    _ExceptionReason.wrongItem => 'Wrong item at location',
    _ExceptionReason.wrongBatch => 'Different batch picked',
    _ExceptionReason.damaged => 'Damaged item',
    _ExceptionReason.other => 'Other',
  };
}

/// The three things a picker has to confirm for a line.
enum _Target { location, item, lot }

extension _TargetExt on _Target {
  String get label => switch (this) {
    _Target.location => 'Location',
    _Target.item => 'Item',
    _Target.lot => 'Batch',
  };

  List<_ExceptionReason> get reasons => switch (this) {
    _Target.location => const [_ExceptionReason.differentLocation, _ExceptionReason.other],
    _Target.item => const [_ExceptionReason.wrongItem, _ExceptionReason.damaged, _ExceptionReason.other],
    _Target.lot => const [_ExceptionReason.wrongBatch, _ExceptionReason.damaged, _ExceptionReason.other],
  };
}

/// Scan outcome for one [_Target]: confirmed, scanned-but-different (needs an exception) or excepted.
class _Check {
  final bool ok;
  final String? scanned;
  final _ExceptionReason? reason;
  final String notes;

  const _Check({this.ok = false, this.scanned, this.reason, this.notes = ''});

  bool get resolved => ok || reason != null;
  bool get mismatch => !ok && reason == null && scanned != null;

  _Check withReason(_ExceptionReason reason, String notes) => _Check(scanned: scanned, reason: reason, notes: notes);
}

class _ExceptionResult {
  final _ExceptionReason reason;
  final String notes;
  const _ExceptionResult(this.reason, this.notes);
}

class _Batch {
  final String batch;
  final String mfg;
  final String exp;
  final int available;
  const _Batch(this.batch, this.mfg, this.exp, this.available);
}

/// Batches of the current product stocked at the current location.
const _batches = [
  _Batch('BCH-2411', 'Mar 2026', 'Feb 2028', 14),
  _Batch('BCH-2398', 'Nov 2025', 'Oct 2027', 6),
  _Batch('BCH-2420', 'May 2026', 'Apr 2028', 22),
];

class _Line {
  final String code;
  final String name;
  final String location;
  final String batch;
  final String mfg;
  final String exp;
  final int qty;
  final int picked;

  /// Exceptions reported for this line (e.g. picked from a different location).
  final int exceptions;

  const _Line(this.code, this.name, this.location, this.batch, this.mfg, this.exp, this.qty, {this.picked = 0, this.exceptions = 0});

  bool get complete => picked >= qty;
  bool get resolved => complete || exceptions > 0;

  _Line resolve() => resolved ? this : _Line(code, name, location, batch, mfg, exp, qty, picked: qty, exceptions: exceptions);
}

const _lines = [
  _Line('TFA-001', 'Tofacitinib 5mg', 'Aisle A1 - Bin B1', 'BCH-2409', 'Jan 2026', 'Dec 2027', 2, picked: 2),
  _Line('PAR-001', 'Paracetamol 500mg', 'Aisle A1 - Bin B2', 'BCH-2410', 'Feb 2026', 'Jan 2028', 1, picked: 1, exceptions: 1),
  _Line('AMX-001', 'Amoxicillin 500mg', 'Aisle A2 - Bin C1', 'BCH-2411', 'Mar 2026', 'Feb 2028', 2),
  _Line('VIT-001', 'Vitamin D3 1000IU', 'Aisle A2 - Bin C3', 'BCH-2412', 'Mar 2026', 'Mar 2028', 1, exceptions: 1),
  _Line('IBU-001', 'Ibuprofen 400mg', 'Aisle B1 - Bin A2', 'BCH-2413', 'Apr 2026', 'Apr 2028', 1, picked: 1),
  _Line('MET-001', 'Metformin 500mg', 'Aisle B1 - Bin A4', 'BCH-2414', 'Apr 2026', 'May 2028', 3),
];

const _current = _Line('AMX-001', 'Amoxicillin 500mg', 'Aisle A2 - Bin C1', 'BCH-2411', 'Mar 2026', 'Feb 2028', 2);

/// Order Picking flow sample (field archetype), reworked from the design reference.
///
/// Order list -> order details (progress + items + summary on one screen) -> pick
/// (location scan -> item scan -> quantity on ONE screen, product in the app bar)
/// -> confirm & complete. Scanner-first: the wedge scanner types
/// into the focused field, the end icon opens the camera sheet, a verified value
/// turns the field read-only with a green tick.
class OrderPickingPage extends StatefulWidget {
  const OrderPickingPage({super.key});

  @override
  State<OrderPickingPage> createState() => _OrderPickingPageState();
}

class _OrderPickingPageState extends State<OrderPickingPage> {
  String _orderFilter = 'pending';
  String _itemsTab = 'all';

  Widget _frame(Widget child) => TMobileDeviceFrame(height: 700, child: child);

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

  /// Order context (reference, customer, delivery, required date) lives in the app bar.
  Widget _orderPage({Widget? footer, List<Widget>? actions, required Widget child}) {
    return _page(
      title: 'SO-10023',
      subTitle: 'ABC Pharmacy',
      actions: [
        TChip(text: 'High Priority', color: context.theme.danger),
        ...?actions,
      ],
      itemInfo: [
        TKeyValue(icon: HugeIcons.strokeRoundedCalendar03, 'Due', value: 'Oct 13, 2026 - 10:24 AM'),
        TKeyValue.progress('', 3 / 6, valueText: '3 / 6', showPercentage: false),
      ],
      footer: footer,
      child: child,
    );
  }

  /// Product context (image, SKU, name) lives in the app bar; location and batch are tiles on the screen.
  Widget _pickPage({required Widget child, Widget? footer}) {
    return _page(
      title: _current.code,
      subTitle: _current.name,
      imageUrl: _productImage,
      actions: const [TChip(text: 'Item 3 / 6')],
      footer: footer,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Picking Flow',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'Order list (with progress) -> order details & progress (tap an item to pick) -> pick (location, item, quantity on one live screen) '
            '-> completed. Scan-first: wedge scanners fill the focused field, the end icon opens the camera sheet. '
            'A different location / item / batch turns its tile warning and offers an exception bottom sheet. '
            'Try: location "Aisle A2 - Bin C1", item "AMX-001", batch "BCH-2411".',
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [_frame(_orders()), _frame(_orderDetails(complete: false)), _frame(_pick()), _frame(_completed())],
          ),
        ],
      ),
    );
  }

  // 1. Order list
  Widget _orders() {
    return _page(
      title: 'Order Picking',
      back: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TTextField.scan(label: null, placeholder: 'Search order number or customer...', onScan: (_) {}, onCameraTap: () {}),
          const SizedBox(height: 8),
          TTabs<String>(
            selectedValue: _orderFilter,
            onTabChanged: (v) => setState(() => _orderFilter = v),
            tabs: const [
              TTab(value: 'pending', text: 'Pending', count: 3),
              TTab(value: 'progress', text: 'In Progress', count: 1),
              TTab(value: 'done', text: 'Completed', count: 8),
            ],
          ),
          const SizedBox(height: 8),
          _orderTile('SO-10023', 'ABC Pharmacy · Colombo 01', 'High Priority', context.theme.danger, done: 4, total: 6),
          const SizedBox(height: 8),
          _orderTile('SO-10022', 'City Medicals · Due: Oct 13, 09:12 AM', 'Medium', context.theme.warning, done: 0, total: 4),
          const SizedBox(height: 8),
          _orderTile('SO-10021', 'HealthPlus · Due: Oct 12, 04:20 PM', 'Low', context.theme.info, done: 0, total: 3),
          const SizedBox(height: 8),
          _orderTile('SO-10020', 'Green Life · Due: Oct 11, 02:15 PM', 'Low', context.theme.info, done: 0, total: 5),
        ],
      ),
    );
  }

  Widget _orderTile(String no, String meta, String status, Color color, {required int done, required int total}) {
    return TTile.task(
      title: no,
      meta: meta,
      status: status,
      statusColor: color,
      done: done,
      total: total,
      icon: Icons.inventory_2_outlined,
      onTap: () {},
    );
  }

  // Order details + picking summary. No Start button: tap an item to pick it.
  Widget _orderDetails({required bool complete}) {
    final lines = [for (final l in _lines) complete ? l.resolve() : l];
    final resolved = lines.where((l) => l.resolved).length;
    final exceptions = lines.fold<int>(0, (sum, l) => sum + l.exceptions);
    final shown = _itemsTab == 'exceptions' ? lines.where((l) => l.exceptions > 0).toList() : lines;

    return _orderPage(
      footer: TActionBar(primaryText: 'Confirm & Complete', primaryIcon: Icons.check, onPrimary: resolved == lines.length ? () {} : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TTabs<String>(
            selectedValue: _itemsTab,
            onTabChanged: (v) => setState(() => _itemsTab = v),
            tabs: [
              TTab(value: 'all', text: 'All Items', count: lines.length),
              TTab(value: 'exceptions', text: 'Exceptions', count: exceptions),
            ],
          ),
          const SizedBox(height: 8),
          for (final line in shown) ...[_lineTile(line), const SizedBox(height: 8)],
        ],
      ),
    );
  }

  /// Picked / requested quantity (success when fully picked, warning otherwise) and a red count badge for exceptions.
  Widget _lineTile(_Line line) {
    final theme = context.theme;
    return TTile(
      title: line.code,
      subtitle: line.name,
      icon: Icons.inventory_2_outlined,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (line.exceptions > 0) ...[
            TChip.solid(text: '${line.exceptions}', icon: Icons.error_outline_rounded, color: theme.danger, size: TChipSize.sm),
            const SizedBox(width: 10),
          ],
          Text(
            '${line.picked}/${line.qty}',
            style: TextStyle(fontWeight: FontWeight.w700, color: line.complete ? theme.success : theme.warning),
          ),
        ],
      ),
    ).card(shadow: TCardShadow.sm, onTap: () {});
  }

  // Location, lot and item on ONE live screen. Anything that differs from the request becomes an exception.
  _Check _loc = const _Check();
  _Check _item = const _Check();
  _Check _lot = const _Check();
  int _pickedQty = _current.qty;

  _Check _get(_Target t) => switch (t) {
    _Target.location => _loc,
    _Target.item => _item,
    _Target.lot => _lot,
  };

  void _set(_Target t, _Check c) => setState(() {
    switch (t) {
      case _Target.location:
        _loc = c;
      case _Target.item:
        _item = c;
      case _Target.lot:
        _lot = c;
    }
  });

  void _reset() => setState(() {
    _loc = const _Check();
    _item = const _Check();
    _lot = const _Check();
  });

  /// Opens the exception bottom sheet for [t]; returns whether a reason was chosen.
  Future<bool> _showException(_Target t) async {
    final result = await TSheetService.showBottomSheet<_ExceptionResult>(
      context,
      title: '${t.label} exception',
      showCloseButton: true,
      (ctx) => _ExceptionSheet(target: t, onSubmit: ctx.close),
    );
    if (result == null || !mounted) return false;
    _set(t, _get(t).withReason(result.reason, result.notes));
    return true;
  }

  /// Lists the batches stocked at the location and asks the picker to confirm the one picked.
  Future<void> _chooseBatch() async {
    final picked = await TSheetService.showBottomSheet<_Batch>(
      context,
      title: 'Which batch did you pick?',
      showCloseButton: true,
      (ctx) => _BatchSheet(batches: _batches, onConfirm: ctx.close),
    );
    if (picked == null || !mounted) return;
    _set(_Target.lot, picked.batch == _current.batch ? _Check(ok: true, scanned: picked.batch) : _Check(scanned: picked.batch));
  }

  void _scanLocation(String code) {
    TFeedback.selection();
    _set(_Target.location, code == _current.location ? _Check(ok: true, scanned: code) : _Check(scanned: code));
  }

  /// The item field takes a product barcode or a lot barcode. Scanning before the location is
  /// resolved asks for a location exception first.
  Future<void> _scanItem(String code) async {
    TFeedback.selection();
    if (!_loc.resolved && !await _showException(_Target.location)) return;
    if (!mounted) return;

    final scannedBatch = _batches.where((b) => b.batch == code).firstOrNull;
    if (code == _current.code) {
      _set(_Target.item, _Check(ok: true, scanned: code));
      if (!_lot.resolved) await _chooseBatch();
    } else if (scannedBatch != null) {
      if (!_item.resolved) _set(_Target.item, _Check(ok: true, scanned: _current.code));
      _set(_Target.lot, code == _current.batch ? _Check(ok: true, scanned: code) : _Check(scanned: code));
    } else {
      _set(_Target.item, _Check(scanned: code));
    }
  }

  Widget _pick() {
    final ready = _loc.resolved && _item.resolved && _lot.resolved;
    return _pickPage(
      footer: TActionBar(primaryText: 'Next', onPrimary: ready ? () {} : null, secondaryText: 'Cancel', onSecondary: _reset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _checkTile(
            target: _Target.location,
            check: _loc,
            icon: HugeIcons.strokeRoundedLocation01,
            title: _current.location,
            subtitle: 'Pick location',
          ),
          const SizedBox(height: 8),
          _checkTile(target: _Target.item, check: _item, icon: Icons.inventory_2_outlined, title: _current.code, subtitle: _current.name),
          const SizedBox(height: 8),
          _checkTile(
            target: _Target.lot,
            check: _lot,
            icon: HugeIcons.strokeRoundedPackage,
            title: _current.batch,
            subtitle: 'Mfg: ${_current.mfg} · Exp: ${_current.exp}',
            trailing: Text(
              'Qty: ${_current.qty}',
              style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.onSurface),
            ),
          ),
          const SizedBox(height: 16),
          TTextField.scan(
            label: 'Location',
            placeholder: 'Scan location',
            value: _loc.ok ? _current.location : null,
            autoFocus: !_loc.resolved,
            size: TInputSize.lg,
            onScan: _scanLocation,
            onCameraTap: () {},
          ),
          const SizedBox(height: 16),
          TTextField.scan(
            label: 'Item',
            placeholder: 'Scan item or batch barcode',
            value: _item.ok ? _current.code : null,
            autoFocus: _loc.resolved && !_item.resolved,
            size: TInputSize.lg,
            onScan: _scanItem,
            onCameraTap: () {},
          ),
          const SizedBox(height: 16),
          TNumberField<int>(
            variant: TNumberFieldVariant.quantity,
            label: 'Picked quantity',
            unit: 'units',
            value: _pickedQty,
            min: 0,
            max: _current.qty,
            disabled: !(_loc.resolved && _item.resolved),
            onValueChanged: (q) => setState(() => _pickedQty = q ?? 0),
          ),
        ],
      ),
    );
  }

  Widget _showButton(_Target t) =>
      TButton(type: TButtonType.text, text: 'Show', color: context.theme.warning, onTap: () => _showException(t));

  String _statusText(_Target t, _Check c) {
    final name = t.label.toLowerCase();
    if (c.mismatch) return 'Different $name scanned (${c.scanned}). Any exception?';
    final from = c.scanned == null ? 'Not scanned' : 'Scanned ${c.scanned}';
    final notes = c.notes.isEmpty ? '' : ' - ${c.notes}';
    return '$from · ${c.reason!.label}$notes';
  }

  /// Location / item / batch tile: neutral until scanned, success when it matches, warning when it differs.
  /// A different scan offers "Show" to choose an exception; the chosen reason is shown in the tile.
  Widget _checkTile({
    required _Target target,
    required _Check check,
    required dynamic icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final theme = context.theme;
    final tone = check.ok
        ? theme.success
        : (check.mismatch || check.reason != null)
        ? theme.warning
        : null;

    return TTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: tone,
      iconBackgroundColor: tone?.withValues(alpha: 0.15),
      trailing: trailing,
      descWidget: tone == null || check.ok
          ? null
          : Row(
              children: [
                Expanded(
                  child: Text(
                    _statusText(target, check),
                    style: TextStyle(color: tone, fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ),
                if (check.mismatch) _showButton(target),
              ],
            ),
    ).card(shadow: TCardShadow.sm, backgroundColor: tone?.withValues(alpha: 0.08), borderColor: tone);
  }

  // 11. Completed
  Widget _completed() {
    return TResult.warning(
      fullPage: true,
      docked: true,
      title: 'Picking Completed',
      subtitle: 'SO-10023 · 4 picked, 2 exceptions',
      primaryAction: TButton(
        size: TSize.xl.copyWith(minW: double.infinity),
        text: 'Next order',
        onTap: () {},
      ),
      secondaryAction: TButton(
        type: TButtonType.outline,
        size: TSize.xl.copyWith(minW: double.infinity),
        text: 'Back to orders',
        onTap: () {},
      ),
    );
  }
}

/// Bottom sheet: pick an exception reason (limited to what fits the target) and add notes.
class _ExceptionSheet extends StatefulWidget {
  final _Target target;
  final ValueChanged<_ExceptionResult> onSubmit;

  const _ExceptionSheet({required this.target, required this.onSubmit});

  @override
  State<_ExceptionSheet> createState() => _ExceptionSheetState();
}

class _ExceptionSheetState extends State<_ExceptionSheet> {
  final _notes = TextEditingController();
  _ExceptionReason? _reason;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TRadioGroup<_ExceptionReason>(
            tile: true,
            value: _reason,
            onValueChanged: (r) => setState(() => _reason = r),
            items: [for (final r in widget.target.reasons) TRadioGroupItem(value: r, label: r.label)],
          ),
          const SizedBox(height: 16),
          TTextField(label: 'Notes (optional)', placeholder: 'e.g. Found in A1-B2 due to re-arrangement', rows: 3, textController: _notes),
          const SizedBox(height: 16),
          TActionBar(
            primaryText: 'Confirm exception',
            primaryColor: context.theme.warning,
            onPrimary: _reason == null ? null : () => widget.onSubmit(_ExceptionResult(_reason!, _notes.text.trim())),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet: batches available at the location; the picker confirms the one actually picked.
class _BatchSheet extends StatefulWidget {
  final List<_Batch> batches;
  final ValueChanged<_Batch> onConfirm;

  const _BatchSheet({required this.batches, required this.onConfirm});

  @override
  State<_BatchSheet> createState() => _BatchSheetState();
}

class _BatchSheetState extends State<_BatchSheet> {
  _Batch? _selected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final b in widget.batches) ...[
            TOptionTile(
              label: b.batch,
              description: 'Mfg ${b.mfg} · Exp ${b.exp} · ${b.available} available',
              leading: HugeIcons.strokeRoundedPackage,
              selected: _selected == b,
              onTap: () => setState(() => _selected = b),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          TActionBar(primaryText: 'Confirm batch', onPrimary: _selected == null ? null : () => widget.onConfirm(_selected!)),
        ],
      ),
    );
  }
}
