import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class MentionsMenubarPage extends StatefulWidget {
  const MentionsMenubarPage({super.key});

  @override
  State<MentionsMenubarPage> createState() => _MentionsMenubarPageState();
}

class _MentionsMenubarPageState extends State<MentionsMenubarPage> {
  String _comment = '';
  String _lastAction = 'No action yet';

  static const _teamMembers = [
    TMentionOption(id: 'u1', label: 'Jane Doe'),
    TMentionOption(id: 'u2', label: 'John Smith'),
    TMentionOption(id: 'u3', label: 'Alicia Keys'),
  ];

  void _act(String action) => setState(() => _lastAction = action);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TMentionsField & TMenubar Showcase', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '@-mention comment composer and a desktop-app-style top menu bar with nested dropdowns.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          TCard(
            title: 'Menubar',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TMenubar(
                  menus: [
                    TMenubarMenu(
                      label: 'File',
                      items: [
                        TDropdownItem(icon: HugeIcons.strokeRoundedNoteAdd, text: 'New', onTap: () => _act('File > New')),
                        TDropdownItem(icon: HugeIcons.strokeRoundedFolderOpen, text: 'Open', onTap: () => _act('File > Open')),
                        const TDropdownItem(customContent: Divider(height: 1)),
                        TDropdownItem(icon: HugeIcons.strokeRoundedLogout01, text: 'Exit', onTap: () => _act('File > Exit')),
                      ],
                    ),
                    TMenubarMenu(
                      label: 'Edit',
                      items: [
                        TDropdownItem(icon: HugeIcons.strokeRoundedUndo, text: 'Undo', onTap: () => _act('Edit > Undo')),
                        TDropdownItem(icon: HugeIcons.strokeRoundedRedo, text: 'Redo', onTap: () => _act('Edit > Redo')),
                      ],
                    ),
                    TMenubarMenu(
                      label: 'View',
                      items: [
                        TDropdownItem(icon: HugeIcons.strokeRoundedZoomIn, text: 'Zoom In', onTap: () => _act('View > Zoom In')),
                        TDropdownItem(icon: HugeIcons.strokeRoundedZoomOut, text: 'Zoom Out', onTap: () => _act('View > Zoom Out')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Last action: $_lastAction', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          TCard(
            title: 'Mentions Field — Comment Composer',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TMentionsField(
                  options: _teamMembers,
                  placeholder: 'Write a comment… type @ to mention a teammate',
                  rows: 3,
                  onChanged: (v) => setState(() => _comment = v),
                ),
                const SizedBox(height: 10),
                Text(
                  'Raw text: ${_comment.isEmpty ? '(empty)' : _comment}',
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
