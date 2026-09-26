import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class _PermissionItem {
  final String id;
  final String label;
  final String scope;
  final bool isSensitive;

  const _PermissionItem({
    required this.id,
    required this.label,
    required this.scope,
    this.isSensitive = false,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is _PermissionItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class TransferListPage extends StatefulWidget {
  const TransferListPage({super.key});

  @override
  State<TransferListPage> createState() => _TransferListPageState();
}

class _TransferListPageState extends State<TransferListPage> {
  static const List<_PermissionItem> _defaultAvailable = [
    _PermissionItem(id: 'perm_delete_cluster', label: 'Delete Production Cluster', scope: 'infrastructure.destroy', isSensitive: true),
    _PermissionItem(id: 'perm_manage_billing', label: 'Manage Invoicing & Billing', scope: 'billing.admin'),
    _PermissionItem(id: 'perm_rotate_keys', label: 'Rotate Secret & API Keys', scope: 'security.credentials.rotate', isSensitive: true),
    _PermissionItem(id: 'perm_canary_deploy', label: 'Deploy Canary Workloads', scope: 'deployments.canary'),
    _PermissionItem(id: 'perm_view_metrics', label: 'View Cluster Telemetry', scope: 'metrics.read'),
    _PermissionItem(id: 'perm_export_csv', label: 'Export Audit Parquet/CSV', scope: 'audit.export'),
    _PermissionItem(id: 'perm_sso_config', label: 'Configure SAML / OIDC SSO', scope: 'auth.identity.provider'),
  ];

  static const List<_PermissionItem> _defaultAssigned = [
    _PermissionItem(id: 'perm_view_dashboard', label: 'View Executive Dashboard', scope: 'dashboard.read'),
    _PermissionItem(id: 'perm_read_users', label: 'List Workspace Members', scope: 'users.read'),
    _PermissionItem(id: 'perm_create_tickets', label: 'Create Support Incidents', scope: 'incidents.create'),
  ];

  late List<_PermissionItem> _available;
  late List<_PermissionItem> _assigned;

  bool _showSearch = true;
  bool _showSelectAll = true;
  bool _allowReordering = true;
  String _selectedRole = 'Platform Engineer';

  @override
  void initState() {
    super.initState();
    _resetData();
  }

  void _resetData() {
    setState(() {
      _available = List.from(_defaultAvailable);
      _assigned = List.from(_defaultAssigned);
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
            'TTransferList Showcase',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Enterprise dual-list shuttle component for batch multi-item transfers, role-based access control (RBAC), '
            'column selectors, and shuttle workflows with search filtering, reordering, and item badges.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Options Toolbar Card
          TCard(
            title: 'Shuttle Configuration',
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Target Role Selector
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Role Target: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    DropdownButton<String>(
                      value: _selectedRole,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'Platform Engineer', child: Text('Platform Engineer')),
                        DropdownMenuItem(value: 'Security Auditor', child: Text('Security Auditor')),
                        DropdownMenuItem(value: 'Billing Operations', child: Text('Billing Operations')),
                      ],
                      onChanged: (val) => setState(() => _selectedRole = val ?? _selectedRole),
                    ),
                  ],
                ),

                // Toggles
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _showSearch,
                      onChanged: (val) => setState(() => _showSearch = val ?? true),
                    ),
                    const Text('Search Filters', style: TextStyle(fontSize: 13)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _showSelectAll,
                      onChanged: (val) => setState(() => _showSelectAll = val ?? true),
                    ),
                    const Text('Select All Checkbox', style: TextStyle(fontSize: 13)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _allowReordering,
                      onChanged: (val) => setState(() => _allowReordering = val ?? true),
                    ),
                    const Text('Allow Up/Down Reordering', style: TextStyle(fontSize: 13)),
                  ],
                ),

                // Reset Button
                TButton(
                  text: 'Reset Defaults',
                  icon: Icons.refresh_rounded,
                  size: TSize.sm,
                  type: TButtonType.outline,
                  onTap: _resetData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Interactive Dual List Transfer Canvas
          TCard(
            title: 'Assign Permissions to "$_selectedRole"',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TTransferList<_PermissionItem>(
                        sourceItems: _available,
                        targetItems: _assigned,
                        sourceTitle: 'Available Permissions',
                        targetTitle: 'Assigned to $_selectedRole',
                        showSearch: _showSearch,
                        showSelectAll: _showSelectAll,
                        allowReordering: _allowReordering,
                        height: 380,
                        boxWidth: 290,
                        itemLabel: (item) => item.label,
                        itemSubtitle: (item) => item.scope,
                        onTargetChanged: (newTarget) => setState(() => _assigned = newTarget),
                        onSourceChanged: (newSource) => setState(() => _available = newSource),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Summary Chips
                Text('Active Assigned Permissions (${_assigned.length}):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _assigned.map((p) {
                    return Chip(
                      label: Text('${p.label} (${p.scope})', style: const TextStyle(fontSize: 11)),
                      backgroundColor: p.isSensitive ? Colors.red.withValues(alpha: 0.12) : colors.surfaceContainerHighest,
                      side: BorderSide(color: p.isSensitive ? Colors.red.shade400 : theme.dividerColor),
                      avatar: p.isSensitive ? const Icon(Icons.shield_outlined, size: 14, color: Colors.red) : null,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
