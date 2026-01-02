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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text('Tabs', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.onSurface)),
          const SizedBox(height: 8),
          Text('Tab navigation components with multiple layout modes and customization options.',
              style: TextStyle(fontSize: 16, color: context.colors.onSurface.withAlpha(179))),
          const SizedBox(height: 32),

          // Basic Tabs
          WidgetDocCard(
            title: 'Basic Tabs',
            description: 'Simple horizontal tabs with text and icons',
            icon: Icons.tab,
            preview: SizedBox(
              height: 300,
              child: TTabView<int>(
                tabs: [
                  TTab(
                    value: 0,
                    text: 'Home',
                    icon: Icons.home,
                    content: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.primary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.home, color: AppColors.primary, size: 32),
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
    TTab(value: 0, text: 'Home', icon: Icons.home),
    TTab(value: 1, text: 'Profile', icon: Icons.person),
    TTab(value: 2, text: 'Settings', icon: Icons.settings),
  ],
  selectedValue: _selectedTab,
  onTabChanged: (value) => setState(() => _selectedTab = value),
)''',
            properties: const [
              PropertyDoc(
                name: 'tabs',
                type: 'List<TTab<T>>',
                description: 'List of tabs to display',
              ),
              PropertyDoc(
                name: 'selectedValue',
                type: 'T?',
                description: 'Currently selected tab value',
              ),
              PropertyDoc(
                name: 'onTabChanged',
                type: 'ValueChanged<T>?',
                description: 'Callback when tab is selected',
              ),
            ],
          ),

          // Scrollable Tabs
          WidgetDocCard(
            title: 'Scrollable Tabs',
            description: 'Tabs with horizontal scrolling and navigation buttons (desktop/web)',
            icon: Icons.swap_horiz,
            preview: SizedBox(
              height: 200,
              child: TTabView<int>(
                tabs: List.generate(
                  10,
                  (i) => TTab(
                    value: i,
                    text: 'Tab ${i + 1}',
                    icon: Icons.star,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.primary.withAlpha(26), AppColors.secondary.withAlpha(26)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: AppColors.primary),
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
    (i) => TTab(value: i, text: 'Tab \${i + 1}', icon: Icons.star),
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
            icon: Icons.swap_vert,
            preview: SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TTabs<int>(
                    controller: _verticalController,
                    tabs: [
                      TTab(value: 0, text: 'Dashboard', icon: Icons.dashboard),
                      TTab(value: 1, text: 'Analytics', icon: Icons.analytics),
                      TTab(value: 2, text: 'Reports', icon: Icons.assessment),
                      TTab(value: 3, text: 'Settings', icon: Icons.settings),
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
                          icon: Icons.dashboard,
                          content: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.dashboard, color: AppColors.primary, size: 32),
                                const SizedBox(height: 8),
                                Text('Dashboard Content',
                                    style: TextStyle(color: context.colors.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('View your main dashboard',
                                    style: TextStyle(color: context.colors.onSurface.withAlpha(179), fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        TTab(
                          value: 1,
                          text: 'Analytics',
                          icon: Icons.analytics,
                          content: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.info.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.analytics, color: AppColors.info, size: 32),
                                const SizedBox(height: 8),
                                Text('Analytics Content',
                                    style: TextStyle(color: context.colors.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Analyze your data', style: TextStyle(color: context.colors.onSurface.withAlpha(179), fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        TTab(
                          value: 2,
                          text: 'Reports',
                          icon: Icons.assessment,
                          content: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.assessment, color: AppColors.warning, size: 32),
                                const SizedBox(height: 8),
                                Text('Reports Content',
                                    style: TextStyle(color: context.colors.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Generate reports', style: TextStyle(color: context.colors.onSurface.withAlpha(179), fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        TTab(
                          value: 3,
                          text: 'Settings',
                          icon: Icons.settings,
                          content: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.settings, color: AppColors.success, size: 32),
                                const SizedBox(height: 8),
                                Text('Settings Content',
                                    style: TextStyle(color: context.colors.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Configure settings', style: TextStyle(color: context.colors.onSurface.withAlpha(179), fontSize: 13)),
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
    TTab(value: 0, text: 'Dashboard', icon: Icons.dashboard),
    TTab(value: 1, text: 'Analytics', icon: Icons.analytics),
    TTab(value: 2, text: 'Reports', icon: Icons.assessment),
    TTab(value: 3, text: 'Settings', icon: Icons.settings),
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
            icon: Icons.wrap_text,
            preview: SizedBox(
              height: 150,
              child: TTabView<String>(
                tabs: [
                  TTab(
                    value: 'all',
                    text: 'All Items',
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Showing deleted items', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                ],
                inline: true,
                wrap: true,
              ),
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
              PropertyDoc(
                name: 'inline',
                type: 'bool',
                defaultValue: 'false',
                description: 'Use inline layout instead of full-width',
              ),
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
            icon: Icons.brush,
            preview: SizedBox(
              height: 150,
              child: TTabView<int>(
                tabs: [
                  TTab(
                    value: 0,
                    text: 'Design',
                    icon: Icons.palette,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Design View', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 1,
                    text: 'Code',
                    icon: Icons.code,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Code View', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 2,
                    text: 'Preview',
                    icon: Icons.visibility,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Preview View', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                  TTab(
                    value: 3,
                    text: 'Preview 1',
                    icon: Icons.visibility,
                    content: (context) => Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Preview View', style: TextStyle(color: context.colors.onSurface)),
                      ),
                    ),
                  ),
                ],
                tabBuilder: (context, tab, isSelected) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primaryContainer : context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? context.colors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tab.icon != null) ...[
                          Icon(
                            tab.icon,
                            size: 18,
                            color: isSelected ? context.colors.onPrimaryContainer : context.colors.onSurface,
                          ),
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
                  );
                },
                wrap: true,
                inline: true,
              ),
            ),
            code: '''TTabs<int>(
  tabs: [
    TTab(value: 0, text: 'Design', icon: Icons.palette),
    TTab(value: 1, text: 'Code', icon: Icons.code),
    TTab(value: 2, text: 'Preview', icon: Icons.visibility),
  ],
  selectedValue: _selectedTab,
  onTabChanged: (value) => setState(() => _selectedTab = value),
  tabBuilder: (context, tab, isSelected) {
    return Container(
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
    );
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'tabBuilder',
                type: 'Widget Function(BuildContext, TTab<T>, bool)?',
                description: 'Custom builder for tab widgets. Receives context, tab, and isSelected state.',
              ),
            ],
          ),

          // Styled Tabs
          WidgetDocCard(
            title: 'Styled Tabs',
            description: 'Tabs with custom colors and styling',
            icon: Icons.color_lens,
            preview: SizedBox(
              height: 150,
              child: TTabView<int>(
                  tabs: [
                    TTab(
                      value: 0,
                      text: 'Overview',
                      icon: Icons.dashboard,
                      content: (context) => Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Overview Content', style: TextStyle(color: context.colors.onSurface)),
                        ),
                      ),
                    ),
                    TTab(
                      value: 1,
                      text: 'Details',
                      icon: Icons.info,
                      content: (context) => Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Details Content', style: TextStyle(color: context.colors.onSurface)),
                        ),
                      ),
                    ),
                    TTab(
                      value: 2,
                      text: 'History',
                      icon: Icons.history,
                      content: (context) => Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('History Content', style: TextStyle(color: context.colors.onSurface)),
                        ),
                      ),
                    ),
                  ],
                  selectedColor: AppColors.primary,
                  unselectedColor: context.colors.onSurfaceVariant,
                  indicatorColor: AppColors.primary,
                  indicatorWidth: 3,
                  borderColor: context.colors.outlineVariant,
                  tabPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  wrap: true),
            ),
            code: '''TTabs<int>(
  tabs: [
    TTab(value: 0, text: 'Overview', icon: Icons.dashboard),
    TTab(value: 1, text: 'Details', icon: Icons.info),
    TTab(value: 2, text: 'History', icon: Icons.history),
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
              PropertyDoc(
                name: 'selectedColor',
                type: 'Color?',
                description: 'Color for selected tab text and icon',
              ),
              PropertyDoc(
                name: 'unselectedColor',
                type: 'Color?',
                description: 'Color for unselected tab text and icon',
              ),
              PropertyDoc(
                name: 'indicatorColor',
                type: 'Color?',
                description: 'Color for the selection indicator',
              ),
              PropertyDoc(
                name: 'indicatorWidth',
                type: 'double?',
                defaultValue: '1',
                description: 'Width of the selection indicator',
              ),
              PropertyDoc(
                name: 'borderColor',
                type: 'Color?',
                description: 'Border color for the tab bar',
              ),
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
            icon: Icons.view_column,
            preview: SizedBox(
              height: 300,
              child: TTabView<int>(
                initialValue: 0,
                tabs: [
                  TTab(
                    value: 0,
                    text: 'Home',
                    icon: Icons.home,
                    content: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.primary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.home, color: AppColors.primary, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Home Content - This is the home page with all your recent activity',
                                style: TextStyle(color: context.colors.onSurface)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TTab(
                    value: 1,
                    text: 'Profile',
                    icon: Icons.person,
                    content: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.success.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: AppColors.success, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Profile Content - View and edit your profile information',
                                style: TextStyle(color: context.colors.onSurface)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TTab(
                    value: 2,
                    text: 'Settings',
                    icon: Icons.settings,
                    content: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.info.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.settings, color: AppColors.info, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Settings Content - Manage your preferences and account settings',
                                style: TextStyle(color: context.colors.onSurface)),
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
      icon: Icons.home,
      content: (context) => HomePage(),
    ),
    TTab(
      value: 1,
      text: 'Profile',
      icon: Icons.person,
      content: (context) => ProfilePage(),
    ),
    TTab(
      value: 2,
      text: 'Settings',
      icon: Icons.settings,
      content: (context) => SettingsPage(),
    ),
  ],
)''',
            properties: const [
              PropertyDoc(
                name: 'tabs',
                type: 'List<TTab<T>>',
                description: 'List of tabs with content builders',
              ),
              PropertyDoc(
                name: 'initialValue',
                type: 'T?',
                description: 'Initial selected tab value',
              ),
              PropertyDoc(
                name: 'controller',
                type: 'TTabController<T>?',
                description: 'Optional controller for managing tab state',
              ),
            ],
          ),

          // Separated Tabs and Content Example
          WidgetDocCard(
            title: 'Separated Tabs and Content',
            description: 'Tabs and content in different locations using TTabController',
            icon: Icons.splitscreen,
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
                        TTab(value: 0, text: 'Dashboard', icon: Icons.dashboard),
                        TTab(value: 1, text: 'Analytics', icon: Icons.analytics),
                        TTab(value: 2, text: 'Reports', icon: Icons.assessment),
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
                            decoration: BoxDecoration(color: AppColors.primary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.dashboard, color: AppColors.primary, size: 40),
                                const SizedBox(height: 12),
                                Text('Dashboard',
                                    style: TextStyle(color: context.colors.onSurface, fontSize: 18, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(
                                  'View your main dashboard with key metrics and insights',
                                  style: TextStyle(color: context.colors.onSurface.withAlpha(179)),
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
                            decoration: BoxDecoration(
                              color: AppColors.info.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.analytics, color: AppColors.info, size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  'Analytics',
                                  style: TextStyle(
                                    color: context.colors.onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Analyze your data with detailed charts and statistics',
                                  style: TextStyle(color: context.colors.onSurface.withAlpha(179)),
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
                            decoration: BoxDecoration(color: AppColors.warning.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.assessment, color: AppColors.warning, size: 40),
                                const SizedBox(height: 12),
                                Text('Reports',
                                    style: TextStyle(color: context.colors.onSurface, fontSize: 18, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text('Generate and view comprehensive reports',
                                    style: TextStyle(color: context.colors.onSurface.withAlpha(179))),
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
    TTab(value: 0, text: 'Dashboard', icon: Icons.dashboard),
    TTab(value: 1, text: 'Analytics', icon: Icons.analytics),
    TTab(value: 2, text: 'Reports', icon: Icons.assessment),
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
              PropertyDoc(
                name: 'tabs',
                type: 'List<TTab<T>>',
                description: 'List of tabs with content builders',
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
