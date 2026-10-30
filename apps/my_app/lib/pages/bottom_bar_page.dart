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
    TBottomBarItem(icon: HugeIcons.strokeRoundedHome01, activeIcon: HugeIcons.strokeRoundedHome01, label: 'Home'),
    TBottomBarItem(icon: HugeIcons.strokeRoundedSearch01, label: 'Search'),
    TBottomBarItem(icon: HugeIcons.strokeRoundedNotification01, activeIcon: HugeIcons.strokeRoundedNotification01, label: 'Alerts', badge: 5),
    TBottomBarItem(icon: HugeIcons.strokeRoundedUser, activeIcon: HugeIcons.strokeRoundedUser, label: 'Profile'),
  ];

  // Badge sample items
  final List<TBottomBarItem> _badgeItems = const [
    TBottomBarItem(icon: HugeIcons.strokeRoundedHome01, activeIcon: HugeIcons.strokeRoundedHome01, label: 'Home'),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedShoppingBag01,
      activeIcon: HugeIcons.strokeRoundedShoppingBag01,
      label: 'Orders',
      badge: 4, // Numeric count
    ),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedBubbleChat,
      activeIcon: HugeIcons.strokeRoundedBubbleChat,
      label: 'Messages',
      badge: 'NEW', // Text pill badge
    ),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedNotification01,
      activeIcon: HugeIcons.strokeRoundedNotification01,
      label: 'Alerts',
      badge: true, // Dot indicator
    ),
    TBottomBarItem(icon: HugeIcons.strokeRoundedUser, activeIcon: HugeIcons.strokeRoundedUser, label: 'Profile'),
  ];

  // Emphasized sample items
  final List<TBottomBarItem> _emphasizedItems = const [
    TBottomBarItem(icon: HugeIcons.strokeRoundedHome01, activeIcon: HugeIcons.strokeRoundedHome01, label: 'Home'),
    TBottomBarItem(icon: HugeIcons.strokeRoundedPackage, activeIcon: HugeIcons.strokeRoundedPackage, label: 'Inventory'),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedBarcodeScan,
      label: 'Scan',
      emphasized: true, // Raised circular primary button
    ),
    TBottomBarItem(icon: HugeIcons.strokeRoundedClock01, activeIcon: HugeIcons.strokeRoundedClock01, label: 'History'),
    TBottomBarItem(icon: HugeIcons.strokeRoundedSettings01, activeIcon: HugeIcons.strokeRoundedSettings01, label: 'Settings'),
  ];

  // Field / Handheld combined workflow items
  final List<TBottomBarItem> _fieldWorkflowItems = const [
    TBottomBarItem(icon: HugeIcons.strokeRoundedDashboardSquare01, activeIcon: HugeIcons.strokeRoundedDashboardSquare01, label: 'Overview'),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedCheckList,
      label: 'Pick Tasks',
      badge: 12, // Pending tasks count
    ),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedBarcodeScan,
      label: 'Scan',
      emphasized: true, // Center raised scan action
    ),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedNotification01,
      activeIcon: HugeIcons.strokeRoundedNotification01,
      label: 'Alerts',
      badge: true, // Unread dot indicator
    ),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedUserCircle,
      activeIcon: HugeIcons.strokeRoundedUserCircle,
      label: 'Account',
      badge: 'PRO', // Status badge
    ),
  ];

  // Custom Color items
  final List<TBottomBarItem> _dangerItems = const [
    TBottomBarItem(icon: HugeIcons.strokeRoundedDashboardSquare01, activeIcon: HugeIcons.strokeRoundedDashboardSquare01, label: 'Monitor'),
    TBottomBarItem(icon: HugeIcons.strokeRoundedAlert02, label: 'Incidents', badge: 3),
    TBottomBarItem(icon: HugeIcons.strokeRoundedShield01, activeIcon: HugeIcons.strokeRoundedShield01, label: 'Security'),
    TBottomBarItem(icon: HugeIcons.strokeRoundedSettings01, label: 'Config'),
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
                TIcon.raw(HugeIcons.strokeRoundedTouch10, size: 18, color: colors.primary),
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
            icon: HugeIcons.strokeRoundedFilterEdit,
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
    TBottomBarItem(icon: HugeIcons.strokeRoundedHome01, activeIcon: HugeIcons.strokeRoundedHome01, label: 'Home'),
    TBottomBarItem(icon: HugeIcons.strokeRoundedSearch01, label: 'Search'),
    TBottomBarItem(icon: HugeIcons.strokeRoundedNotification01, activeIcon: HugeIcons.strokeRoundedNotification01, label: 'Alerts', badge: 5),
    TBottomBarItem(icon: HugeIcons.strokeRoundedUser, activeIcon: HugeIcons.strokeRoundedUser, label: 'Profile'),
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
            icon: HugeIcons.strokeRoundedCheckUnread04,
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
    TBottomBarItem(icon: HugeIcons.strokeRoundedHome01, activeIcon: HugeIcons.strokeRoundedHome01, label: 'Home'),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedShoppingBag01,
      activeIcon: HugeIcons.strokeRoundedShoppingBag01,
      label: 'Orders',
      badge: 4, // Integer count badge
    ),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedBubbleChat,
      activeIcon: HugeIcons.strokeRoundedBubbleChat,
      label: 'Messages',
      badge: 'NEW', // Text pill badge
    ),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedNotification01,
      activeIcon: HugeIcons.strokeRoundedNotification01,
      label: 'Alerts',
      badge: true, // Unread dot indicator
    ),
    TBottomBarItem(icon: HugeIcons.strokeRoundedUser, activeIcon: HugeIcons.strokeRoundedUser, label: 'Profile'),
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
            icon: HugeIcons.strokeRoundedCenterFocus,
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
    TBottomBarItem(icon: HugeIcons.strokeRoundedHome01, activeIcon: HugeIcons.strokeRoundedHome01, label: 'Home'),
    TBottomBarItem(icon: HugeIcons.strokeRoundedPackage, activeIcon: HugeIcons.strokeRoundedPackage, label: 'Inventory'),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedBarcodeScan,
      label: 'Scan',
      emphasized: true, // Raised circular primary button floating above the bar
    ),
    TBottomBarItem(icon: HugeIcons.strokeRoundedClock01, label: 'History'),
    TBottomBarItem(icon: HugeIcons.strokeRoundedSettings01, activeIcon: HugeIcons.strokeRoundedSettings01, label: 'Settings'),
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
            icon: HugeIcons.strokeRoundedHand,
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
    TBottomBarItem(icon: HugeIcons.strokeRoundedDashboardSquare01, activeIcon: HugeIcons.strokeRoundedDashboardSquare01, label: 'Overview'),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedCheckList,
      label: 'Pick Tasks',
      badge: 12, // Task count
    ),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedBarcodeScan,
      label: 'Scan',
      emphasized: true, // Center raised scan action
    ),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedNotification01,
      activeIcon: HugeIcons.strokeRoundedNotification01,
      label: 'Alerts',
      badge: true, // Unread dot indicator
    ),
    TBottomBarItem(
      icon: HugeIcons.strokeRoundedUserCircle,
      activeIcon: HugeIcons.strokeRoundedUserCircle,
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
            icon: HugeIcons.strokeRoundedPaintBoard,
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
    TBottomBarItem(icon: HugeIcons.strokeRoundedDashboardSquare01, activeIcon: HugeIcons.strokeRoundedDashboardSquare01, label: 'Monitor'),
    TBottomBarItem(icon: HugeIcons.strokeRoundedAlert02, label: 'Incidents', badge: 3),
    TBottomBarItem(icon: HugeIcons.strokeRoundedShield01, activeIcon: HugeIcons.strokeRoundedShield01, label: 'Security'),
    TBottomBarItem(icon: HugeIcons.strokeRoundedSettings01, label: 'Config'),
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
