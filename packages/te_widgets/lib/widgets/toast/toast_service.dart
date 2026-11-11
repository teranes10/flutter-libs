import 'dart:async';

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A service for displaying toast notifications.
///
/// `TToastService` provides toast messages with:
/// - Success, info, warning, and error variants
/// - Auto-dismiss with configurable duration
/// - Pause on hover
/// - Mobile and desktop positioning
/// - Custom icons and colors
///
/// ## Basic Usage
///
/// ```dart
/// TToastService.success(context, 'Operation completed!');
/// TToastService.error(context, 'Something went wrong');
/// ```
///
/// ## With Title
///
/// ```dart
/// TToastService.info(context, 'Your changes have been saved', 'Success');
/// ```
///
/// ## Custom Toast
///
/// ```dart
/// TToastService.show(
///   context,
///   'Custom message',
///   title: 'Custom Title',
///   icon: HugeIcons.strokeRoundedStar,
///   color: Colors.purple,
///   duration: Duration(seconds: 5),
/// )
/// ```
///
/// See also:
/// - [TAlert] for dialog alerts
class TToastService {
  /// Shows a custom toast notification.
  static void show(
    BuildContext context,
    String? message, {
    String? title,
    dynamic icon,
    Duration? duration,
    Alignment? alignment,
    Color? color,
    TVariant? type,
    TError? error,
  }) {
    if (!context.mounted) return;

    final theme = context.theme;
    final mColor = color ?? theme.primary;
    final wTheme = context.getWidgetTheme(type ?? theme.toastType, mColor);
    final isMobile = context.isMobile;

    final resolvedAlignment = alignment ?? (isMobile ? Alignment.topCenter : Alignment.topRight);
    _ToastHost.add(
      context,
      duration: duration ?? const Duration(seconds: 3),
      alignment: resolvedAlignment,
      dedupeKey: '$resolvedAlignment|$title|$message|${mColor.toARGB32()}',
      builder: (context, holder) {
        return Semantics(
          liveRegion: true,
          container: true,
          child: TCard(
            elevation: 8,
            backgroundColor: wTheme.container,
            shadowColor: wTheme.shadow,
            borderColor: wTheme.outline,
            margin: isMobile ? null : const EdgeInsets.fromLTRB(5, 5, 35, 2),
            padding: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: MouseRegion(
              onEnter: (_) => holder.pause(),
              onExit: (_) => holder.start(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: title != null ? 6 : 10),
                    child: Row(
                      children: [
                        if (icon != null) TIcon.raw(icon, color: wTheme.onContainer, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (title != null)
                                Text(title, style: TextStyle(color: wTheme.onContainer, fontWeight: FontWeight.w400, fontSize: 14)),
                              if (message != null)
                                Text(message, style: TextStyle(color: wTheme.onContainer, fontWeight: FontWeight.w300, fontSize: 13)),
                              if (error != null) TErrorBuilder(error: error, color: wTheme.onContainer, showIcon: false)
                            ],
                          ),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: holder.count,
                          builder: (context, count, _) => count > 1
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Text('×$count',
                                      style: TextStyle(color: wTheme.onContainer, fontWeight: FontWeight.w500, fontSize: 12)),
                                )
                              : const SizedBox.shrink(),
                        ),
                        TButton(
                          type: TButtonType.text,
                          size: TButtonSize.xxs,
                          icon: HugeIcons.strokeRoundedCancel01,
                          color: color,
                          onPressed: (_) => holder.dismiss(),
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: holder.remaining,
                    builder: (context, _) => LinearProgressIndicator(
                      value: holder.remaining.value,
                      minHeight: 2,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                      color: wTheme.onContainer.withValues(alpha: 0.5),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows a success toast.
  static void success(BuildContext context, String message, [String? title]) {
    show(context, message, title: title, icon: HugeIcons.strokeRoundedCheckmarkCircle03, color: context.theme.success);
  }

  /// Shows an info toast.
  static void info(BuildContext context, String message, [String? title]) {
    show(context, message, title: title, icon: HugeIcons.strokeRoundedInformationCircle, color: context.theme.info);
  }

  /// Shows a warning toast.
  static void warning(BuildContext context, String message, [String? title]) {
    show(context, message, title: title, icon: HugeIcons.strokeRoundedAlert01, color: context.theme.warning);
  }

  /// Shows an error toast.
  static void error(BuildContext context, String? message, [String? title, TError? error]) {
    show(context, message,
        title: title,
        icon: HugeIcons.strokeRoundedAlertCircle,
        color: context.theme.danger,
        error: error,
        duration: const Duration(seconds: 6));
  }
}

/// Controls a single visible toast (pause/resume the auto-close countdown, dismiss it).
class _ToastHolder {
  _ToastHolder(this.duration);

  final Duration duration;

  /// Fraction of the display time left, 1 -> 0. Set by the toast item before the first build.
  Animation<double> remaining = const AlwaysStoppedAnimation(1);
  VoidCallback? _onResume;
  VoidCallback? _onPause;
  VoidCallback? _onDismiss;
  VoidCallback? _onRestart;

  /// How many identical toasts were merged into this one.
  final ValueNotifier<int> count = ValueNotifier(1);
  bool closing = false;

  bool get attached => _onDismiss != null;

  void restart() => _onRestart?.call();
  void start() => _onResume?.call();
  void pause() => _onPause?.call();
  void dismiss() => _onDismiss?.call();
}

class _ToastEntry {
  _ToastEntry(this.alignment, this.holder, this.builder, this.dedupeKey);

  final Alignment alignment;
  final String dedupeKey;
  final _ToastHolder holder;
  final Widget Function(BuildContext context, _ToastHolder holder) builder;
}

/// Hosts all visible toasts in a single overlay entry, stacked per alignment.
class _ToastHost {
  static final ValueNotifier<List<_ToastEntry>> _toasts = ValueNotifier([]);
  static OverlayEntry? _entry;
  static OverlayState? _overlay;

  /// Maximum number of toasts visible at once per alignment; the oldest is dismissed beyond this.
  static const int maxVisible = 4;

  static void add(
    BuildContext context, {
    required Duration duration,
    required Alignment alignment,
    required String dedupeKey,
    required Widget Function(BuildContext context, _ToastHolder holder) builder,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    // (Re)create the host when there is none, or the overlay it lived in was replaced/disposed.
    if (_entry == null || _overlay != overlay || !_overlay!.mounted) {
      if (_overlay?.mounted ?? false) _entry?.remove();
      _toasts.value = [];
      _entry = OverlayEntry(builder: (_) => const _ToastLayer());
      _overlay = overlay;
      overlay.insert(_entry!);
    }

    final live = _toasts.value.where((e) => e.alignment == alignment && !e.holder.closing).toList();

    // Merge an identical toast into the one already showing instead of stacking a copy.
    for (final e in live) {
      if (e.dedupeKey == dedupeKey) {
        e.holder.count.value++;
        e.holder.restart();
        return;
      }
    }

    // Toasts added in this same frame have no widget yet (nothing to animate), so drop them outright.
    final dropped = <_ToastEntry>{};
    for (var i = 0; live.length - i >= maxVisible; i++) {
      if (live[i].holder.attached) {
        live[i].holder.dismiss();
      } else {
        dropped.add(live[i]);
      }
    }

    final entry = _ToastEntry(alignment, _ToastHolder(duration), builder, dedupeKey);
    _toasts.value = [..._toasts.value.where((e) => !dropped.contains(e)), entry];
  }

  static void remove(_ToastEntry entry) {
    _toasts.value = _toasts.value.where((e) => e != entry).toList();
  }
}

class _ToastLayer extends StatelessWidget {
  const _ToastLayer();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<_ToastEntry>>(
      valueListenable: _ToastHost._toasts,
      builder: (context, toasts, _) {
        final groups = <Alignment, List<_ToastEntry>>{};
        for (final t in toasts) {
          (groups[t.alignment] ??= []).add(t);
        }
        return Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Stack(
              children: [
                for (final g in groups.entries)
                  Align(
                    alignment: g.key,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        verticalDirection: g.key.y > 0 ? VerticalDirection.up : VerticalDirection.down,
                        children: [for (final t in g.value) _ToastItem(key: ObjectKey(t), entry: t)],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToastItem extends StatefulWidget {
  const _ToastItem({super.key, required this.entry});

  final _ToastEntry entry;

  @override
  State<_ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<_ToastItem> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  late final AnimationController _life = AnimationController(vsync: this, duration: widget.entry.holder.duration);
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    final holder = widget.entry.holder;
    holder.remaining = ReverseAnimation(_life);
    holder._onDismiss = _close;
    holder._onPause = _life.stop;
    holder._onRestart = () {
      if (!_closing) _life.forward(from: 0);
    };
    holder._onResume = () {
      if (!_closing && !_life.isCompleted) _life.forward();
    };
    _life.addStatusListener((status) {
      if (status == AnimationStatus.completed) _close();
    });
    _controller.forward();
    _life.forward();
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    widget.entry.holder.closing = true;
    _life.stop();
    if (mounted) await _controller.reverse();
    _ToastHost.remove(widget.entry);
  }

  @override
  void dispose() {
    _life.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Swiping away: the Dismissible already collapses the item, so just drop the entry afterwards.
  void _onSwiped(DismissDirection _) {
    _closing = true;
    widget.entry.holder.closing = true;
    _life.stop();
    _ToastHost.remove(widget.entry);
  }

  void _onDrag(DismissUpdateDetails details) {
    if (_closing) return;
    if (details.progress > 0) {
      _life.stop();
    } else if (!_life.isAnimating) {
      _life.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.entry.alignment;
    final sided = a.x.abs() > 0.3;
    final slideFrom = sided ? Offset(a.x > 0 ? 0.25 : -0.25, 0) : Offset(0, a.y > 0 ? 0.4 : -0.4);
    final eased = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

    return SizeTransition(
      sizeFactor: eased,
      alignment: Alignment(0, a.y > 0 ? 1 : -1),
      child: FadeTransition(
        opacity: eased,
        child: SlideTransition(
          position: Tween(begin: slideFrom, end: Offset.zero).animate(eased),
          child: Dismissible(
            key: ValueKey(widget.entry),
            direction: sided ? DismissDirection.horizontal : (a.y > 0 ? DismissDirection.down : DismissDirection.up),
            onUpdate: _onDrag,
            onDismissed: _onSwiped,
            child: widget.entry.builder(context, widget.entry.holder),
          ),
        ),
      ),
    );
  }
}
