import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/alert/alert_service.dart';
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
  void _showServiceAlert() {
    TAlertService.confirmDelete(context, () => {});
  }

  void _showServiceModal() {
    TModalService.show(
      context,
      (context) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('This modal was opened using TModalService!'),
              SizedBox(height: 20),
              Text('Click outside or the X button to close.'),
            ],
          ),
        );
      },
      config: const TModalConfig(
        title: 'Add New Product',
        width: 600,
        persistent: false,
      ),
      onClose: () {
        print('Service modal closed');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _showServiceModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Show Modal '),
              ),
              ElevatedButton(
                onPressed: _showServiceAlert,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Show Alert '),
              ),
              Wrap(
                spacing: 32,
                runSpacing: 32,
                alignment: WrapAlignment.center,
                children: [
                  // Basic tooltip
                  TTooltip(
                    message: 'Compact tooltip near the hovering point',
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Hover Me'),
                    ),
                  ),

                  // Success variant
                  TTooltip(
                    message: 'Operation completed successfully!',
                    color: AppColors.success,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
                    ),
                  ),

                  // Warning variant
                  TTooltip(
                    message: 'Please review your input before proceeding',
                    color: AppColors.warning,
                    size: TTooltipSize.large,
                    position: TTooltipPosition.left,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.warning, color: Colors.orange, size: 24),
                    ),
                  ),

                  // Error variant with tap trigger
                  TTooltip(
                    message: 'An error occurred while processing your request',
                    color: AppColors.danger,
                    triggerMode: TTooltipTriggerMode.tap,
                    position: TTooltipPosition.right,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.error, color: Colors.red, size: 24),
                    ),
                  ),

                  // Info variant with custom icon
                  TTooltip(
                    message: 'This feature provides detailed analytics and insights',
                    color: AppColors.info,
                    icon: Icons.analytics,
                    maxWidth: 300,
                    position: TTooltipPosition.right,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.analytics, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Analytics', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                  ),

                  // Rich content tooltip
                  TTooltip(
                    message: '',
                    richMessage: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rich Content Tooltip',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This tooltip contains multiple lines and rich formatting with custom styling.',
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Interactive',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    color: AppColors.secondary,
                    position: TTooltipPosition.right,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Rich Content'),
                    ),
                  ),

                  // Small size tooltip
                  TTooltip(
                    message: 'Compact tooltip near the hovering point',
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Stateful Modal
      ],
    );
  }
}
