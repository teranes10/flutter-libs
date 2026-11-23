import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:te_widgets/te_widgets.dart';

part 'field_prop.dart';
part 'form_field.dart';
part 'form_builder_config.dart';
part 'form_controller.dart';
part 'form_tab.dart';
part 'form_type.dart';
part 'form_table_headers.dart';

/// A responsive form builder with grid and tab layouts.
///
/// `TFormBuilder` provides automatic form layout with:
/// - 12-column responsive grid system
/// - Automatic field sizing based on breakpoints
/// - Integration with TFormBase
/// - Nested form support (accordion, horizontal/vertical tabs, horizontal/vertical stepper)
/// - Section error flags, sequential steppers and scroll-to-first-error via [TFormController]
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
///     TFormTab(title: 'Account', icon: HugeIcons.strokeRoundedUser, input: accountForm),
///     TFormTab(title: 'Settings', icon: HugeIcons.strokeRoundedSettings01, input: settingsForm),
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

  /// On mobile, horizontal tabs fit as many per row as possible and stretch to fill each row.
  final bool tabFlowOnMobile;

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

  final dynamic icon;

  /// Optional title for the form (renders inside an accordion when provided).
  final String? label;

  /// Optional subtitle for the form.
  final String? description;

  final bool initiallyExpanded;

  /// Optional footer widget displayed below the form fields.
  final Widget? footer;

  /// Optional controller for section navigation (Next/Back) and error reveal.
  final TFormController? controller;

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
    this.tabFlowOnMobile = true,
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
    this.controller,
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
    this.tabFlowOnMobile = true,
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
    this.controller,
  })  : input = null,
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
    this.tabFlowOnMobile = true,
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
    this.controller,
  })  : input = null,
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
    this.controller,
  })  : input = null,
        fields = null,
        tabAxis = Axis.vertical,
        tabInline = false,
        tabWrap = false,
        tabFlowOnMobile = true;

  @override
  State<TFormBuilder> createState() => _TFormBuilderState();
}


class _TFormBuilderState extends State<TFormBuilder> {
  late TTabController<dynamic> _tabController;
  bool _isInternalTabController = false;

  /// Sections whose error flag is shown (after Next, Save or a blocked step).
  /// A flag clears itself as soon as the section becomes valid.
  final Set<int> _flagged = {};

  /// Stepper steps passed with Next, shown with a tick while still valid.
  final Set<int> _completed = {};

  /// Expanded sections in the accordion layout.
  final Set<int> _expanded = {0};

  /// Expansion of this builder's own [TFormBuilder.label] accordion.
  late bool _selfExpanded = widget.initiallyExpanded;

  /// One key per section, used to find its fields when revealing errors.
  final Map<int, GlobalKey> _sectionKeys = {};

  /// Enclosing builder's controller when this builder's tabs drive its footer.
  TFormController? _claimed;

  /// Layout resolved in the last build; null for a form without sections.
  TFormType? _type;

  List<TFormTab> get _tabs => widget.tabs ?? widget.input?.tabs ?? const [];

  int get _currentIndex {
    final index = _tabs.indexWhere((tab) => tab.effectiveValue == _tabController.value);
    return index < 0 ? 0 : index;
  }

  bool _sectionHasErrors(int index) => _tabs[index].validationErrors.isNotEmpty;

  bool _isFlagged(int index) => _flagged.contains(index) && _sectionHasErrors(index);

  bool get _hasErrors {
    final tabs = _tabs;
    if (tabs.isNotEmpty) return tabs.any((tab) => tab.validationErrors.isNotEmpty);
    return (widget.input?.validationErrors ?? TFormBase._validateFields([...?widget.fields])).isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _initTabController();
    widget.controller?._attach(this);
  }

  void _initTabController() {
    final tabs = _tabs;
    if (widget.tabController != null) {
      _tabController = widget.tabController!;
      _isInternalTabController = false;
    } else {
      _tabController = TTabController<dynamic>(
        initialValue: widget.initialTabValue ?? (tabs.isNotEmpty ? tabs.first.effectiveValue : null),
      );
      _isInternalTabController = true;
    }
    _tabController.addListener(_onTabControllerChanged);
  }

  void _onTabControllerChanged() {
    widget.onTabChanged?.call(_tabController.value);
    // The stepper and the controller's index are driven from build.
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(TFormBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabController != oldWidget.tabController) {
      _tabController.removeListener(_onTabControllerChanged);
      if (_isInternalTabController) {
        _tabController.dispose();
      }
      _initTabController();
    }
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _claimed?._releaseSections(this);
    _tabController.removeListener(_onTabControllerChanged);
    if (_isInternalTabController) {
      _tabController.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Navigation & error reveal
  // ---------------------------------------------------------------------

  /// Rebuilds so section error flags follow the values (a fixed section un-flags).
  void _refreshFlags() {
    if (_flagged.isEmpty || !mounted) return;
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _select(int index) async {
    final value = _tabs[index].effectiveValue;
    if (_tabController.value != value) await _tabController.selectTab(value);
  }

  /// Waits for pending layout, and for an expand animation when [animated].
  Future<void> _settle({bool animated = false}) async {
    await WidgetsBinding.instance.endOfFrame;
    if (animated) await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  void _scrollTo(BuildContext target, {double alignment = 0.2}) {
    Scrollable.ensureVisible(
      target,
      alignment: alignment,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<bool> _goTo(int target, {bool fromNext = false}) async {
    final tabs = _tabs;
    if (target < 0 || target >= tabs.length) return false;

    final type = _type;
    if (type == null || !type.isPaged) {
      setState(() => _expanded.add(target));
      return true;
    }

    final current = _currentIndex;
    if (type.isStepper && target > current) {
      // Sequential: every step before the target must be valid.
      for (var i = current; i < target; i++) {
        if (_sectionHasErrors(i)) {
          final firstError = await _revealErrors(only: i);
          if (firstError != null && firstError.mounted) _scrollTo(firstError);
          return false;
        }
        _completed.add(i);
      }
    } else if (fromNext) {
      // Tabs are free to navigate, but a section left with errors gets flagged.
      _flagged.add(current);
    }

    await _select(target);
    if (!mounted || _currentIndex != target) return false; // vetoed by TTabController.beforeChange

    // Bring the section header back into view when the user had scrolled down.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    });
    return true;
  }

  /// Flags sections with errors (only section [only] when given), opens the
  /// first one, shows the error of every field in it and returns the first
  /// invalid field's context (or the section when no field could be found).
  Future<BuildContext?> _revealErrors({int? only}) async {
    final tabs = _tabs;
    final needsSelfExpand = widget.label != null && !_selfExpanded;
    BuildContext? root;

    if (tabs.isNotEmpty) {
      final failing = [
        for (var i = 0; i < tabs.length; i++)
          if ((only == null || only == i) && _sectionHasErrors(i)) i,
      ];
      if (failing.isEmpty) return null;

      final first = failing.first;
      final isPaged = _type?.isPaged ?? false;
      final needsExpand = needsSelfExpand || (!isPaged && !_expanded.contains(first));
      setState(() {
        _flagged.addAll(failing);
        _completed.removeAll(failing);
        if (!isPaged) _expanded.addAll(failing);
        _selfExpanded = true;
      });
      if (isPaged) await _select(first);
      await _settle(animated: needsExpand || !isPaged);

      // Accordion sections are all visible: show the messages in every failing one.
      if (!isPaged) {
        BuildContext? firstError;
        for (final i in failing) {
          final section = _sectionKeys[i]?.currentContext;
          if (!mounted || section == null || !section.mounted) continue;
          final error = await _revealFieldErrors(section as Element) ?? section; // not `??=`: every section must reveal
          firstError ??= error;
        }
        return firstError;
      }
      root = _sectionKeys[first]?.currentContext;
    } else {
      if (!_hasErrors) return null;
      if (needsSelfExpand) setState(() => _selfExpanded = true);
      await _settle(animated: needsSelfExpand);
      root = context;
    }

    if (!mounted || root == null || !root.mounted) return null;
    return await _revealFieldErrors(root as Element) ?? root;
  }

  /// Shows the validation message of every field under [root] (in layout
  /// order) and returns the first invalid one. Nested builders reveal their
  /// own sections so errors hidden in a nested tab or accordion surface too.
  static Future<BuildContext?> _revealFieldErrors(Element root) async {
    final targets = <State>[];
    void visit(Element element) {
      if (element is StatefulElement) {
        final state = element.state;
        if (state is _TFormBuilderState) {
          targets.add(state);
          return;
        }
        if (state is TInputValidationStateMixin) targets.add(state);
      }
      element.visitChildren(visit);
    }

    root.visitChildren(visit);

    BuildContext? first;
    for (final state in targets) {
      if (!state.mounted) continue;
      if (state is _TFormBuilderState) {
        final error = await state._revealErrors(); // not `??=`: every nested builder must reveal
        first ??= error;
      } else if (state is TInputValidationStateMixin) {
        state.triggerValidation(state.currentValue);
        if (state.hasErrors) first ??= state.context;
      }
    }
    return first;
  }

  // ---------------------------------------------------------------------
  // Layout
  // ---------------------------------------------------------------------

  /// Builds the column widgets for [fieldList], attaching value-change listeners.
  List<Widget> _buildFieldCols(List<TFormField> fieldList, [TFormBase? formInput]) {
    return fieldList.map((field) {
      field._attach(() {
        widget.onValueChanged?.call();
        (formInput ?? widget.input)?.onValueChanged();
        _refreshFlags();
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

  /// The content of section [index], keyed so its fields can be found.
  Widget _buildSection(int index, TFormTab tab) {
    return KeyedSubtree(
      key: _sectionKeys.putIfAbsent(index, GlobalKey.new),
      child: _buildSingleFormContent(
        formInput: tab.input,
        formFields: tab.input?.fields ?? tab.fields ?? [],
        formSidebarFields: tab.input?.sidebarFields ?? tab.sidebarFields,
        formSidebarSize: tab.input?.sidebarSize ?? tab.sidebarSize ?? const TGridSize(sm: 0, md: 0, lg: 4),
        formFooter: tab.footer ?? tab.input?.footer,
      ),
    );
  }

  Widget _buildAccordionSections(List<TFormTab> tabs) {
    final danger = context.theme.danger;
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
              iconColor: _isFlagged(i) ? danger : null,
              trailing: _isFlagged(i) ? TIcon.raw(HugeIcons.strokeRoundedAlertCircle, size: 16, color: danger) : null,
              isExpanded: _expanded.contains(i),
              onExpansionChanged: (open) => setState(() => open ? _expanded.add(i) : _expanded.remove(i)),
              margin: EdgeInsets.zero,
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              content: _buildSection(i, tabs[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildStepper(List<TFormTab> tabs, TFormType type, int index) {
    return TStepper(
      type: type == TFormType.verticalStepper ? TStepperType.vertical : TStepperType.horizontal,
      currentStep: index,
      onStepTapped: (i) => _goTo(i),
      steps: [
        for (var i = 0; i < tabs.length; i++)
          TStep(
            title: Text(tabs[i].title),
            subtitle: tabs[i].subtitle != null ? Text(tabs[i].subtitle!) : null,
            hasError: _isFlagged(i),
            isCompleted: _completed.contains(i) && !_sectionHasErrors(i),
            content: _buildSection(i, tabs[i]),
          ),
      ],
    );
  }

  Widget _buildTabs(List<TFormTab> tabs, Axis axis) {
    final tabsBar = TTabs<dynamic>(
      controller: _tabController,
      tabs: [for (var i = 0; i < tabs.length; i++) tabs[i].toTab(hasError: _isFlagged(i))],
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
      flowOnMobile: widget.tabFlowOnMobile,
      tabBuilder: widget.tabBuilder,
    );

    final contentWidget = TTabContent<dynamic>(
      controller: _tabController,
      tabs: [for (var i = 0; i < tabs.length; i++) tabs[i].toTab(content: (_) => _buildSection(i, tabs[i]))],
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
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tabWidth != null) SizedBox(width: widget.tabWidth, child: tabsBar) else tabsBar,
        SizedBox(width: widget.gapX),
        Expanded(child: contentWidget),
      ],
    );
  }

  TFormType _resolveType(BuildContext context) {
    final scoped = TFormTypeScope.maybeOf(context);
    final type = widget.formType ?? scoped ?? widget.input?.defaultFormType;
    if (type == null) return widget.tabAxis == Axis.vertical ? TFormType.verticalTabs : TFormType.horizontalTabs;
    // A nested sub-form has no footer to drive a stepper, so it shows the inherited stepper scope as tabs.
    if (widget.formType == null && scoped != null && _claimed == null && widget.controller == null) return type.asTabs;
    return type;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    Widget formContent;

    if (tabs.isNotEmpty) {
      // Tabs declared as a nested field drive the form footer of the enclosing builder.
      if (widget.controller == null) {
        final scoped = context.getInheritedWidgetOfExactType<_TFormControllerScope>()?.controller;
        if (scoped != null && scoped._claimSections(this)) _claimed = scoped;
      }
      final type = _type = _resolveType(context);
      final index = _currentIndex;
      (widget.controller ?? _claimed)?._report(type, index, tabs.length);

      formContent = switch (type) {
        TFormType.accordion => _buildAccordionSections(tabs),
        TFormType.horizontalStepper || TFormType.verticalStepper => _buildStepper(tabs, type, index),
        TFormType.verticalTabs => _buildTabs(tabs, Axis.vertical),
        TFormType.horizontalTabs => _buildTabs(tabs, Axis.horizontal),
      };

      if (widget.footer != null) {
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
    } else {
      _type = null;
      if (widget.controller != null && widget.controller!._sections == null) widget.controller!._report(null, 0, 0);
      formContent = _buildSingleFormContent(
        formInput: widget.input,
        formFields: widget.input?.fields ?? widget.fields ?? [],
        formSidebarFields: widget.input?.sidebarFields,
        formSidebarSize: widget.input?.sidebarSize ?? const TGridSize(sm: 0, md: 0, lg: 4),
        formFooter: widget.footer ?? widget.input?.footer,
      );
    }

    final controller = widget.controller;
    if (controller != null) formContent = _TFormControllerScope(controller: controller, child: formContent);

    if (widget.label == null) return formContent;

    return TAccordion(
      title: widget.label!,
      subtitle: widget.description,
      leading: widget.icon,
      isExpanded: _selfExpanded,
      onExpansionChanged: (open) => setState(() => _selfExpanded = open),
      content: formContent,
      margin: EdgeInsets.zero,
      expandedMargin: const EdgeInsets.only(top: 20),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    );
  }
}

/// Lets a nested sections builder find the controller of the form it lives in.
class _TFormControllerScope extends InheritedWidget {
  const _TFormControllerScope({required this.controller, required super.child});

  final TFormController controller;

  @override
  bool updateShouldNotify(_TFormControllerScope old) => controller != old.controller;
}
