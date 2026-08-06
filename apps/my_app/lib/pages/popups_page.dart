import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class PopupsPage extends StatefulWidget {
  const PopupsPage({super.key});

  @override
  State<PopupsPage> createState() => _PopupsPageState();
}

class _PopupsPageState extends State<PopupsPage> {
  void _showModal({required String title, double width = 600, bool persistent = false}) {
    TModalService.show(
      context,
      title: title,
      width: width,
      persistent: persistent,
      (ctx) =>
          Padding(padding: const EdgeInsets.all(20), child: Text('This is a ${persistent ? "persistent" : "standard"} "$title" modal')),
    );
  }

  void _showSnackBar(String message) {
    TSnackbarService.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Alerts =====
          const Text('📢 Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 16,
            children: [
              TButton(
                color: context.theme.warning,
                text: 'Archive (Confirm)',
                onPressed: (_) => TAlertService.confirmArchive(context, () {}),
              ),
              TButton(color: context.theme.info, text: 'Restore (Confirm)', onPressed: (_) => TAlertService.confirmRestore(context, () {})),
              TButton(color: context.theme.danger, text: 'Delete (Confirm)', onPressed: (_) => TAlertService.confirmDelete(context, () {})),
              TButton(
                color: context.theme.info,
                text: 'Info Alert',
                onPressed: (_) => TAlertService.info(context, 'Info', 'Just an informational alert'),
              ),
              TButton(
                color: context.theme.success,
                text: 'Success Alert',
                onPressed: (_) => TAlertService.success(context, 'Success', 'Operation was successful'),
              ),
              TButton(
                color: context.theme.warning,
                text: 'Warning Alert',
                onPressed: (_) => TAlertService.warning(
                  context,
                  'Unsaved Changes',
                  'You have unsaved changes. If you leave now, your edits will be lost.',
                ),
              ),
              TButton(
                color: context.theme.danger,
                text: 'Error Alert',
                onPressed: (_) =>
                    TAlertService.error(context, 'Failed to Save', 'Something went wrong while saving your data. Please try again.'),
              ),
              TButton(
                color: context.theme.info,
                text: 'Progress Alert',
                onPressed: (_) async {
                  final stream = Stream.periodic(const Duration(seconds: 1), (i) => 'Processing item ${i + 1} of 3...').take(3);
                  final controller = TAlertService.progress(context, 'In Progress', 'Starting...', progressStream: stream);

                  // Simulate work finishing and closing the dialog
                  await Future.delayed(const Duration(seconds: 4));
                  controller.close();
                },
              ),
              TButton(
                color: context.theme.info,
                text: 'Prompt Alert',
                onPressed: (_) => TAlertService.prompt(
                  context,
                  title: 'Enter Name',
                  placeholder: 'What is your name?',
                  onConfirm: (name) => TToastService.success(context, 'Hello, $name!'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ===== Toasts =====
          const Text('📢 Toasts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 16,
            children: [
              TButton(
                color: context.theme.info,
                text: 'Info Toast',
                onPressed: (_) => TToastService.info(context, 'Just an informational alert', 'Info'),
              ),
              TButton(
                color: context.theme.info,
                text: 'Info Toast without Title',
                onPressed: (_) => TToastService.info(context, 'Just an informational alert'),
              ),
              TButton(
                color: context.theme.success,
                text: 'Success Toast',
                onPressed: (_) => TToastService.success(context, 'Operation was successful', 'Success'),
              ),
              TButton(
                color: context.theme.warning,
                text: 'Warning Toast',
                onPressed: (_) => TToastService.warning(
                  context,
                  'You have unsaved changes. If you leave now, your edits will be lost.',
                  'Unsaved Changes',
                ),
              ),
              TButton(
                color: context.theme.danger,
                text: 'Error Toast',
                onPressed: (_) =>
                    TToastService.error(context, 'Something went wrong while saving your data. Please try again.', 'Failed to Save'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ===== Snackbars =====
          const Text('🍿 Snackbars', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              TButton(
                color: context.theme.info,
                text: 'Info SnackBar (Action)',
                onPressed: (_) => TSnackbarService.info(
                  context,
                  'Your package is on the way.',
                  title: 'Info',
                  actionText: 'Track',
                  onTap: () => _showSnackBar('Tracking package...'),
                ),
              ),
              TButton(
                color: context.theme.success,
                text: 'Success SnackBar',
                onPressed: (_) => TSnackbarService.success(context, 'Project updated successfully.', title: 'Success'),
              ),
              TButton(
                color: context.theme.warning,
                text: 'Warning SnackBar (Action)',
                onPressed: (_) => TSnackbarService.warning(
                  context,
                  'Storage space is almost full.',
                  title: 'Storage Warning',
                  actionText: 'Manage',
                  onTap: () => _showSnackBar('Opening storage manager...'),
                ),
              ),
              TButton(
                color: context.theme.danger,
                text: 'Error SnackBar',
                onPressed: (_) =>
                    TSnackbarService.error(context, 'An error occurred while uploading. Please try again.', title: 'Upload Failed'),
              ),
              TButton(
                color: context.theme.primary,
                text: 'Custom Purple SnackBar',
                onPressed: (_) => TSnackbarService.show(
                  context,
                  'This is a fully customized purple snackbar.',
                  title: 'Custom Styles',
                  icon: Icons.star_purple500_rounded,
                  color: Colors.purple,
                  actionText: 'Perfect',
                  onTap: () => _showSnackBar('Custom snackbar action pressed!'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ===== Modals =====
          const Text('🗔 Modals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 16,
            children: [
              TButton(
                text: 'Standard Modal',
                onPressed: (_) => _showModal(title: 'Standard Modal'),
              ),
              TButton(
                text: 'Wide Modal (800px)',
                onPressed: (_) => _showModal(title: 'Wide Modal', width: 800),
              ),
              TButton(
                text: 'Persistent Modal',
                onPressed: (_) => _showModal(title: 'Persistent Modal', persistent: true),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ===== Sheets =====
          const Text('📑 Sheets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              TButton(
                text: 'Bottom Sheet (Sliding)',
                onPressed: (_) => TSheetService.showBottomSheet(
                  context,
                  title: 'Bottom Sheet',
                  showCloseButton: true,
                  (ctx) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('This is a bottom sheet with sliding animation.'),
                        const SizedBox(height: 20),
                        TButton(text: 'Close', onPressed: (_) => ctx.close()),
                      ],
                    ),
                  ),
                ),
              ),
              TButton(
                text: 'Bottom Sheet (Drawing)',
                onPressed: (_) => TSheetService.showBottomSheet(
                  context,
                  title: 'Bottom Sheet',
                  showCloseButton: true,
                  animationType: TSheetAnimationType.drawing,
                  (ctx) => Padding(padding: const EdgeInsets.all(20), child: const Text('This is a bottom sheet with drawing animation.')),
                ),
              ),
              TButton(
                text: 'Side Sheet (Right)',
                onPressed: (_) => TSheetService.showSideSheet(
                  context,
                  title: 'Side Sheet',
                  showCloseButton: true,
                  (ctx) => Padding(padding: const EdgeInsets.all(20), child: const Text('This is a side sheet from the right.')),
                ),
              ),
              TButton(
                text: 'Side Sheet (Left, Drawing)',
                onPressed: (_) => TSheetService.showSideSheet(
                  context,
                  title: 'Side Sheet',
                  showCloseButton: true,
                  fromLeft: true,
                  animationType: TSheetAnimationType.drawing,
                  (ctx) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: const Text('This is a side sheet from the left with drawing animation.'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ===== Divider =====
          const Text('➖ Dividers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const TDivider(),
          const Text('Custom color and thickness:'),
          TDivider(color: context.theme.primary, thickness: 2, space: 40),
          const Text('Indented divider:'),
          const TDivider(indent: 50, endIndent: 50),
          const SizedBox(height: 12),
          const Text('Vertical Divider (inside a Row):'),
          const SizedBox(height: 8),
          Container(
            height: 50,
            decoration: BoxDecoration(border: Border.all(color: context.colors.outlineVariant)),
            child: Row(
              children: [
                Expanded(child: Center(child: Text('Left'))),
                TDivider.vertical(),
                Expanded(child: Center(child: Text('Right'))),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ===== Tooltip Showcase =====
          const Text('💡 Tooltips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('— Position & Formatting'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.start,
            children: [
              TTooltip(
                message: 'Default tooltip',
                child: ElevatedButton(onPressed: () {}, child: const Text('Hover')),
              ),
              TTooltip(message: 'Top tooltip', position: TTooltipPosition.top, child: Icon(Icons.arrow_upward, size: 32)),
              TTooltip(message: 'Bottom tooltip', position: TTooltipPosition.bottom, child: Icon(Icons.arrow_downward, size: 32)),
              TTooltip(message: 'Left tooltip', position: TTooltipPosition.left, child: Icon(Icons.arrow_back, size: 32)),
              TTooltip(message: 'Right tooltip', position: TTooltipPosition.right, child: Icon(Icons.arrow_forward, size: 32)),
            ],
          ),
          const SizedBox(height: 16),

          const Text('— Variants: Success, Warning, Error, Info'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.start,
            children: [
              TTooltip(
                message: 'Operation successful',
                color: context.theme.success,
                child: Icon(Icons.check_circle, color: Colors.green, size: 32),
              ),
              TTooltip(
                message: 'Check this warning',
                color: context.theme.warning,
                size: TTooltipSize.large,
                position: TTooltipPosition.left,
                child: Icon(Icons.warning, color: Colors.orange, size: 32),
              ),
              TTooltip(
                message: 'Error occurred',
                color: context.theme.danger,
                position: TTooltipPosition.right,
                child: Icon(Icons.error, color: Colors.red, size: 32),
              ),
              TTooltip(
                message: 'See more info',
                color: context.theme.info,
                icon: Icons.info_outline,
                position: TTooltipPosition.right,
                child: Icon(Icons.info, color: Colors.blue, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text('— Rich Content & Custom'),

          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              TTooltip(
                message: '',
                richMessage: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rich Tooltip', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('This tooltip includes multiple lines and a button.'),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _showSnackBar('Rich tooltip action'),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Action'),
                    ),
                  ],
                ),
                color: context.theme.secondary,
                position: TTooltipPosition.right,
                child: OutlinedButton.icon(
                  onPressed: () => _showSnackBar('Rich Content pressed'),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Rich Content'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text('— Delay & Padding Example'),
          TTooltip(
            message: 'Tooltip with 500ms delay & padding',
            showDelay: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(12),
            position: TTooltipPosition.top,
            child: const Icon(Icons.hourglass_empty, size: 32),
          ),

          const SizedBox(height: 32),
          const Text('— Date time text with tooltip'),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TDateTimeText(dateTime: DateTime.now().subtract(Duration(seconds: 5))),
              TDateTimeText(dateTime: DateTime.now().subtract(Duration(minutes: 5))),
              TDateTimeText(dateTime: DateTime.now().subtract(Duration(hours: 5))),
              TDateTimeText(dateTime: DateTime.now().subtract(Duration(days: 5))),
              TDateTimeText(dateTime: DateTime.now().subtract(Duration(days: 7))),
            ],
          ),
          const SizedBox(height: 32),

          // ===== Barcodes =====
          const Text('🔍 Barcode Scanner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            children: [
              TBarcodeScanner(
                title: 'Auto-close Scanner',
                onScanned: (BarcodeCapture capture) {
                  final barcode = capture.barcodes.firstOrNull?.rawValue;
                  if (barcode != null) {
                    TToastService.success(context, 'Scanned: $barcode');
                  }
                },
                child: const TButton(text: 'Scan (Auto-close)'),
              ),
              TBarcodeScanner(
                title: 'One-by-one Scanner',
                mode: TBarcodeScannerMode.stayOpen,
                onScanned: (BarcodeCapture capture) {
                  final barcode = capture.barcodes.firstOrNull?.rawValue;
                  if (barcode != null) {
                    TToastService.info(context, 'Scanned: $barcode');
                  }
                },
                child: const TButton(text: 'Scan (One-by-one)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
