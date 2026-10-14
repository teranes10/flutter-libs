import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation and showcase page for the [TBanner] widget.
class BannersPage extends StatefulWidget {
  const BannersPage({super.key});

  @override
  State<BannersPage> createState() => _BannersPageState();
}

enum _OfflineDemoState {
  offline,
  syncing,
  pendingChanges,
  error,
  fullySynced,
}

class _BannersPageState extends State<BannersPage> {
  bool _showDismissibleBanner = true;
  _OfflineDemoState _offlineState = _OfflineDemoState.offline;
  bool _stickyOffline = false;
  String _lastActionStatus = 'No action triggered yet';

  void _setAction(String msg) {
    setState(() => _lastActionStatus = msg);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Alert Banners & Callouts',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'In-page contextual notices, callouts, and connectivity banners with semantic themes, custom icon sizing, aligned geometry, and offline sync support.',
            style: TextStyle(
              fontSize: 16,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Feedback Banner
          TBanner.info(
            variant: TVariant.tonal,
            title: 'Action Triggered',
            message: _lastActionStatus,
          ),
          const SizedBox(height: 24),

          // 1. Semantic Intent Types
          WidgetDocCard(
            title: 'Semantic Types (Info, Success, Warning, Error, Neutral)',
            description: 'Standardized intent callouts with auto-resolved theme colors and indicator icons',
            icon: Icons.campaign_rounded,
            preview: Column(
              children: [
                const TBanner.info(
                  title: 'System Information',
                  message: 'Scheduled maintenance is planned for Sunday at 02:00 UTC.',
                ),
                const TBanner.success(
                  title: 'Payment Processed',
                  message: 'Invoice #1042 was successfully paid via Stripe Checkout.',
                ),
                const TBanner.warning(
                  title: 'High API Latency',
                  message: 'European edge regions are currently experiencing elevated latency.',
                ),
                const TBanner.error(
                  title: 'Sync Failed',
                  message: 'Could not sync inventory items with Shopify. Please re-authenticate.',
                ),
                const TBanner.neutral(
                  title: 'Tip of the Day',
                  message: 'Use keyboard shortcut Cmd+K to quickly search and jump between pages.',
                ),
              ],
            ),
            code: '''TBanner.info(
  title: 'System Information',
  message: 'Scheduled maintenance is planned for Sunday.',
)

TBanner.success(
  title: 'Payment Processed',
  message: 'Invoice #1042 was successfully paid.',
)

TBanner.warning(
  title: 'High Latency',
  message: 'Edge regions are experiencing elevated latency.',
)

TBanner.error(
  title: 'Sync Failed',
  message: 'Could not sync inventory items with Shopify.',
)''',
          ),
          const SizedBox(height: 24),

          // 2. Visual Variants (TVariant)
          WidgetDocCard(
            title: 'Visual Variants (tonal, softOutline, outline, solid)',
            description: 'Consistent with TVariant token system across buttons and chips',
            icon: Icons.palette_outlined,
            preview: Column(
              children: [
                const TBanner.info(
                  variant: TVariant.tonal,
                  title: 'Tonal Variant (Default)',
                  message: 'Subtle container fill with color-matched accent border.',
                ),
                const TBanner.info(
                  variant: TVariant.softOutline,
                  title: 'Soft Outline Variant',
                  message: 'Translucent background with crisp tinted border.',
                ),
                const TBanner.info(
                  variant: TVariant.outline,
                  title: 'Outline Variant',
                  message: 'Transparent background with border outline.',
                ),
                const TBanner.info(
                  variant: TVariant.solid,
                  title: 'Solid Prominent Variant',
                  message: 'High-contrast solid colored background for critical alerts.',
                ),
              ],
            ),
            code: '''TBanner.info(variant: TVariant.tonal, message: 'Tonal variant')
TBanner.info(variant: TVariant.softOutline, message: 'Soft outline variant')
TBanner.info(variant: TVariant.outline, message: 'Outline variant')
TBanner.info(variant: TVariant.solid, message: 'Solid variant')''',
          ),
          const SizedBox(height: 24),

          // 3. Actions & Dismissible
          WidgetDocCard(
            title: 'Action Button & Dismiss Action',
            description: 'Interactive callouts featuring primary buttons and onDismiss callbacks aligned with text',
            icon: Icons.touch_app_rounded,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showDismissibleBanner)
                  TBanner.warning(
                    title: 'Database Backup Pending',
                    message: 'Your automated daily snapshot has not run in the last 48 hours.',
                    action: TButton(
                      text: 'Trigger Backup',
                      type: TButtonType.solid,
                      color: Colors.amber.shade800,
                      size: TButtonSize.xs,
                      onTap: () => _setAction('Clicked: Trigger Backup'),
                    ),
                    onDismiss: () {
                      setState(() => _showDismissibleBanner = false);
                      _setAction('Dismissed Database Backup banner');
                    },
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TButton(
                      text: 'Restore Dismissed Banner',
                      type: TButtonType.tonal,
                      size: TButtonSize.xs,
                      icon: Icons.replay_rounded,
                      onTap: () {
                        setState(() => _showDismissibleBanner = true);
                        _setAction('Restored Dismissed Banner');
                      },
                    ),
                  ),
                TBanner.error(
                  title: 'Webhook Signature Mismatch',
                  message: 'Events from endpoint /api/webhooks/github could not be validated.',
                  action: TButton(
                    text: 'View Logs',
                    icon: Icons.receipt_long_rounded,
                    type: TButtonType.tonal,
                    size: TButtonSize.xs,
                    onTap: () => _setAction('Clicked: View Webhook Logs'),
                  ),
                ),
              ],
            ),
            code: '''TBanner.warning(
  title: 'Database Backup Pending',
  message: 'Your automated daily snapshot has not run.',
  action: TButton(
    text: 'Trigger Backup',
    type: TButtonType.solid,
    size: TButtonSize.xs,
    onTap: () => triggerBackup(),
  ),
  onDismiss: () => dismissNotice(),
)''',
          ),
          const SizedBox(height: 24),

          // 4. Offline Connectivity Banner (TBanner.offline)
          WidgetDocCard(
            title: 'Offline & Sync Status Banner (TBanner.offline)',
            description: 'Connectivity notice designed for offline-first field apps. Automatically handles offline, syncing, changes pending, error states with Retry, and disappears when fully synced.',
            icon: Icons.wifi_off_rounded,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Simulated State Switcher
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildOfflineChip(_OfflineDemoState.offline, 'Offline Notice', Icons.cloud_off_rounded),
                    _buildOfflineChip(_OfflineDemoState.syncing, 'Actively Syncing', Icons.sync_rounded),
                    _buildOfflineChip(_OfflineDemoState.pendingChanges, 'Pending Sync', Icons.cloud_upload_outlined),
                    _buildOfflineChip(_OfflineDemoState.error, 'Sync Error', Icons.error_outline_rounded),
                    _buildOfflineChip(_OfflineDemoState.fullySynced, 'Fully Synced (Hidden)', Icons.check_circle_outline_rounded),
                  ],
                ),
                const SizedBox(height: 14),

                // Sticky Toggle Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TSwitch(
                      value: _stickyOffline,
                      onValueChanged: (v) => setState(() => _stickyOffline = v ?? false),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'sticky: $_stickyOffline (flush edge-to-edge docking)',
                      style: TextStyle(fontSize: 13, color: colors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Live Preview Container
                Container(
                  padding: _stickyOffline ? EdgeInsets.zero : const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildActiveOfflineBanner(),
                      if (_offlineState == _OfflineDemoState.fullySynced)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 18, color: colors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'TBanner.offline returns SizedBox.shrink() when fully synced.',
                                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            code: '''// 1. Offline Notice (shows pending count & last sync time)
TBanner.offline(
  online: false,
  pendingCount: 14,
  lastSync: DateTime.now().subtract(const Duration(minutes: 24)),
  onViewPending: () => viewPendingList(),
  sticky: false,
)

// 2. Actively Syncing (animated progress indicator)
TBanner.offline(
  online: true,
  syncing: true,
  pendingCount: 6,
)

// 3. Sync Failed (presents Retry action)
TBanner.offline(
  online: true,
  error: 'Connection timed out to warehouse API',
  onRetry: () => retrySync(),
)

// 4. Fully Synced (disappears automatically)
TBanner.offline(
  online: true,
  syncing: false,
  pendingCount: 0,
) // Returns SizedBox.shrink()''',
          ),
          const SizedBox(height: 24),

          // 5. Icon Sizing & Precise Vertical Alignment
          WidgetDocCard(
            title: 'Icon Sizing & Vertical Centering Alignment',
            description: 'Custom iconSize property with pixel-perfect vertical centering aligned to the first line of text',
            icon: Icons.format_size_rounded,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TBanner.info(
                  iconSize: 16.0,
                  title: 'Compact 16dp Icon (iconSize: 16.0)',
                  message: 'The leading icon size is adjusted down to 16dp and stays vertically centered with the title line.',
                ),
                const TBanner.success(
                  iconSize: 20.0,
                  title: 'Default 20dp Icon (iconSize: 20.0)',
                  message: 'Standard alert size giving optical balance to bold titles and multiline messages.',
                ),
                const TBanner.warning(
                  iconSize: 26.0,
                  title: 'Prominent 26dp Icon (iconSize: 26.0)',
                  message: 'Enlarged semantic icon for prominent operational warnings or handheld inspection screens.',
                ),
                const TBanner.neutral(
                  message: 'Single-line message without title: the icon is centered with this single line rather than hanging lower.',
                ),
              ],
            ),
            code: '''// Custom icon size
TBanner.info(
  iconSize: 16.0,
  title: 'Compact 16dp Icon',
  message: 'Icon size adjusted to 16dp.',
)

TBanner.warning(
  iconSize: 26.0,
  title: 'Prominent 26dp Icon',
  message: 'Enlarged semantic indicator.',
)

// Single-line message with centered alignment
TBanner.neutral(
  message: 'Single line message with centered icon.',
)''',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOfflineChip(_OfflineDemoState state, String label, IconData icon) {
    final isSelected = _offlineState == state;
    return TButton(
      text: label,
      icon: icon,
      type: isSelected ? TButtonType.solid : TButtonType.tonal,
      size: TButtonSize.xs,
      onTap: () => setState(() => _offlineState = state),
    );
  }

  Widget _buildActiveOfflineBanner() {
    return switch (_offlineState) {
      _OfflineDemoState.offline => TBanner.offline(
          online: false,
          pendingCount: 14,
          lastSync: DateTime.now().subtract(const Duration(minutes: 24)),
          sticky: _stickyOffline,
          onViewPending: () => _setAction('Clicked: View pending (14 items)'),
        ),
      _OfflineDemoState.syncing => TBanner.offline(
          online: true,
          syncing: true,
          pendingCount: 6,
          sticky: _stickyOffline,
        ),
      _OfflineDemoState.pendingChanges => TBanner.offline(
          online: true,
          syncing: false,
          pendingCount: 5,
          lastSync: DateTime.now().subtract(const Duration(minutes: 6)),
          sticky: _stickyOffline,
          onRetry: () => _setAction('Clicked: Sync now'),
        ),
      _OfflineDemoState.error => TBanner.offline(
          online: false,
          error: 'Connection timed out while reaching warehouse API',
          sticky: _stickyOffline,
          onRetry: () => _setAction('Clicked: Retry failed sync'),
        ),
      _OfflineDemoState.fullySynced => TBanner.offline(
          online: true,
          syncing: false,
          pendingCount: 0,
          sticky: _stickyOffline,
        ),
    };
  }
}
