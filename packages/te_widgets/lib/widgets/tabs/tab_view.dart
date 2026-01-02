import 'package:flutter/material.dart';
import 'tab.dart';
import 'tab_controller.dart';
import 'tab_content.dart';
import 'tabs.dart';

/// A convenience widget that combines [TTabs] and [TTabContent] vertically.
///
/// Automatically creates and manages a [TTabController] if one isn't provided.
/// Useful for simple tab+content layouts where tabs are above the content.
///
/// Example:
/// ```dart
/// TTabView<int>(
///   initialValue: 0,
///   tabs: [
///     TTab(
///       value: 0,
///       text: 'Tab 1',
///       content: (context) => Page1(),
///     ),
///     TTab(
///       value: 1,
///       text: 'Tab 2',
///       content: (context) => Page2(),
///     ),
///   ],
/// )
/// ```
class TTabView<T> extends StatefulWidget {
  /// The list of tabs with their content builders.
  final List<TTab<T>> tabs;

  /// Optional controller for managing tab state.
  ///
  /// If not provided, a controller will be created automatically.
  final TTabController<T>? controller;

  /// Initial selected value when controller is not provided.
  final T? initialValue;

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

  /// Width of the selection indicator.
  final double? indicatorWidth;

  /// Whether to use inline layout instead of full-width.
  final bool inline;

  /// The axis along which the tabs are laid out.
  final Axis axis;

  /// Whether tabs should be scrollable.
  final bool scrollable;

  /// Whether to show navigation buttons in scrollable mode.
  final bool showNavigationButtons;

  /// Whether to wrap tabs into multiple lines when using inline mode.
  final bool wrap;

  /// Custom builder for tab widgets.
  final Widget Function(BuildContext context, TTab<T> tab, bool isSelected)? tabBuilder;

  /// Color for navigation buttons.
  final Color? navigationButtonColor;

  /// Background color for navigation buttons.
  final Color? navigationButtonBackgroundColor;

  /// Creates a tab view widget.
  const TTabView({
    super.key,
    required this.tabs,
    this.controller,
    this.initialValue,
    this.borderColor,
    this.selectedColor,
    this.unselectedColor,
    this.disabledColor,
    this.indicatorColor,
    this.tabPadding,
    this.indicatorWidth,
    this.inline = false,
    this.axis = Axis.horizontal,
    this.scrollable = false,
    this.showNavigationButtons = true,
    this.wrap = false,
    this.tabBuilder,
    this.navigationButtonColor,
    this.navigationButtonBackgroundColor,
  });

  @override
  State<TTabView<T>> createState() => _TTabViewState<T>();
}

class _TTabViewState<T> extends State<TTabView<T>> {
  late TTabController<T> _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = TTabController<T>(initialValue: widget.initialValue);
      _isInternalController = true;
    }
  }

  @override
  void didUpdateWidget(TTabView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_isInternalController) {
        _controller.dispose();
      }
      if (widget.controller != null) {
        _controller = widget.controller!;
        _isInternalController = false;
      } else {
        _controller = TTabController<T>(initialValue: widget.initialValue);
        _isInternalController = true;
      }
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TTabs<T>(
          controller: _controller,
          tabs: widget.tabs,
          borderColor: widget.borderColor,
          selectedColor: widget.selectedColor,
          unselectedColor: widget.unselectedColor,
          disabledColor: widget.disabledColor,
          indicatorColor: widget.indicatorColor,
          tabPadding: widget.tabPadding,
          indicatorWidth: widget.indicatorWidth,
          inline: widget.inline,
          axis: widget.axis,
          scrollable: widget.scrollable,
          showNavigationButtons: widget.showNavigationButtons,
          wrap: widget.wrap,
          tabBuilder: widget.tabBuilder,
          navigationButtonColor: widget.navigationButtonColor,
          navigationButtonBackgroundColor: widget.navigationButtonBackgroundColor,
        ),
        Expanded(
          child: TTabContent<T>(
            controller: _controller,
            tabs: widget.tabs,
          ),
        ),
      ],
    );
  }
}
