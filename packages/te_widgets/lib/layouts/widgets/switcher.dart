import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Where a context switcher is drawn; passed to [TSwitcherBuilder].
enum TSwitcherVariant {
  /// Full-width row under the sidebar logo.
  full,

  /// Avatar only, under the minified sidebar logo.
  minified,

  /// Compact pill after the logo in the top bar (no sidebar).
  compact,
}

/// Builds the context switcher for a given [TSwitcherVariant]. See `TLayout.switcher`.
typedef TSwitcherBuilder = Widget Function(TSwitcherVariant variant);

/// One entry of a [TSwitcher].
class TSwitcherOption {
  const TSwitcherOption({required this.id, required this.name, this.subtitle});

  final String id;
  final String name;
  final String? subtitle;
}

/// Dropdown to change the active context (workspace, tenant, company, project...).
///
/// Use it inside `TLayout.switcher`:
/// ```dart
/// switcher: (variant) => TSwitcher(
///   variant: variant,
///   options: options,
///   selectedId: current,
///   onChanged: (w) => setState(() => current = w.id),
/// )
/// ```
class TSwitcher extends StatelessWidget {
  const TSwitcher({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    this.variant = TSwitcherVariant.full,
  });

  final List<TSwitcherOption> options;
  final String selectedId;
  final ValueChanged<TSwitcherOption> onChanged;
  final TSwitcherVariant variant;

  Widget _avatar(BuildContext context, TSwitcherOption w, {double size = 28}) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(7)),
      child: Text(
        w.name.isEmpty ? '?' : w.name[0].toUpperCase(),
        style: TextStyle(fontSize: size * 0.46, fontWeight: FontWeight.w700, color: colors.onPrimaryContainer, height: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final current = options.firstWhere((w) => w.id == selectedId, orElse: () => options.first);
    final fill = colors.onSurface.withAlpha(14);
    final chevron = TIcon.raw(HugeIcons.strokeRoundedUnfoldMore, size: 16, color: colors.onSurfaceVariant);

    final Widget trigger = switch (variant) {
      TSwitcherVariant.minified => TTooltip(message: current.name, child: _avatar(context, current, size: 36)),
      TSwitcherVariant.compact => Container(
          padding: const EdgeInsets.fromLTRB(4, 3, 8, 3),
          decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              _avatar(context, current, size: 22),
              Text(current.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              chevron,
            ],
          ),
        ),
      TSwitcherVariant.full => Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(10)),
          child: Row(
            spacing: 10,
            children: [
              _avatar(context, current),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(current.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    if (current.subtitle != null)
                      Text(
                        current.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              chevron,
            ],
          ),
        ),
    };

    return TPopover(
      alignment: variant == TSwitcherVariant.minified ? TPopupAlignment.rightTop : TPopupAlignment.bottomLeft,
      padding: const EdgeInsets.all(6),
      minWidth: 170,
      maxWidth: 220,
      builder: (context, close) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final w in options)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                close();
                if (w.id != selectedId) onChanged(w);
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  spacing: 10,
                  children: [
                    _avatar(context, w, size: 26),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          if (w.subtitle != null) Text(w.subtitle!, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    if (w.id == selectedId) TIcon.raw(HugeIcons.strokeRoundedTick02, size: 16, color: colors.primary),
                  ],
                ),
              ),
            ),
        ],
      ),
      child: MouseRegion(cursor: SystemMouseCursors.click, child: trigger),
    );
  }
}
