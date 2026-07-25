import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TRowExpandedBuilder {
  static Widget keyValue(BuildContext ctx, List<TKeyValue> values) {
    final colors = ctx.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.surfaceContainerLowest, borderRadius: BorderRadius.circular(8)),
      child: TKeyValueSection(
        values: values,
      ),
    );
  }

  static Widget tabs(
    BuildContext ctx, {
    required List<TTab<String>> tabs,
    String? initialValue,
    TTabController<String>? controller,
    Widget? header,
    String editTabLabel = 'Edit',
    String editTabValue = '__edit__',
    Widget Function(BuildContext)? editTabBuilder,
  }) {
    return TExpandedTabs(
      tabs: tabs,
      initialValue: initialValue,
      controller: controller,
      header: header,
      editTabLabel: editTabLabel,
      editTabValue: editTabValue,
      editTabBuilder: editTabBuilder,
    );
  }
}

class TExpandedTabs extends StatefulWidget {
  final List<TTab<String>> tabs;
  final String? initialValue;
  final TTabController<String>? controller;
  final Widget? header;
  final String editTabLabel;
  final String editTabValue;
  final Widget Function(BuildContext)? editTabBuilder;
  final VoidCallback? onEditTabActivated;

  const TExpandedTabs({
    super.key,
    required this.tabs,
    this.initialValue,
    this.controller,
    this.header,
    this.editTabLabel = 'Edit',
    this.editTabValue = '__edit__',
    this.editTabBuilder,
    this.onEditTabActivated,
  });

  @override
  State<TExpandedTabs> createState() => TExpandedTabsState();
}

class TExpandedTabsState extends State<TExpandedTabs> {
  late final TTabController<String> _controller;
  late final bool _isControllerOwned;

  @override
  void initState() {
    super.initState();
    _isControllerOwned = widget.controller == null;
    _controller = widget.controller ?? TTabController<String>(initialValue: widget.initialValue);

    _controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    final tableScope = TTableScope.maybeOf(context);
    if (tableScope != null && _controller.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          tableScope.controller.setAdditionalState('active_tab', _controller.value);
        }
      });
    }
    
    if (_controller.value == widget.editTabValue) {
      widget.onEditTabActivated?.call();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tableScope = TTableScope.maybeOf(context);
    if (tableScope != null) {
      final desiredTab = tableScope.controller.value.additional['active_tab'];
      if (desiredTab != null && desiredTab != _controller.value) {
        _controller.value = desiredTab;
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    if (_isControllerOwned) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<TTab<String>> effectiveTabs = [...widget.tabs];
    if (widget.editTabBuilder != null) {
      effectiveTabs.add(TTab<String>(
        text: widget.editTabLabel,
        value: widget.editTabValue,
        content: widget.editTabBuilder,
      ));
    }
    
    dynamic effectiveInitialValue = widget.initialValue;

    final content = TTabView<String>(
      tabs: effectiveTabs,
      initialValue: _controller.value ?? effectiveInitialValue,
      controller: _controller,
      borderColor: context.colors.outlineVariant.o(0.25),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;

        final childContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (widget.header != null) widget.header!,
            if (hasBoundedHeight) Expanded(child: content) else content,
          ],
        );

        return childContent;
      },
    );
  }
}
