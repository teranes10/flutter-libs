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

  /// Builds a standard header for the expanded details pane.
  static Widget header(
    BuildContext ctx, {
    String? title,
    String? subTitle,
    String? imageUrl,
    String? description,
    List<TButtonGroupItem> actions = const [],
    VoidCallback? onClose,
  }) {
    final colors = ctx.colors;
    final isDesktop = ctx.isDesktop;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isDesktop) ...[
                Builder(
                  builder: (buttonContext) {
                    return IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        final showMode = TExpansionShowModeScope.of(buttonContext);
                        if (showMode == TExpansionShowMode.page) {
                          Navigator.of(buttonContext).maybePop();
                        } else if (onClose != null) {
                          onClose();
                        } else {
                          Navigator.of(buttonContext).maybePop();
                        }
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
              if (imageUrl != null && imageUrl.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: TImage(
                    url: imageUrl,
                    size: 60,
                    color: colors.surfaceContainerLow,
                    disabled: true,
                    border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (subTitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actions.isNotEmpty)
                    TButtonGroup(
                      type: TButtonGroupType.icon,
                      alignment: WrapAlignment.end,
                      items: actions,
                    ),
                  if (onClose != null && isDesktop) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget tabs<T>(
    BuildContext ctx, {
    required List<TTab<T>> tabs,
    T? initialValue,
    TTabController<T>? controller,
    Widget? header,
  }) {
    final content = TTabView<T>(
      tabs: tabs,
      initialValue: initialValue,
      controller: controller,
      borderColor: ctx.colors.outlineVariant.o(0.25),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;

        final childContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (header != null) header,
            if (hasBoundedHeight) Expanded(child: content) else content,
          ],
        );

        // Customize card margins and shape based on showMode
        final showMode = TExpansionShowModeScope.of(context);
        EdgeInsets margin;
        double elevation;
        ShapeBorder shape;

        switch (showMode) {
          case TExpansionShowMode.side:
            margin = const EdgeInsets.only(left: 2);
            elevation = 2;
            shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
            break;
          case TExpansionShowMode.page:
            margin = EdgeInsets.zero;
            elevation = 0;
            shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
            break;
          case TExpansionShowMode.inline:
            margin = const EdgeInsets.all(12);
            elevation = 2;
            shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
            break;
        }

        return Card(
          margin: margin,
          elevation: elevation,
          shape: shape,
          child: childContent,
        );
      },
    );
  }
}

enum TExpansionShowMode { inline, side, page }

class TExpansionShowModeScope extends InheritedWidget {
  final TExpansionShowMode showMode;

  const TExpansionShowModeScope({
    super.key,
    required this.showMode,
    required super.child,
  });

  static TExpansionShowMode? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TExpansionShowModeScope>()?.showMode;
  }

  static TExpansionShowMode of(BuildContext context) {
    return maybeOf(context) ?? TExpansionShowMode.inline;
  }

  @override
  bool updateShouldNotify(TExpansionShowModeScope oldWidget) => showMode != oldWidget.showMode;
}
