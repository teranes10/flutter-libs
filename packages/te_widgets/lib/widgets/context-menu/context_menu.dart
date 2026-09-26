import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/configs/theme/app_colors.dart';
import 'package:te_widgets/extensions/build_context_x.dart';
import 'package:te_widgets/widgets/icon/icon.dart';

/// Base class for items inside a [TContextMenu].
abstract class TContextMenuEntry {
  const TContextMenuEntry();
}

/// A standard actionable item in a [TContextMenu].
class TContextMenuItem extends TContextMenuEntry {
  /// The label text of the menu item.
  final String text;

  /// Optional leading icon (IconData or Widget).
  final dynamic icon;

  /// Optional keyboard shortcut label (e.g. '⌘C', 'Delete').
  final String? shortcut;

  /// Whether this is a destructive/danger action (rendered with danger color).
  final bool isDestructive;

  /// Whether the item is interactive.
  final bool isEnabled;

  /// Callback executed when the item is tapped.
  final VoidCallback? onTap;

  const TContextMenuItem({
    required this.text,
    this.icon,
    this.shortcut,
    this.isDestructive = false,
    this.isEnabled = true,
    this.onTap,
  });
}

/// A visual separator line in a [TContextMenu].
class TContextMenuDivider extends TContextMenuEntry {
  const TContextMenuDivider();
}

/// A right-click (secondary tap) and long-press contextual menu wrapper.
///
/// Wraps any widget to present a desktop/web context menu at the cursor coordinates,
/// complete with hover highlights, shortcut labels, destructive action styling,
/// and automatic viewport boundary clamping.
///
/// On Flutter Web, automatically suppresses the browser's native context menu
/// while hovering over or interacting with the widget, preventing both menus from
/// appearing simultaneously.
class TContextMenu extends StatefulWidget {
  /// The items to show in the context menu.
  final List<TContextMenuEntry> items;

  /// The child widget that responds to right-click / long-press.
  final Widget child;

  /// Whether the context menu is enabled.
  final bool enabled;

  /// Whether to automatically override the browser's default context menu on Flutter Web.
  ///
  /// When `true` (default), suppresses the browser's native right-click menu while
  /// hovering over or interacting with this widget.
  final bool overrideBrowserContextMenu;

  /// Minimum width of the context menu card.
  final double minWidth;

  /// Maximum width of the context menu card.
  final double maxWidth;

  const TContextMenu({
    super.key,
    required this.items,
    required this.child,
    this.enabled = true,
    this.overrideBrowserContextMenu = true,
    this.minWidth = 190.0,
    this.maxWidth = 260.0,
  });

  /// Reference counter for active context menu regions on Flutter Web.
  static int _activeWebContextCount = 0;

  /// Globally disables the native browser context menu in Flutter Web.
  static Future<void> disableBrowserContextMenu() async {
    if (kIsWeb) {
      await BrowserContextMenu.disableContextMenu();
    }
  }

  /// Globally re-enables the native browser context menu in Flutter Web.
  static Future<void> enableBrowserContextMenu() async {
    if (kIsWeb) {
      await BrowserContextMenu.enableContextMenu();
    }
  }

  static void _acquireWebContext() {
    if (!kIsWeb) return;
    _activeWebContextCount++;
    if (_activeWebContextCount == 1) {
      BrowserContextMenu.disableContextMenu();
    }
  }

  static void _releaseWebContext() {
    if (!kIsWeb) return;
    _activeWebContextCount = math.max(0, _activeWebContextCount - 1);
    if (_activeWebContextCount == 0) {
      BrowserContextMenu.enableContextMenu();
    }
  }

  @override
  State<TContextMenu> createState() => _TContextMenuState();
}

class _TContextMenuState extends State<TContextMenu> {
  final OverlayPortalController _portalController = OverlayPortalController();
  Offset _tapPosition = Offset.zero;
  bool _isHovered = false;
  bool _isShowingMenu = false;

  void _onEnter() {
    if (widget.overrideBrowserContextMenu && !_isHovered) {
      _isHovered = true;
      TContextMenu._acquireWebContext();
    }
  }

  void _onExit() {
    if (widget.overrideBrowserContextMenu && _isHovered) {
      _isHovered = false;
      if (!_isShowingMenu) {
        TContextMenu._releaseWebContext();
      }
    }
  }

  void _showMenu(Offset globalPosition) {
    if (!widget.enabled || widget.items.isEmpty) return;
    if (_portalController.isShowing) return;

    if (widget.overrideBrowserContextMenu && !_isShowingMenu) {
      _isShowingMenu = true;
      if (!_isHovered) {
        TContextMenu._acquireWebContext();
      }
    }

    // Convert global screen coordinate to local coordinates of the target Overlay.
    // This correctly handles offsets introduced by parent Layouts, Navigators, Sidebars,
    // TopBars, and window padding.
    final overlayRenderBox = Overlay.of(context).context.findRenderObject() as RenderBox?;
    final localTapPosition = overlayRenderBox != null
        ? overlayRenderBox.globalToLocal(globalPosition)
        : globalPosition;

    setState(() {
      _tapPosition = localTapPosition;
    });
    _portalController.show();
  }

  void _hideMenu() {
    if (_portalController.isShowing) {
      _portalController.hide();
    }
    if (widget.overrideBrowserContextMenu && _isShowingMenu) {
      _isShowingMenu = false;
      if (!_isHovered) {
        TContextMenu._releaseWebContext();
      }
    }
  }

  @override
  void dispose() {
    if (widget.overrideBrowserContextMenu) {
      if (_isHovered) {
        _isHovered = false;
        TContextMenu._releaseWebContext();
      }
      if (_isShowingMenu) {
        _isShowingMenu = false;
        TContextMenu._releaseWebContext();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: (context) {
        final overlayRenderBox = Overlay.of(context).context.findRenderObject() as RenderBox?;
        final overlaySize = overlayRenderBox?.size ?? MediaQuery.of(context).size;

        // Estimated height based on entries
        double estimatedHeight = 16.0;
        for (final entry in widget.items) {
          if (entry is TContextMenuDivider) {
            estimatedHeight += 9.0;
          } else {
            estimatedHeight += 34.0;
          }
        }

        // Clamp coordinates within overlay boundaries
        const margin = 8.0;
        final double left = (_tapPosition.dx + widget.minWidth > overlaySize.width - margin)
            ? math.max(margin, _tapPosition.dx - widget.minWidth)
            : math.max(margin, _tapPosition.dx);

        final double top = (_tapPosition.dy + estimatedHeight > overlaySize.height - margin)
            ? math.max(margin, _tapPosition.dy - estimatedHeight)
            : math.max(margin, _tapPosition.dy);

        return SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Barrier dismiss layer
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _hideMenu,
                  onSecondaryTap: _hideMenu,
                ),
              ),

              // Floating Menu Card positioned relative to the Overlay coordinate system
              Positioned(
                left: left,
                top: top,
                child: MouseRegion(
                  onEnter: (_) => _onEnter(),
                  onExit: (_) => _onExit(),
                  child: KeyboardListener(
                    focusNode: FocusNode()..requestFocus(),
                    onKeyEvent: (event) {
                      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
                        _hideMenu();
                      }
                    },
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        constraints: BoxConstraints(minWidth: widget.minWidth, maxWidth: widget.maxWidth),
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        decoration: BoxDecoration(
                          color: isDark ? colors.surfaceContainerHigh : colors.surface,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow.withValues(alpha: isDark ? 0.4 : 0.15),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: widget.items.map((entry) {
                            if (entry is TContextMenuDivider) {
                              return Divider(
                                height: 9,
                                thickness: 1,
                                color: colors.outlineVariant.withValues(alpha: 0.4),
                              );
                            }

                            final item = entry as TContextMenuItem;
                            final itemColor = !item.isEnabled
                                ? colors.onSurfaceVariant.withValues(alpha: 0.4)
                                : (item.isDestructive ? AppColors.danger : colors.onSurface);

                            return _ContextMenuItemRow(
                              item: item,
                              itemColor: itemColor,
                              onTap: () {
                                if (item.isEnabled) {
                                  _hideMenu();
                                  item.onTap?.call();
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onEnter(),
        onExit: (_) => _onExit(),
        child: Listener(
          onPointerDown: (event) {
            if (event.buttons == kSecondaryMouseButton) {
              _showMenu(event.position);
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onSecondaryTapDown: (details) => _showMenu(details.globalPosition),
            onLongPressStart: (details) => _showMenu(details.globalPosition),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _ContextMenuItemRow extends StatefulWidget {
  final TContextMenuItem item;
  final Color itemColor;
  final VoidCallback onTap;

  const _ContextMenuItemRow({
    required this.item,
    required this.itemColor,
    required this.onTap,
  });

  @override
  State<_ContextMenuItemRow> createState() => _ContextMenuItemRowState();
}

class _ContextMenuItemRowState extends State<_ContextMenuItemRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInteractive = widget.item.isEnabled;

    Color? bg;
    if (_isHovered && isInteractive) {
      bg = widget.item.isDestructive
          ? AppColors.danger.withValues(alpha: 0.1)
          : (isDark ? colors.surfaceContainerHighest : colors.surfaceContainerLow);
    }

    return MouseRegion(
      onEnter: (_) {
        if (isInteractive) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (isInteractive) setState(() => _isHovered = false);
      },
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          color: bg ?? Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
          child: Row(
            children: [
              if (widget.item.icon != null) ...[
                TIcon(
                  icon: widget.item.icon,
                  size: 16,
                  color: widget.itemColor,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  widget.item.text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: widget.itemColor,
                  ),
                ),
              ),
              if (widget.item.shortcut != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.item.shortcut!,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Courier',
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
