import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class WatermarkPage extends StatefulWidget {
  const WatermarkPage({super.key});

  @override
  State<WatermarkPage> createState() => _WatermarkPageState();
}

class _WatermarkPageState extends State<WatermarkPage> {
  String _watermarkText = 'CONFIDENTIAL • admin@acmecorp.internal';
  bool _isMultiline = false;
  double _opacity = 0.12;
  double _angleDeg = -22.0;
  double _gapX = 140.0;
  final double _gapY = 120.0;
  bool _enabled = true;
  String _interactionFeedback = 'No action clicked yet';

  List<String> get _watermarkLines => [
        'ACME CORP INTERNAL ONLY',
        'User: Sarah Connor (ID: #9482)',
        'Timestamp: 2026-09-26 12:00 UTC',
      ];

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
            'TWatermark Showcase',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'High-security confidentiality watermark overlay for admin dashboards, financial records, '
            'and sensitive customer data. Non-intrusive pointer pass-through ensures 100% full interactivity with underlying controls.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Controls
          TCard(
            title: 'Watermark Parameters',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Text Field
                    SizedBox(
                      width: 320,
                      child: TextField(
                        controller: TextEditingController(text: _watermarkText)
                          ..selection = TextSelection.collapsed(offset: _watermarkText.length),
                        onChanged: (val) => setState(() => _watermarkText = val),
                        decoration: const InputDecoration(
                          labelText: 'Watermark Text',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    // Multiline Toggle
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _isMultiline,
                          onChanged: (val) => setState(() => _isMultiline = val ?? false),
                        ),
                        const Text('Multiline Audit Stamp', style: TextStyle(fontSize: 13)),
                      ],
                    ),

                    // Enabled Toggle
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: _enabled,
                          onChanged: (val) => setState(() => _enabled = val),
                        ),
                        const SizedBox(width: 4),
                        Text(_enabled ? 'Enabled' : 'Disabled', style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Sliders Row
                Wrap(
                  spacing: 32,
                  runSpacing: 16,
                  children: [
                    // Opacity Slider
                    SizedBox(
                      width: 240,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Opacity: ${(_opacity * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Slider(
                            value: _opacity,
                            min: 0.04,
                            max: 0.40,
                            divisions: 18,
                            onChanged: (val) => setState(() => _opacity = val),
                          ),
                        ],
                      ),
                    ),

                    // Rotation Angle Slider
                    SizedBox(
                      width: 240,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Angle: ${_angleDeg.toInt()}°', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Slider(
                            value: _angleDeg,
                            min: -60.0,
                            max: 60.0,
                            divisions: 24,
                            onChanged: (val) => setState(() => _angleDeg = val),
                          ),
                        ],
                      ),
                    ),

                    // Spacing Sliders
                    SizedBox(
                      width: 240,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Horizontal Gap: ${_gapX.toInt()}px', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Slider(
                            value: _gapX,
                            min: 80.0,
                            max: 260.0,
                            divisions: 9,
                            onChanged: (val) => setState(() => _gapX = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Protected View with Live Interactions
          TCard(
            title: 'Protected Confidential Payroll & Financial Records',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Interaction Feedback Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Pointer Test: $_interactionFeedback',
                        style: TextStyle(fontSize: 13, color: colors.primary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Watermarked Container Wrapping Interactive Table
                TWatermark(
                  enabled: _enabled,
                  text: _isMultiline ? null : _watermarkText,
                  lines: _isMultiline ? _watermarkLines : null,
                  opacity: _opacity,
                  rotateAngle: _angleDeg * math.pi / 180.0,
                  gapX: _gapX,
                  gapY: _gapY,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                      color: theme.cardColor,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Employee ID', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Salary (USD)', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: [
                        _buildRow('EMP-1049', 'Sarah Connor', 'Security Operations', '\$145,000', colors),
                        _buildRow('EMP-2841', 'John Reese', 'Machine Intelligence', '\$162,000', colors),
                        _buildRow('EMP-3920', 'Harold Finch', 'Systems Architecture', '\$210,000', colors),
                        _buildRow('EMP-4481', 'Sameen Shaw', 'Field Operations', '\$138,000', colors),
                        _buildRow('EMP-5923', 'Root Groves', 'Special Projects', '\$195,000', colors),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(String id, String name, String dept, String salary, ColorScheme colors) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600))),
        DataCell(Text(name)),
        DataCell(Text(dept)),
        DataCell(Text(salary, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TButton(
                text: 'View',
                size: TSize.xs,
                type: TButtonType.outline,
                onTap: () => setState(() => _interactionFeedback = 'Clicked View on $name ($id)'),
              ),
              const SizedBox(width: 6),
              TButton(
                text: 'Approve',
                size: TSize.xs,
                color: colors.primary,
                type: TButtonType.solid,
                onTap: () => setState(() => _interactionFeedback = 'Approved bonus for $name ($id)'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
