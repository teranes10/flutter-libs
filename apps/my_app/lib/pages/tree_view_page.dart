import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({super.key});

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  TTreeSelectionMode _selectionMode = TTreeSelectionMode.multi;
  bool _showLines = true;
  String _searchQuery = '';
  Set<String> _selectedKeys = {'auth', 'login'};
  String _lastClickedNode = 'None';

  List<TTreeNode<String>> _getTreeData() {
    return [
      const TTreeNode(
        key: 'packages',
        label: 'packages',
        badge: 'Core',
        children: [
          TTreeNode(
            key: 'te_widgets',
            label: 'te_widgets',
            badge: 'v1.4.0',
            children: [
              TTreeNode(
                key: 'lib',
                label: 'lib',
                children: [
                  TTreeNode(
                    key: 'widgets',
                    label: 'widgets',
                    children: [
                      TTreeNode(key: 'button', label: 'button.dart', icon: Icons.code_rounded),
                      TTreeNode(key: 'table', label: 'crud_table.dart', icon: Icons.code_rounded),
                      TTreeNode(key: 'popover', label: 'popover.dart', icon: Icons.code_rounded),
                      TTreeNode(key: 'tree', label: 'tree_view.dart', icon: Icons.code_rounded),
                    ],
                  ),
                  TTreeNode(key: 'theme', label: 't_theme.dart', icon: Icons.palette_outlined),
                ],
              ),
              TTreeNode(key: 'pubspec_widgets', label: 'pubspec.yaml', icon: Icons.description_outlined),
            ],
          ),
          TTreeNode(
            key: 'te_editor',
            label: 'te_editor',
            children: [
              TTreeNode(key: 'editor_lib', label: 'lib', children: [
                TTreeNode(key: 'quill', label: 'quill_editor.dart', icon: Icons.code_rounded),
              ]),
            ],
          ),
        ],
      ),
      const TTreeNode(
        key: 'apps',
        label: 'apps',
        children: [
          TTreeNode(
            key: 'my_app',
            label: 'my_app',
            children: [
              TTreeNode(
                key: 'src_pages',
                label: 'pages',
                children: [
                  TTreeNode(key: 'dashboard_page', label: 'dashboard_page.dart', icon: Icons.dashboard_outlined),
                  TTreeNode(key: 'users_page', label: 'users_page.dart', icon: Icons.people_outline),
                  TTreeNode(key: 'settings_page', label: 'settings_page.dart', icon: Icons.settings_outlined),
                ],
              ),
              TTreeNode(key: 'main', label: 'main.dart', icon: Icons.play_arrow_outlined),
            ],
          ),
        ],
      ),
      const TTreeNode(
        key: 'cloud_storage',
        label: 'cloud_storage (Async Fetch)',
        isLeaf: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Tree View',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'Interactive hierarchical tree explorer supporting single/multi-selection, tri-state checkboxes, search filtering with auto-expansion, connecting lines, and async child loading.',
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // Feedback Banner
          TBanner.info(
            variant: TVariant.tonal,
            title: 'Selected Nodes (${_selectedKeys.length})',
            message: _selectedKeys.isEmpty
                ? 'No nodes currently selected'
                : 'Keys: ${_selectedKeys.join(', ')} | Last clicked: $_lastClickedNode',
          ),
          const SizedBox(height: 24),

          // Controls Toolbar Card
          TCard(
            title: 'Tree Controls & Search',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Search Input
                SizedBox(
                  width: 260,
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      hintText: 'Filter tree nodes...',
                      hintStyle: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colors.outlineVariant),
                      ),
                    ),
                  ),
                ),

                // Selection Mode Dropdown / Toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Selection Mode: ', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                    SegmentedButton<TTreeSelectionMode>(
                      segments: const [
                        ButtonSegment(value: TTreeSelectionMode.none, label: Text('None', style: TextStyle(fontSize: 12))),
                        ButtonSegment(value: TTreeSelectionMode.single, label: Text('Single', style: TextStyle(fontSize: 12))),
                        ButtonSegment(value: TTreeSelectionMode.multi, label: Text('Multi', style: TextStyle(fontSize: 12))),
                      ],
                      selected: {_selectionMode},
                      onSelectionChanged: (val) => setState(() => _selectionMode = val.first),
                    ),
                  ],
                ),

                // Connecting lines toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _showLines,
                      onChanged: (val) => setState(() => _showLines = val ?? true),
                    ),
                    const Text('Show branch lines', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tree Canvas Card
          TCard(
            title: 'File Explorer Tree',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: TTreeView<String>(
                nodes: _getTreeData(),
                selectionMode: _selectionMode,
                selectedKeys: _selectedKeys,
                showConnectingLines: _showLines,
                searchQuery: _searchQuery,
                expandedKeys: const {'packages', 'te_widgets'},
                onSelectionChanged: (keys) => setState(() => _selectedKeys = keys),
                onNodeTap: (node) => setState(() => _lastClickedNode = node.label),
                onLoadChildren: (node) async {
                  // Simulate async network latency
                  await Future.delayed(const Duration(milliseconds: 750));
                  return [
                    const TTreeNode(key: 'bucket_1', label: 'production-backups-2026.tar.gz', icon: Icons.archive_outlined),
                    const TTreeNode(key: 'bucket_2', label: 'user-avatars-cdn', icon: Icons.folder_outlined),
                    const TTreeNode(key: 'bucket_3', label: 'audit-ledger.parquet', icon: Icons.data_array_rounded),
                  ];
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
