import 'package:flutter/material.dart';
import 'package:te_scanner/te_scanner.dart';
import 'package:te_widgets/te_widgets.dart';

/// Sample for [TScanView]: an inline camera scanner with a scan history and a manual-entry fallback.
class ScanViewPage extends StatefulWidget {
  const ScanViewPage({super.key});

  @override
  State<ScanViewPage> createState() => _ScanViewPageState();
}

class _ScanViewPageState extends State<ScanViewPage> {
  final List<String> _scans = [];
  bool _paused = false;

  void _add(String value) {
    setState(() => _scans.insert(0, value));
    TToastService.success(context, 'Scanned: $value');
  }

  Future<void> _manualEntry() async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manual entry'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Barcode'),
        ),
        actions: [
          TButton(text: 'Cancel', type: TButtonType.softText, onTap: () => Navigator.pop(ctx)),
          TButton(text: 'Add', onTap: () => Navigator.pop(ctx, controller.text.trim())),
        ],
      ),
    );
    controller.dispose();
    if (value != null && value.isNotEmpty) _add(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 300,
                child: TScanView(paused: _paused, onScan: (value, _) => _add(value), onManualEntry: _manualEntry),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TButton(
                    text: _paused ? 'Resume' : 'Pause',
                    type: TButtonType.softText,
                    icon: _paused ? HugeIcons.strokeRoundedPlay : HugeIcons.strokeRoundedPause,
                    onTap: () => setState(() => _paused = !_paused),
                  ),
                  const Spacer(),
                  if (_scans.isNotEmpty) TButton(text: 'Clear', type: TButtonType.softText, onTap: () => setState(_scans.clear)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Scans (${_scans.length})',
                style: TextStyle(fontWeight: FontWeight.w700, color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              if (_scans.isEmpty)
                Text('Point the camera at a barcode.', style: TextStyle(color: colors.onSurfaceVariant))
              else
                for (final s in _scans)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(s, style: TextStyle(color: colors.onSurface)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
