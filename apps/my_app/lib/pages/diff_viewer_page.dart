import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class DiffViewerPage extends StatefulWidget {
  const DiffViewerPage({super.key});

  @override
  State<DiffViewerPage> createState() => _DiffViewerPageState();
}

class _DiffViewerPageState extends State<DiffViewerPage> {
  String _selectedPreset = 'Config YAML';
  TDiffViewMode _mode = TDiffViewMode.sideBySide;
  bool _showLineNumbers = true;

  static const String _configOld = '''apiVersion: apps/v1
kind: Deployment
metadata:
  name: billing-service
  namespace: production
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
  template:
    spec:
      containers:
      - name: billing
        image: billing:v1.2.0
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
        env:
        - name: LOG_LEVEL
          value: "info"
        - name: DATABASE_URL
          value: "postgres://db-prod:5432/billing"''';

  static const String _configNew = '''apiVersion: apps/v1
kind: Deployment
metadata:
  name: billing-service
  namespace: production
  annotations:
    prometheus.io/scrape: "true"
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
  template:
    spec:
      containers:
      - name: billing
        image: billing:v1.3.1
        resources:
          limits:
            cpu: 1000m
            memory: 1024Mi
        env:
        - name: LOG_LEVEL
          value: "debug"
        - name: DATABASE_URL
          value: "postgres://db-prod:5432/billing"
        - name: CACHE_REDIS_URL
          value: "redis://cache-prod:6379"''';

  static const String _sqlOld = '''CREATE TABLE customer_orders (
  id UUID PRIMARY KEY,
  customer_id UUID NOT NULL,
  amount_cents INTEGER NOT NULL,
  status VARCHAR(32) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);''';

  static const String _sqlNew = '''CREATE TABLE customer_orders (
  id UUID PRIMARY KEY,
  customer_id UUID NOT NULL,
  amount_cents INTEGER NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  status VARCHAR(32) DEFAULT 'pending',
  is_subscription BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);''';

  String get _currentOldText => _selectedPreset == 'Config YAML' ? _configOld : _sqlOld;
  String get _currentNewText => _selectedPreset == 'Config YAML' ? _configNew : _sqlNew;

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
            'TDiffViewer Showcase',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Line-by-line diff and version comparison component supporting side-by-side split and unified inline modes, '
            'with additions, deletions, line numbers, and change statistics.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Control Toolbar Card
          TCard(
            title: 'Diff Comparison Settings',
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Preset Dropdown
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Preset: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    DropdownButton<String>(
                      value: _selectedPreset,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'Config YAML', child: Text('Kubernetes Deployment YAML')),
                        DropdownMenuItem(value: 'SQL Schema', child: Text('PostgreSQL Schema Migration')),
                      ],
                      onChanged: (val) => setState(() => _selectedPreset = val ?? _selectedPreset),
                    ),
                  ],
                ),

                // View Mode
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Mode: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    SegmentedButton<TDiffViewMode>(
                      segments: const [
                        ButtonSegment(value: TDiffViewMode.sideBySide, label: Text('Side-by-Side')),
                        ButtonSegment(value: TDiffViewMode.inline, label: Text('Unified Inline')),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (val) => setState(() => _mode = val.first),
                    ),
                  ],
                ),

                // Line Numbers Toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _showLineNumbers,
                      onChanged: (val) => setState(() => _showLineNumbers = val ?? true),
                    ),
                    const Text('Show Line Numbers', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Diff Canvas Card
          TCard(
            title: 'Comparing: $_selectedPreset',
            child: SizedBox(
              height: 480,
              child: TDiffViewer(
                key: ValueKey('$_selectedPreset-$_mode-$_showLineNumbers'),
                oldText: _currentOldText,
                newText: _currentNewText,
                oldTitle: _selectedPreset == 'Config YAML' ? 'v1.2.0 (Live)' : 'Migration 001',
                newTitle: _selectedPreset == 'Config YAML' ? 'v1.3.1 (Staging)' : 'Migration 002',
                mode: _mode,
                showLineNumbers: _showLineNumbers,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
