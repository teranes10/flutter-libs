import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';

/// How a [TCalendarPicker] selects dates.
enum TCalendarSelection { single, range }

enum _CalendarView { days, months, years }

/// A month-grid calendar for picking one date or a date range.
///
/// Used by [TDatePicker], [TDateTimePicker] and [TDateRangePicker]; also usable on its own.
///
/// ```dart
/// TCalendarPicker.single(value: date, onChanged: (d) => setState(() => date = d));
/// TCalendarPicker.range(start: a, end: b, onRangeChanged: (s, e) => ...);
/// ```
///
/// In range mode the first tap sets the start, the second sets the end (a tap before the start moves the start);
/// a tap after a complete range starts a new one. [onRangeChanged] reports `end == null` while the range is incomplete.
class TCalendarPicker extends StatefulWidget {
  final TCalendarSelection selection;

  /// Selected date (single mode) or range start (range mode).
  final DateTime? start;

  /// Range end (range mode only).
  final DateTime? end;

  final ValueChanged<DateTime>? onChanged;
  final void Function(DateTime start, DateTime? end)? onRangeChanged;

  /// Selectable bounds. Default 1900-01-01 to 2100-12-31.
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// First weekday column (`DateTime.monday` .. `DateTime.sunday`). Defaults to Monday.
  final int firstDayOfWeek;

  const TCalendarPicker.single({
    super.key,
    DateTime? value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.firstDayOfWeek = DateTime.monday,
  })  : selection = TCalendarSelection.single,
        start = value,
        end = null,
        onRangeChanged = null;

  const TCalendarPicker.range({
    super.key,
    this.start,
    this.end,
    this.onRangeChanged,
    this.firstDate,
    this.lastDate,
    this.firstDayOfWeek = DateTime.monday,
  })  : selection = TCalendarSelection.range,
        onChanged = null;

  @override
  State<TCalendarPicker> createState() => _TCalendarPickerState();
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

class _TCalendarPickerState extends State<TCalendarPicker> {
  late DateTime _month; // first day of the displayed month
  _CalendarView _view = _CalendarView.days;
  DateTime? _hover;

  DateTime get _first => _day(widget.firstDate ?? DateTime(1900));
  DateTime get _last => _day(widget.lastDate ?? DateTime(2100, 12, 31));

  @override
  void initState() {
    super.initState();
    final anchor = widget.start ?? DateTime.now();
    _month = DateTime(anchor.year, anchor.month);
  }

  @override
  void didUpdateWidget(covariant TCalendarPicker old) {
    super.didUpdateWidget(old);
    // Follow an externally changed selection (e.g. typed into the field) into view.
    if (widget.start != null && widget.start != old.start) {
      final s = widget.start!;
      if (s.year != _month.year || s.month != _month.month) _month = DateTime(s.year, s.month);
    }
  }

  bool _enabled(DateTime d) => !d.isBefore(_first) && !d.isAfter(_last);

  void _select(DateTime d) {
    final day = _day(d);
    if (!_enabled(day)) return;
    if (widget.selection == TCalendarSelection.single) {
      widget.onChanged?.call(day);
      return;
    }
    final s = widget.start == null ? null : _day(widget.start!);
    final e = widget.end == null ? null : _day(widget.end!);
    if (s == null || e != null) {
      widget.onRangeChanged?.call(day, null);
    } else if (day.isBefore(s)) {
      widget.onRangeChanged?.call(day, null);
    } else {
      widget.onRangeChanged?.call(s, day);
    }
  }

  void _shiftMonth(int delta) => setState(() => _month = DateTime(_month.year, _month.month + delta));

  bool get _canPrev => DateTime(_month.year, _month.month).isAfter(DateTime(_first.year, _first.month));
  bool get _canNext => DateTime(_month.year, _month.month).isBefore(DateTime(_last.year, _last.month));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(context),
        const SizedBox(height: 8),
        switch (_view) {
          _CalendarView.days => _days(context),
          _CalendarView.months => _months(context),
          _CalendarView.years => _years(context),
        },
      ],
    );
  }

  Widget _header(BuildContext context) {
    final colors = context.colors;
    final days = _view == _CalendarView.days;
    Widget chip(String text, _CalendarView target) => _Tappable(
          onTap: () => setState(() => _view = _view == target ? _CalendarView.days : target),
          borderRadius: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.onSurface)),
                const SizedBox(width: 4),
                TIcon.raw(HugeIcons.strokeRoundedArrowDown01, size: 16, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        );
    return Row(
      children: [
        if (days)
          TIcon.raw(HugeIcons.strokeRoundedArrowLeft01,
              size: 20,
              color: _canPrev ? colors.onSurface : colors.onSurface.withAlpha(60),
              onTap: _canPrev ? () => _shiftMonth(-1) : null),
        Expanded(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                chip('${_month.year}', _CalendarView.years),
                const SizedBox(width: 12),
                chip(DateFormat('MMMM').format(_month), _CalendarView.months),
              ],
            ),
          ),
        ),
        if (days)
          TIcon.raw(HugeIcons.strokeRoundedArrowRight01,
              size: 20, color: _canNext ? colors.onSurface : colors.onSurface.withAlpha(60), onTap: _canNext ? () => _shiftMonth(1) : null),
      ],
    );
  }

  Widget _days(BuildContext context) {
    final colors = context.colors;
    final today = _day(DateTime.now());
    final offset = (_month.weekday - widget.firstDayOfWeek + 7) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final rows = ((offset + daysInMonth) / 7).ceil();

    final s = widget.start == null ? null : _day(widget.start!);
    final e = widget.end == null ? null : _day(widget.end!);
    // While the range is incomplete, preview it up to the hovered day.
    final previewEnd =
        e ?? (widget.selection == TCalendarSelection.range && s != null && _hover != null && !_hover!.isBefore(s) ? _hover : null);

    // 2024-01-01 is a Monday: a stable reference for localized weekday initials.
    final labels = [
      for (var i = 0; i < 7; i++) DateFormat.E().format(DateTime(2024, 1, 1 + (widget.firstDayOfWeek - 1 + i))).substring(0, 2),
    ];

    return MouseRegion(
      onExit: (_) => setState(() => _hover = null),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (final l in labels)
                Expanded(
                  child: Center(
                    child: Text(l, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var r = 0; r < rows; r++)
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: Builder(builder: (context) {
                      final dayNum = r * 7 + c - offset + 1;
                      if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox(height: 40);
                      final date = DateTime(_month.year, _month.month, dayNum);
                      final isStart = s != null && date == s;
                      final isEnd = (e ?? previewEnd) != null && date == (e ?? previewEnd);
                      final inRange = widget.selection == TCalendarSelection.range &&
                          s != null &&
                          previewEnd != null &&
                          date.isAfter(s) &&
                          date.isBefore(previewEnd);
                      return _DayCell(
                        date: date,
                        enabled: _enabled(date),
                        isToday: date == today,
                        selected: widget.selection == TCalendarSelection.single ? isStart : (isStart || (e != null && isEnd)),
                        rangeStart: widget.selection == TCalendarSelection.range && isStart && previewEnd != null && previewEnd != s,
                        rangeEnd: widget.selection == TCalendarSelection.range && isEnd && s != null && date != s,
                        inRange: inRange,
                        // The previewed end (hover) is drawn as a band end, not a filled circle.
                        previewEnd: e == null && isEnd && date != s,
                        onTap: () => _select(date),
                        onHover: widget.selection == TCalendarSelection.range ? () => setState(() => _hover = date) : null,
                      );
                    }),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _months(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    return _Grid(
      count: 12,
      builder: (i) {
        final m = DateTime(_month.year, i + 1);
        final enabled = !DateTime(m.year, m.month + 1).isBefore(_first) && !m.isAfter(_last);
        return _GridCell(
          label: DateFormat.MMM().format(m),
          selected: m.year == (widget.start ?? now).year && m.month == (widget.start ?? now).month && widget.start != null,
          current: m.year == now.year && m.month == now.month,
          enabled: enabled,
          onTap: () => setState(() {
            _month = m;
            _view = _CalendarView.days;
          }),
          colors: colors,
        );
      },
    );
  }

  Widget _years(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    final count = _last.year - _first.year + 1;
    // A scrollable 4-column grid, opened scrolled to the displayed year.
    final rowsBefore = ((_month.year - _first.year) ~/ 4);
    return SizedBox(
      height: 240,
      child: GridView.builder(
        controller: ScrollController(initialScrollOffset: (rowsBefore * 48.0 - 96).clamp(0, double.infinity)),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisExtent: 48),
        itemCount: count,
        itemBuilder: (context, i) {
          final year = _first.year + i;
          return _GridCell(
            label: '$year',
            selected: widget.start?.year == year,
            current: year == now.year,
            enabled: true,
            onTap: () => setState(() {
              _month = DateTime(year, _month.month);
              _view = _CalendarView.months;
            }),
            colors: colors,
          );
        },
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final int count;
  final Widget Function(int) builder;

  const _Grid({required this.count, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < count / 4; r++)
          Row(children: [for (var c = 0; c < 4; c++) Expanded(child: SizedBox(height: 48, child: builder(r * 4 + c)))]),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  final String label;
  final bool selected, current, enabled;
  final VoidCallback onTap;
  final ColorScheme colors;

  const _GridCell({
    required this.label,
    required this.selected,
    required this.current,
    required this.enabled,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: _Tappable(
        onTap: enabled ? onTap : null,
        borderRadius: 10,
        color: selected ? colors.primary : null,
        border: current && !selected ? Border.all(color: colors.primary.withAlpha(150)) : null,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? colors.onPrimary : (enabled ? colors.onSurface : colors.onSurface.withAlpha(70)),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool enabled, isToday, selected, rangeStart, rangeEnd, inRange, previewEnd;
  final VoidCallback onTap;
  final VoidCallback? onHover;

  const _DayCell({
    required this.date,
    required this.enabled,
    required this.isToday,
    required this.selected,
    required this.rangeStart,
    required this.rangeEnd,
    required this.inRange,
    required this.previewEnd,
    required this.onTap,
    this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final band = colors.primary.withAlpha(colors.isDarkMode ? 55 : 38);
    final fg = selected
        ? colors.onPrimary
        : !enabled
            ? colors.onSurface.withAlpha(70)
            : (inRange || previewEnd)
                ? colors.onSurface
                : (isToday ? colors.primary : colors.onSurface);

    // The band runs edge to edge through the cell; start/end halves are capped by the circle.
    final bandLeft = inRange || rangeEnd || previewEnd;
    final bandRight = inRange || rangeStart;

    return MouseRegion(
      onEnter: (_) => onHover?.call(),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (bandLeft || bandRight)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: ColoredBox(color: bandLeft ? band : Colors.transparent)),
                        Expanded(child: ColoredBox(color: bandRight ? band : Colors.transparent)),
                      ],
                    ),
                  ),
                ),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? colors.primary : (previewEnd ? band : null),
                  border: isToday && !selected ? Border.all(color: colors.primary.withAlpha(150)) : null,
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle(fontSize: 13, fontWeight: selected || isToday ? FontWeight.w600 : FontWeight.w400, color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal hover-aware tap target (no Material ancestor needed).
class _Tappable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final BoxBorder? border;

  const _Tappable({required this.child, required this.onTap, this.borderRadius = 8, this.color, this.border});

  @override
  State<_Tappable> createState() => _TappableState();
}

class _TappableState extends State<_Tappable> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = widget.onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.color ?? (_hover && enabled ? colors.onSurface.withAlpha(18) : null),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
