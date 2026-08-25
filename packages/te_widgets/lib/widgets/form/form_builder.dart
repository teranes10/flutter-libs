import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:te_widgets/te_widgets.dart';

part 'field_prop.dart';
part 'form_field.dart';
part 'form_builder_config.dart';
part 'form_tab.dart';
part 'form_type.dart';

/// A responsive form builder with grid and tab layouts.
///
/// `TFormBuilder` provides automatic form layout with:
/// - 12-column responsive grid system
/// - Automatic field sizing based on breakpoints
/// - Integration with TFormBase
/// - Nested form support (accordion, horizontal tabs, vertical tabs)
///
/// ## Basic Usage
///
/// ```dart
/// class UserForm extends TFormBase {
///   final name = TFieldProp<String>('');
///   final email = TFieldProp<String>('');
///
///   @override
///   List<TFormField> get fields => [
///     TFormField.text(name, 'Name').size(6),
///     TFormField.text(email, 'Email').size(6),
///   ];
/// }
///
/// TFormBuilder(input: UserForm())
/// ```
///
/// ## Tabbed Sub-forms Usage
///
/// ```dart
/// TFormBuilder.horizontalTabs(
///   tabs: [
///     TFormTab(title: 'Account', icon: Icons.person, input: accountForm),
///     TFormTab(title: 'Settings', icon: Icons.settings, input: settingsForm),
///   ],
/// )
/// ```
///
/// See also:
/// - [TFormField] for field creation
/// - [TFormBase] for form models
/// - [TFormTab] for tab configurations
/// - [TTabs] for tab navigation
class TFormBuilder extends StatefulWidget {
  /// The form model to build.
  final TFormBase? input;

  /// Manual list of fields (alternative to input or tabs).
  final List<TFormField>? fields;

  /// List of tab configurations for sub forms.
  final List<TFormTab>? tabs;

  /// Layout type for forms with sub forms (accordion, horizontal tabs, vertical tabs).
  final TFormType? formType;

  /// Layout axis for tabs (horizontal or vertical).
  final Axis tabAxis;

  /// Optional controller for managing tab selection.
  final TTabController<dynamic>? tabController;

  /// Initial selected tab value when [tabController] is not provided.
  final dynamic initialTabValue;

  /// Callback fired when the selected tab changes.
  final ValueChanged<dynamic>? onTabChanged;

  /// Width of vertical tabs column.
  final double? tabWidth;

  /// Whether tabs should be scrollable.
  final bool scrollableTabs;

  /// Whether to show navigation arrows for scrollable tabs.
  final bool showTabNavigationButtons;

  /// Whether tabs use inline mode instead of full width.
  final bool tabInline;

  /// Whether tabs wrap onto multiple lines in inline mode.
  final bool tabWrap;

  /// Padding for each tab item.
  final EdgeInsets? tabPadding;

  /// Spacing between tab items.
  final double tabSpacing;

  /// Width/thickness of the tab selection indicator.
  final double? tabIndicatorWidth;

  /// Color for the selected tab text/icon.
  final Color? tabSelectedColor;

  /// Color for unselected tabs.
  final Color? tabUnselectedColor;

  /// Color for the tab selection indicator.
  final Color? tabIndicatorColor;

  /// Border color for the tab bar.
  final Color? tabBorderColor;

  /// Custom builder for tab items.
  final Widget Function(BuildContext, TTab<dynamic>, bool, VoidCallback?)? tabBuilder;

  /// Horizontal spacing between fields.
  final double gapX;

  /// Vertical spacing between fields.
  final double gapY;

  /// Callback fired when any field value changes.
  final VoidCallback? onValueChanged;

  final IconData? icon;

  /// Optional title for the form (renders inside an accordion when provided).
  final String? label;

  /// Optional subtitle for the form.
  final String? description;

  final bool initiallyExpanded;

  /// Optional footer widget displayed below the form fields.
  final Widget? footer;

  /// Creates a form builder.
  const TFormBuilder({
    super.key,
    this.input,
    this.fields,
    this.tabs,
    this.formType,
    this.tabAxis = Axis.horizontal,
    this.tabController,
    this.initialTabValue,
    this.onTabChanged,
    this.tabWidth,
    this.scrollableTabs = false,
    this.showTabNavigationButtons = true,
    this.tabInline = false,
    this.tabWrap = false,
    this.tabPadding,
    this.tabSpacing = 2,
    this.tabIndicatorWidth,
    this.tabSelectedColor,
    this.tabUnselectedColor,
    this.tabIndicatorColor,
    this.tabBorderColor,
    this.tabBuilder,
    this.gapX = 16.0,
    this.gapY = 26.0,
    this.onValueChanged,
    this.icon,
    this.label,
    this.description,
    this.initiallyExpanded = false,
    this.footer,
  }) : assert(
         (input != null ? 1 : 0) + (fields != null ? 1 : 0) + (tabs != null ? 1 : 0) == 1,
         'Provide exactly one of "input", "fields", or "tabs".',
       );

  /// Creates a form builder with tabs.
  const TFormBuilder.tabs({
    super.key,
    required List<TFormTab> this.tabs,
    this.formType,
    this.tabAxis = Axis.horizontal,
    this.tabController,
    this.initialTabValue,
    this.onTabChanged,
    this.tabWidth,
    this.scrollableTabs = false,
    this.showTabNavigationButtons = true,
    this.tabInline = false,
    this.tabWrap = false,
    this.tabPadding,
    this.tabSpacing = 2,
    this.tabIndicatorWidth,
    this.tabSelectedColor,
    this.tabUnselectedColor,
    this.tabIndicatorColor,
    this.tabBorderColor,
    this.tabBuilder,
    this.gapX = 16.0,
    this.gapY = 26.0,
    this.onValueChanged,
    this.icon,
    this.label,
    this.description,
    this.initiallyExpanded = false,
    this.footer,
  }) : input = null,
       fields = null;

  /// Creates a form builder with horizontal tabs.
  const TFormBuilder.horizontalTabs({
    super.key,
    required List<TFormTab> this.tabs,
    this.formType,
    this.tabController,
    this.initialTabValue,
    this.onTabChanged,
    this.scrollableTabs = false,
    this.showTabNavigationButtons = true,
    this.tabInline = false,
    this.tabWrap = false,
    this.tabPadding,
    this.tabSpacing = 2,
    this.tabIndicatorWidth,
    this.tabSelectedColor,
    this.tabUnselectedColor,
    this.tabIndicatorColor,
    this.tabBorderColor,
    this.tabBuilder,
    this.gapX = 16.0,
    this.gapY = 26.0,
    this.onValueChanged,
    this.icon,
    this.label,
    this.description,
    this.initiallyExpanded = false,
    this.footer,
  }) : input = null,
       fields = null,
       tabAxis = Axis.horizontal,
       tabWidth = null;

  /// Creates a form builder with vertical tabs.
  const TFormBuilder.verticalTabs({
    super.key,
    required List<TFormTab> this.tabs,
    this.formType,
    this.tabController,
    this.initialTabValue,
    this.onTabChanged,
    this.tabWidth,
    this.scrollableTabs = false,
    this.showTabNavigationButtons = true,
    this.tabPadding,
    this.tabSpacing = 2,
    this.tabIndicatorWidth,
    this.tabSelectedColor,
    this.tabUnselectedColor,
    this.tabIndicatorColor,
    this.tabBorderColor,
    this.tabBuilder,
    this.gapX = 16.0,
    this.gapY = 26.0,
    this.onValueChanged,
    this.icon,
    this.label,
    this.description,
    this.initiallyExpanded = false,
    this.footer,
  }) : input = null,
       fields = null,
       tabAxis = Axis.vertical,
       tabInline = false,
       tabWrap = false;

  @override
  State<TFormBuilder> createState() => _TFormBuilderState();
}

class _TFormBuilderState extends State<TFormBuilder> {
  late TTabController<dynamic> _tabController;
  bool _isInternalTabController = false;

  @override
  void initState() {
    super.initState();
    _initTabController();
  }

  void _initTabController() {
    final effectiveTabs = widget.tabs ?? widget.input?.tabs;
    if (widget.tabController != null) {
      _tabController = widget.tabController!;
      _isInternalTabController = false;
    } else if (effectiveTabs != null && effectiveTabs.isNotEmpty) {
      final initialVal = widget.initialTabValue ?? effectiveTabs.first.value ?? effectiveTabs.first.title;
      _tabController = TTabController<dynamic>(initialValue: initialVal);
      _isInternalTabController = true;
    } else {
      _tabController = TTabController<dynamic>();
      _isInternalTabController = true;
    }
    _tabController.addListener(_onTabControllerChanged);
  }

  void _onTabControllerChanged() {
    widget.onTabChanged?.call(_tabController.value);
  }

  @override
  void didUpdateWidget(TFormBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabController != oldWidget.tabController) {
      oldWidget.tabController?.removeListener(_onTabControllerChanged);
      if (_isInternalTabController) {
        _tabController.dispose();
      }
      _initTabController();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabControllerChanged);
    if (_isInternalTabController) {
      _tabController.dispose();
    }
    super.dispose();
  }

  /// Builds the column widgets for [fieldList], attaching value-change listeners.
  List<Widget> _buildFieldCols(List<TFormField> fieldList, [TFormBase? formInput]) {
    return fieldList.map((field) {
      field._attach(() {
        widget.onValueChanged?.call();
        (formInput ?? widget.input)?.onValueChanged();
      });

      return TGridCol(
        sm: field._size.sm,
        md: field._size.md,
        lg: field._size.lg,
        child: field._field,
      );
    }).toList();
  }

  Widget _buildSingleFormContent({
    TFormBase? formInput,
    required List<TFormField> formFields,
    List<TFormField>? formSidebarFields,
    TGridSize formSidebarSize = const TGridSize(sm: 0, md: 0, lg: 4),
    Widget? formFooter,
  }) {
    Widget content;

    if (formSidebarFields != null) {
      // Sidebar span at each breakpoint (0 means no sidebar at that size).
      final sidebarSm = formSidebarSize.sm ?? 0;
      final sidebarMd = formSidebarSize.md ?? 0;
      final sidebarLg = formSidebarSize.lg ?? 4;

      // Main area occupies the remainder of the 12-column grid.
      final mainSm = sidebarSm == 0 ? 12 : 12 - sidebarSm;
      final mainMd = sidebarMd == 0 ? 12 : 12 - sidebarMd;
      final mainLg = sidebarLg == 0 ? 12 : 12 - sidebarLg;

      final mainCol = TGridCol(
        sm: mainSm,
        md: mainMd,
        lg: mainLg,
        child: TGridRow(
          gapX: widget.gapX,
          gapY: widget.gapY,
          children: _buildFieldCols(formFields, formInput),
        ),
      );

      // On breakpoints where the sidebar span is 0, append sidebar fields
      // below main fields in a full-width single column.
      final sidebarCol = TGridCol(
        sm: sidebarSm == 0 ? 12 : sidebarSm,
        md: sidebarMd == 0 ? 12 : sidebarMd,
        lg: sidebarLg == 0 ? 12 : sidebarLg,
        child: TGridRow(
          gapX: widget.gapX,
          gapY: widget.gapY,
          children: _buildFieldCols(formSidebarFields, formInput),
        ),
      );

      // On sm/md where sidebar span is 0 the sidebar col becomes 12-wide and
      // wraps below; on lg it sits alongside the main col (8:4).
      content = TGridRow(
        gapX: widget.gapX,
        gapY: widget.gapY,
        children: [mainCol, sidebarCol],
      );
    } else {
      content = TGridRow(
        gapX: widget.gapX,
        gapY: widget.gapY,
        children: _buildFieldCols(formFields, formInput),
      );
    }

    if (formFooter != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          Padding(
            padding: EdgeInsets.only(top: widget.gapY),
            child: formFooter,
          ),
        ],
      );
    }

    return content;
  }

  Widget _buildTabContent(TFormTab tab) {
    final tabFields = tab.input?.fields ?? tab.fields ?? [];
    final tabSidebarFields = tab.input?.sidebarFields ?? tab.sidebarFields;
    final tabSidebarSize = tab.input?.sidebarSize ?? tab.sidebarSize ?? const TGridSize(sm: 0, md: 0, lg: 4);
    final tabFooter = tab.footer ?? tab.input?.footer;

    return _buildSingleFormContent(
      formInput: tab.input,
      formFields: tabFields,
      formSidebarFields: tabSidebarFields,
      formSidebarSize: tabSidebarSize,
      formFooter: tabFooter,
    );
  }

  Widget _buildAccordionTabsContent(List<TFormTab> tabs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < tabs.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == tabs.length - 1 ? 0 : widget.gapY / 2),
            child: TAccordion(
              title: tabs[i].title,
              subtitle: tabs[i].subtitle,
              leading: tabs[i].icon,
              initiallyExpanded: i == 0,
              margin: EdgeInsets.zero,
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              content: _buildTabContent(tabs[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildTabsContent([List<TFormTab>? customTabs, Axis? customAxis]) {
    final tabs = customTabs ?? widget.tabs ?? widget.input?.tabs ?? [];
    if (tabs.isEmpty) return const SizedBox.shrink();

    final axis = customAxis ?? widget.tabAxis;
    final tabItems = tabs.map((tab) => tab.toTab()).toList();

    final tabsBar = TTabs<dynamic>(
      controller: _tabController,
      tabs: tabItems,
      axis: axis,
      borderColor: widget.tabBorderColor,
      selectedColor: widget.tabSelectedColor,
      unselectedColor: widget.tabUnselectedColor,
      indicatorColor: widget.tabIndicatorColor,
      tabPadding: widget.tabPadding,
      tabSpacing: widget.tabSpacing,
      indicatorWidth: widget.tabIndicatorWidth,
      inline: widget.tabInline,
      scrollable: widget.scrollableTabs,
      showNavigationButtons: widget.showTabNavigationButtons,
      wrap: widget.tabWrap,
      tabBuilder: widget.tabBuilder,
      onTabChanged: (val) {
        widget.onTabChanged?.call(val);
      },
    );

    final contentWidget = TTabContent<dynamic>(
      controller: _tabController,
      tabs: tabs.map((tab) {
        final tabValue = tab.value ?? tab.title;
        return TTab<dynamic>(
          value: tabValue,
          text: tab.title,
          icon: tab.icon,
          isEnabled: tab.isEnabled,
          isActive: tab.isActive,
          data: tab.data,
          content: (context) => _buildTabContent(tab),
        );
      }).toList(),
    );

    if (axis == Axis.horizontal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          tabsBar,
          SizedBox(height: widget.gapY),
          contentWidget,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.tabWidth != null)
            SizedBox(width: widget.tabWidth, child: tabsBar)
          else
            tabsBar,
          SizedBox(width: widget.gapX),
          Expanded(child: contentWidget),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget formContent;

    final effectiveTabs = widget.tabs ?? widget.input?.tabs;
    final effectiveFormType = widget.formType ?? TFormTypeScope.maybeOf(context);

    if (effectiveTabs != null && effectiveTabs.isNotEmpty) {
      if (effectiveFormType == TFormType.accordion) {
        formContent = _buildAccordionTabsContent(effectiveTabs);
      } else {
        final axis = effectiveFormType == TFormType.verticalTabs
            ? Axis.vertical
            : (effectiveFormType == TFormType.horizontalTabs ? Axis.horizontal : widget.tabAxis);
        formContent = _buildTabsContent(effectiveTabs, axis);
      }
    } else {
      final resolvedFields = widget.input?.fields ?? widget.fields ?? [];
      final resolvedSidebarFields = widget.input?.sidebarFields;
      final resolvedSidebarSize = widget.input?.sidebarSize ?? const TGridSize(sm: 0, md: 0, lg: 4);
      final resolvedFooter = widget.footer ?? widget.input?.footer;

      formContent = _buildSingleFormContent(
        formInput: widget.input,
        formFields: resolvedFields,
        formSidebarFields: resolvedSidebarFields,
        formSidebarSize: resolvedSidebarSize,
        formFooter: resolvedFooter,
      );
    }

    if (effectiveTabs != null && widget.footer != null) {
      formContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          formContent,
          Padding(
            padding: EdgeInsets.only(top: widget.gapY),
            child: widget.footer!,
          ),
        ],
      );
    }

    if (widget.label == null) return formContent;

    return TAccordion(
      title: widget.label!,
      subtitle: widget.description,
      leading: widget.icon,
      initiallyExpanded: widget.initiallyExpanded,
      content: formContent,
      margin: EdgeInsets.zero,
      expandedMargin: const EdgeInsets.only(top: 20),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    );
  }
}
