import 'package:flutter/material.dart';
import 'package:my_app/widgets/widget_doc_card.dart';
import 'package:te_widgets/te_widgets.dart';

/// Documentation and showcase page for [TBottomBar] and [TBottomBarItem].
class BottomBarPage extends StatefulWidget {
  const BottomBarPage({super.key});

  @override
  State<BottomBarPage> createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage> {
  // Configurator state
  int _interactiveIndex = 0;
  TBottomBarTextPosition _textPosition = TBottomBarTextPosition.bottomAlways;
  TVariant _variant = TVariant.tonal;

  // Showcase indices
  int _badgeIndex = 0;
  int _emphasizedIndex = 2; // Center "Scan" selected by default
  int _fieldWorkflowIndex = 2; // Center "Scan"
  int _customColorIndex = 0;

  // Interactive sample items
  final List<TBottomBarItem> _configuratorItems = const [
    TBottomBarItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    TBottomBarItem(icon: Icons.search_rounded, label: 'Search'),
    TBottomBarItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Alerts', badge: 5),
    TBottomBarItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  // Badge sample items
  final List<TBottomBarItem> _badgeItems = const [
    TBottomBarItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    TBottomBarItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: 'Orders',
      badge: 4, // Numeric count
    ),
    TBottomBarItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Messages',
      badge: 'NEW', // Text pill badge
    ),
    TBottomBarItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Alerts',
      badge: true, // Dot indicator
    ),
    TBottomBarItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  // Emphasized sample items
  final List<TBottomBarItem> _emphasizedItems = const [
    TBottomBarItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    TBottomBarItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded, label: 'Inventory'),
    TBottomBarItem(
      icon: Icons.qr_code_scanner_rounded,
      label: 'Scan',
      emphasized: true, // Raised circular primary button
    ),
    TBottomBarItem(icon: Icons.history_rounded, activeIcon: Icons.history_rounded, label: 'History'),
    TBottomBarItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
  ];

  // Field / Handheld combined workflow items
  final List<TBottomBarItem> _fieldWorkflowItems = const [
    TBottomBarItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Overview'),
    TBottomBarItem(
      icon: Icons.checklist_rounded,
      label: 'Pick Tasks',
      badge: 12, // Pending tasks count
    ),
    TBottomBarItem(
      icon: Icons.qr_code_scanner_rounded,
      label: 'Scan',
      emphasized: true, // Center raised scan action
    ),
    TBottomBarItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Alerts',
      badge: true, // Unread dot indicator
    ),
    TBottomBarItem(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle_rounded,
      label: 'Account',
      badge: 'PRO', // Status badge
    ),
  ];

  // Custom Color items
  final List<TBottomBarItem> _dangerItems = const [
    TBottomBarItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Monitor'),
    TBottomBarItem(icon: Icons.warning_amber_rounded, label: 'Incidents', badge: 3),
    TBottomBarItem(icon: Icons.shield_outlined, activeIcon: Icons.shield, label: 'Security'),
    TBottomBarItem(icon: Icons.settings_outlined, label: 'Config'),
  ];

  Widget _buildMockContainer({required BuildContext context, required Widget child, required String activeLabel, String? subtitle}) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.touch_app_outlined, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Active: $activeLabel',
                  style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface, fontSize: 13),
                ),
                if (subtitle != null) ...[const Spacer(), Text(subtitle, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant))],
              ],
            ),
          ),
          const Divider(height: 1),
          // Pad slightly on top so emphasized button has space to pop upwards
          Padding(padding: const EdgeInsets.only(top: 8), child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Bottom Bar',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Mobile and handheld navigation bar supporting active highlights, label positioning, '
            'notification badges (counts, dots, labels), and raised circular emphasized actions.',
            style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 28),

          // 1. Interactive Configurator
          WidgetDocCard(
            title: 'Interactive Playground & Variants',
            description: 'Experiment with label placement modes, highlight variants, and tab switching.',
            icon: Icons.tune_rounded,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Text Position',
                  style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TBottomBarTextPosition.values.map((pos) {
                    return ChoiceChip(
                      label: Text(pos.name),
                      selected: _textPosition == pos,
                      onSelected: (selected) {
                        if (selected) setState(() => _textPosition = pos);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Highlight Variant',
                  style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TVariant.values.map((v) {
                    return ChoiceChip(
                      label: Text(v.name),
                      selected: _variant == v,
                      onSelected: (selected) {
                        if (selected) setState(() => _variant = v);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _buildMockContainer(
                  context: context,
                  activeLabel: _configuratorItems[_interactiveIndex].label,
                  subtitle: '${_textPosition.name} • ${_variant.name}',
                  child: TBottomBar(
                    currentIndex: _interactiveIndex,
                    onTap: (index) => setState(() => _interactiveIndex = index),
                    items: _configuratorItems,
                    textPosition: _textPosition,
                    variant: _variant,
                  ),
                ),
              ],
            ),
            code:
                '''TBottomBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  textPosition: TBottomBarTextPosition.${_textPosition.name},
  variant: TVariant.${_variant.name},
  items: const [
    TBottomBarItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    TBottomBarItem(icon: Icons.search_rounded, label: 'Search'),
    TBottomBarItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Alerts', badge: 5),
    TBottomBarItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ],
)''',
            properties: const [
              PropertyDoc(name: 'currentIndex', type: 'int', isRequired: true, description: 'Index of the currently selected tab'),
              PropertyDoc(
                name: 'items',
                type: 'List<TBottomBarItem>',
                isRequired: true,
                description: 'Items to display in the bottom navigation bar',
              ),
              PropertyDoc(name: 'onTap', type: 'ValueChanged<int>?', description: 'Callback fired when an item is tapped'),
              PropertyDoc(
                name: 'textPosition',
                type: 'TBottomBarTextPosition',
                defaultValue: 'rightActive',
                description: 'Label placement (rightActive, bottomAlways, bottomActive, none)',
              ),
              PropertyDoc(
                name: 'variant',
                type: 'TVariant',
                defaultValue: 'tonal',
                description: 'Active item highlight style (tonal, filled, outline, softOutline, text)',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Badges Sample
          WidgetDocCard(
            title: 'Badge Sample (Count, Dot, Label)',
            description:
                'TBottomBarItem accepts any badge format: integer count (e.g. 4), boolean status dot (true), '
                'or text pill (e.g. "NEW"). Badges wrap the tab icon automatically with consistent alignment.',
            icon: Icons.mark_chat_unread_outlined,
            preview: _buildMockContainer(
              context: context,
              activeLabel: _badgeItems[_badgeIndex].label,
              subtitle: 'Tap items to switch',
              child: TBottomBar(
                currentIndex: _badgeIndex,
                onTap: (index) => setState(() => _badgeIndex = index),
                items: _badgeItems,
                textPosition: TBottomBarTextPosition.bottomAlways,
                variant: TVariant.tonal,
              ),
            ),
            code: '''TBottomBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  textPosition: TBottomBarTextPosition.bottomAlways,
  variant: TVariant.tonal,
  items: const [
    TBottomBarItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    TBottomBarItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: 'Orders',
      badge: 4, // Integer count badge
    ),
    TBottomBarItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Messages',
      badge: 'NEW', // Text pill badge
    ),
    TBottomBarItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Alerts',
      badge: true, // Unread dot indicator
    ),
    TBottomBarItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ],
)''',
            properties: const [
              PropertyDoc(
                name: 'badge',
                type: 'dynamic',
                description: 'Optional badge overlay on the item icon: int count, bool dot, String label, or custom Widget',
              ),
              PropertyDoc(
                name: 'activeIcon',
                type: 'dynamic',
                description: 'Optional icon displayed when the item is active; falls back to icon if null',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Emphasized Action Sample
          WidgetDocCard(
            title: 'Emphasized Action Sample (Scan / Create)',
            description:
                'Setting emphasized: true renders the item as a raised, circular primary action button '
                'that floats above the bottom bar with an elevated drop shadow. Ideal for center Scan, Quick Add, '
                'or POS checkout actions.',
            icon: Icons.center_focus_strong_rounded,
            preview: _buildMockContainer(
              context: context,
              activeLabel: _emphasizedItems[_emphasizedIndex].label,
              subtitle: 'Center Scan is emphasized: true',
              child: TBottomBar(
                currentIndex: _emphasizedIndex,
                onTap: (index) => setState(() => _emphasizedIndex = index),
                items: _emphasizedItems,
                textPosition: TBottomBarTextPosition.bottomAlways,
                variant: TVariant.tonal,
              ),
            ),
            code: '''TBottomBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  textPosition: TBottomBarTextPosition.bottomAlways,
  variant: TVariant.tonal,
  items: const [
    TBottomBarItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    TBottomBarItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded, label: 'Inventory'),
    TBottomBarItem(
      icon: Icons.qr_code_scanner_rounded,
      label: 'Scan',
      emphasized: true, // Raised circular primary button floating above the bar
    ),
    TBottomBarItem(icon: Icons.history_rounded, label: 'History'),
    TBottomBarItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
  ],
)''',
            properties: const [
              PropertyDoc(
                name: 'emphasized',
                type: 'bool',
                defaultValue: 'false',
                description: 'Renders the item as a raised, filled circular primary action (e.g. center "Scan" button)',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. Combined Field App Workflow Sample (Emphasized + Badges)
          WidgetDocCard(
            title: 'Field App Pattern (Emphasized Action + Badges)',
            description:
                'Real-world warehouse & field technician pattern combining pending task counters, '
                'alert dots, and a center emphasized barcode scanner.',
            icon: Icons.handyman_outlined,
            preview: _buildMockContainer(
              context: context,
              activeLabel: _fieldWorkflowItems[_fieldWorkflowIndex].label,
              subtitle: 'Full handheld pattern',
              child: TBottomBar(
                currentIndex: _fieldWorkflowIndex,
                onTap: (index) => setState(() => _fieldWorkflowIndex = index),
                items: _fieldWorkflowItems,
                textPosition: TBottomBarTextPosition.bottomAlways,
                variant: TVariant.tonal,
              ),
            ),
            code: '''TBottomBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  textPosition: TBottomBarTextPosition.bottomAlways,
  variant: TVariant.tonal,
  items: const [
    TBottomBarItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Overview'),
    TBottomBarItem(
      icon: Icons.checklist_rounded,
      label: 'Pick Tasks',
      badge: 12, // Task count
    ),
    TBottomBarItem(
      icon: Icons.qr_code_scanner_rounded,
      label: 'Scan',
      emphasized: true, // Center raised scan action
    ),
    TBottomBarItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Alerts',
      badge: true, // Unread dot indicator
    ),
    TBottomBarItem(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle_rounded,
      label: 'Account',
      badge: 'PRO', // Status pill
    ),
  ],
)''',
            properties: const [
              PropertyDoc(name: 'haptic', type: 'bool', defaultValue: 'true', description: 'Triggers light selection haptic on tap'),
              PropertyDoc(name: 'iconSize', type: 'double', defaultValue: '24', description: 'Base icon size for bottom bar items'),
            ],
          ),
          const SizedBox(height: 24),

          // 5. Custom Color (Danger / Themed)
          WidgetDocCard(
            title: 'Custom Color & Soft Outline Variant',
            description: 'Customize highlight color (e.g. Danger / Incident alert bar) and active-only label layout.',
            icon: Icons.palette_outlined,
            preview: _buildMockContainer(
              context: context,
              activeLabel: _dangerItems[_customColorIndex].label,
              subtitle: 'Color: danger • Variant: softOutline',
              child: TBottomBar(
                currentIndex: _customColorIndex,
                onTap: (index) => setState(() => _customColorIndex = index),
                items: _dangerItems,
                textPosition: TBottomBarTextPosition.rightActive,
                variant: TVariant.softOutline,
                color: context.theme.danger,
              ),
            ),
            code: '''TBottomBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  items: const [
    TBottomBarItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Monitor'),
    TBottomBarItem(icon: Icons.warning_amber_rounded, label: 'Incidents', badge: 3),
    TBottomBarItem(icon: Icons.shield_outlined, activeIcon: Icons.shield, label: 'Security'),
    TBottomBarItem(icon: Icons.settings_outlined, label: 'Config'),
  ],
  textPosition: TBottomBarTextPosition.rightActive,
  variant: TVariant.softOutline,
  color: context.theme.danger,
)''',
            properties: const [
              PropertyDoc(name: 'color', type: 'Color?', description: 'Primary accent color for active item highlights'),
              PropertyDoc(name: 'background', type: 'Color?', description: 'Custom bar background color (defaults to surface)'),
              PropertyDoc(name: 'borderRadius', type: 'double?', description: 'Border radius of the active tab highlight pill'),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
