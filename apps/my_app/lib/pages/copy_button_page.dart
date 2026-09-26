import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation and showcase page for the [TCopyButton] and [TCopyable] widgets.
class CopyButtonPage extends StatelessWidget {
  const CopyButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Copy Button & Copyable',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'One-click clipboard copy utility with animated state transitions, toast alerts, and monospace code pills.',
            style: TextStyle(
              fontSize: 16,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // 1. Icon-Only Copy Buttons
          WidgetDocCard(
            title: 'Icon-Only Copy Button (TCopyButton)',
            description: 'Minimal copy action with smooth animated transition to checkmark feedback',
            icon: Icons.copy_rounded,
            preview: const Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TCopyButton(
                  text: 'https://api.myapp.com/v1/orders',
                  size: TButtonSize.xs,
                ),
                TCopyButton(
                  text: 'npm install te_widgets',
                  type: TButtonType.tonal,
                  size: TButtonSize.sm,
                ),
                TCopyButton(
                  text: '9f8231ab-8321-4f10-b992',
                  type: TButtonType.solid,
                  size: TButtonSize.sm,
                ),
              ],
            ),
            code: '''// Soft-text minimal copy button
TCopyButton(text: 'https://api.myapp.com/v1/orders')

// Tonal button size sm
TCopyButton(
  text: 'npm install te_widgets',
  type: TButtonType.tonal,
  size: TButtonSize.sm,
)''',
          ),
          const SizedBox(height: 24),

          // 2. Button with Label & Toast
          WidgetDocCard(
            title: 'Copy Button with Text Label & Toast Alert',
            description: 'Displays a readable label that changes to "Copied!" and emits a toast notification',
            icon: Icons.notifications_active_outlined,
            preview: const Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TCopyButton(
                  text: 'sec_live_9941a87b32c0',
                  label: 'Copy Secret Key',
                  copiedLabel: 'Secret Key Copied!',
                  type: TButtonType.tonal,
                  size: TButtonSize.sm,
                  showToast: true,
                ),
                TCopyButton(
                  text: 'git clone https://github.com/teranes10/flutter-libs.git',
                  label: 'Clone Repo',
                  type: TButtonType.outline,
                  size: TButtonSize.sm,
                ),
              ],
            ),
            code: '''TCopyButton(
  text: 'sec_live_9941a87b32c0',
  label: 'Copy Secret Key',
  copiedLabel: 'Secret Key Copied!',
  type: TButtonType.tonal,
  size: TButtonSize.sm,
  showToast: true,
)''',
          ),
          const SizedBox(height: 24),

          // 3. TCopyable (Hover & Monospace Code Pill)
          WidgetDocCard(
            title: 'Inline Copyable Pill (TCopyable)',
            description: 'Pairs text with a copy button that appears on hover or stays visible',
            icon: Icons.code_rounded,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hover over the codes below to reveal copy button:',
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TCopyable.text(
                      'pk_live_51M0abcdef1234567890',
                      monospace: true,
                    ),
                    TCopyable.text(
                      'webhook_secret_9941',
                      monospace: true,
                      showButtonAlways: true,
                    ),
                    TCopyable.text(
                      'c41b89ef-5079-4d24-81d3-a4175b5b93d4',
                      monospace: true,
                    ),
                  ],
                ),
              ],
            ),
            code: '''// Monospace code pill (reveals copy button on hover)
TCopyable.text(
  'pk_live_51M0abcdef1234567890',
  monospace: true,
)

// Always-visible copy button
TCopyable.text(
  'webhook_secret_9941',
  monospace: true,
  showButtonAlways: true,
)''',
          ),
          const SizedBox(height: 24),

          // 4. In Context (Card / Table Cell Simulation)
          WidgetDocCard(
            title: 'Admin Context (API Credentials Card)',
            description: 'Common usage inside developer settings and credential management panels',
            icon: Icons.vpn_key_outlined,
            preview: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.terminal_rounded, size: 20, color: colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Production API Endpoint',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.onSurface),
                      ),
                      const Spacer(),
                      const TChip.tonal(text: 'Live Mode', color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const TCopyable.text(
                    'https://api.company.com/v2/analytics/stream',
                    monospace: true,
                    showButtonAlways: true,
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Text('Client ID: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      TCopyable.text('client_live_0921', monospace: true),
                      SizedBox(width: 20),
                      Text('App ID: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      TCopyable.text('app_94821', monospace: true),
                    ],
                  ),
                ],
              ),
            ),
            code: '''TCopyable.text(
  'https://api.company.com/v2/analytics/stream',
  monospace: true,
  showButtonAlways: true,
)''',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
