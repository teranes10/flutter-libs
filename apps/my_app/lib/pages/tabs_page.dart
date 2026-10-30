import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page for Tabs widgets.
class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  // Controllers for new examples
  late final TTabController<int> _verticalController;
  late final TTabController<int> _separatedController;
  int _segmentedTab = 1;

  @override
  void initState() {
    super.initState();
    _verticalController = TTabController<int>(initialValue: 0);
    _separatedController = TTabController<int>(initialValue: 0);
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _separatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Tabs',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Tab navigation components with multiple layout modes and customization options.',
            style: TextStyle(fontSize: 16, color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          // Basic Tabs
          WidgetDocCard(
            title: 'Basic Tabs',
            description: 'Simple horizontal tabs with text and icons',
            icon: HugeIcons.strokeRoundedBrowser,
            preview: SizedBox(
              height: 300,
              child: TTabView<int>(
                tabs: [
                  TTab(
                    value: 0,
                    text: 'Home',
                    icon: HugeIcons.strokeRoundedHome01,
                    content: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: context.theme.primary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          TIcon.raw(HugeIcons.strokeRoundedHome01, color: context.theme.primary, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Home Content - This is the home page with all your recent activity',
                              style: TextStyle(color: context.colors.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            code: '''int _selectedTab = 0;

TTabs<int>(
  tabs: [
    TTab(value: 0, text: 'Home', icon: HugeIcons.strokeRoundedHome01),
    TTab(value: 1, text: 'Profile', icon: HugeIcons.strokeRoundedUser),
    TTab(value: 2, text: 'Settings', icon: HugeIcons.strokeRoundedSettings01),
  ],
  selectedValue: _selectedTab,
  onTabChanged: (value) => setState(() => _selectedTab = value),
)''',
            properties: const [
              PropertyDoc(name: 'tabs', type: 'List<TTab<T>>', description: 'List of tabs to display'),
              PropertyDoc(name: 'selectedValue', type: 'T?', description: 'Currently selected tab value'),
              PropertyDoc(name: 'onTabChanged', type: 'ValueChanged<T>?', description: 'Callback when tab is selected'),
            ],
          ),

          // Tabs with Count
          WidgetDocCard(
            title: 'Tabs with Count',
            description: 'Tabs displaying numeric counts in badges (e.g. status filters, pending queues)',
            icon: HugeIcons.strokeRoundedArrangeByNumbers91,
            preview: SizedBox(
              height: 200,
              child: TTabView<String>(
                initialValue: 'all',
                tabs: [
                  TTab(
                    value: 'all',
                    text: 'All',
                    count: 24,
                    icon: HugeIcons.strokeRoundedList,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.theme.primary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            TIcon.raw(HugeIcons.strokeRoundedList, color: context.theme.primary, size: 28),
                            const SizedBox(width: 12),
                            Text('All Items (24 items total)', style: TextStyle(color: context.colors.onSurface)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TTab(
                    value: 'pending',
                    text: 'Pending',
                    count: 5,
                    icon: HugeIcons.strokeRoundedClock01,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.theme.primary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            TIcon.raw(HugeIcons.strokeRoundedClock01, color: context.theme.primary, size: 28),
                            const SizedBox(width: 12),
                            Text('Pending Items (5 items awaiting review)', style: TextStyle(color: context.colors.onSurface)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TTab(
                    value: 'completed',
                    text: 'Completed',
                    count: 18,
                    icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.theme.primary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            TIcon.raw(HugeIcons.strokeRoundedCheckmarkCircle01, color: context.theme.primary, size: 28),
                            const SizedBox(width: 12),
                            Text('Completed Items (18 items finished)', style: TextStyle(color: context.colors.onSurface)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TTab(
                    value: 'archived',
                    text: 'Archived',
                    count: 1,
                    icon: HugeIcons.strokeRoundedArchive,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.theme.primary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            TIcon.raw(HugeIcons.strokeRoundedArchive, color: context.theme.primary, size: 28),
                            const SizedBox(width: 12),
                            Text('Archived Items (1 item in archive)', style: TextStyle(color: context.colors.onSurface)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            code: '''TTabs<String>(
  selectedValue: _filter,
  onTabChanged: (val) => setState(() => _filter = val),
  tabs: const [
    TTab(value: 'all', text: 'All', count: 24, icon: HugeIcons.strokeRoundedList),
    TTab(value: 'pending', text: 'Pending', count: 5, icon: HugeIcons.strokeRoundedClock01),
    TTab(value: 'completed', text: 'Completed', count: 18, icon: HugeIcons.strokeRoundedCheckmarkCircle01),
    TTab(value: 'archived', text: 'Archived', count: 1, icon: HugeIcons.strokeRoundedArchive),
  ],
)''',
            properties: const [
              PropertyDoc(
                name: 'count',
                type: 'int?',
                description: 'Optional count displayed as a styled pill badge next to the tab label',
              ),
              PropertyDoc(name: 'text', type: 'String?', description: 'Text label for the tab'),
              PropertyDoc(name: 'icon', type: 'dynamic', description: 'Optional icon widget or IconData'),
            ],
          ),

          // Scrollable Tabs
          WidgetDocCard(
            title: 'Scrollable Tabs',
            description: 'Tabs with horizontal scrolling and navigation buttons (desktop/web)',
            icon: HugeIcons.strokeRoundedArrowLeftRight,
            preview: SizedBox(
              height: 200,
              child: TTabView<int>(
                tabs: List.generate(
                  10,
                  (i) => TTab(
                    value: i,
                    text: 'Tab ${i + 1}',
                    icon: HugeIcons.strokeRoundedStar,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [context.theme.primary.withAlpha(26), context.theme.secondary.withAlpha(26)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            TIcon.raw(HugeIcons.strokeRoundedStar, color: context.theme.primary),
                            const SizedBox(width: 12),
                            Text(
                              'Content for Tab ${i + 1}',
                              style: TextStyle(color: context.colors.onSurface, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                scrollable: true,
                showNavigationButtons: true,
              ),
            ),
            code: '''TTabs<int>(
  tabs: List.generate(
    10,
    (i) => TTab(value: i, text: 'Tab \${i + 1}', icon: HugeIcons.strokeRoundedStar),
  ),
  selectedValue: _selectedTab,
  onTabChanged: (value) => setState(() => _selectedTab = value),
  scrollable: true,
  showNavigationButtons: true,
)''',
            properties: const [
              PropertyDoc(
                name: 'scrollable',
                type: 'bool',
                defaultValue: 'false',
                description: 'Enable scrolling with swipe and navigation buttons',
              ),
              PropertyDoc(
                name: 'showNavigationButtons',
                type: 'bool',
                defaultValue: 'true',
                description: 'Show navigation arrows on desktop/web platforms',
              ),
            ],
          ),

          // Vertical Tabs
          WidgetDocCard(
            title: 'Vertical Tabs',
            description: 'Tabs arranged vertically with right-side indicator',
            icon: HugeIcons.strokeRoundedArrowUpDown,
            preview: SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TTabs<int>(
                    controller: _verticalController,
                    tabs: [
                      TTab(value: 0, text: 'Dashboard', icon: HugeIcons.strokeRoundedDashboardSquare01),
                      TTab(value: 1, text: 'Analytics', icon: HugeIcons.strokeRoundedAnalytics01),
                      TTab(value: 2, text: 'Reports', icon: HugeIcons.strokeRoundedAnalytics02),
                      TTab(value: 3, text: 'Settings', icon: HugeIcons.strokeRoundedSettings01),
                    ],
                    axis: Axis.vertical,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TTabContent<int>(
                      controller: _verticalController,
                      tabs: [
                        TTab(
                          value: 0,
                          text: 'Dashboard',
                          icon: HugeIcons.strokeRoundedDashboardSquare01,
                          content: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: context.theme.primary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TIcon.raw(HugeIcons.strokeRoundedDashboardSquare01, color: context.theme.primary, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Dashboard Content',
                                  style: TextStyle(color: context.colors.onSurface, fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text('View your main dashboard', style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        TTab(
                          value: 1,
                          text: 'Analytics',
                          icon: HugeIcons.strokeRoundedAnalytics01,
                          content: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: context.theme.info.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TIcon.raw(HugeIcons.strokeRoundedAnalytics01, color: context.theme.info, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Analytics Content',
                                  style: TextStyle(color: context.colors.onSurface, fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text('Analyze your data', style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        TTab(
                          value: 2,
                          text: 'Reports',
                          icon: HugeIcons.strokeRoundedAnalytics02,
                          content: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: context.theme.warning.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TIcon.raw(HugeIcons.strokeRoundedAnalytics02, color: context.theme.warning, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Reports Content',
                                  style: TextStyle(color: context.colors.onSurface, fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text('Generate reports', style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        TTab(
                          value: 3,
                          text: 'Settings',
                          icon: HugeIcons.strokeRoundedSettings01,
                          content: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: context.theme.success.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TIcon.raw(HugeIcons.strokeRoundedSettings01, color: context.theme.success, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Settings Content',
                                  style: TextStyle(color: context.colors.onSurface, fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text('Configure settings', style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            code: '''TTabs<int>(
  tabs: [
    TTab(value: 0, text: 'Dashboard', icon: HugeIcons.strokeRoundedDashboardSquare01),
    TTab(value: 1, text: 'Analytics', icon: HugeIcons.strokeRoundedAnalytics01),
    TTab(value: 2, text: 'Reports', icon: HugeIcons.strokeRoundedAnalytics02),
    TTab(value: 3, text: 'Settings', icon: HugeIcons.strokeRoundedSettings01),
  ],
  selectedValue: _selectedTab,
  onTabChanged: (value) => setState(() => _selectedTab = value),
  axis: Axis.vertical,
)''',
            properties: const [
              PropertyDoc(
                name: 'axis',
                type: 'Axis',
                defaultValue: 'Axis.horizontal',
                description: 'Layout direction (horizontal or vertical)',
              ),
            ],
          ),

          // Wrap Mode Tabs
          WidgetDocCard(
            title: 'Wrap Mode',
            description: 'Tabs that wrap to multiple lines when space is limited',
            icon: HugeIcons.strokeRoundedTextWrap,
            preview: TTabView<String>(
                tabs: [
                  TTab(
                    value: 'all',
                    text: 'All Items',
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('Showing all items', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 'active',
                    text: 'Active',
                    isActive: true,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('Showing active items', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 'pending',
                    text: 'Pending',
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('Showing pending items', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 'completed',
                    text: 'Completed',
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('Showing completed items', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 'archived',
                    text: 'Archived',
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('Showing archived items', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 'deleted',
                    text: 'Deleted',
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('Showing deleted items', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                ],
                inline: true,
                wrap: true,
              ),
            code: '''TTabs<String>(
  tabs: [
    TTab(value: 'all', text: 'All Items'),
    TTab(value: 'active', text: 'Active', isActive: true),
    TTab(value: 'pending', text: 'Pending'),
    TTab(value: 'completed', text: 'Completed'),
    TTab(value: 'archived', text: 'Archived'),
  ],
  selectedValue: _selectedTab,
  onTabChanged: (value) => setState(() => _selectedTab = value),
  inline: true,
  wrap: true,
)''',
            properties: const [
              PropertyDoc(name: 'inline', type: 'bool', defaultValue: 'false', description: 'Use inline layout instead of full-width'),
              PropertyDoc(
                name: 'wrap',
                type: 'bool',
                defaultValue: 'false',
                description: 'Wrap tabs to multiple lines (requires inline: true)',
              ),
            ],
          ),

          // Custom Tab Builder
          WidgetDocCard(
            title: 'Custom Tab Builder',
            description: 'Fully customizable tab appearance using tabBuilder',
            icon: HugeIcons.strokeRoundedPaintBrush01,
            preview: SizedBox(
              height: 150,
              child: TTabView<int>(
                tabs: [
                  TTab(
                    value: 0,
                    text: 'Design',
                    icon: HugeIcons.strokeRoundedPaintBoard,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('Design View', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 1,
                    text: 'Code',
                    icon: HugeIcons.strokeRoundedCodeSquare,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('Code View', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 2,
                    text: 'Preview',
                    icon: HugeIcons.strokeRoundedView,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('Preview View', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 3,
                    text: 'Preview 1',
                    icon: HugeIcons.strokeRoundedView,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('Preview View', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                ],
                tabBuilder: (context, tab, isSelected, onTap) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? context.colors.primaryContainer : context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? context.colors.primary : Colors.transparent, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (tab.icon != null) ...[
                              TIcon.raw(tab.icon, size: 18, color: isSelected ? context.colors.onPrimaryContainer : context.colors.onSurface),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              tab.text ?? '',
                              style: TextStyle(
                                color: isSelected ? context.colors.onPrimaryContainer : context.colors.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                wrap: true,
                inline: true,
              ),
            ),
            code: '''TTabs<int>(
  tabs: [
    TTab(value: 0, text: 'Design', icon: HugeIcons.strokeRoundedPaintBoard),
    TTab(value: 1, text: 'Code', icon: HugeIcons.strokeRoundedCodeSquare),
    TTab(value: 2, text: 'Preview', icon: HugeIcons.strokeRoundedView),
  ],
  selectedValue: _selectedTab,
  onTabChanged: (value) => setState(() => _selectedTab = value),
  tabBuilder: (context, tab, isSelected, onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tab.icon != null) Icon(tab.icon, size: 18),
              SizedBox(width: 8),
              Text(tab.text ?? ''),
            ],
          ),
        ),
      ),
    );
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'tabBuilder',
                type: 'Widget Function(BuildContext, TTab<T>, bool, VoidCallback?)?',
                description:
                    'Custom builder for tab widgets. Receives context, tab, isSelected state, and onTap callback. Builder should handle its own Material/InkWell.',
              ),
            ],
          ),

          // Styled Tabs
          WidgetDocCard(
            title: 'Styled Tabs',
            description: 'Tabs with custom colors and styling',
            icon: HugeIcons.strokeRoundedColorPicker,
            preview: SizedBox(
              height: 150,
              child: TTabView<int>(
                tabs: [
                  TTab(
                    value: 0,
                    text: 'Overview',
                    icon: HugeIcons.strokeRoundedDashboardSquare01,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('Overview Content', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 1,
                    text: 'Details',
                    icon: HugeIcons.strokeRoundedInformationCircle,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('Details Content', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 2,
                    text: 'History',
                    icon: HugeIcons.strokeRoundedClock01,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text('History Content', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                ],
                selectedColor: context.theme.primary,
                unselectedColor: context.colors.onSurfaceVariant,
                indicatorColor: context.theme.primary,
                indicatorWidth: 3,
                borderColor: context.colors.outlineVariant,
                tabPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                wrap: true,
              ),
            ),
            code: '''TTabs<int>(
  tabs: [
    TTab(value: 0, text: 'Overview', icon: HugeIcons.strokeRoundedDashboardSquare01),
    TTab(value: 1, text: 'Details', icon: HugeIcons.strokeRoundedInformationCircle),
    TTab(value: 2, text: 'History', icon: HugeIcons.strokeRoundedClock01),
  ],
  selectedValue: _selectedTab,
  onTabChanged: (value) => setState(() => _selectedTab = value),
  selectedColor: AppColors.primary,
  unselectedColor: Colors.grey,
  indicatorColor: AppColors.primary,
  indicatorWidth: 3,
  borderColor: Colors.grey.shade300,
  tabPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
)''',
            properties: const [
              PropertyDoc(name: 'selectedColor', type: 'Color?', description: 'Color for selected tab text and icon'),
              PropertyDoc(name: 'unselectedColor', type: 'Color?', description: 'Color for unselected tab text and icon'),
              PropertyDoc(name: 'indicatorColor', type: 'Color?', description: 'Color for the selection indicator'),
              PropertyDoc(name: 'indicatorWidth', type: 'double?', defaultValue: '1', description: 'Width of the selection indicator'),
              PropertyDoc(name: 'borderColor', type: 'Color?', description: 'Border color for the tab bar'),
              PropertyDoc(
                name: 'tabPadding',
                type: 'EdgeInsets?',
                defaultValue: 'EdgeInsets.symmetric(vertical: 5, horizontal: 16)',
                description: 'Padding for each tab',
              ),
            ],
          ),

          // TTabView Example
          WidgetDocCard(
            title: 'Tab View (Simple Pattern)',
            description: 'Combined tabs and content using TTabView',
            icon: HugeIcons.strokeRoundedViewOff,
            preview: SizedBox(
              height: 300,
              child: TTabView<int>(
                initialValue: 0,
                tabs: [
                  TTab(
                    value: 0,
                    text: 'Home',
                    icon: HugeIcons.strokeRoundedHome01,
                    content: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: context.theme.primary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          TIcon.raw(HugeIcons.strokeRoundedHome01, color: context.theme.primary, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Home Content - This is the home page with all your recent activity',
                              style: TextStyle(color: context.colors.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TTab(
                    value: 1,
                    text: 'Profile',
                    icon: HugeIcons.strokeRoundedUser,
                    content: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: context.theme.success.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          TIcon.raw(HugeIcons.strokeRoundedUser, color: context.theme.success, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Profile Content - View and edit your profile information',
                              style: TextStyle(color: context.colors.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TTab(
                    value: 2,
                    text: 'Settings',
                    icon: HugeIcons.strokeRoundedSettings01,
                    content: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: context.theme.info.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          TIcon.raw(HugeIcons.strokeRoundedSettings01, color: context.theme.info, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Settings Content - Manage your preferences and account settings',
                              style: TextStyle(color: context.colors.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            code: '''TTabView<int>(
  initialValue: 0,
  tabs: [
    TTab(
      value: 0,
      text: 'Home',
      icon: HugeIcons.strokeRoundedHome01,
      content: (context) => HomePage(),
    ),
    TTab(
      value: 1,
      text: 'Profile',
      icon: HugeIcons.strokeRoundedUser,
      content: (context) => ProfilePage(),
    ),
    TTab(
      value: 2,
      text: 'Settings',
      icon: HugeIcons.strokeRoundedSettings01,
      content: (context) => SettingsPage(),
    ),
  ],
)''',
            properties: const [
              PropertyDoc(name: 'tabs', type: 'List<TTab<T>>', description: 'List of tabs with content builders'),
              PropertyDoc(name: 'initialValue', type: 'T?', description: 'Initial selected tab value'),
              PropertyDoc(name: 'controller', type: 'TTabController<T>?', description: 'Optional controller for managing tab state'),
            ],
          ),

          // Separated Tabs and Content Example
          WidgetDocCard(
            title: 'Separated Tabs and Content',
            description: 'Tabs and content in different locations using TTabController',
            icon: HugeIcons.strokeRoundedLayoutLeft,
            preview: SizedBox(
              height: 350,
              child: Column(
                children: [
                  // Tabs at top
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                    child: TTabs<int>(
                      controller: _separatedController,
                      tabs: [
                        TTab(value: 0, text: 'Dashboard', icon: HugeIcons.strokeRoundedDashboardSquare01),
                        TTab(value: 1, text: 'Analytics', icon: HugeIcons.strokeRoundedAnalytics01),
                        TTab(value: 2, text: 'Reports', icon: HugeIcons.strokeRoundedAnalytics02),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Content below
                  Expanded(
                    child: TTabContent<int>(
                      controller: _separatedController,
                      tabs: [
                        TTab(
                          value: 0,
                          text: 'Dashboard',
                          content: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: context.theme.primary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TIcon.raw(HugeIcons.strokeRoundedDashboardSquare01, color: context.theme.primary, size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  'Dashboard',
                                  style: TextStyle(color: context.colors.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'View your main dashboard with key metrics and insights',
                                  style: TextStyle(color: context.colors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                        TTab(
                          value: 1,
                          text: 'Analytics',
                          content: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: context.theme.info.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TIcon.raw(HugeIcons.strokeRoundedAnalytics01, color: context.theme.info, size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  'Analytics',
                                  style: TextStyle(color: context.colors.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Analyze your data with detailed charts and statistics',
                                  style: TextStyle(color: context.colors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                        TTab(
                          value: 2,
                          text: 'Reports',
                          content: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: context.theme.warning.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TIcon.raw(HugeIcons.strokeRoundedAnalytics02, color: context.theme.warning, size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  'Reports',
                                  style: TextStyle(color: context.colors.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Text('Generate and view comprehensive reports', style: TextStyle(color: context.colors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            code: '''// Create controller
final controller = TTabController<int>(initialValue: 0);

// Tabs (e.g., in AppBar)
TTabs(
  controller: controller,
  tabs: [
    TTab(value: 0, text: 'Dashboard', icon: HugeIcons.strokeRoundedDashboardSquare01),
    TTab(value: 1, text: 'Analytics', icon: HugeIcons.strokeRoundedAnalytics01),
    TTab(value: 2, text: 'Reports', icon: HugeIcons.strokeRoundedAnalytics02),
  ],
)

// Content (e.g., in body)
TTabContent(
  controller: controller,
  tabs: [
    TTab(value: 0, content: (context) => DashboardPage()),
    TTab(value: 1, content: (context) => AnalyticsPage()),
    TTab(value: 2, content: (context) => ReportsPage()),
  ],
)''',
            properties: const [
              PropertyDoc(
                name: 'controller',
                type: 'TTabController<T>',
                description: 'Shared controller for synchronizing tabs and content',
              ),
              PropertyDoc(name: 'tabs', type: 'List<TTab<T>>', description: 'List of tabs with content builders'),
            ],
          ),

          // Segmented Tabs
          WidgetDocCard(
            title: 'Segmented Tabs',
            description: 'Pill-in-a-track control for switching between a few views (e.g. Global / Node settings)',
            icon: HugeIcons.strokeRoundedViewAgenda,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TTabs<int>(
                  style: TTabStyle.segmented,
                  inline: true,
                  fill: true,
                  selectedValue: _segmentedTab,
                  onTabChanged: (v) => setState(() => _segmentedTab = v),
                  tabs: const [
                    TTab(value: 1, text: 'Global settings'),
                    TTab(value: 2, text: 'Node settings'),
                  ],
                ),
                const SizedBox(height: 16),
                // Content-sized, with icons and a count.
                TTabs<int>(
                  style: TTabStyle.segmented,
                  inline: true,
                  selectedValue: _segmentedTab,
                  onTabChanged: (v) => setState(() => _segmentedTab = v),
                  tabs: const [
                    TTab(value: 1, text: 'Global', icon: HugeIcons.strokeRoundedPolicy),
                    TTab(value: 2, text: 'Node', icon: HugeIcons.strokeRoundedShrub, count: 4),
                    TTab(value: 3, text: 'Archived', isEnabled: false),
                  ],
                ),
              ],
            ),
            code: '''int _tab = 1;

// Equal-width halves
TTabs<int>(
  style: TTabStyle.segmented,
  inline: true,
  fill: true,
  selectedValue: _tab,
  onTabChanged: (v) => setState(() => _tab = v),
  tabs: const [
    TTab(value: 1, text: 'Global settings'),
    TTab(value: 2, text: 'Node settings'),
  ],
)

// Content-sized (omit fill), with icons / counts
TTabs<int>(
  style: TTabStyle.segmented,
  inline: true,
  selectedValue: _tab,
  tabs: const [
    TTab(value: 1, text: 'Global', icon: HugeIcons.strokeRoundedPolicy),
    TTab(value: 2, text: 'Node', icon: HugeIcons.strokeRoundedShrub, count: 4),
  ],
)''',
            properties: const [
              PropertyDoc(name: 'style', type: 'TTabStyle', defaultValue: 'TTabStyle.underline', description: 'Use TTabStyle.segmented for the pill-in-a-track look (horizontal only)'),
              PropertyDoc(name: 'inline', type: 'bool', defaultValue: 'false', description: 'Required for segmented so the track hugs the tabs'),
              PropertyDoc(name: 'fill', type: 'bool', defaultValue: 'false', description: 'Share the width evenly between segments'),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
