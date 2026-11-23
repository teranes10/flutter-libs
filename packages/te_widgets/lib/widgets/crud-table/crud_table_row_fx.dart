part of 'crud_table.dart';

enum _RowFxKind { added, updated, removing }

/// A pending row animation, keyed by item key (see [_TCrudTableState._rowFx]).
class _RowFx {
  final _RowFxKind kind;
  final DateTime started = DateTime.now();

  /// Set once a row widget has played the enter/flash animation, so rows rebuilt by scrolling do not replay it.
  bool played = false;

  _RowFx(this.kind);

  static const exitDuration = Duration(milliseconds: 320);
  static const enterDuration = Duration(milliseconds: 450);
  static const flashDuration = Duration(milliseconds: 1200);
}

/// Animates a single row: grows+fades in when added, flashes when updated, shrinks+fades out when removed.
class _TCrudRowFx extends StatefulWidget {
  /// Returns the pending animation of this row's item (read live, so it works even if the table is not rebuilt).
  final _RowFx? Function() lookup;
  final Listenable changes;
  final Widget child;

  const _TCrudRowFx({super.key, required this.lookup, required this.changes, required this.child});

  @override
  State<_TCrudRowFx> createState() => _TCrudRowFxState();
}

class _TCrudRowFxState extends State<_TCrudRowFx> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  _RowFx? _active;
  _RowFx? _seen;

  /// Keeps the row's state when the animation wrappers around it appear / disappear.
  final GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.changes.addListener(_sync);
    _start();
  }

  @override
  void didUpdateWidget(covariant _TCrudRowFx old) {
    super.didUpdateWidget(old);
    if (old.changes != widget.changes) {
      old.changes.removeListener(_sync);
      widget.changes.addListener(_sync);
    }
    _start();
  }

  void _sync() {
    if (!mounted) return;
    _start();
    setState(() {});
  }

  void _start() {
    final fx = widget.lookup();
    if (identical(fx, _seen)) return;
    _seen = fx;
    if (fx == null || fx.played && fx.kind != _RowFxKind.removing) return;
    fx.played = true;
    _active = fx;
    switch (fx.kind) {
      case _RowFxKind.added:
        _c.duration = _RowFx.enterDuration;
        _c.forward(from: 0);
      case _RowFxKind.updated:
        _c.duration = _RowFx.flashDuration;
        _c.forward(from: 0);
      case _RowFxKind.removing:
        _c.duration = _RowFx.exitDuration;
        final elapsed = DateTime.now().difference(fx.started).inMilliseconds / _RowFx.exitDuration.inMilliseconds;
        _c.forward(from: elapsed.clamp(0.0, 1.0));
    }
  }

  @override
  void dispose() {
    widget.changes.removeListener(_sync);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fx = _active;
    final keyed = KeyedSubtree(key: _childKey, child: widget.child);
    if (fx == null) return keyed;
    final accent = context.colors.primary;
    final radius = BorderRadius.circular(12);

    return AnimatedBuilder(
      animation: _c,
      child: keyed,
      builder: (context, child) {
        final t = _c.value;
        switch (fx.kind) {
          case _RowFxKind.added:
            final e = Curves.easeOutCubic.transform(t);
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: e,
                child: Opacity(
                  opacity: e,
                  child: Transform.translate(
                    offset: Offset(0, (1 - e) * -12),
                    child: _flash(child!, accent, radius, (1 - t).clamp(0.0, 1.0) * 0.18),
                  ),
                ),
              ),
            );
          case _RowFxKind.updated:
            // Cells flip on their own (see _TCellFlip); the row only gets a soft accent wash.
            final a = t < 0.15 ? t / 0.15 : 1 - Curves.easeOut.transform((t - 0.15) / 0.85);
            return _flash(child!, accent, radius, a.clamp(0.0, 1.0) * 0.14);
          case _RowFxKind.removing:
            final e = Curves.easeInCubic.transform(t);
            return IgnorePointer(
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 1 - e,
                  child: Opacity(
                    opacity: 1 - e,
                    child: Transform.translate(offset: Offset(e * 40, 0), child: child),
                  ),
                ),
              ),
            );
        }
      },
    );
  }

  Widget _flash(Widget child, Color color, BorderRadius radius, double alpha) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(borderRadius: radius, color: color.withValues(alpha: alpha)),
      child: child,
    );
  }
}

extension _TCrudTableRowFxExt<T, K, F extends TFormBase> on _TCrudTableState<T, K, F> {
  bool get _animate => widget.config.animateChanges;

  Map<K, _RowFx> _fxOf(TListController<T, K> c) => _rowFx.putIfAbsent(c, () => <K, _RowFx>{});

  /// Wraps [row] so it plays the pending animation (if any) of [controller]'s item.
  Widget Function(BuildContext, TListItem<T, K>, int, Widget) _fxRowBuilder(TListController<T, K> controller) {
    return (ctx, item, index, row) {
      final inner = widget.rowBuilder?.call(ctx, item, index, row) ?? row;
      if (!_animate) return inner;
      return _TCrudRowFx(
        key: ValueKey('rowfx_${item.key}'),
        lookup: () => _rowFx[controller]?[item.key],
        changes: _rowFxTick,
        child: inner,
      );
    };
  }

  void _markFx(TListController<T, K> controller, K key, _RowFxKind kind) {
    if (!_animate) return;
    final fx = _RowFx(kind);
    _fxOf(controller)[key] = fx;
    _rowFxTick.value++;
    final life = kind == _RowFxKind.updated ? _RowFx.flashDuration : _RowFx.enterDuration;
    Future<void>.delayed(life + const Duration(milliseconds: 100), () {
      if (_rowFx[controller]?[key] == fx) _rowFx[controller]?.remove(key);
    });
  }

  /// Lets a closing dialog / overlay get out of the way so the row animation is actually seen.
  Future<void> _afterDetailsClose() async {
    if (_animate) await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  void _animatedAdd(TListController<T, K> controller, T item) {
    _markFx(controller, controller.itemKey(item), _RowFxKind.added);
    controller.addItem(item);
  }

  void _animatedUpdate(TListController<T, K> controller, T oldItem, T newItem) {
    _markFx(controller, controller.itemKey(oldItem), _RowFxKind.updated);
    controller.updateItem(oldItem, newItem);
  }

  /// Plays the exit animation, then removes [item] from [controller].
  Future<void> _animatedRemove(TListController<T, K> controller, T item) async {
    final key = controller.itemKey(item);
    if (_animate && mounted && controller.getItem(key) != null) {
      final fx = _RowFx(_RowFxKind.removing);
      _fxOf(controller)[key] = fx;
      _rowFxTick.value++;
      await Future<void>.delayed(_RowFx.exitDuration);
      _rowFx[controller]?.remove(key);
      if (!mounted) return;
    }
    controller.removeItem(item);
  }
}
