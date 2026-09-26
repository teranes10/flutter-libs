import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class CommandPalettePage extends StatefulWidget {
  const CommandPalettePage({super.key});

  @override
  State<CommandPalettePage> createState() => _CommandPalettePageState();
}

class _CommandPalettePageState extends State<CommandPalettePage> {
  String _lastCommandRun = 'None (Press ⌘K or click search to launch)';

  List<TCommandGroup> _getCommands() {
    return [
      TCommandGroup(
        heading: 'Navigation & Pages',
        items: [
          TCommandItem(
            id: 'nav_dashboard',
            title: 'Overview Dashboard',
            subtitle: 'Real-time metrics, active sessions, and revenue KPIs',
            icon: Icons.dashboard_rounded,
            shortcut: '⌘1',
            badge: 'Home',
            keywords: ['home', 'kpi', 'metrics'],
            onSelect: () => setState(() => _lastCommandRun = 'Navigated to Overview Dashboard'),
          ),
          TCommandItem(
            id: 'nav_users',
            title: 'User Management',
            subtitle: 'Browse 14,200 active enterprise user profiles',
            icon: Icons.people_outline_rounded,
            shortcut: '⌘2',
            keywords: ['customers', 'accounts', 'members'],
            onSelect: () => setState(() => _lastCommandRun = 'Opened User Directory'),
          ),
          TCommandItem(
            id: 'nav_billing',
            title: 'Billing & Invoices',
            subtitle: 'Stripe subscription plans, payment logs, and invoices',
            icon: Icons.receipt_long_rounded,
            shortcut: '⌘3',
            keywords: ['payments', 'plans', 'subscriptions'],
            onSelect: () => setState(() => _lastCommandRun = 'Opened Billing Dashboard'),
          ),
          TCommandItem(
            id: 'nav_settings',
            title: 'Organization Settings',
            subtitle: 'Security, SSO authentication, and team roles',
            icon: Icons.settings_outlined,
            shortcut: '⌘,',
            keywords: ['config', 'security', 'preferences'],
            onSelect: () => setState(() => _lastCommandRun = 'Opened Organization Settings'),
          ),
        ],
      ),
      TCommandGroup(
        heading: 'Quick Actions',
        items: [
          TCommandItem(
            id: 'act_invite',
            title: 'Invite Team Collaborator',
            subtitle: 'Send email invitation with customized RBAC role',
            icon: Icons.person_add_alt_1_rounded,
            badge: 'Admin',
            keywords: ['invite', 'add user', 'member'],
            onSelect: () => setState(() => _lastCommandRun = 'Triggered: Invite Team Collaborator Modal'),
          ),
          TCommandItem(
            id: 'act_api_key',
            title: 'Generate Production API Token',
            subtitle: 'Create a scoped bearer key for cloud integrations',
            icon: Icons.key_rounded,
            shortcut: '⌘N',
            keywords: ['secret', 'token', 'auth'],
            onSelect: () => setState(() => _lastCommandRun = 'Triggered: Generate API Key'),
          ),
          TCommandItem(
            id: 'act_export',
            title: 'Export Audit Logs (CSV / JSON)',
            subtitle: 'Download tamper-proof activity logs for compliance',
            icon: Icons.download_rounded,
            keywords: ['backup', 'audit', 'logs'],
            onSelect: () => setState(() => _lastCommandRun = 'Triggered: Audit Log Export'),
          ),
          TCommandItem(
            id: 'act_cache',
            title: 'Flush Redis Edge Cache',
            subtitle: 'Purge stale static responses across CDN endpoints',
            icon: Icons.cleaning_services_rounded,
            badge: 'Danger',
            keywords: ['clear cache', 'purge', 'redis'],
            onSelect: () => setState(() => _lastCommandRun = 'Executed: Flushed Edge Cache'),
          ),
        ],
      ),
      TCommandGroup(
        heading: 'System & Theme',
        items: [
          TCommandItem(
            id: 'sys_status',
            title: 'Service Health Status',
            subtitle: 'All 8 microservices operating normally (99.98% SLA)',
            icon: Icons.health_and_safety_outlined,
            keywords: ['health', 'uptime', 'sla'],
            onSelect: () => setState(() => _lastCommandRun = 'Checked System Health Status'),
          ),
          TCommandItem(
            id: 'sys_docs',
            title: 'Developer Documentation',
            subtitle: 'Browse API references, schema models, and SDKs',
            icon: Icons.menu_book_rounded,
            shortcut: 'F1',
            keywords: ['help', 'manual', 'api'],
            onSelect: () => setState(() => _lastCommandRun = 'Opened Developer Documentation'),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final commands = _getCommands();

    return TCommandPaletteScope(
      groups: commands,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Command Palette (⌘K)',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'A Raycast/Spotlight-style floating launcher with live fuzzy keyword search, category groupings, keyboard shortcuts, and full arrow navigation.',
              style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            // Execution Feedback Banner
            TBanner.success(
              variant: TVariant.tonal,
              title: 'Last Command Result',
              message: _lastCommandRun,
            ),
            const SizedBox(height: 24),

            // Launcher card
            TCard(
              title: 'Interactive Launcher Triggers',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Try pressing ⌘K (macOS) or Ctrl+K (Windows/Linux) directly from your keyboard, or click the search trigger below:',
                    style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Trigger Button
                      TCommandPaletteTrigger(
                        groups: commands,
                        width: 320,
                        placeholder: 'Search pages or actions...',
                        shortcut: '⌘K',
                      ),

                      // Manual Open Button
                      TButton(
                        text: 'Open Palette',
                        icon: Icons.terminal_rounded,
                        type: TButtonType.solid,
                        onTap: () => TCommandPalette.show(context, groups: commands),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Available Commands Preview Table
            TCard(
              title: 'Registered Commands Preview',
              child: Column(
                children: commands.map((group) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          group.heading,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      ...group.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: TTile(
                            size: TTileSize.h6,
                            leading: item.icon != null ? TIcon(icon: item.icon, size: 18) : null,
                            title: item.title,
                            subtitle: item.subtitle,
                            trailing: item.shortcut != null
                                ? TCopyable.text(item.shortcut!)
                                : null,
                            onTap: () {
                              item.onSelect();
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
