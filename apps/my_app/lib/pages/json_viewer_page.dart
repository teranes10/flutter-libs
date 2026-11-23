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
      {'name': 'sidecar-telemetry', 'image': 'registry.internal/otel-agent:1.8.2', 'cpu': '100m', 'memory': '256Mi'},
    ],
    'tags': {'team': 'core-platform', 'costCenter': 'CC-4091', 'tier': 1},
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
    return TPageWrapper(
      title: 'TJsonViewer Showcase',
      description:
          'Interactive, collapsible JSON and map object tree inspector with search query highlighting, '
          'type-specific syntax coloring, depth controls, item counts, and one-click JSON clipboard copying.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TCard(
            title: 'Inspector Options',
            child: Wrap(
              spacing: 20,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(
                  width: 220,
                  child: TSelect<String, String, String>(
                    label: 'Sample Dataset',
                    items: const ['Cloud Deployment', 'Audit Event'],
                    value: _selectedDataset,
                    onValueChanged: (val) => setState(() => _selectedDataset = val ?? _selectedDataset),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TTextField(
                    label: 'Search',
                    placeholder: 'Search keys or values...',
                    clearable: true,
                    onValueChanged: (val) => setState(() => _searchQuery = val?.toString() ?? ''),
                  ),
                ),
                TCheckbox(
                  label: 'Show Item Counts',
                  value: _showItemCount,
                  onValueChanged: (val) => setState(() => _showItemCount = val ?? true),
                ),
                TCheckbox(
                  label: 'Copy Button',
                  value: _showCopyButton,
                  onValueChanged: (val) => setState(() => _showCopyButton = val ?? true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
