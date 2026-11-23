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
    return TPageWrapper(
      title: 'TDiffViewer Showcase',
      description:
          'Line-by-line diff and version comparison component supporting side-by-side split and unified inline modes, '
          'with additions, deletions, line numbers, and change statistics.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TCard(
            title: 'Diff Comparison Settings',
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(
                  width: 280,
                  child: TSelect<String, String, String>(
                    label: 'Preset',
                    items: const ['Config YAML', 'SQL Schema'],
                    itemText: (v) => v == 'Config YAML' ? 'Kubernetes Deployment YAML' : 'PostgreSQL Schema Migration',
                    value: _selectedPreset,
                    onValueChanged: (val) => setState(() => _selectedPreset = val ?? _selectedPreset),
                  ),
                ),
                TButtonGroup(
                  type: TButtonGroupType.segmented,
                  label: 'Mode',
                  initialIndex: _mode == TDiffViewMode.sideBySide ? 0 : 1,
                  onIndexChanged: (i) => setState(() => _mode = i == 0 ? TDiffViewMode.sideBySide : TDiffViewMode.inline),
                  items: [
                    TButtonGroupItem(text: 'Side-by-Side'),
                    TButtonGroupItem(text: 'Unified Inline'),
                  ],
                ),
                TCheckbox(
                  label: 'Show Line Numbers',
                  value: _showLineNumbers,
                  onValueChanged: (val) => setState(() => _showLineNumbers = val ?? true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
