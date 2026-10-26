import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

import '../widgets/mobile_device_frame.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  TResultStatus _activeTab = TResultStatus.success;
  String _lastActionStatus = 'No action triggered yet';
  bool _isDocked = true;

  void _setAction(String msg) {
    setState(() => _lastActionStatus = msg);
  }

  void _openFullscreenSample(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          final colors = Theme.of(ctx).colorScheme;
          return Stack(
            children: [
              _buildResult(
                colors: colors,
                status: _activeTab,
                fullPage: true,
                docked: _isDocked,
                onCustomPrimary: () {
                  Navigator.of(ctx).pop();
                  _setAction('Primary action tapped in full-page mode');
                },
                onCustomSecondary: () {
                  Navigator.of(ctx).pop();
                  _setAction('Secondary action tapped in full-page mode');
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: IconButton.filledTonal(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close full-screen preview',
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Result / Status Pages',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'Standardized enterprise outcome pages for communicating success states, access restrictions (403), missing resources (404), server failures (500), and mobile docked actions.',
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // Feedback Banner
          TBanner.info(variant: TVariant.tonal, title: 'Action Triggered', message: _lastActionStatus),
          const SizedBox(height: 24),

          // Status Switcher
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabChip(TResultStatus.success, 'Success', Icons.check_circle_outline),
                const SizedBox(width: 8),
                _buildTabChip(TResultStatus.forbidden, '403 Forbidden', Icons.lock_outline),
                const SizedBox(width: 8),
                _buildTabChip(TResultStatus.notFound, '404 Not Found', Icons.search_off),
                const SizedBox(width: 8),
                _buildTabChip(TResultStatus.serverError, '500 Server Error', Icons.cloud_off_rounded),
                const SizedBox(width: 8),
                _buildTabChip(TResultStatus.warning, 'Warning Notice', Icons.warning_amber_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Standard Inline Result (Desktop / Dashboard Embed)
          TCard(
            title: 'Standard Inline Layout (Card / Dialog Embed)',
            child: _buildResult(colors: colors, status: _activeTab, fullPage: false, docked: false),
          ),
          const SizedBox(height: 24),

          // 2. Docked Prop Sample (Mobile / Handheld Full-Page Archetype)
          TCard(
            title: 'Mobile / Handheld Layout (`docked` prop sample)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The docked property is designed for mobile and handheld devices. When fullPage: true and docked: true, primary and secondary action buttons are extracted from the scrollable body and pinned into Scaffold.bottomNavigationBar with a SafeArea, stacked vertically for ergonomic thumb reach.',
                  style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant, height: 1.4),
                ),
                const SizedBox(height: 16),

                // Interactive Controls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TSwitch(value: _isDocked, onValueChanged: (val) => setState(() => _isDocked = val ?? false)),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'docked: $_isDocked',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colors.onSurface),
                              ),
                              Text(
                                _isDocked ? 'Actions pinned to bottom navigation bar' : 'Actions render inline inside scrollable body',
                                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                      TButton(
                        text: 'Launch Fullscreen Page',
                        icon: Icons.fullscreen_rounded,
                        type: TButtonType.solid,
                        size: TButtonSize.sm,
                        onTap: () => _openFullscreenSample(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Phone Mockup + Code Details
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    // Phone mockup
                    TMobileDeviceFrame(
                      title: 'Result Preview',
                      height: 640,
                      width: 360,
                      onBackPressed: () => _setAction('Back button pressed on mobile frame'),
                      child: _buildResult(colors: colors, status: _activeTab, fullPage: true, docked: _isDocked),
                    ),

                    // Explanation & Code card
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.touch_app_outlined, size: 18, color: colors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'How `docked` Works',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colors.onSurface),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _buildBulletPoint(
                                  'docked: true',
                                  'Actions are hoisted out of the scrolling column and pinned into Scaffold.bottomNavigationBar with SafeArea.',
                                  colors,
                                ),
                                const SizedBox(height: 6),
                                _buildBulletPoint(
                                  'fullPage: true required',
                                  'The docked behavior activates only when fullPage is true (which provides the underlying Scaffold).',
                                  colors,
                                ),
                                const SizedBox(height: 6),
                                _buildBulletPoint(
                                  'Ergonomic layout',
                                  'Primary and secondary buttons stretch full-width and stack vertically for effortless single-handed thumb tapping.',
                                  colors,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Code Snippet Box
                          Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerLow,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                                    border: Border(bottom: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.4))),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Dart Code Example',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant),
                                      ),
                                      TCopyButton(text: _sampleCodeSnippet),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: SelectableText(
                                    _sampleCodeSnippet,
                                    style: TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.45, color: colors.onSurface),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description, ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant, height: 1.4),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabChip(TResultStatus status, String label, IconData icon) {
    final isSelected = _activeTab == status;
    return TButton(
      text: label,
      icon: icon,
      type: isSelected ? TButtonType.solid : TButtonType.tonal,
      size: TButtonSize.xs,
      onTap: () => setState(() => _activeTab = status),
    );
  }

  Widget _buildResult({
    required ColorScheme colors,
    required TResultStatus status,
    bool fullPage = false,
    bool docked = false,
    VoidCallback? onCustomPrimary,
    VoidCallback? onCustomSecondary,
  }) {
    switch (status) {
      case TResultStatus.success:
        return TResult.success(
          fullPage: fullPage,
          docked: docked,
          title: 'Order Successfully Placed',
          subtitle: 'Order #982104 has been confirmed and dispatched to our European fulfillment hub.',
          extra: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colors.onSurface),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Enterprise Cloud Pro',
                        style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$2,400.00',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: colors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Provisioning Time',
                        style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Under 2m',
                      style: TextStyle(fontSize: 12, color: colors.primary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          primaryAction: TButton(
            text: 'Go to Cloud Console',
            type: TButtonType.solid,
            icon: Icons.dashboard_rounded,
            onTap: onCustomPrimary ?? () => _setAction('Clicked: Go to Cloud Console'),
          ),
          secondaryAction: TButton(
            text: 'Download Receipt',
            type: TButtonType.tonal,
            icon: Icons.download_rounded,
            onTap: onCustomSecondary ?? () => _setAction('Clicked: Download Receipt'),
          ),
        );
      case TResultStatus.forbidden:
        return TResult.forbidden(
          fullPage: fullPage,
          docked: docked,
          title: '403 Access Denied',
          subtitle: 'You need the "Security Admin" or "Org Owner" RBAC permission to access cluster firewall rules.',
          primaryAction: TButton(
            text: 'Request Permission',
            icon: Icons.vpn_key_rounded,
            type: TButtonType.solid,
            onTap: onCustomPrimary ?? () => _setAction('Clicked: Request Permission'),
          ),
          secondaryAction: TButton(
            text: 'Back to Dashboard',
            type: TButtonType.tonal,
            onTap: onCustomSecondary ?? () => _setAction('Clicked: Back to Dashboard'),
          ),
        );
      case TResultStatus.notFound:
        return TResult.notFound(
          fullPage: fullPage,
          docked: docked,
          title: '404 Resource Not Found',
          subtitle: 'The dataset or invoice ID you navigated to could not be found or has been moved.',
          primaryAction: TButton(
            text: 'Return Home',
            icon: Icons.home_rounded,
            type: TButtonType.solid,
            onTap: onCustomPrimary ?? () => _setAction('Clicked: Return Home'),
          ),
          secondaryAction: TButton(
            text: 'Search Directory',
            icon: Icons.search_rounded,
            type: TButtonType.tonal,
            onTap: onCustomSecondary ?? () => _setAction('Clicked: Search Directory'),
          ),
        );
      case TResultStatus.serverError:
        return TResult.serverError(
          fullPage: fullPage,
          docked: docked,
          title: '500 Internal Gateway Error',
          subtitle: 'An unexpected exception occurred while processing the request. Error Trace ID: req_9821_f10a.',
          primaryAction: TButton(
            text: 'Retry Request',
            icon: Icons.refresh_rounded,
            type: TButtonType.solid,
            onTap: onCustomPrimary ?? () => _setAction('Clicked: Retry Request'),
          ),
          secondaryAction: TButton(
            text: 'System Status Page',
            icon: Icons.health_and_safety_outlined,
            type: TButtonType.tonal,
            onTap: onCustomSecondary ?? () => _setAction('Clicked: System Status Page'),
          ),
        );
      case TResultStatus.warning:
      default:
        return TResult.warning(
          fullPage: fullPage,
          docked: docked,
          title: 'Scheduled System Maintenance',
          subtitle: 'Database migrations are scheduled tonight from 02:00 UTC to 03:00 UTC. Brief read-only mode applies.',
          primaryAction: TButton(
            text: 'Acknowledge',
            type: TButtonType.solid,
            onTap: onCustomPrimary ?? () => _setAction('Clicked: Acknowledge Maintenance Notice'),
          ),
          secondaryAction: TButton(
            text: 'View Maintenance Schedule',
            type: TButtonType.tonal,
            onTap: onCustomSecondary ?? () => _setAction('Clicked: View Maintenance Schedule'),
          ),
        );
    }
  }

  static const String _sampleCodeSnippet = '''TResult.success(
  fullPage: true, // Enables full-page Scaffold
  docked: true,   // Docks actions into bottomNavigationBar
  title: 'Order Successfully Placed',
  subtitle: 'Order #982104 confirmed and dispatched.',
  extra: const OrderSummaryCard(),
  primaryAction: TButton(
    text: 'Go to Cloud Console',
    type: TButtonType.solid,
    icon: Icons.dashboard_rounded,
    onTap: () => navigateToConsole(),
  ),
  secondaryAction: TButton(
    text: 'Download Receipt',
    type: TButtonType.tonal,
    icon: Icons.download_rounded,
    onTap: () => downloadReceipt(),
  ),
);''';
}
