import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TourPage extends StatefulWidget {
  const TourPage({super.key});

  @override
  State<TourPage> createState() => _TourPageState();
}

class _TourPageState extends State<TourPage> {
  final TTourController _tourController = TTourController();

  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _metricKey = GlobalKey();
  final GlobalKey _actionKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  String _tourStatus = 'Tour is idle. Click "Start Tour" to begin.';

  @override
  void dispose() {
    _tourController.dispose();
    super.dispose();
  }

  void _startTour() {
    _tourController.start([
      TTourStep(
        targetKey: _searchKey,
        title: 'Global Search',
        description: 'Press ⌘K or click here to instantly jump to any customer, order, or setting across the console.',
        icon: HugeIcons.strokeRoundedSearch01,
      ),
      TTourStep(
        targetKey: _metricKey,
        title: 'Live Telemetry & KPIs',
        description: 'Monitor real-time cluster health, transaction throughput, and resource utilization at a glance.',
        icon: HugeIcons.strokeRoundedDashboardSpeed01,
      ),
      TTourStep(
        targetKey: _actionKey,
        title: 'Primary Action Hub',
        description: 'Deploy new microservices, create API keys, or trigger canary rollouts with one click.',
        icon: HugeIcons.strokeRoundedAddCircle,
      ),
      TTourStep(
        targetKey: _profileKey,
        title: 'Account & Security Settings',
        description: 'Manage MFA enforcement, rotate API tokens, and switch between developer workspaces here.',
        icon: HugeIcons.strokeRoundedShield01,
      ),
    ]);

    setState(() {
      _tourStatus = 'Tour in progress...';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TTour(
      controller: _tourController,
      onFinish: () => setState(() => _tourStatus = 'Tour successfully completed! You are ready to explore.'),
      onSkip: () => setState(() => _tourStatus = 'Tour was dismissed. You can restart anytime.'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('TTour Showcase', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Interactive guided tour and spotlight onboarding guide. Automatically highlights screen elements '
              'with animated cutout masks and anchored instructional cards to guide operators through complex workflows.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // Controls Card
            TCard(
              title: 'Onboarding Controller',
              child: Row(
                children: [
                  TButton(
                    text: 'Start Feature Tour',
                    icon: HugeIcons.strokeRoundedPlay,
                    type: TButtonType.solid,
                    color: colors.primary,
                    size: TSize.md,
                    onTap: _startTour,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_tourStatus, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mock Interactive Dashboard Canvas
            TCard(
              title: 'Sample Workspace Dashboard',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mock Top Navbar
                  Row(
                    children: [
                      // Target 1: Search Field
                      Expanded(
                        child: Container(
                          key: _searchKey,
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              TIcon.raw(HugeIcons.strokeRoundedSearch01, size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              const Text('Search resources, logs, and users (⌘K)...', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Target 3: Action Button
                      TButton(
                        key: _actionKey,
                        text: 'Deploy Microservice',
                        icon: HugeIcons.strokeRoundedRocket,
                        type: TButtonType.solid,
                        size: TSize.sm,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),

                      // Target 4: Profile / Settings Icon
                      Container(
                        key: _profileKey,
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                        child: TIcon.raw(HugeIcons.strokeRoundedUser, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Target 2: KPI Metrics Cards
                  Container(
                    key: _metricKey,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricCol('Active Pods', '48 / 50', HugeIcons.strokeRoundedCloudCheck, Colors.green),
                        Container(width: 1, height: 40, color: theme.dividerColor),
                        _buildMetricCol('Throughput', '14.2k req/s', HugeIcons.strokeRoundedDashboardSpeed01, Colors.blue),
                        Container(width: 1, height: 40, color: theme.dividerColor),
                        _buildMetricCol('Error Rate', '0.01%', HugeIcons.strokeRoundedCheckmarkCircle01, Colors.teal),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Data Placeholder Card
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: const Center(
                      child: Text(
                        'Click "Start Feature Tour" above to experience the guided walkthrough.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, dynamic icon, Color color) {
    return Row(
      children: [
        TIcon.raw(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
