import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  TResultStatus _activeTab = TResultStatus.success;
  String _lastActionStatus = 'No action triggered yet';

  void _setAction(String msg) {
    setState(() => _lastActionStatus = msg);
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
            'Standardized enterprise outcome pages for communicating success states, access restrictions (403), missing resources (404), and server failures (500).',
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // Feedback Banner
          TBanner.info(
            variant: TVariant.tonal,
            title: 'Action Triggered',
            message: _lastActionStatus,
          ),
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

          // Result Card Display
          TCard(
            title: 'Live Preview',
            child: _buildActiveResult(colors),
          ),
        ],
      ),
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

  Widget _buildActiveResult(ColorScheme colors) {
    return switch (_activeTab) {
      TResultStatus.success => TResult.success(
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
                Text('Order Summary', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colors.onSurface)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Enterprise Cloud Pro (Annual)', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    Text('\$2,400.00', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: colors.onSurface)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estimated Provisioning Time', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    Text('Under 2 minutes', style: TextStyle(fontSize: 12, color: colors.primary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          primaryAction: TButton(
            text: 'Go to Cloud Console',
            type: TButtonType.solid,
            icon: Icons.dashboard_rounded,
            onTap: () => _setAction('Clicked: Go to Cloud Console'),
          ),
          secondaryAction: TButton(
            text: 'Download Receipt',
            type: TButtonType.tonal,
            icon: Icons.download_rounded,
            onTap: () => _setAction('Clicked: Download Receipt'),
          ),
        ),
      TResultStatus.forbidden => TResult.forbidden(
          title: '403 Access Denied',
          subtitle: 'You need the "Security Admin" or "Org Owner" RBAC permission to access cluster firewall rules.',
          primaryAction: TButton(
            text: 'Request Permission',
            icon: Icons.vpn_key_rounded,
            type: TButtonType.solid,
            onTap: () => _setAction('Clicked: Request Permission'),
          ),
          secondaryAction: TButton(
            text: 'Back to Dashboard',
            type: TButtonType.tonal,
            onTap: () => _setAction('Clicked: Back to Dashboard'),
          ),
        ),
      TResultStatus.notFound => TResult.notFound(
          title: '404 Resource Not Found',
          subtitle: 'The dataset or invoice ID you navigated to could not be found or has been moved.',
          primaryAction: TButton(
            text: 'Return Home',
            icon: Icons.home_rounded,
            type: TButtonType.solid,
            onTap: () => _setAction('Clicked: Return Home'),
          ),
          secondaryAction: TButton(
            text: 'Search Directory',
            icon: Icons.search_rounded,
            type: TButtonType.tonal,
            onTap: () => _setAction('Clicked: Search Directory'),
          ),
        ),
      TResultStatus.serverError => TResult.serverError(
          title: '500 Internal Gateway Error',
          subtitle: 'An unexpected exception occurred while processing the request. Error Trace ID: req_9821_f10a.',
          primaryAction: TButton(
            text: 'Retry Request',
            icon: Icons.refresh_rounded,
            type: TButtonType.solid,
            onTap: () => _setAction('Clicked: Retry Request'),
          ),
          secondaryAction: TButton(
            text: 'System Status Page',
            icon: Icons.health_and_safety_outlined,
            type: TButtonType.tonal,
            onTap: () => _setAction('Clicked: System Status Page'),
          ),
        ),
      _ => TResult.warning(
          title: 'Scheduled System Maintenance',
          subtitle: 'Database migrations are scheduled tonight from 02:00 UTC to 03:00 UTC. Brief read-only mode applies.',
          primaryAction: TButton(
            text: 'Acknowledge',
            type: TButtonType.solid,
            onTap: () => _setAction('Clicked: Acknowledge Maintenance Notice'),
          ),
        ),
    };
  }
}
