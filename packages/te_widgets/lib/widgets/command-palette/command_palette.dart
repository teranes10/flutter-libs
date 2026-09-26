import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/extensions/build_context_x.dart';
import 'package:te_widgets/widgets/badge/badge.dart';
import 'package:te_widgets/widgets/empty-state/empty_state.dart';
import 'package:te_widgets/widgets/icon/icon.dart';

/// A single actionable item in a [TCommandPalette].
class TCommandItem {
  /// Unique identifier for this command.
  final String id;

  /// Primary title of the command.
  final String title;

  /// Optional secondary description.
  final String? subtitle;

  /// Leading icon (IconData or Widget).
  final dynamic icon;

  /// Visual shortcut pill (e.g. '⌘K', '⌘P').
  final String? shortcut;

  /// Optional status or category badge.
  final String? badge;

  /// Additional keywords for search matching.
  final List<String> keywords;

  /// Action executed when the command is triggered.
  final VoidCallback onSelect;

  const TCommandItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.shortcut,
    this.badge,
    this.keywords = const [],
    required this.onSelect,
  });

  /// Checks if this item matches the search query.
  bool matches(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase().trim();
    if (title.toLowerCase().contains(q)) return true;
    if (subtitle != null && subtitle!.toLowerCase().contains(q)) return true;
    for (final kw in keywords) {
      if (kw.toLowerCase().contains(q)) return true;
    }
    return false;
  }
}

/// A section of related commands in a [TCommandPalette].
class TCommandGroup {
  /// Group header title (e.g. 'NAVIGATION', 'QUICK ACTIONS').
  final String heading;

  /// The list of command items in this group.
  final List<TCommandItem> items;

  const TCommandGroup({
    required this.heading,
    required this.items,
  });
}

/// A macOS Spotlight / Raycast-style command bar dialog for global search and actions.
///
/// Features:
/// - Instant fuzzy keyword filtering.
/// - Full keyboard navigation (Arrow Up/Down, Enter to trigger, Escape to close).
/// - Grouped sections with category headings.
/// - Keyboard shortcut pills and status badges.
/// - Global shortcut listener via [TCommandPaletteScope] or manual trigger via [TCommandPaletteTrigger].
class TCommandPalette extends StatefulWidget {
  /// Grouped commands to display.
  final List<TCommandGroup> groups;

  /// Search input placeholder.
  final String placeholder;

  /// Maximum dialog width.
  final double width;

  /// Maximum list height.
  final double maxHeight;

  /// Optional custom empty state widget when search yields no results.
  final Widget? emptyState;

  const TCommandPalette({
    super.key,
    required this.groups,
    this.placeholder = 'Type a command or search...',
    this.width = 620.0,
    this.maxHeight = 440.0,
    this.emptyState,
  });

  /// Shows the command palette in a top-centered modal dialog.
  static Future<TCommandItem?> show(
    BuildContext context, {
    required List<TCommandGroup> groups,
    String placeholder = 'Type a command or search...',
    double width = 620.0,
    double maxHeight = 440.0,
    Widget? emptyState,
  }) {
    return showGeneralDialog<TCommandItem>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Command Palette',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            child: Material(
              type: MaterialType.transparency,
              child: TCommandPalette(
                groups: groups,
                placeholder: placeholder,
                width: width,
                maxHeight: maxHeight,
                emptyState: emptyState,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  @override
  State<TCommandPalette> createState() => _TCommandPaletteState();
}

class _TCommandPaletteState extends State<TCommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _selectedIndex = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _query = _searchController.text.trim();
      _selectedIndex = 0;
    });
  }

  /// Extracts filtered groups and flattened list of visible items.
  (List<TCommandGroup>, List<TCommandItem>) _filterItems() {
    final filteredGroups = <TCommandGroup>[];
    final allItems = <TCommandItem>[];

    for (final group in widget.groups) {
      final matchingItems = group.items.where((item) => item.matches(_query)).toList();
      if (matchingItems.isNotEmpty) {
        filteredGroups.add(TCommandGroup(heading: group.heading, items: matchingItems));
        allItems.addAll(matchingItems);
      }
    }

    return (filteredGroups, allItems);
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final (_, flatItems) = _filterItems();
    if (flatItems.isEmpty) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % flatItems.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + flatItems.length) % flatItems.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_selectedIndex >= 0 && _selectedIndex < flatItems.length) {
        _selectItem(flatItems[_selectedIndex]);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
    }
  }

  void _selectItem(TCommandItem item) {
    Navigator.of(context).pop(item);
    item.onSelect();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (filteredGroups, flatItems) = _filterItems();

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          color: isDark ? colors.surfaceContainerHigh : colors.surface,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: isDark ? 0.45 : 0.18),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Search Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.4))),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 20, color: colors.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: TextStyle(fontSize: 14, color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: widget.placeholder,
                        hintStyle: TextStyle(fontSize: 14, color: colors.onSurfaceVariant.withValues(alpha: 0.7)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    InkWell(
                      onTap: () => _searchController.clear(),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.close_rounded, size: 16, color: colors.onSurfaceVariant),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'ESC',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Results List / Empty State
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxHeight),
              child: flatItems.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36.0),
                      child: widget.emptyState ??
                          TEmptyState.search(
                            query: _query,
                            description: 'No commands found for "$_query"',
                          ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: _calculateTotalRows(filteredGroups),
                      itemBuilder: (context, index) {
                        final entry = _getEntryAt(filteredGroups, index);
                        if (entry.isHeader) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Text(
                              entry.headerText!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                                letterSpacing: 0.8,
                              ),
                            ),
                          );
                        }

                        final item = entry.item!;
                        final isSelected = entry.flatIndex == _selectedIndex;

                        return MouseRegion(
                          onEnter: (_) {
                            setState(() => _selectedIndex = entry.flatIndex);
                          },
                          child: InkWell(
                            onTap: () => _selectItem(item),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primaryContainer.withValues(alpha: isDark ? 0.3 : 0.5)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  if (item.icon != null) ...[
                                    TIcon(
                                      icon: item.icon,
                                      size: 18,
                                      color: isSelected ? colors.primary : colors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            color: isSelected ? colors.primary : colors.onSurface,
                                          ),
                                        ),
                                        if (item.subtitle != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            item.subtitle!,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: colors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (item.badge != null) ...[
                                    const SizedBox(width: 8),
                                    TBadge(
                                      label: item.badge!,
                                      color: colors.primary,
                                    ),
                                  ],
                                  if (item.shortcut != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                                      ),
                                      child: Text(
                                        item.shortcut!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: colors.onSurfaceVariant,
                                          fontFamily: 'Courier',
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom Navigation Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.35))),
                color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
              ),
              child: Row(
                children: [
                  _buildFooterHint(colors, '↑↓', 'Navigate'),
                  const SizedBox(width: 14),
                  _buildFooterHint(colors, '↵', 'Select'),
                  const SizedBox(width: 14),
                  _buildFooterHint(colors, 'ESC', 'Dismiss'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterHint(ColorScheme colors, String keyText, String actionText) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Text(
            keyText,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
              fontFamily: 'Courier',
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          actionText,
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  int _calculateTotalRows(List<TCommandGroup> groups) {
    int count = 0;
    for (final group in groups) {
      count += 1 + group.items.length; // 1 header + items
    }
    return count;
  }

  _ListEntry _getEntryAt(List<TCommandGroup> groups, int targetIndex) {
    int currentIndex = 0;
    int flatItemCounter = 0;

    for (final group in groups) {
      if (currentIndex == targetIndex) {
        return _ListEntry(isHeader: true, headerText: group.heading);
      }
      currentIndex++;

      for (final item in group.items) {
        if (currentIndex == targetIndex) {
          return _ListEntry(isHeader: false, item: item, flatIndex: flatItemCounter);
        }
        currentIndex++;
        flatItemCounter++;
      }
    }

    return _ListEntry(isHeader: true, headerText: '');
  }
}

class _ListEntry {
  final bool isHeader;
  final String? headerText;
  final TCommandItem? item;
  final int flatIndex;

  _ListEntry({
    required this.isHeader,
    this.headerText,
    this.item,
    this.flatIndex = 0,
  });
}

/// A ready-to-use search button for TopBars and headers that launches [TCommandPalette].
class TCommandPaletteTrigger extends StatelessWidget {
  /// The command groups to present when triggered.
  final List<TCommandGroup> groups;

  /// Display placeholder text (e.g. 'Search or jump to...').
  final String placeholder;

  /// Shortcut badge text (e.g. '⌘K' or 'Ctrl+K').
  final String shortcut;

  /// Width of the trigger widget.
  final double? width;

  const TCommandPaletteTrigger({
    super.key,
    required this.groups,
    this.placeholder = 'Search or jump to...',
    this.shortcut = '⌘K',
    this.width = 240.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: () => TCommandPalette.show(context, groups: groups),
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 16, color: colors.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                placeholder,
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant.withValues(alpha: 0.8)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Text(
                shortcut,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                  fontFamily: 'Courier',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scope wrapper that registers a global `Cmd+K` / `Ctrl+K` key binding to show [TCommandPalette].
class TCommandPaletteScope extends StatelessWidget {
  /// The underlying page or app content.
  final Widget child;

  /// The groups to display when the keyboard shortcut triggers.
  final List<TCommandGroup> groups;

  /// Whether the shortcut is currently enabled.
  final bool enabled;

  const TCommandPaletteScope({
    super.key,
    required this.child,
    required this.groups,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
          TCommandPalette.show(context, groups: groups);
        },
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          TCommandPalette.show(context, groups: groups);
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
