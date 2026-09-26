import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class ContextMenuPage extends StatefulWidget {
  const ContextMenuPage({super.key});

  @override
  State<ContextMenuPage> createState() => _ContextMenuPageState();
}

class _ContextMenuPageState extends State<ContextMenuPage> {
  String _lastAction = 'Right click on the cards or rows below';

  void _trigger(String action) {
    setState(() {
      _lastAction = action;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Context Menu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Desktop & web secondary-click (right-click) and mobile long-press contextual menus with keyboard shortcuts and danger variants.',
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // Status Banner
          Row(
            children: [
              Expanded(
                child: TBanner.info(
                  variant: TVariant.tonal,
                  title: 'Context Action Triggered',
                  message: _lastAction,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TBanner.success(
                  variant: TVariant.tonal,
                  title: 'Web Integration',
                  message: 'Browser native context menu is automatically overridden on hover and right-click on Flutter Web.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section 1: Canvas / Workspace Context Menu
          TCard(
            title: 'Workspace Canvas (Right-Click Inside)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secondary click (right-click on desktop/web or long-press on mobile) anywhere inside the dashed region below:',
                  style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                TContextMenu(
                  items: [
                    TContextMenuItem(
                      text: 'New Folder',
                      icon: Icons.create_new_folder_outlined,
                      shortcut: '⇧⌘N',
                      onTap: () => _trigger('Created New Folder in Workspace'),
                    ),
                    TContextMenuItem(
                      text: 'Upload Assets',
                      icon: Icons.upload_file_rounded,
                      onTap: () => _trigger('Selected Upload Assets'),
                    ),
                    TContextMenuItem(
                      text: 'Paste from Clipboard',
                      icon: Icons.paste_rounded,
                      shortcut: '⌘V',
                      onTap: () => _trigger('Pasted clipboard data into canvas'),
                    ),
                    const TContextMenuDivider(),
                    TContextMenuItem(
                      text: 'Select All Items',
                      icon: Icons.select_all_rounded,
                      shortcut: '⌘A',
                      onTap: () => _trigger('Selected all items in workspace'),
                    ),
                    TContextMenuItem(
                      text: 'Canvas Settings',
                      icon: Icons.tune_rounded,
                      onTap: () => _trigger('Opened Canvas Settings'),
                    ),
                    const TContextMenuDivider(),
                    TContextMenuItem(
                      text: 'Clear Canvas',
                      icon: Icons.delete_sweep_rounded,
                      isDestructive: true,
                      onTap: () => _trigger('Cleared all items from canvas'),
                    ),
                  ],
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? colors.surfaceContainerHighest.withValues(alpha: 0.3) : colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mouse_outlined, size: 36, color: colors.primary),
                        const SizedBox(height: 8),
                        Text(
                          'Right-Click Anywhere Inside This Area',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          'Coordinates automatically anchor the context menu with boundary safety checks',
                          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Table / Row Context Menu
          TCard(
            title: 'Table Row Context Menus',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Right click any row in this customer dataset to trigger row-specific context options:',
                  style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                ...[
                  ('Acme Corp', 'Enterprise Plan • \$48,000/yr', 'Active', colors.primary),
                  ('Starlight Dynamics', 'Scale Plan • \$14,400/yr', 'Pending Renewal', Colors.amber.shade700),
                  ('Zenith Labs', 'Startup Plan • \$3,600/yr', 'Suspended', AppColors.danger),
                ].map((row) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TContextMenu(
                      items: [
                        TContextMenuItem(
                          text: 'View ${row.$1} Profile',
                          icon: Icons.visibility_outlined,
                          onTap: () => _trigger('Viewing customer profile: ${row.$1}'),
                        ),
                        TContextMenuItem(
                          text: 'Edit Account & Quota',
                          icon: Icons.edit_outlined,
                          shortcut: '⌘E',
                          onTap: () => _trigger('Editing quota for: ${row.$1}'),
                        ),
                        TContextMenuItem(
                          text: 'Duplicate Record',
                          icon: Icons.copy_rounded,
                          shortcut: '⌘D',
                          onTap: () => _trigger('Duplicated record for: ${row.$1}'),
                        ),
                        const TContextMenuDivider(),
                        TContextMenuItem(
                          text: 'Send In-App Notification',
                          icon: Icons.send_rounded,
                          onTap: () => _trigger('Sent notification to: ${row.$1}'),
                        ),
                        const TContextMenuDivider(),
                        TContextMenuItem(
                          text: 'Delete Customer',
                          icon: Icons.delete_outline,
                          isDestructive: true,
                          shortcut: '⌫',
                          onTap: () => _trigger('Deleted customer account: ${row.$1}'),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? colors.surfaceContainerHigh : colors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.business_rounded, color: colors.primary, size: 20),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(row.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text(row.$2, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            TBadge(label: row.$3, color: row.$4),
                            const SizedBox(width: 12),
                            Icon(Icons.more_vert_rounded, size: 18, color: colors.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
