import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page showcasing all TButton variants and features.
class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  final _dynamicLoadingNotifier = ValueNotifier<String>('Starting...');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Button Components',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Customizable button widgets with multiple variants, sizes, and states.',
            style: TextStyle(fontSize: 16, color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          // Solid Buttons
          WidgetDocCard(
            title: 'Solid Buttons',
            description: 'Filled buttons with solid background colors',
            icon: HugeIcons.strokeRoundedRectangleCircle,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(type: TButtonType.solid, text: 'Primary', color: context.theme.primary, onTap: () {}),
                TButton(type: TButtonType.solid, text: 'Secondary', color: context.theme.secondary, onTap: () {}),
                TButton(type: TButtonType.solid, text: 'Success', color: context.theme.success, onTap: () {}),
                TButton(type: TButtonType.solid, text: 'Danger', color: context.theme.danger, onTap: () {}),
              ],
            ),
            code: '''TButton(
  type: TButtonType.solid,
  text: 'Primary',
  color: AppColors.primary,
  onTap: () {},
)''',
            properties: const [
              PropertyDoc(
                name: 'type',
                type: 'TButtonType',
                defaultValue: 'TButtonType.solid',
                description: 'The visual variant of the button',
              ),
              PropertyDoc(name: 'text', type: 'String?', description: 'The text to display on the button'),
              PropertyDoc(name: 'color', type: 'Color?', description: 'The primary color of the button'),
              PropertyDoc(name: 'onTap', type: 'VoidCallback?', description: 'Callback fired when the button is tapped'),
            ],
          ),

          // Tonal Buttons
          WidgetDocCard(
            title: 'Tonal Buttons',
            description: 'Buttons with subtle background tint',
            icon: HugeIcons.strokeRoundedPaintBoard,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(type: TButtonType.tonal, icon: HugeIcons.strokeRoundedHome01, text: 'Primary', color: context.theme.primary, onTap: () {}),
                TButton(type: TButtonType.tonal, icon: HugeIcons.strokeRoundedSettings01, text: 'Secondary', color: context.theme.secondary, onTap: () {}),
                TButton(type: TButtonType.tonal, icon: HugeIcons.strokeRoundedTick01, text: 'Success', color: context.theme.success, onTap: () {}),
                TButton(type: TButtonType.tonal, icon: HugeIcons.strokeRoundedAlert02, text: 'Warning', color: context.theme.warning, onTap: () {}),
              ],
            ),
            code: '''TButton(
  type: TButtonType.tonal,
  icon: HugeIcons.strokeRoundedHome01,
  text: 'Primary',
  color: AppColors.primary,
  onTap: () {},
)''',
            properties: const [PropertyDoc(name: 'icon', type: 'IconData?', description: 'The icon to display before the text')],
          ),

          // Outline Buttons
          WidgetDocCard(
            title: 'Outline Buttons',
            description: 'Buttons with colored borders',
            icon: HugeIcons.strokeRoundedBorderNone02,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(type: TButtonType.outline, icon: HugeIcons.strokeRoundedAdd01, text: 'Add', color: context.theme.primary, onTap: () {}),
                TButton(type: TButtonType.outline, icon: HugeIcons.strokeRoundedEdit02, text: 'Edit', color: context.theme.info, onTap: () {}),
                TButton(type: TButtonType.outline, icon: HugeIcons.strokeRoundedDelete01, text: 'Delete', color: context.theme.danger, onTap: () {}),
              ],
            ),
            code: '''TButton(
  type: TButtonType.outline,
  icon: HugeIcons.strokeRoundedAdd01,
  text: 'Add',
  color: AppColors.primary,
  onTap: () {},
)''',
          ),

          // Icon Buttons
          WidgetDocCard(
            title: 'Icon Buttons',
            description: 'Compact icon-only buttons',
            icon: HugeIcons.strokeRoundedTouch10,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(type: TButtonType.icon, icon: HugeIcons.strokeRoundedView, color: context.theme.success, onTap: () {}),
                TButton(type: TButtonType.icon, icon: HugeIcons.strokeRoundedEdit02, color: context.theme.info, onTap: () {}),
                TButton(type: TButtonType.icon, icon: HugeIcons.strokeRoundedArchive, color: context.theme.warning, onTap: () {}),
                TButton(type: TButtonType.icon, icon: HugeIcons.strokeRoundedDelete02, color: context.theme.danger, onTap: () {}),
              ],
            ),
            code: '''TButton(
  type: TButtonType.icon,
  icon: HugeIcons.strokeRoundedView,
  color: AppColors.success,
  onTap: () {},
)''',
          ),

          // Button Sizes
          WidgetDocCard(
            title: 'Button Sizes',
            description: 'Different size options for buttons',
            icon: HugeIcons.strokeRoundedImageActualSize,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TButton(text: 'XXS', size: TButtonSize.xxs, onTap: () {}),
                TButton(text: 'XS', size: TButtonSize.xs, onTap: () {}),
                TButton(text: 'SM', size: TButtonSize.sm, onTap: () {}),
                TButton(text: 'MD', size: TButtonSize.md, onTap: () {}),
                TButton(text: 'LG', size: TButtonSize.lg, onTap: () {}),
              ],
            ),
            code: '''TButton(
  text: 'Small',
  size: TButtonSize.sm,
  onTap: () {},
)

TButton(
  text: 'Medium',
  size: TButtonSize.md, // default
  onTap: () {},
)

TButton(
  text: 'Large',
  size: TButtonSize.lg,
  onTap: () {},
)''',
            properties: const [
              PropertyDoc(
                name: 'size',
                type: 'TButtonSize?',
                defaultValue: 'TButtonSize.md',
                description: 'The size configuration for the button. Available: xxs, xs, sm, md, lg, block',
              ),
            ],
          ),

          // Button Shapes
          WidgetDocCard(
            title: 'Button Shapes',
            description: 'Different shape options',
            icon: HugeIcons.strokeRoundedFactory,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(icon: HugeIcons.strokeRoundedHome01, text: 'Normal', shape: TButtonShape.normal, onTap: () {}),
                TButton(icon: HugeIcons.strokeRoundedHome01, text: 'Pill', shape: TButtonShape.pill, onTap: () {}),
                TButton(icon: HugeIcons.strokeRoundedHome01, shape: TButtonShape.circle, onTap: () {}),
              ],
            ),
            code: '''TButton(
  icon: HugeIcons.strokeRoundedHome01,
  text: 'Normal',
  shape: TButtonShape.normal,
  onTap: () {},
)

TButton(
  icon: HugeIcons.strokeRoundedHome01,
  text: 'Pill',
  shape: TButtonShape.pill,
  onTap: () {},
)

TButton(
  icon: HugeIcons.strokeRoundedHome01,
  shape: TButtonShape.circle, // icon only
  onTap: () {},
)''',
            properties: const [
              PropertyDoc(
                name: 'shape',
                type: 'TButtonShape?',
                defaultValue: 'TButtonShape.normal',
                description: 'The shape of the button. Options: normal, pill, circle',
              ),
            ],
          ),

          // Loading State
          WidgetDocCard(
            title: 'Loading State',
            description: 'Buttons with automatic loading indicator',
            icon: HugeIcons.strokeRoundedHourglass,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TButton(
                  text: 'Submit Form',
                  icon: HugeIcons.strokeRoundedSent,
                  loading: true,
                  color: context.theme.primary,
                  onPressed: (options) {
                    Future.delayed(const Duration(seconds: 2), () {
                      options.stopLoading();
                      _showSnackBar('Operation completed!');
                    });
                  },
                ),
                const SizedBox(height: 16),
                TButton(
                  text: 'Dynamic Loading',
                  icon: HugeIcons.strokeRoundedRefresh,
                  loading: true,
                  loadingNotifier: _dynamicLoadingNotifier,
                  color: context.theme.secondary,
                  onPressed: (options) async {
                    _dynamicLoadingNotifier.value = 'Connecting...';
                    await Future.delayed(const Duration(seconds: 1));
                    _dynamicLoadingNotifier.value = 'Syncing...';
                    await Future.delayed(const Duration(seconds: 1));
                    options.stopLoading();
                    _showSnackBar('Sync completed!');
                  },
                ),
              ],
            ),
            code: '''// Standard Loading
TButton(
  text: 'Submit Form',
  icon: HugeIcons.strokeRoundedSent,
  loading: true, // Enable loading state
  color: AppColors.primary,
  onPressed: (options) async {
    // Perform async operation
    await submitForm();
    
    // Stop loading when done
    options.stopLoading();
  },
)

// Dynamic Loading Message
final notifier = ValueNotifier<String>('Starting...');
TButton(
  text: 'Dynamic Sync',
  loading: true,
  loadingNotifier: notifier,
  onPressed: (options) async {
    notifier.value = 'Syncing...';
    await syncData();
    options.stopLoading();
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'loading',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to show loading indicator when onPressed is called',
              ),
              PropertyDoc(name: 'loadingText', type: 'String', defaultValue: "'Loading...'", description: 'Text to display while loading'),
              PropertyDoc(
                name: 'loadingNotifier',
                type: 'ValueNotifier<String>?',
                description: 'Dynamically update loading text while loading',
              ),
              PropertyDoc(
                name: 'onPressed',
                type: 'Function(TButtonPressOptions)?',
                description: 'Callback with loading state control. Use options.stopLoading() to hide indicator',
              ),
            ],
          ),

          // Toggle Button
          WidgetDocCard(
            title: 'Toggle Button',
            description: 'Buttons that can be toggled between active/inactive states',
            icon: HugeIcons.strokeRoundedToggleOn,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(
                  shape: TButtonShape.circle,
                  icon: HugeIcons.strokeRoundedFavouriteCircle,
                  activeIcon: HugeIcons.strokeRoundedFavourite,
                  color: Colors.grey,
                  activeColor: Colors.red,
                  onChanged: (isActive) => _showSnackBar('Favorite: $isActive'),
                ),
                TButton(
                  icon: HugeIcons.strokeRoundedNotification01,
                  activeIcon: HugeIcons.strokeRoundedNotification02,
                  text: 'Notifications',
                  color: context.theme.grey,
                  activeColor: context.theme.primary,
                  onChanged: (isActive) => _showSnackBar('Notifications: $isActive'),
                ),
              ],
            ),
            code: '''TButton(
  icon: HugeIcons.strokeRoundedFavouriteCircle,
  activeIcon: HugeIcons.strokeRoundedFavourite,
  color: Colors.grey,
  activeColor: Colors.red,
  onChanged: (isActive) {
    print('Active: \$isActive');
  },
)''',
            properties: const [
              PropertyDoc(name: 'active', type: 'bool', defaultValue: 'false', description: 'Whether the button is in active state'),
              PropertyDoc(
                name: 'activeIcon',
                type: 'IconData?',
                description: 'Icon to display when active. Falls back to icon if not provided',
              ),
              PropertyDoc(
                name: 'activeColor',
                type: 'Color?',
                description: 'Color to use when active. Falls back to color if not provided',
              ),
              PropertyDoc(name: 'onChanged', type: 'ValueChanged<bool>?', description: 'Callback fired when active state changes'),
            ],
          ),

          // Tile Buttons
          WidgetDocCard(
            title: 'Tile Buttons',
            description: 'Buttons with icon above and text below (Tile Shape)',
            icon: HugeIcons.strokeRoundedGrid,
            preview: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                TButton(
                  shape: TButtonShape.tile,
                  type: TButtonType.tonal,
                  icon: HugeIcons.strokeRoundedDashboardSquare01,
                  text: 'Dashboard',
                  color: context.theme.primary,
                  onTap: () {},
                ),
                TButton(
                  shape: TButtonShape.tile,
                  type: TButtonType.solid,
                  icon: HugeIcons.strokeRoundedShoppingCart01,
                  text: 'Orders',
                  color: context.theme.secondary,
                  onTap: () {},
                ),
                TButton(
                  shape: TButtonShape.tile,
                  type: TButtonType.outline,
                  icon: HugeIcons.strokeRoundedUserGroup,
                  text: 'Customers',
                  color: context.theme.success,
                  onTap: () {},
                ),
                TButton(
                  shape: TButtonShape.tile,
                  type: TButtonType.filledOutline,
                  icon: HugeIcons.strokeRoundedAnalytics01,
                  text: 'Reports',
                  color: context.theme.danger,
                  onTap: () {},
                ),
              ],
            ),
            code: '''TButton(
  shape: TButtonShape.tile,
  type: TButtonType.tonal,
  icon: HugeIcons.strokeRoundedDashboardSquare01,
  text: 'Dashboard',
  color: AppColors.primary,
  onTap: () {},
)''',
          ),

          // Button Badges & Alignments
          WidgetDocCard(
            title: 'Button Badges & Alignments',
            description: 'Buttons with notification counts, text pills, status dots, and customizable corner/edge alignments',
            icon: HugeIcons.strokeRoundedCheckUnread04,
            preview: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TButton(icon: HugeIcons.strokeRoundedNotification01, text: 'Alerts', badge: 5, color: context.theme.primary, onTap: () {}),
                TButton(
                  type: TButtonType.tonal,
                  icon: HugeIcons.strokeRoundedMail01,
                  text: 'Messages',
                  badge: 128,
                  color: context.theme.secondary,
                  onTap: () {},
                ),
                TButton(
                  shape: TButtonShape.circle,
                  icon: HugeIcons.strokeRoundedBubbleChat,
                  badge: true,
                  badgeColor: context.theme.success,
                  onTap: () {},
                ),
                TButton(
                  type: TButtonType.outline,
                  icon: HugeIcons.strokeRoundedAiAutoRotate,
                  text: 'AI Assistant',
                  badge: 'NEW',
                  badgeAlignment: Alignment.topLeft,
                  badgeColor: context.theme.primary,
                  onTap: () {},
                ),
                TButton(
                  type: TButtonType.softOutline,
                  icon: HugeIcons.strokeRoundedLocateOff,
                  text: 'Flash Deals',
                  badge: 'HOT',
                  badgeAlignment: Alignment.bottomRight,
                  badgeColor: context.theme.danger,
                  onTap: () {},
                ),
                TButton(
                  type: TButtonType.tonal,
                  icon: HugeIcons.strokeRoundedInbox,
                  text: 'Inbox',
                  badge: 3,
                  badgeAlignment: Alignment.bottomLeft,
                  badgeColor: context.theme.info,
                  onTap: () {},
                ),
                TButton(shape: TButtonShape.circle, icon: HugeIcons.strokeRoundedShoppingBag01, badge: 2, onTap: () {}),
              ],
            ),
            code: '''// 1. Notification Count Badge (Default Top-Right)
TButton(
  icon: HugeIcons.strokeRoundedNotification01,
  text: 'Alerts',
  badge: 5,
  onTap: () {},
)

// 2. High Count (Auto Formats to 99+)
TButton(
  type: TButtonType.tonal,
  icon: HugeIcons.strokeRoundedMail01,
  text: 'Messages',
  badge: 128,
  onTap: () {},
)

// 3. Status Dot Badge
TButton(
  shape: TButtonShape.circle,
  icon: HugeIcons.strokeRoundedBubbleChat,
  badge: true,
  badgeColor: AppColors.success,
  onTap: () {},
)

// 4. Custom Text Badge on Top-Left
TButton(
  type: TButtonType.outline,
  icon: HugeIcons.strokeRoundedAiAutoRotate,
  text: 'AI Assistant',
  badge: 'NEW',
  badgeAlignment: Alignment.topLeft,
  badgeColor: AppColors.primary,
  onTap: () {},
)

// 5. Custom Text Badge on Bottom-Right
TButton(
  icon: HugeIcons.strokeRoundedLocateOff,
  text: 'Flash Deals',
  badge: 'HOT',
  badgeAlignment: Alignment.bottomRight,
  badgeColor: AppColors.danger,
  onTap: () {},
)''',
            properties: const [
              PropertyDoc(
                name: 'badge',
                type: 'dynamic',
                description: 'Badge overlay content. Supports int/num (count), String (text label), bool (status dot), or custom Widget',
              ),
              PropertyDoc(
                name: 'badgeAlignment',
                type: 'Alignment',
                defaultValue: 'Alignment.topRight',
                description: 'The alignment of the badge overlay (topRight, topLeft, bottomRight, bottomLeft, topCenter, etc.)',
              ),
              PropertyDoc(name: 'badgeColor', type: 'Color?', description: 'Custom background color for the badge container'),
              PropertyDoc(
                name: 'badgeTextColor',
                type: 'Color?',
                defaultValue: 'Colors.white',
                description: 'Custom text color for numerical or text badges',
              ),
            ],
          ),

          // Button Group
          WidgetDocCard(
            title: 'Button Group',
            description: 'Group multiple buttons together',
            icon: HugeIcons.strokeRoundedAiView,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TButtonGroup(
                  type: TButtonGroupType.solid,
                  items: [
                    TButtonGroupItem(icon: HugeIcons.strokeRoundedAlignLeft, onTap: () {}),
                    TButtonGroupItem(icon: HugeIcons.strokeRoundedKeyframeAlignCenter, onTap: () {}),
                    TButtonGroupItem(icon: HugeIcons.strokeRoundedAlignRight, onTap: () {}),
                    TButtonGroupItem(icon: HugeIcons.strokeRoundedTextAlignJustify, onTap: () {}),
                  ],
                ),
              ],
            ),
            code: '''TButtonGroup(
  type: TButtonGroupType.solid,
  items: [
    TButtonGroupItem(
      icon: HugeIcons.strokeRoundedAlignLeft,
      onTap: () {},
    ),
    TButtonGroupItem(
      icon: HugeIcons.strokeRoundedKeyframeAlignCenter,
      onTap: () {},
    ),
    TButtonGroupItem(
      icon: HugeIcons.strokeRoundedAlignRight,
      onTap: () {},
    ),
  ],
)''',
          ),

          // Cycle Button Group
          WidgetDocCard(
            title: 'Cycle Button Group',
            description: 'Show only one button at a time and cycle through the items on tap',
            icon: HugeIcons.strokeRoundedRefresh,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TButtonGroup(
                  type: TButtonGroupType.solid,
                  cycle: true,
                  onIndexChanged: (index) {
                    _showSnackBar('Cycled to index $index');
                  },
                  items: [
                    TButtonGroupItem(
                      icon: HugeIcons.strokeRoundedPlay,
                      text: 'Play',
                      color: context.theme.success,
                      onTap: () => debugPrint('Play tapped'),
                    ),
                    TButtonGroupItem(
                      icon: HugeIcons.strokeRoundedPause,
                      text: 'Pause',
                      color: context.theme.warning,
                      onTap: () => debugPrint('Pause tapped'),
                    ),
                    TButtonGroupItem(icon: HugeIcons.strokeRoundedStop, text: 'Stop', color: context.theme.danger, onTap: () => debugPrint('Stop tapped')),
                  ],
                ),
              ],
            ),
            code: '''TButtonGroup(
  type: TButtonGroupType.solid,
  cycle: true,
  onIndexChanged: (index) {
    print('Cycled to index \$index');
  },
  items: [
    TButtonGroupItem(
      icon: HugeIcons.strokeRoundedPlay,
      text: 'Play',
      color: AppColors.success,
    ),
    TButtonGroupItem(
      icon: HugeIcons.strokeRoundedPause,
      text: 'Pause',
      color: AppColors.warning,
    ),
    TButtonGroupItem(
      icon: HugeIcons.strokeRoundedStop,
      text: 'Stop',
      color: AppColors.danger,
    ),
  ],
)''',
          ),

          // Stateful Button Group
          WidgetDocCard(
            title: 'Stateful Button Group',
            description: 'Show multiple buttons with internal selection state management',
            icon: HugeIcons.strokeRoundedCheckmarkSquare01,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TButtonGroup(
                  type: TButtonGroupType.tonal,
                  initialIndex: 0,
                  onIndexChanged: (index) {
                    _showSnackBar('Selected option index $index');
                  },
                  items: [
                    TButtonGroupItem(text: 'Option A'),
                    TButtonGroupItem(text: 'Option B'),
                    TButtonGroupItem(text: 'Option C'),
                  ],
                ),
              ],
            ),
            code: '''TButtonGroup(
  type: TButtonGroupType.outline,
  initialIndex: 0,
  onIndexChanged: (index) {
    print('Selected Option index \$index');
  },
  items: [
    TButtonGroupItem(text: 'Option A'),
    TButtonGroupItem(text: 'Option B'),
    TButtonGroupItem(text: 'Option C'),
  ],
)''',
          ),

          // Separated Selectable Cards (Button Group)
          WidgetDocCard(
            title: 'Separated Selectable Cards',
            description: 'Button group configured with separated buttons, tile shape layout, and active tick indicators',
            icon: HugeIcons.strokeRoundedGrid,
            preview: TButtonGroup(
              separated: true,
              showTick: true,
              theme: const TButtonGroupTheme(type: TButtonGroupType.softOutline, shape: TButtonShape.tile, borderRadius: 12),
              initialIndex: 0,
              items: [
                TButtonGroupItem(icon: HugeIcons.strokeRoundedPackage, text: 'Parcel'),
                TButtonGroupItem(icon: HugeIcons.strokeRoundedInbox, text: 'Box'),
                TButtonGroupItem(icon: HugeIcons.strokeRoundedShoppingBag01, text: 'Bag'),
              ],
            ),
            code: '''TButtonGroup(
  separated: true,
  expanded: true,
  showTick: true,
  theme: const TButtonGroupTheme(
    type: TButtonGroupType.softOutline,
    shape: TButtonShape.tile,
    borderRadius: 12,
  ),
  initialIndex: 0,
  items: [
    TButtonGroupItem(icon: HugeIcons.strokeRoundedPackage, text: 'Parcel'),
    TButtonGroupItem(icon: HugeIcons.strokeRoundedInbox, text: 'Box'),
    TButtonGroupItem(icon: HugeIcons.strokeRoundedShoppingBag01, text: 'Bag'),
  ],
)''',
          ),

          // Segmented Button Group
          WidgetDocCard(
            title: 'Segmented Button Group',
            description: 'Pill-in-a-track selector; the active item is raised',
            icon: HugeIcons.strokeRoundedViewAgenda,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TButtonGroup(
                  type: TButtonGroupType.segmented,
                  expanded: true,
                  initialIndex: 0,
                  items: [
                    TButtonGroupItem(text: 'Global settings'),
                    TButtonGroupItem(text: 'Node settings'),
                  ],
                ),
                const SizedBox(height: 16),
                TButtonGroup(
                  type: TButtonGroupType.segmented,
                  initialIndex: 1,
                  items: [
                    TButtonGroupItem(icon: HugeIcons.strokeRoundedAiView, text: 'List'),
                    TButtonGroupItem(icon: HugeIcons.strokeRoundedGrid, text: 'Grid'),
                    TButtonGroupItem(icon: HugeIcons.strokeRoundedMaps, text: 'Map'),
                  ],
                ),
              ],
            ),
            code: '''// Full width, equal segments
TButtonGroup(
  type: TButtonGroupType.segmented,
  expanded: true,
  initialIndex: 0,
  onIndexChanged: (i) => setState(() => _view = i),
  items: [
    TButtonGroupItem(text: 'Global settings'),
    TButtonGroupItem(text: 'Node settings'),
  ],
)

// Content-sized with icons
TButtonGroup(
  type: TButtonGroupType.segmented,
  initialIndex: 1,
  items: [
    TButtonGroupItem(icon: HugeIcons.strokeRoundedAiView, text: 'List'),
    TButtonGroupItem(icon: HugeIcons.strokeRoundedGrid, text: 'Grid'),
    TButtonGroupItem(icon: HugeIcons.strokeRoundedMaps, text: 'Map'),
  ],
)''',
            properties: const [
              PropertyDoc(name: 'type', type: 'TButtonGroupType', description: 'Use TButtonGroupType.segmented'),
              PropertyDoc(name: 'expanded', type: 'bool', defaultValue: 'false', description: 'Stretch to full width with equal-width segments'),
              PropertyDoc(name: 'initialIndex', type: 'int?', description: 'Initially selected segment; enables stateful selection'),
              PropertyDoc(name: 'onIndexChanged', type: 'ValueChanged<int>?', description: 'Called when the selected segment changes'),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating));
  }
}
