import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class CalendarViewPage extends StatefulWidget {
  const CalendarViewPage({super.key});

  @override
  State<CalendarViewPage> createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> {
  DateTime _month = DateTime(2026, 10);
  DateTime? _selected;

  final Map<String, List<TCalendarEvent>> _events = {
    '2026-10-10': [TCalendarEvent(label: 'Release', color: Colors.indigo)],
    '2026-10-14': [
      TCalendarEvent(label: 'Standup', color: Colors.teal),
      TCalendarEvent(label: 'Review', color: Colors.orange),
      TCalendarEvent(label: 'Retro', color: Colors.purple),
    ],
    '2026-10-22': [TCalendarEvent(label: 'Deadline', color: Colors.red)],
  };

  String _key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TCalendarView Showcase', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Full month-grid calendar for scheduling/events admin screens — Ant Design\'s Calendar equivalent, '
            'distinct from the compact TDatePicker popup field.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          TCard(
            title: 'Events Calendar',
            child: TCalendarView(
              month: _month,
              selectedDate: _selected,
              eventsOf: (day) => _events[_key(day)] ?? const [],
              onDateSelected: (day) => setState(() => _selected = day),
              onMonthChanged: (month) => setState(() => _month = month),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selected == null ? 'No date selected' : 'Selected: ${_key(_selected!)}',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
