import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page showcasing date and time picker widgets.
class PickersPage extends StatefulWidget {
  const PickersPage({super.key});

  @override
  State<PickersPage> createState() => _PickersPageState();
}

class _PickersPageState extends State<PickersPage> {
  // DatePicker notifiers
  final _birthDateNotifier = ValueNotifier<DateTime?>(null);
  final _appointmentDateNotifier = ValueNotifier<DateTime?>(null);

  // TimePicker notifiers
  final _meetingTimeNotifier = ValueNotifier<TimeOfDay?>(null);
  final _alarmTimeNotifier = ValueNotifier<TimeOfDay?>(TimeOfDay(hour: 7, minute: 0));

  // DateTimePicker notifiers
  final _eventStartNotifier = ValueNotifier<DateTime?>(null);
  final _deliveryTimeNotifier = ValueNotifier<DateTime?>(null);

  // Booking system example
  final _checkInNotifier = ValueNotifier<DateTime?>(null);
  final _checkOutNotifier = ValueNotifier<DateTime?>(null);

  @override
  void dispose() {
    _birthDateNotifier.dispose();
    _appointmentDateNotifier.dispose();
    _meetingTimeNotifier.dispose();
    _alarmTimeNotifier.dispose();
    _eventStartNotifier.dispose();
    _deliveryTimeNotifier.dispose();
    _checkInNotifier.dispose();
    _checkOutNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Picker Components',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Date, time, and datetime pickers with calendar and clock interfaces.',
            style: TextStyle(
              fontSize: 13,
              color: context.colors.onSurface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 32),

          // ==================== DATE PICKER ====================

          // Basic Date Picker
          WidgetDocCard(
            title: 'Date Picker',
            description: 'Calendar-based date selection with formatted display',
            icon: Icons.calendar_today,
            preview: TDatePicker(
              label: 'Birth Date',
              placeholder: 'Select your birth date',
              valueNotifier: _birthDateNotifier,
            ),
            code: '''TDatePicker(
  label: 'Birth Date',
  placeholder: 'Select your birth date',
  onValueChanged: (date) {
    print('Selected date: \$date');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'label',
                type: 'String?',
                description: 'Label text displayed above the field',
              ),
              PropertyDoc(
                name: 'placeholder',
                type: 'String?',
                description: 'Placeholder text when no date is selected',
              ),
              PropertyDoc(
                name: 'format',
                type: 'DateFormat?',
                defaultValue: "DateFormat('MMM dd, yyyy')",
                description: 'Custom date format for display',
              ),
              PropertyDoc(
                name: 'onValueChanged',
                type: 'ValueChanged<DateTime?>?',
                description: 'Callback fired when date changes',
              ),
            ],
          ),

          // Date Picker with Range
          WidgetDocCard(
            title: 'Date Picker with Range Constraints',
            description: 'Restrict selectable dates to a specific range',
            icon: Icons.date_range,
            preview: TDatePicker(
              label: 'Appointment Date',
              placeholder: 'Select appointment date',
              valueNotifier: _appointmentDateNotifier,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 90)),
              isRequired: true,
            ),
            code: '''TDatePicker(
  label: 'Appointment Date',
  placeholder: 'Select appointment date',
  firstDate: DateTime.now(), // Cannot select past dates
  lastDate: DateTime.now().add(Duration(days: 90)), // Max 90 days ahead
  isRequired: true,
  onValueChanged: (date) {
    print('Appointment: \$date');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'firstDate',
                type: 'DateTime?',
                description: 'The earliest selectable date',
              ),
              PropertyDoc(
                name: 'lastDate',
                type: 'DateTime?',
                description: 'The latest selectable date',
              ),
              PropertyDoc(
                name: 'isRequired',
                type: 'bool',
                defaultValue: 'false',
                description: 'Shows required indicator (*)',
              ),
            ],
          ),

          // Date Picker with Custom Format
          WidgetDocCard(
            title: 'Date Picker with Custom Format',
            description: 'Use custom date formatting patterns',
            icon: Icons.format_paint,
            preview: TDatePicker(
              label: 'Event Date',
              placeholder: 'dd/MM/yyyy',
              format: DateFormat('dd/MM/yyyy'),
              valueNotifier: ValueNotifier<DateTime?>(null),
            ),
            code: '''import 'package:intl/intl.dart';

TDatePicker(
  label: 'Event Date',
  placeholder: 'dd/MM/yyyy',
  format: DateFormat('dd/MM/yyyy'), // e.g., "31/12/2024"
  onValueChanged: (date) => print(date),
)

// Other format examples:
// DateFormat('yyyy-MM-dd')        // "2024-12-31"
// DateFormat('EEEE, MMMM d, y')   // "Tuesday, December 31, 2024"
// DateFormat('MMM d, yyyy')       // "Dec 31, 2024" (default)''',
            properties: const [
              PropertyDoc(
                name: 'format',
                type: 'DateFormat?',
                description: 'Custom DateFormat from intl package',
              ),
            ],
          ),

          // Date Picker with Validation
          WidgetDocCard(
            title: 'Date Picker with Validation',
            description: 'Add validation rules to ensure data integrity',
            icon: Icons.verified,
            preview: TDatePicker(
              label: 'Start Date',
              placeholder: 'Select start date',
              isRequired: true,
              valueNotifier: ValueNotifier<DateTime?>(null),
              rules: [
                (date) {
                  if (date == null) return 'Date is required';
                  if (date.isBefore(DateTime.now())) {
                    return 'Date cannot be in the past';
                  }
                  return null;
                },
              ],
            ),
            code: '''TDatePicker(
  label: 'Start Date',
  placeholder: 'Select start date',
  isRequired: true,
  rules: [
    (date) {
      if (date == null) return 'Date is required';
      if (date.isBefore(DateTime.now())) {
        return 'Date cannot be in the past';
      }
      return null; // Valid
    },
  ],
  validationDebounce: Duration(milliseconds: 300),
)''',
            properties: const [
              PropertyDoc(
                name: 'rules',
                type: 'List<String? Function(DateTime?)>?',
                description: 'Validation rules. Each returns error message or null',
              ),
              PropertyDoc(
                name: 'validationDebounce',
                type: 'Duration?',
                description: 'Delay validation after user interaction',
              ),
            ],
          ),

          // ==================== TIME PICKER ====================

          // Basic Time Picker
          WidgetDocCard(
            title: 'Time Picker',
            description: 'Clock-style time selection with formatted display',
            icon: Icons.access_time,
            preview: TTimePicker(
              label: 'Meeting Time',
              placeholder: 'Select meeting time',
              valueNotifier: _meetingTimeNotifier,
            ),
            code: '''TTimePicker(
  label: 'Meeting Time',
  placeholder: 'Select meeting time',
  onValueChanged: (time) {
    print('Selected time: \${time?.format(context)}');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'label',
                type: 'String?',
                description: 'Label text displayed above the field',
              ),
              PropertyDoc(
                name: 'placeholder',
                type: 'String?',
                description: 'Placeholder text when no time is selected',
              ),
              PropertyDoc(
                name: 'format',
                type: 'DateFormat?',
                defaultValue: "DateFormat('hh:mm a')",
                description: 'Custom time format for display',
              ),
              PropertyDoc(
                name: 'onValueChanged',
                type: 'ValueChanged<TimeOfDay?>?',
                description: 'Callback fired when time changes',
              ),
            ],
          ),

          // Time Picker with 24-hour format
          WidgetDocCard(
            title: 'Time Picker - 24 Hour Format',
            description: 'Display time in 24-hour format instead of 12-hour',
            icon: Icons.schedule,
            preview: TTimePicker(
              label: 'Start Time',
              placeholder: 'HH:mm',
              format: DateFormat('HH:mm'),
              valueNotifier: ValueNotifier<TimeOfDay?>(null),
            ),
            code: '''import 'package:intl/intl.dart';

TTimePicker(
  label: 'Start Time',
  format: DateFormat('HH:mm'), // 24-hour format (e.g., "14:30")
  onValueChanged: (time) => print(time),
)

// Default format: DateFormat('hh:mm a') // 12-hour (e.g., "02:30 PM")''',
            properties: const [
              PropertyDoc(
                name: 'format',
                type: 'DateFormat?',
                description: 'Custom DateFormat for time display',
              ),
            ],
          ),

          // Time Picker with Initial Value
          WidgetDocCard(
            title: 'Time Picker with Initial Value',
            description: 'Set a default time value',
            icon: Icons.alarm,
            preview: TTimePicker(
              label: 'Alarm Time',
              placeholder: 'Set alarm',
              valueNotifier: _alarmTimeNotifier,
            ),
            code: '''TTimePicker(
  label: 'Alarm Time',
  value: TimeOfDay(hour: 7, minute: 0), // 7:00 AM
  onValueChanged: (time) => print(time),
)''',
            properties: const [
              PropertyDoc(
                name: 'value',
                type: 'TimeOfDay?',
                description: 'Initial time value',
              ),
              PropertyDoc(
                name: 'valueNotifier',
                type: 'ValueNotifier<TimeOfDay?>?',
                description: 'Two-way binding with ValueNotifier',
              ),
            ],
          ),

          // Time Picker with Validation
          WidgetDocCard(
            title: 'Time Picker with Business Hours Validation',
            description: 'Validate time selection within specific hours',
            icon: Icons.business,
            preview: TTimePicker(
              label: 'Office Hours',
              placeholder: 'Select time',
              isRequired: true,
              valueNotifier: ValueNotifier<TimeOfDay?>(null),
              rules: [
                (time) {
                  if (time == null) return 'Time is required';
                  if (time.hour < 9 || time.hour >= 17) {
                    return 'Please select between 9 AM and 5 PM';
                  }
                  return null;
                },
              ],
            ),
            code: '''TTimePicker(
  label: 'Office Hours',
  isRequired: true,
  rules: [
    (time) {
      if (time == null) return 'Time is required';
      
      // Validate business hours (9 AM - 5 PM)
      if (time.hour < 9 || time.hour >= 17) {
        return 'Please select between 9 AM and 5 PM';
      }
      return null;
    },
  ],
)''',
            properties: const [
              PropertyDoc(
                name: 'rules',
                type: 'List<String? Function(TimeOfDay?)>?',
                description: 'Validation rules for time selection',
              ),
            ],
          ),

          // ==================== DATE TIME PICKER ====================

          // Basic DateTime Picker
          WidgetDocCard(
            title: 'DateTime Picker',
            description: 'Combined date and time selection with tabbed interface',
            icon: Icons.event_available,
            preview: TDateTimePicker(
              label: 'Event Start',
              placeholder: 'Select date and time',
              valueNotifier: _eventStartNotifier,
            ),
            code: '''TDateTimePicker(
  label: 'Event Start',
  placeholder: 'Select date and time',
  onValueChanged: (dateTime) {
    print('Selected: \$dateTime');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'label',
                type: 'String?',
                description: 'Label text displayed above the field',
              ),
              PropertyDoc(
                name: 'placeholder',
                type: 'String?',
                description: 'Placeholder text when no datetime is selected',
              ),
              PropertyDoc(
                name: 'format',
                type: 'DateFormat?',
                defaultValue: "DateFormat('MMM dd, yyyy hh:mm a')",
                description: 'Custom datetime format for display',
              ),
              PropertyDoc(
                name: 'onValueChanged',
                type: 'ValueChanged<DateTime?>?',
                description: 'Callback fired when datetime changes',
              ),
            ],
          ),

          // DateTime Picker with Custom Format
          WidgetDocCard(
            title: 'DateTime Picker with Custom Format',
            description: 'Use custom datetime formatting patterns',
            icon: Icons.edit_calendar,
            preview: TDateTimePicker(
              label: 'Delivery Time',
              placeholder: 'dd/MM/yyyy HH:mm',
              format: DateFormat('dd/MM/yyyy HH:mm'),
              valueNotifier: _deliveryTimeNotifier,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 30)),
            ),
            code: '''import 'package:intl/intl.dart';

TDateTimePicker(
  label: 'Delivery Time',
  format: DateFormat('dd/MM/yyyy HH:mm'), // e.g., "31/12/2024 14:30"
  firstDate: DateTime.now(),
  lastDate: DateTime.now().add(Duration(days: 30)),
  onValueChanged: (dateTime) {
    print('Delivery: \$dateTime');
  },
)

// Other format examples:
// DateFormat('MMM dd, yyyy hh:mm a')     // "Dec 31, 2024 02:30 PM" (default)
// DateFormat('yyyy-MM-dd HH:mm:ss')      // "2024-12-31 14:30:00"
// DateFormat('EEEE, MMM d @ h:mm a')     // "Tuesday, Dec 31 @ 2:30 PM"''',
            properties: const [
              PropertyDoc(
                name: 'format',
                type: 'DateFormat?',
                description: 'Custom DateFormat for datetime display',
              ),
              PropertyDoc(
                name: 'firstDate',
                type: 'DateTime?',
                description: 'The earliest selectable date',
              ),
              PropertyDoc(
                name: 'lastDate',
                type: 'DateTime?',
                description: 'The latest selectable date',
              ),
            ],
          ),

          // DateTime Picker with Advanced Validation
          WidgetDocCard(
            title: 'DateTime Picker with Advanced Validation',
            description: 'Complex validation rules for datetime selection',
            icon: Icons.rule,
            preview: TDateTimePicker(
              label: 'Appointment',
              placeholder: 'Select appointment time',
              isRequired: true,
              valueNotifier: ValueNotifier<DateTime?>(null),
              rules: [
                (dateTime) {
                  if (dateTime == null) return 'Date and time are required';

                  // Must be at least 24 hours in the future
                  final minDateTime = DateTime.now().add(Duration(hours: 24));
                  if (dateTime.isBefore(minDateTime)) {
                    return 'Must be scheduled at least 24 hours in advance';
                  }

                  // Must be during business hours
                  if (dateTime.hour < 9 || dateTime.hour >= 17) {
                    return 'Must be during business hours (9 AM - 5 PM)';
                  }

                  return null;
                },
              ],
            ),
            code: '''TDateTimePicker(
  label: 'Appointment',
  isRequired: true,
  rules: [
    (dateTime) {
      if (dateTime == null) return 'Date and time are required';
      
      // Must be at least 24 hours in the future
      final minDateTime = DateTime.now().add(Duration(hours: 24));
      if (dateTime.isBefore(minDateTime)) {
        return 'Must be scheduled at least 24 hours in advance';
      }
      
      // Must be during business hours
      if (dateTime.hour < 9 || dateTime.hour >= 17) {
        return 'Must be during business hours (9 AM - 5 PM)';
      }
      
      return null;
    },
  ],
)''',
            properties: const [
              PropertyDoc(
                name: 'rules',
                type: 'List<String? Function(DateTime?)>?',
                description: 'Validation rules for datetime selection',
              ),
            ],
          ),

          // ==================== ADVANCED EXAMPLES ====================

          // Booking System Example
          WidgetDocCard(
            title: 'Advanced: Booking System',
            description: 'Check-in and check-out dates with dependent validation',
            icon: Icons.hotel,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TDatePicker(
                  label: 'Check-in Date',
                  placeholder: 'Select check-in date',
                  valueNotifier: _checkInNotifier,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<DateTime?>(
                  valueListenable: _checkInNotifier,
                  builder: (context, checkInDate, _) {
                    return TDatePicker(
                      label: 'Check-out Date',
                      placeholder: 'Select check-out date',
                      valueNotifier: _checkOutNotifier,
                      firstDate: checkInDate?.add(Duration(days: 1)) ?? DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      isRequired: true,
                      disabled: checkInDate == null,
                    );
                  },
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<DateTime?>(
                  valueListenable: _checkInNotifier,
                  builder: (context, checkIn, _) {
                    return ValueListenableBuilder<DateTime?>(
                      valueListenable: _checkOutNotifier,
                      builder: (context, checkOut, _) {
                        if (checkIn != null && checkOut != null) {
                          final nights = checkOut.difference(checkIn).inDays;
                          return Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  'Total: $nights night${nights != 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    );
                  },
                ),
              ],
            ),
            code: '''final checkIn = ValueNotifier<DateTime?>(null);
final checkOut = ValueNotifier<DateTime?>(null);

Column(
  children: [
    TDatePicker(
      label: 'Check-in Date',
      valueNotifier: checkIn,
      firstDate: DateTime.now(),
      isRequired: true,
    ),
    ValueListenableBuilder<DateTime?>(
      valueListenable: checkIn,
      builder: (context, checkInDate, _) {
        return TDatePicker(
          label: 'Check-out Date',
          valueNotifier: checkOut,
          // Dynamic constraint based on check-in
          firstDate: checkInDate?.add(Duration(days: 1)) ?? DateTime.now(),
          isRequired: true,
          disabled: checkInDate == null, // Disabled until check-in selected
        );
      },
    ),
  ],
)''',
            properties: const [
              PropertyDoc(
                name: 'disabled',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether the picker is disabled',
              ),
              PropertyDoc(
                name: 'valueNotifier',
                type: 'ValueNotifier<T?>?',
                description: 'Two-way binding for reactive state management',
              ),
            ],
          ),

          // Clear Button Example
          WidgetDocCard(
            title: 'Pickers with Clear Button',
            description: 'Enable clear button to quickly reset selected dates/times',
            icon: Icons.clear_all,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TDatePicker(
                  label: 'Event Date',
                  placeholder: 'Select date',
                  clearable: true,
                  valueNotifier: ValueNotifier<DateTime?>(null),
                ),
                const SizedBox(height: 16),
                TTimePicker(
                  label: 'Event Time',
                  placeholder: 'Select time',
                  clearable: true,
                  valueNotifier: ValueNotifier<TimeOfDay?>(null),
                ),
                const SizedBox(height: 16),
                TDateTimePicker(
                  label: 'Event DateTime',
                  placeholder: 'Select date and time',
                  clearable: true,
                  valueNotifier: ValueNotifier<DateTime?>(null),
                ),
              ],
            ),
            code: '''TDatePicker(
  label: 'Event Date',
  clearable: true, // Show clear button when date is selected
  onValueChanged: (date) => print(date),
)

TTimePicker(
  label: 'Event Time',
  clearable: true, // Show clear button when time is selected
  onValueChanged: (time) => print(time),
)

TDateTimePicker(
  label: 'Event DateTime',
  clearable: true, // Show clear button when datetime is selected
  onValueChanged: (dateTime) => print(dateTime),
)''',
            properties: const [
              PropertyDoc(
                name: 'clearable',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to show a clear button when picker has a value',
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
