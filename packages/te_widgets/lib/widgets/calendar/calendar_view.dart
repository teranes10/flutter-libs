import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// An event badge shown inside a [TCalendarView] day cell.
class TCalendarEvent {
  /// Short label shown on the day cell.
  final String label;

  /// Dot/badge color.
  final Color color;

  const TCalendarEvent({required this.label, this.color = Colors.blue});
}

/// A full month-grid calendar (Ant Design's `Calendar`), distinct from
/// [TDatePicker] which is a compact popup field for picking a single date.
/// Use this when the calendar grid itself is the primary content of the
/// page/panel (e.g. a scheduling or events admin screen).
///
/// ```dart
/// TCalendarView(
///   month: DateTime(2026, 10),
///   selectedDate: _selected,
///   eventsOf: (day) => _eventsByDate[day] ?? const [],
///   onDateSelected: (day) => setState(() => _selected = day),
/// )
/// ```
class TCalendarView extends StatelessWidget {
  /// Any date within the month to render.
  final DateTime month;

  /// Currently selected date, highlighted in the grid.
  final DateTime? selectedDate;

  /// Called when a day cell is tapped.
  final ValueChanged<DateTime>? onDateSelected;

  /// Returns the events to render on a given day's cell.
  final List<TCalendarEvent> Function(DateTime day)? eventsOf;

  /// Called when the user navigates to the previous/next month.
  final ValueChanged<DateTime>? onMonthChanged;

  /// Maximum events shown per cell before collapsing into a "+N" count.
  final int maxEventsPerCell;

  const TCalendarView({
    super.key,
    required this.month,
    this.selectedDate,
    this.onDateSelected,
    this.eventsOf,
    this.onMonthChanged,
    this.maxEventsPerCell = 2,
  });

  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = (firstOfMonth.weekday - DateTime.monday) % 7;
    final totalCells = leadingEmpty + daysInMonth;
    final trailingEmpty = (7 - (totalCells % 7)) % 7;
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: TIcon.raw(HugeIcons.strokeRoundedArrowLeft01),
              onPressed: () => onMonthChanged?.call(DateTime(month.year, month.month - 1)),
            ),
            Expanded(
              child: Text(
                '${_monthName(month.month)} ${month.year}',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: colors.onSurface),
              ),
            ),
            IconButton(
              icon: TIcon.raw(HugeIcons.strokeRoundedArrowRight01),
              onPressed: () => onMonthChanged?.call(DateTime(month.year, month.month + 1)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: _weekdayLabels
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = constraints.maxWidth / 7;
            final weekCount = ((leadingEmpty + daysInMonth + trailingEmpty) / 7).ceil();
            final gridBorder = colors.outlineVariant.o(0.5);

            const gridRadius = BorderRadius.all(Radius.circular(8));

            return ClipRRect(
              borderRadius: gridRadius,
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: gridBorder), borderRadius: gridRadius),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(weekCount, (week) {
                    final isLastRow = week == weekCount - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(7, (weekday) {
                          final index = week * 7 + weekday;
                          final isLastCol = weekday == 6;
                          final cellBorder = Border(
                            right: isLastCol ? BorderSide.none : BorderSide(color: gridBorder),
                            bottom: isLastRow ? BorderSide.none : BorderSide(color: gridBorder),
                          );

                          if (index < leadingEmpty || index >= leadingEmpty + daysInMonth) {
                            return Expanded(
                              child: Container(
                                constraints: BoxConstraints(minHeight: cellWidth / 2.5),
                                decoration: BoxDecoration(border: cellBorder),
                              ),
                            );
                          }

                          final day = DateTime(month.year, month.month, index - leadingEmpty + 1);
                          final isSelected = selectedDate != null && _isSameDay(day, selectedDate!);
                          final isToday = _isSameDay(day, today);
                          final events = eventsOf?.call(day) ?? const <TCalendarEvent>[];
                          final overflow = events.length - maxEventsPerCell;

                          return Expanded(
                            child: InkWell(
                              onTap: () => onDateSelected?.call(day),
                              child: Container(
                                constraints: BoxConstraints(minHeight: cellWidth / 2.5),
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primary.withValues(alpha: 0.14)
                                      : (isToday ? colors.primary.withValues(alpha: 0.06) : null),
                                  border: cellBorder,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? colors.primary : colors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    ...events.take(maxEventsPerCell).map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 0.5),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                            decoration: BoxDecoration(
                                                color: e.color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(3)),
                                            child: Text(
                                              e.label,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 9.5, color: e.color, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        )),
                                    if (overflow > 0)
                                      Text('+$overflow more', style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _monthName(int month) => const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][month - 1];
}
