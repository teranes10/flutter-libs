import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class JsonViewerPage extends StatefulWidget {
  const JsonViewerPage({super.key});

  @override
  State<JsonViewerPage> createState() => _JsonViewerPageState();
}

class _JsonViewerPageState extends State<JsonViewerPage> {
  String _selectedDataset = 'Cloud Deployment';
  String _searchQuery = '';
  final int _initialDepth = 2;
  bool _showItemCount = true;
  bool _showCopyButton = true;

  final Map<String, dynamic> _deploymentData = {
    'deploymentId': 'dpl_9841_prod_east',
    'status': 'HEALTHY',
    'version': 'v2.14.0',
    'replicas': 6,
    'autoScale': true,
    'environment': {
      'region': 'us-east-1',
      'cluster': 'k8s-prod-primary',
      'vpc': 'vpc-0914a8f902c',
      'subnets': ['subnet-east-1a', 'subnet-east-1b', 'subnet-east-1c'],
    },
    'containers': [
      {
        'name': 'api-gateway',
        'image': 'registry.internal/api-gw:2.14.0',
        'cpu': '500m',
        'memory': '1024Mi',
        'ports': [80, 443],
        'livenessProbe': {
          'httpGet': {'path': '/healthz', 'port': 80},
          'initialDelaySeconds': 15,
        },
      },
      {
        'name': 'sidecar-telemetry',
        'image': 'registry.internal/otel-agent:1.8.2',
        'cpu': '100m',
        'memory': '256Mi',
      },
    ],
    'tags': {
      'team': 'core-platform',
      'costCenter': 'CC-4091',
      'tier': 1,
    },
  };

  final Map<String, dynamic> _auditData = {
    'eventId': 'evt_991823194',
    'timestamp': '2026-09-26T05:21:00Z',
    'actor': {
      'userId': 'usr_admin_09',
      'email': 'security-lead@acmecorp.internal',
      'roles': ['SuperAdmin', 'SecurityAuditor'],
      'ipAddress': '192.168.1.144',
      'mfaVerified': true,
    },
    'action': 'iam.policy.update',
    'resource': {
      'type': 'DatabaseCluster',
      'identifier': 'pg-aurora-orders-prod',
      'changes': {
        'sslEnforced': {'previous': false, 'current': true},
        'backupRetentionDays': {'previous': 7, 'current': 30},
      },
    },
    'result': 'SUCCESS',
  };

  dynamic get _currentData {
    switch (_selectedDataset) {
      case 'Audit Event':
        return _auditData;
      case 'Cloud Deployment':
      default:
        return _deploymentData;
    }
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
            'TJsonViewer Showcase',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Interactive, collapsible JSON and map object tree inspector with search query highlighting, '
            'type-specific syntax coloring, depth controls, item counts, and one-click JSON clipboard copying.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Control Toolbar Card
          TCard(
            title: 'Inspector Options',
            child: Wrap(
              spacing: 20,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Dataset Dropdown
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Sample Dataset: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    DropdownButton<String>(
                      value: _selectedDataset,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'Cloud Deployment', child: Text('Cloud Deployment')),
                        DropdownMenuItem(value: 'Audit Event', child: Text('Audit Event')),
                      ],
                      onChanged: (val) => setState(() => _selectedDataset = val ?? _selectedDataset),
                    ),
                  ],
                ),

                // Search Field
                SizedBox(
                  width: 240,
                  height: 36,
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search keys or values...',
                      prefixIcon: const Icon(Icons.search, size: 16),
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),

                // Toggles
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _showItemCount,
                      onChanged: (val) => setState(() => _showItemCount = val ?? true),
                    ),
                    const Text('Show Item Counts', style: TextStyle(fontSize: 13)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _showCopyButton,
                      onChanged: (val) => setState(() => _showCopyButton = val ?? true),
                    ),
                    const Text('Copy Button', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // JSON Viewer Card
          TCard(
            title: 'Inspecting: $_selectedDataset',
            child: TJsonViewer(
              key: ValueKey('$_selectedDataset-$_initialDepth'),
              data: _currentData,
              initialDepth: _initialDepth,
              showItemCount: _showItemCount,
              showCopyButton: _showCopyButton,
              searchQuery: _searchQuery,
            ),
          ),
        ],
      ),
    );
  }
}
