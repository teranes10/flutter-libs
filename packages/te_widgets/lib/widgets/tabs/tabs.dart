import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'tab_renderer.dart';
import 'tab_scroll_manager.dart';

/// A tab navigation component with indicator.
///
/// `TTabs` provides tab navigation with:
/// - Icon and/or text tabs
/// - Active indicator line
/// - Disabled state support
/// - Inline or full-width layout
/// - Horizontal or vertical orientation
/// - Scrollable mode with navigation controls
/// - Wrap mode for multi-line layout
/// - Custom tab builder support
/// - Custom colors
///
/// ## Basic Usage
///
/// ```dart
/// TTabs<int>(
///   tabs: [
///     TTab(value: 0, text: 'Home', icon: Icons.home),
///     TTab(value: 1, text: 'Profile', icon: Icons.person),
///     TTab(value: 2, text: 'Settings', icon: Icons.settings),
///   ],
///   selectedValue: currentTab,
///   onTabChanged: (value) => setState(() => currentTab = value),
/// )
/// ```
///
/// ## Scrollable Tabs with Navigation
///
/// ```dart
/// TTabs<int>(
///   tabs: manyTabs,
///   selectedValue: currentTab,
///   onTabChanged: (value) => setState(() => currentTab = value),
///   scrollable: true,
///   showNavigationButtons: true,
/// )
/// ```
///
/// ## Vertical Tabs
///
/// ```dart
/// TTabs<String>(
///   tabs: tabs,
///   selectedValue: selectedTab,
///   onTabChanged: (value) => loadData(value),
///   axis: Axis.vertical,
/// )
/// ```
///
/// ## Wrap Mode
///
/// ```dart
/// TTabs<String>(
///   tabs: tabs,
///   selectedValue: selectedTab,
///   onTabChanged: (value) => loadData(value),
///   inline: true,
///   wrap: true,
/// )
/// ```
///
/// ## Custom Tab Builder
///
/// ```dart
/// TTabs<String>(
///   tabs: tabs,
///   selectedValue: selectedTab,
///   onTabChanged: (value) => loadData(value),
///   tabBuilder: (context, tab, isSelected) {
///     return CustomTabWidget(tab: tab, isSelected: isSelected);
///   },
/// )
/// ```
///
/// Type parameter:
/// - [T]: The type of tab values
///
/// See also:
/// - [TTab] for tab configuration
class TTabs<T> extends StatefulWidget {
  /// The list of tabs to display.
  final List<TTab<T>> tabs;

  /// Optional controller for managing tab state.
  ///
  /// When provided, the controller's value is used instead of [selectedValue],
  /// and tab changes update the controller instead of calling [onTabChanged].
  /// This allows sharing state between [TTabs] and [TTabContent] widgets.
  final TTabController<T>? controller;

  /// The currently selected tab value.
  ///
  /// Ignored if [controller] is provided.
  final T? selectedValue;

  /// Callback fired when a tab is selected.
  ///
  /// Ignored if [controller] is provided.
  final ValueChanged<T>? onTabChanged;

  /// Border color for the tab bar.
  final Color? borderColor;

  /// Color for the selected tab.
  final Color? selectedColor;

  /// Color for unselected tabs.
  final Color? unselectedColor;

  /// Color for disabled tabs.
  final Color? disabledColor;

  /// Color for the selection indicator.
  final Color? indicatorColor;

  /// Padding for each tab.
  final EdgeInsets? tabPadding;

  /// Spacing for each tab
  final double tabSpacing;
  final double tabRunSpacing;

  /// Width of the selection indicator.
  final double? indicatorWidth;

  /// Whether to use inline layout instead of full-width.
  final bool inline;

  /// The axis along which the tabs are laid out.
  final Axis axis;

  /// Whether tabs should be scrollable.
  /// When true, tabs can be scrolled with swipe gestures and navigation buttons.
  final bool scrollable;

  /// Whether to show navigation buttons in scrollable mode.
  /// Only shown on desktop/web platforms.
  final bool showNavigationButtons;

  /// Whether to wrap tabs into multiple lines when using inline mode.
  /// Mutually exclusive with scrollable mode.
  final bool wrap;

  /// Custom builder for tab widgets.
  /// When provided, this builder is used instead of the default tab rendering.
  /// Receives the tab, whether it's selected, and should return a widget.
  final Widget Function(BuildContext context, TTab<T> tab, bool isSelected)? tabBuilder;

  /// Color for navigation buttons.
  final Color? navigationButtonColor;

  /// Background color for navigation buttons.
  final Color? navigationButtonBackgroundColor;

  /// Creates a tabs component.
  const TTabs({
    super.key,
    required this.tabs,
    this.controller,
    this.selectedValue,
    this.onTabChanged,
    this.borderColor,
    this.selectedColor,
    this.unselectedColor,
    this.disabledColor,
    this.indicatorColor,
    this.tabPadding,
    this.tabSpacing = 2,
    this.tabRunSpacing = 2,
    this.indicatorWidth = 1,
    this.inline = false,
    this.axis = Axis.horizontal,
    this.scrollable = false,
    this.showNavigationButtons = true,
    this.wrap = false,
    this.tabBuilder,
    this.navigationButtonColor,
    this.navigationButtonBackgroundColor,
  }) : assert(!wrap || !scrollable, 'Wrap and scrollable modes are mutually exclusive');

  @override
  State<TTabs<T>> createState() => _TTabsState<T>();
}

class _TTabsState<T> extends State<TTabs<T>> {
  late ScrollController _scrollController;
  late TabScrollManager _scrollManager;
  bool _canScrollStart = false;
  bool _canScrollEnd = false;
  final Map<T, GlobalKey> _tabKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollState);

    _scrollManager = TabScrollManager(
      scrollController: _scrollController,
      axis: widget.axis,
      tabKeys: _tabKeys,
    );

    // Initialize keys for each tab
    for (final tab in widget.tabs) {
      _tabKeys[tab.value] = GlobalKey();
    }

    // Update scroll state after initial layout
    if (widget.scrollable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScrollState();
      });
    }

    // Listen to controller if provided
    widget.controller?.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChange);
    _scrollController.removeListener(_updateScrollState);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TTabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Debug logging for Basic Tabs
    if (widget.tabs.isNotEmpty && widget.tabs.first.text == 'Home') {
      print('TTabs [Basic]: didUpdateWidget called');
      print('  oldWidget.selectedValue: ${oldWidget.selectedValue}');
      print('  widget.selectedValue: ${widget.selectedValue}');
      print('  controller: ${widget.controller}');
    }

    // Update keys if tabs changed
    if (oldWidget.tabs != widget.tabs) {
      _tabKeys.clear();
      for (final tab in widget.tabs) {
        _tabKeys[tab.value] = GlobalKey();
      }
    }

    // Scroll to selected tab if it changed
    if (oldWidget.selectedValue != widget.selectedValue && widget.selectedValue != null) {
      if (widget.tabs.isNotEmpty && widget.tabs.first.text == 'Home') {
        print('TTabs [Basic]: selectedValue changed, will scroll');
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedTab();
      });
    }

    // Update scroll state after layout
    if (widget.scrollable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScrollState();
      });
    }

    // Update controller listener
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      widget.controller?.addListener(_handleControllerChange);
    }
  }

  void _handleControllerChange() {
    setState(() {
      // Rebuild to reflect new selection
    });

    // Scroll to new selection if needed
    if (widget.scrollable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedTab();
      });
    }
  }

  void _updateScrollState() {
    if (!mounted) return;

    setState(() {
      _canScrollStart = _scrollManager.canScrollStart();
      _canScrollEnd = _scrollManager.canScrollEnd();
    });
  }

  void _scrollToSelectedTab() {
    final selectedValue = widget.controller?.value ?? widget.selectedValue;
    if (!widget.scrollable || selectedValue == null) return;
    _scrollManager.scrollToTab(selectedValue);
  }

  void _scrollToStart() {
    _scrollManager.scrollToStart();
  }

  void _scrollToEnd() {
    _scrollManager.scrollToEnd();
  }

  void _onSelectTab(TTab<T> tab) {
    widget.controller?.selectTab(tab.value);
    widget.onTabChanged?.call(tab.value);
  }

  Widget _buildTab(BuildContext context, TTab<T> tab, ColorScheme colors) {
    final selectedValue = widget.controller?.value ?? widget.selectedValue;
    final isSelected = selectedValue == tab.value;

    final tabWidget = widget.tabBuilder != null
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              key: _tabKeys[tab.value],
              onTap: tab.isEnabled ? () => _onSelectTab(tab) : null,
              child: widget.tabBuilder!(context, tab, isSelected),
            ),
          )
        : TabRenderer.buildDefaultTab<T>(
            context: context,
            tab: tab,
            isSelected: isSelected,
            colors: colors,
            tabKey: _tabKeys[tab.value]!,
            axis: widget.axis,
            tabPadding: widget.tabPadding,
            indicatorWidth: widget.indicatorWidth,
            selectedColor: widget.selectedColor,
            unselectedColor: widget.unselectedColor,
            disabledColor: widget.disabledColor,
            indicatorColor: widget.indicatorColor,
            controller: widget.controller,
            onTab: tab.isEnabled ? () => _onSelectTab(tab) : null,
          );

    if (widget.inline || widget.scrollable || widget.wrap) {
      return tabWidget;
    } else {
      return Expanded(child: tabWidget);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final defaultBorderColor = widget.borderColor ?? Colors.transparent;
    final defaultNavButtonColor = widget.navigationButtonColor ?? colors.onSurface;
    final defaultNavButtonBgColor = widget.navigationButtonBackgroundColor ?? colors.surface.withOpacity(0.9);

    final tabWidgets = widget.tabs.map((tab) => _buildTab(context, tab, colors)).toList();

    Widget tabsContent;

    if (widget.scrollable) {
      // Scrollable mode
      final scrollView = SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: widget.axis,
        child: widget.axis == Axis.horizontal
            ? Row(spacing: widget.tabSpacing, children: tabWidgets)
            : Column(spacing: widget.tabSpacing, children: tabWidgets),
      );

      // Add navigation buttons for desktop/web
      final showNavButtons = widget.showNavigationButtons &&
          (Theme.of(context).platform == TargetPlatform.macOS ||
              Theme.of(context).platform == TargetPlatform.windows ||
              Theme.of(context).platform == TargetPlatform.linux);

      if (showNavButtons) {
        tabsContent = widget.axis == Axis.horizontal
            ? Row(
                children: [
                  if (_canScrollStart)
                    _NavigationButton(
                      icon: Icons.chevron_left,
                      onPressed: _scrollToStart,
                      color: defaultNavButtonColor,
                      backgroundColor: defaultNavButtonBgColor,
                    ),
                  Expanded(child: scrollView),
                  if (_canScrollEnd)
                    _NavigationButton(
                      icon: Icons.chevron_right,
                      onPressed: _scrollToEnd,
                      color: defaultNavButtonColor,
                      backgroundColor: defaultNavButtonBgColor,
                    ),
                ],
              )
            : Column(
                children: [
                  if (_canScrollStart)
                    _NavigationButton(
                      icon: Icons.keyboard_arrow_up,
                      onPressed: _scrollToStart,
                      color: defaultNavButtonColor,
                      backgroundColor: defaultNavButtonBgColor,
                    ),
                  Expanded(child: scrollView),
                  if (_canScrollEnd)
                    _NavigationButton(
                      icon: Icons.keyboard_arrow_down,
                      onPressed: _scrollToEnd,
                      color: defaultNavButtonColor,
                      backgroundColor: defaultNavButtonBgColor,
                    ),
                ],
              );
      } else {
        tabsContent = scrollView;
      }
    } else if (widget.wrap && widget.inline) {
      // Wrap mode
      tabsContent = Wrap(
        direction: widget.axis,
        spacing: widget.tabSpacing,
        runSpacing: widget.tabRunSpacing,
        children: tabWidgets,
      );
    } else if (widget.inline) {
      // Inline mode
      tabsContent = widget.axis == Axis.horizontal
          ? Row(mainAxisSize: MainAxisSize.min, spacing: widget.tabSpacing, children: tabWidgets)
          : Column(mainAxisSize: MainAxisSize.min, spacing: widget.tabSpacing, children: tabWidgets);
    } else {
      // Full-width mode
      tabsContent = widget.axis == Axis.horizontal
          ? Row(spacing: widget.tabSpacing, children: tabWidgets)
          : IntrinsicHeight(child: Column(spacing: widget.tabSpacing, children: tabWidgets));
    }

    final border = widget.axis == Axis.horizontal
        ? Border(bottom: BorderSide(color: defaultBorderColor))
        : Border(right: BorderSide(color: defaultBorderColor));

    return Container(
      decoration: BoxDecoration(border: border),
      child: tabsContent,
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color backgroundColor;

  const _NavigationButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: color,
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}
