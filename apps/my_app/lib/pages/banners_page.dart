import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation and showcase page for the [TBanner] widget.
class BannersPage extends StatefulWidget {
  const BannersPage({super.key});

  @override
  State<BannersPage> createState() => _BannersPageState();
}

class _BannersPageState extends State<BannersPage> {
  bool _showDismissibleBanner = true;

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
            'In-page contextual notices and callouts with semantic themes, CTAs, and dismiss actions.',
            style: TextStyle(
              fontSize: 16,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

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
            description: 'Interactive callouts featuring primary buttons and onDismiss callbacks',
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
                      onTap: () {},
                    ),
                    onDismiss: () {
                      setState(() => _showDismissibleBanner = false);
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
                      onTap: () => setState(() => _showDismissibleBanner = true),
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
                    onTap: () {},
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
