import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/alert/alert_service.dart';
import 'package:te_widgets/widgets/button/button.dart';
import 'package:te_widgets/widgets/modal/modal_config.dart';
import 'package:te_widgets/widgets/modal/modal_service.dart';
import 'package:te_widgets/widgets/tooltip/tooltip.dart';
import 'package:te_widgets/widgets/tooltip/tooltip_config.dart';

class PopupsPage extends StatefulWidget {
  const PopupsPage({super.key});

  @override
  State<PopupsPage> createState() => _PopupsPageState();
}

class _PopupsPageState extends State<PopupsPage> {
  void _showModal({required String title, double width = 600, bool persistent = false}) {
    TModalService.show(
      context,
      (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text('This is a ${persistent ? "persistent" : "standard"} "$title" modal'),
      ),
      config: TModalConfig(
        title: title,
        width: width,
        persistent: persistent,
      ),
      onClose: () => debugPrint('Modal "$title" closed'),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Alerts =====
          const Text('📢 Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(spacing: 16, children: [
            TButton(color: AppColors.warning, text: 'Archive (Confirm)', onPressed: (_) => TAlertService.confirmArchive(context, () {})),
            TButton(color: AppColors.info, text: 'Restore (Confirm)', onPressed: (_) => TAlertService.confirmRestore(context, () {})),
            TButton(color: AppColors.danger, text: 'Delete (Confirm)', onPressed: (_) => TAlertService.confirmDelete(context, () {})),
            TButton(
              color: AppColors.info,
              text: 'Info Alert',
              onPressed: (_) => TAlertService.info(context, 'Info', 'Just an informational alert'),
            ),
            TButton(
              color: AppColors.success,
              text: 'Success Alert',
              onPressed: (_) => TAlertService.success(context, 'Success', 'Operation was successful'),
            ),
            TButton(
              color: AppColors.warning,
              text: 'Warning Alert',
              onPressed: (_) =>
                  TAlertService.warning(context, 'Unsaved Changes', 'You have unsaved changes. If you leave now, your edits will be lost.'),
            ),
            TButton(
              color: AppColors.danger,
              text: 'Error Alert',
              onPressed: (_) => TAlertService.error(context, 'Failed to Save', 'Something went wrong while saving your data. Please try again.'),
            ),
          ]),
          const SizedBox(height: 32),

          // ===== Modals =====
          const Text('🗔 Modals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(spacing: 16, children: [
            TButton(text: 'Standard Modal', onPressed: (_) => _showModal(title: 'Standard Modal')),
            TButton(text: 'Wide Modal (800px)', onPressed: (_) => _showModal(title: 'Wide Modal', width: 800)),
            TButton(text: 'Persistent Modal', onPressed: (_) => _showModal(title: 'Persistent Modal', persistent: true)),
          ]),
          const SizedBox(height: 32),

          // ===== Tooltip Showcase =====
          const Text('💡 Tooltips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('— Position & Formatting'),
          const SizedBox(height: 16),
          Wrap(spacing: 24, runSpacing: 24, alignment: WrapAlignment.start, children: [
            TTooltip(
              message: 'Default tooltip',
              child: ElevatedButton(onPressed: () {}, child: const Text('Hover')),
            ),
            TTooltip(
              message: 'Top tooltip',
              position: TTooltipPosition.top,
              child: Icon(Icons.arrow_upward, size: 32),
            ),
            TTooltip(
              message: 'Bottom tooltip',
              position: TTooltipPosition.bottom,
              child: Icon(Icons.arrow_downward, size: 32),
            ),
            TTooltip(
              message: 'Left tooltip',
              position: TTooltipPosition.left,
              child: Icon(Icons.arrow_back, size: 32),
            ),
            TTooltip(
              message: 'Right tooltip',
              position: TTooltipPosition.right,
              child: Icon(Icons.arrow_forward, size: 32),
            ),
          ]),
          const SizedBox(height: 16),

          const Text('— Variants: Success, Warning, Error, Info'),
          const SizedBox(height: 16),
          Wrap(spacing: 24, runSpacing: 24, alignment: WrapAlignment.start, children: [
            TTooltip(
              message: 'Operation successful',
              color: AppColors.success,
              child: Icon(Icons.check_circle, color: Colors.green, size: 32),
            ),
            TTooltip(
              message: 'Check this warning',
              color: AppColors.warning,
              size: TTooltipSize.large,
              position: TTooltipPosition.left,
              child: Icon(Icons.warning, color: Colors.orange, size: 32),
            ),
            TTooltip(
              message: 'Error occurred',
              color: AppColors.danger,
              position: TTooltipPosition.right,
              child: Icon(Icons.error, color: Colors.red, size: 32),
            ),
            TTooltip(
              message: 'See more info',
              color: AppColors.info,
              icon: Icons.info_outline,
              position: TTooltipPosition.right,
              child: Icon(Icons.info, color: Colors.blue, size: 32),
            ),
          ]),
          const SizedBox(height: 16),

          const Text('— Rich Content & Custom'),

          const SizedBox(height: 16),
          Wrap(spacing: 24, runSpacing: 24, children: [
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
              color: AppColors.secondary,
              position: TTooltipPosition.right,
              child: OutlinedButton.icon(
                onPressed: () => _showSnackBar('Rich Content pressed'),
                icon: const Icon(Icons.info_outline),
                label: const Text('Rich Content'),
              ),
            ),
          ]),
          const SizedBox(height: 16),

          const Text('— Delay & Padding Example'),
          TTooltip(
            message: 'Tooltip with 500ms delay & padding',
            showDelay: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(20),
            position: TTooltipPosition.top,
            child: const Icon(Icons.hourglass_empty, size: 32),
          ),
        ],
      ),
    );
  }
}
