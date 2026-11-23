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
                      TTreeNode(key: 'button', label: 'button.dart', icon: HugeIcons.strokeRoundedCodeSquare),
                      TTreeNode(key: 'table', label: 'crud_table.dart', icon: HugeIcons.strokeRoundedCodeSquare),
                      TTreeNode(key: 'popover', label: 'popover.dart', icon: HugeIcons.strokeRoundedCodeSquare),
                      TTreeNode(key: 'tree', label: 'tree_view.dart', icon: HugeIcons.strokeRoundedCodeSquare),
                    ],
                  ),
                  TTreeNode(key: 'theme', label: 't_theme.dart', icon: HugeIcons.strokeRoundedPaintBoard),
                ],
              ),
              TTreeNode(key: 'pubspec_widgets', label: 'pubspec.yaml', icon: HugeIcons.strokeRoundedFile01),
            ],
          ),
          TTreeNode(
            key: 'te_editor',
            label: 'te_editor',
            children: [
              TTreeNode(
                key: 'editor_lib',
                label: 'lib',
                children: [TTreeNode(key: 'quill', label: 'quill_editor.dart', icon: HugeIcons.strokeRoundedCodeSquare)],
              ),
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
                  TTreeNode(key: 'dashboard_page', label: 'dashboard_page.dart', icon: HugeIcons.strokeRoundedDashboardSquare01),
                  TTreeNode(key: 'users_page', label: 'users_page.dart', icon: HugeIcons.strokeRoundedUserGroup),
                  TTreeNode(key: 'settings_page', label: 'settings_page.dart', icon: HugeIcons.strokeRoundedSettings01),
                ],
              ),
              TTreeNode(key: 'main', label: 'main.dart', icon: HugeIcons.strokeRoundedPlay),
            ],
          ),
        ],
      ),
      const TTreeNode(key: 'cloud_storage', label: 'cloud_storage (Async Fetch)', isLeaf: false),
    ];
  }

  static const _modes = TTreeSelectionMode.values;

  @override
  Widget build(BuildContext context) {
    return TPageWrapper(
      title: 'Tree View',
      description:
          'Interactive hierarchical tree explorer supporting single/multi-selection, tri-state checkboxes, search filtering with auto-expansion, connecting lines, and async child loading.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TBanner.info(
            variant: TVariant.tonal,
            title: 'Selected Nodes (${_selectedKeys.length})',
            message: _selectedKeys.isEmpty
                ? 'No nodes currently selected'
                : 'Keys: ${_selectedKeys.join(', ')} | Last clicked: $_lastClickedNode',
          ),
          const SizedBox(height: 24),
          TCard(
            title: 'Tree Controls & Search',
            child: Wrap(
              spacing: 20,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 260,
                  child: TTextField(
                    placeholder: 'Filter tree nodes...',
                    value: _searchQuery,
                    clearable: true,
                    onValueChanged: (val) => setState(() => _searchQuery = val ?? ''),
                  ),
                ),
                TButtonGroup(
                  initialIndex: _modes.indexOf(_selectionMode),
                  onIndexChanged: (i) => setState(() => _selectionMode = _modes[i]),
                  items: [for (final m in _modes) TButtonGroupItem(text: m.name[0].toUpperCase() + m.name.substring(1))],
                ),
                TCheckbox(label: 'Show branch lines', value: _showLines, onValueChanged: (val) => setState(() => _showLines = val ?? true)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TCard(
            title: 'File Explorer Tree',
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
                  const TTreeNode(key: 'bucket_1', label: 'production-backups-2026.tar.gz', icon: HugeIcons.strokeRoundedArchive),
                  const TTreeNode(key: 'bucket_2', label: 'user-avatars-cdn', icon: HugeIcons.strokeRoundedFolder01),
                  const TTreeNode(key: 'bucket_3', label: 'audit-ledger.parquet', icon: HugeIcons.strokeRoundedDataRecovery),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }
}
