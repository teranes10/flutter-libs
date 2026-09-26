import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class SplitPanePage extends StatefulWidget {
  const SplitPanePage({super.key});

  @override
  State<SplitPanePage> createState() => _SplitPanePageState();
}

class _SplitPanePageState extends State<SplitPanePage> {
  final TSplitPaneController _controller = TSplitPaneController(initialRatio: 0.35);

  Axis _axis = Axis.horizontal;
  bool _showCollapseButtons = true;
  bool _collapsibleLeading = true;
  final bool _collapsibleTrailing = true;
  final double _minLeadingExtent = 120.0;
  final double _minTrailingExtent = 150.0;
  double _currentRatio = 0.35;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            'TSplitPane Showcase',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Draggable, resizable two-pane container supporting horizontal & vertical splits, '
            'min/max extent constraints, quick-collapse chevrons, double-click reset, and programmatic controller binding.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Control Toolbar Card
          TCard(
            title: 'Split Pane Configuration',
            child: Wrap(
              spacing: 20,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Orientation Switch
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Orientation:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 8),
                    SegmentedButton<Axis>(
                      segments: const [
                        ButtonSegment(value: Axis.horizontal, label: Text('Horizontal'), icon: Icon(Icons.splitscreen_rounded, size: 16)),
                        ButtonSegment(value: Axis.vertical, label: Text('Vertical'), icon: Icon(Icons.table_rows_rounded, size: 16)),
                      ],
                      selected: {_axis},
                      onSelectionChanged: (val) => setState(() => _axis = val.first),
                    ),
                  ],
                ),

                // Programmatic Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TButton(
                      text: 'Collapse Left',
                      icon: Icons.first_page_rounded,
                      type: TButtonType.outline,
                      size: TSize.sm,
                      onTap: () => _controller.collapseLeading(),
                    ),
                    const SizedBox(width: 8),
                    TButton(
                      text: 'Expand / Reset',
                      icon: Icons.restart_alt_rounded,
                      type: TButtonType.outline,
                      size: TSize.sm,
                      onTap: () => _controller.reset(),
                    ),
                    const SizedBox(width: 8),
                    TButton(
                      text: 'Collapse Right',
                      icon: Icons.last_page_rounded,
                      type: TButtonType.outline,
                      size: TSize.sm,
                      onTap: () => _controller.collapseTrailing(),
                    ),
                  ],
                ),

                // Toggles
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _showCollapseButtons,
                      onChanged: (val) => setState(() => _showCollapseButtons = val ?? true),
                    ),
                    const Text('Show Collapse Chevrons', style: TextStyle(fontSize: 13)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _collapsibleLeading,
                      onChanged: (val) => setState(() => _collapsibleLeading = val ?? true),
                    ),
                    const Text('Snap Collapse Leading', style: TextStyle(fontSize: 13)),
                  ],
                ),

                // Ratio Badge
                TBadge.standalone(
                  label: 'Split: ${(_currentRatio * 100).toStringAsFixed(1)}% / ${((1.0 - _currentRatio) * 100).toStringAsFixed(1)}%',
                  color: colors.primary,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Interactive Workspace Split Canvas
          TCard(
            title: _axis == Axis.horizontal ? 'IDE Workspace (Master-Detail)' : 'Editor & Terminal Output (Stacked)',
            child: Container(
              height: 480,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: TSplitPane(
                key: ValueKey(_axis),
                axis: _axis,
                controller: _controller,
                initialRatio: 0.35,
                minLeadingExtent: _minLeadingExtent,
                minTrailingExtent: _minTrailingExtent,
                showCollapseButtons: _showCollapseButtons,
                collapsibleLeading: _collapsibleLeading,
                collapsibleTrailing: _collapsibleTrailing,
                onResized: (r) => setState(() => _currentRatio = r),
                leading: _buildLeadingPane(theme, colors),
                trailing: _buildTrailingPane(theme, colors),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingPane(ThemeData theme, ColorScheme colors) {
    return Container(
      color: theme.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
            child: const Row(
              children: [
                Icon(Icons.folder_open_rounded, size: 18),
                SizedBox(width: 8),
                Text('Project Explorer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: const [
                _ExplorerItem(icon: Icons.folder, label: 'src/lib', isFolder: true),
                _ExplorerItem(icon: Icons.code, label: 'split_pane.dart', indent: 16),
                _ExplorerItem(icon: Icons.code, label: 'tree_view.dart', indent: 16),
                _ExplorerItem(icon: Icons.code, label: 'result.dart', indent: 16),
                _ExplorerItem(icon: Icons.code, label: 'watermark.dart', indent: 16),
                _ExplorerItem(icon: Icons.folder, label: 'test', isFolder: true),
                _ExplorerItem(icon: Icons.bug_report, label: 'phase4_widgets_test.dart', indent: 16),
                _ExplorerItem(icon: Icons.description, label: 'README.md'),
                _ExplorerItem(icon: Icons.settings, label: 'pubspec.yaml'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingPane(ThemeData theme, ColorScheme colors) {
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
            child: Row(
              children: [
                const Icon(Icons.code_rounded, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('split_pane.dart', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                TBadge.standalone(
                  label: 'Dart 3.5',
                  color: colors.secondaryContainer,
                  textColor: colors.onSecondaryContainer,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA),
              child: SingleChildScrollView(
                child: Text(
                  '// Enterprise Split Pane Implementation\n'
                  'class TSplitPane extends StatefulWidget {\n'
                  '  final Widget leading;\n'
                  '  final Widget trailing;\n'
                  '  final Axis axis;\n'
                  '  final TSplitPaneController? controller;\n'
                  '  final double initialRatio;\n'
                  '  final bool showCollapseButtons;\n'
                  '  final bool collapsibleLeading;\n'
                  '\n'
                  '  const TSplitPane({\n'
                  '    super.key,\n'
                  '    required this.leading,\n'
                  '    required this.trailing,\n'
                  '    this.axis = Axis.horizontal,\n'
                  '    this.initialRatio = 0.5,\n'
                  '  });\n'
                  '}\n\n'
                  '// Tip: Drag the handle divider or double-click to reset.',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: theme.brightness == Brightness.dark ? Colors.green.shade300 : Colors.indigo.shade800,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplorerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isFolder;
  final double indent;

  const _ExplorerItem({
    required this.icon,
    required this.label,
    this.isFolder = false,
    this.indent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent, top: 2, bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isFolder ? Colors.amber : Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
