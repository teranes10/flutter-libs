import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class SpeedDialPage extends StatefulWidget {
  const SpeedDialPage({super.key});

  @override
  State<SpeedDialPage> createState() => _SpeedDialPageState();
}

class _SpeedDialPageState extends State<SpeedDialPage> {
  String _lastTriggeredAction = 'No action triggered yet';

  void _triggerAction(String action) {
    setState(() {
      _lastTriggeredAction = 'Triggered "$action" at ${DateTime.now().toIso8601String().substring(11, 19)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'TSpeedDial Showcase',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Multi-action expandable floating action button menu with animated icon rotation, '
            'staggered scale transitions, action labels, and modal backdrop dismissal.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Status Feedback Card
          TCard(
            title: 'Action Trigger Feedback',
            child: Row(
              children: [
                Icon(Icons.touch_app_rounded, color: colors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _lastTriggeredAction,
                    style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Interactive Simulation Container
          TCard(
            title: 'Interactive Speed Dial Canvas (Bottom-Right FAB)',
            child: Container(
              height: 440,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.dashboard_customize_outlined, size: 48, color: theme.disabledColor),
                        const SizedBox(height: 12),
                        Text(
                          'Click the "+" button in the bottom right corner',
                          style: TextStyle(fontSize: 14, color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),

                  // Floating Speed Dial in the bottom-right corner
                  Positioned(
                    right: 24,
                    bottom: 24,
                    child: TSpeedDial(
                      tooltip: 'Quick Actions',
                      children: [
                        TSpeedDialChild(
                          icon: Icons.person_add_rounded,
                          label: 'Add New Member',
                          onTap: () => _triggerAction('Add New Member'),
                        ),
                        TSpeedDialChild(
                          icon: Icons.upload_file_rounded,
                          label: 'Import CSV Records',
                          onTap: () => _triggerAction('Import CSV Records'),
                        ),
                        TSpeedDialChild(
                          icon: Icons.picture_as_pdf_rounded,
                          label: 'Export Analytics PDF',
                          onTap: () => _triggerAction('Export Analytics PDF'),
                        ),
                        TSpeedDialChild(
                          icon: Icons.notifications_active_rounded,
                          label: 'Broadcast Notification',
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          onTap: () => _triggerAction('Broadcast Notification'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
