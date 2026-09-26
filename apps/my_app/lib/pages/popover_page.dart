import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class PopoverPage extends StatefulWidget {
  const PopoverPage({super.key});

  @override
  State<PopoverPage> createState() => _PopoverPageState();
}

class _PopoverPageState extends State<PopoverPage> {
  String _lastActionStatus = 'No action performed yet';
  bool _filterEmailAlerts = true;
  bool _filterSmsAlerts = false;

  void _setStatus(String status) {
    setState(() {
      _lastActionStatus = status;
    });
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
            'Popover & Popconfirm',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Floating anchored popups for rich contextual details, compact filtering, and inline confirmation dialogs without full-screen modal interruption.',
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // Status Banner
          TBanner.info(
            variant: TVariant.tonal,
            title: 'Last Interaction Event',
            message: _lastActionStatus,
          ),
          const SizedBox(height: 24),

          // Section 1: Standard & Rich Popovers
          TCard(
            title: 'Anchored Popover Cards',
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // 1. User Card Popover
                TPopover(
                  title: 'Account Overview',
                  showCloseButton: true,
                  width: 280,
                  alignment: TPopupAlignment.bottomLeft,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colors.primaryContainer,
                            child: Icon(Icons.person_rounded, color: colors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sarah Jenkins', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colors.onSurface)),
                                Text('Lead Architect', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TAlignedRow(
                        wrapperModeThreshold: 1,
                        left: [
                          TChip(text: 'Enterprise', type: TVariant.tonal, size: TChipSize.sm),
                        ],
                        right: [
                          TButton(
                            text: 'View Profile',
                            type: TButtonType.tonal,
                            size: TButtonSize.xs,
                            onTap: () => _setStatus('Viewed Sarah Jenkins profile'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  child: TButton(
                    text: 'User Card (Tap)',
                    icon: Icons.person_outline,
                    type: TButtonType.tonal,
                  ),
                ),

                // 2. Filter Form Popover
                TPopover(
                  title: 'Notification Filters',
                  showCloseButton: true,
                  width: 300,
                  alignment: TPopupAlignment.bottomCenter,
                  builder: (context, close) {
                    return StatefulBuilder(
                      builder: (context, setLocalState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Email Alerts', style: TextStyle(fontSize: 13)),
                              subtitle: const Text('Receive digest emails', style: TextStyle(fontSize: 11)),
                              value: _filterEmailAlerts,
                              onChanged: (val) {
                                setLocalState(() => _filterEmailAlerts = val);
                                setState(() => _filterEmailAlerts = val);
                              },
                            ),
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('SMS Critical Alerts', style: TextStyle(fontSize: 13)),
                              subtitle: const Text('Immediate high-severity pings', style: TextStyle(fontSize: 11)),
                              value: _filterSmsAlerts,
                              onChanged: (val) {
                                setLocalState(() => _filterSmsAlerts = val);
                                setState(() => _filterSmsAlerts = val);
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TButton(
                                  text: 'Apply',
                                  type: TButtonType.solid,
                                  size: TButtonSize.xs,
                                  onTap: () {
                                    close();
                                    _setStatus('Filters saved (Email: $_filterEmailAlerts, SMS: $_filterSmsAlerts)');
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: TButton(
                    text: 'Filter Settings',
                    icon: Icons.filter_alt_outlined,
                    type: TButtonType.tonal,
                  ),
                ),

                // 3. Hover Trigger Popover
                TPopover(
                  triggerMode: TMenuTriggerMode.hover,
                  title: 'Hover Inspection',
                  width: 240,
                  alignment: TPopupAlignment.topCenter,
                  content: Text(
                    'This popover reveals itself smoothly on mouse hover without needing an explicit tap!',
                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                  ),
                  child: TButton(
                    text: 'Hover over me',
                    icon: Icons.mouse_rounded,
                    type: TButtonType.softOutline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Inline Confirmation (TPopconfirm)
          TCard(
            title: 'Inline Action Confirmation (TPopconfirm)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eliminates heavy full-screen modal alerts for table row deletions, status resets, and one-click sensitive actions.',
                  style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // Danger confirmation
                    TPopconfirm.danger(
                      title: 'Delete Production Database?',
                      description: 'All replicas will be detached and data erased permanently.',
                      confirmText: 'Delete DB',
                      onConfirm: () async {
                        await Future.delayed(const Duration(milliseconds: 700));
                        _setStatus('Deleted production database cluster');
                      },
                      onCancel: () => _setStatus('Cancelled database deletion'),
                      child: TButton(
                        text: 'Delete Cluster',
                        icon: Icons.delete_forever_rounded,
                        color: AppColors.danger,
                        type: TButtonType.solid,
                      ),
                    ),

                    // Standard confirmation
                    TPopconfirm(
                      title: 'Archive Project Workspace?',
                      description: 'Team members will no longer be able to submit edits.',
                      confirmText: 'Archive',
                      confirmColor: colors.primary,
                      icon: Icons.archive_outlined,
                      onConfirm: () {
                        _setStatus('Project workspace successfully archived');
                      },
                      onCancel: () => _setStatus('Archive cancelled'),
                      child: TButton(
                        text: 'Archive Project',
                        icon: Icons.archive_outlined,
                        type: TButtonType.tonal,
                      ),
                    ),

                    // Reset settings confirmation
                    TPopconfirm(
                      title: 'Reset API Credentials?',
                      description: 'Active client access tokens will immediately expire.',
                      confirmText: 'Regenerate',
                      confirmColor: Colors.orange.shade700,
                      icon: Icons.key_rounded,
                      iconColor: Colors.orange.shade700,
                      onConfirm: () async {
                        await Future.delayed(const Duration(milliseconds: 500));
                        _setStatus('API secret rotated and new tokens issued');
                      },
                      child: TButton(
                        text: 'Rotate API Keys',
                        icon: Icons.refresh_rounded,
                        type: TButtonType.softOutline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
