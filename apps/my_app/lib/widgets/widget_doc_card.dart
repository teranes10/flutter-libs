import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:te_widgets/te_widgets.dart';

/// A model representing a single property of a widget.
///
/// Used to document widget properties with their types, default values,
/// and descriptions in the documentation system.
class PropertyDoc {
  /// The name of the property.
  final String name;

  /// The Dart type of the property (e.g., 'String', 'Color?', 'VoidCallback').
  final String type;

  /// Whether this property is required.
  final bool isRequired;

  /// The default value of the property, if any.
  final String? defaultValue;

  /// A description of what this property does.
  final String description;

  const PropertyDoc({
    required this.name,
    required this.type,
    this.isRequired = false,
    this.defaultValue,
    required this.description,
  });
}

/// A comprehensive documentation card for widgets with preview, code, and properties tabs.
///
/// This widget provides a professional documentation interface with:
/// - Live preview of the widget
/// - Syntax-highlighted code snippet
/// - Property documentation table
/// - Copy-to-clipboard functionality
///
/// Example:
/// ```dart
/// WidgetDocCard(
///   title: 'Primary Button',
///   description: 'A solid button with primary color',
///   preview: TButton(
///     text: 'Click Me',
///     color: AppColors.primary,
///     onTap: () {},
///   ),
///   code: '''
/// TButton(
///   text: 'Click Me',
///   color: AppColors.primary,
///   onTap: () {},
/// )''',
///   properties: [
///     PropertyDoc(
///       name: 'text',
///       type: 'String?',
///       description: 'The text to display on the button',
///     ),
///   ],
/// )
/// ```
class WidgetDocCard extends StatefulWidget {
  /// The title of this documentation section.
  final String title;

  /// An optional description providing context about the widget.
  final String? description;

  /// The live widget preview.
  final Widget preview;

  /// The code snippet as a string.
  final String code;

  /// List of property documentation.
  final List<PropertyDoc> properties;

  /// Optional icon to display in the header.
  final IconData? icon;

  /// Whether to start with the code tab expanded.
  final bool defaultShowCode;

  // Removed const to allow dynamic preview widgets that depend on parent state
  const WidgetDocCard({
    super.key,
    required this.title,
    this.description,
    required this.preview,
    required this.code,
    this.properties = const [],
    this.icon,
    this.defaultShowCode = false,
  });

  @override
  State<WidgetDocCard> createState() => _WidgetDocCardState();
}

class _WidgetDocCardState extends State<WidgetDocCard> with SingleTickerProviderStateMixin {
  late ValueNotifier _tabController;
  bool _codeCopied = false;

  @override
  void initState() {
    super.initState();
    _tabController = ValueNotifier(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeTheme = Map.of(isDark ? draculaTheme : githubTheme);
    codeTheme['root'] = TextStyle(color: colors.onSurface, backgroundColor: colors.surface);

    return TCard(
      borderRadius: BorderRadius.circular(16),
      margin: const EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant.withAlpha(100)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Icon | Title,Subtitle | Tabs
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withAlpha(13), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 600;

                  final titleSection = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            widget.icon,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      if (widget.icon != null) const SizedBox(width: 10),
                      // Title and Subtitle
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.description != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.description!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.onSurface.withAlpha(179),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );

                  final tabsSection = Container(
                    constraints: BoxConstraints(
                      minWidth: isSmallScreen ? 100 : 125,
                      maxWidth: 125,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface.withAlpha(128),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: _tabController,
                      builder: (ctx, value, _) {
                        return TTabs(
                          tabPadding: EdgeInsets.symmetric(vertical: 4, horizontal: isSmallScreen ? 6 : 8),
                          selectedValue: value,
                          inline: true,
                          tabs: [
                            TTab(value: 0, icon: Icons.remove_red_eye),
                            TTab(value: 1, icon: Icons.code),
                            if (widget.properties.isNotEmpty) TTab(value: 2, icon: Icons.list_alt),
                          ],
                          onTabChanged: (value) => _tabController.value = value,
                        );
                      },
                    ),
                  );

                  return isSmallScreen
                      ? SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              titleSection,
                              tabsSection,
                            ],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: titleSection),
                            tabsSection,
                          ],
                        );
                },
              ),
            ),

            // Tab Content with intrinsic height
            ValueListenableBuilder(
                valueListenable: _tabController,
                builder: (context, value, _) {
                  return TLazyIndexedStack(
                    index: value,
                    children: [
                      // Preview Tab
                      (_) => Padding(padding: EdgeInsetsGeometry.all(14), child: widget.preview),

                      // Code Tab
                      (_) => Padding(
                            padding: EdgeInsetsGeometry.all(14),
                            child: Stack(
                              children: [
                                SelectableText(
                                  widget.code.trim(),
                                  style: const TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: TButton(
                                    size: TButtonSize.xs,
                                    type: TButtonType.tonal,
                                    icon: _codeCopied ? Icons.check : Icons.copy,
                                    color: _codeCopied ? AppColors.success : AppColors.primary,
                                    onTap: _copyCode,
                                  ),
                                ),
                              ],
                            ),
                          ),

                      // Properties Tab
                      if (widget.properties.isNotEmpty)
                        (_) => Padding(
                              padding: const EdgeInsets.all(16),
                              child: PropertyDocumentation(properties: widget.properties),
                            ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.code.trim()));
    setState(() => _codeCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _codeCopied = false);
      }
    });
  }
}

/// A widget that displays property documentation in a structured table format.
///
/// Shows property name, type, required status, default value, and description.
class PropertyDocumentation extends StatelessWidget {
  /// The list of properties to document.
  final List<PropertyDoc> properties;

  const PropertyDocumentation({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Properties',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 64, // Account for padding
            ),
            child: Table(
              border: TableBorder.all(
                color: colors.outline.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: IntrinsicColumnWidth(),
                2: IntrinsicColumnWidth(),
                3: FlexColumnWidth(1),
              },
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withAlpha(128),
                  ),
                  children: [
                    _buildHeaderCell('Name'),
                    _buildHeaderCell('Type'),
                    _buildHeaderCell('Default'),
                    _buildHeaderCell('Description'),
                  ],
                ),
                // Rows
                ...properties.map((prop) => TableRow(
                      children: [
                        _buildCell(
                          context,
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                prop.name,
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (prop.isRequired) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withAlpha(26),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'required',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        _buildCell(
                          context,
                          Text(
                            prop.type,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 12,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                        _buildCell(
                          context,
                          Text(
                            prop.defaultValue ?? '-',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 12,
                              color: colors.onSurface.withAlpha(179),
                            ),
                          ),
                        ),
                        _buildCell(
                          context,
                          Text(
                            prop.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurface.withAlpha(204),
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, Widget child) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}
