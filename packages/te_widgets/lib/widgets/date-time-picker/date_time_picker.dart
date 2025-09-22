import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';

class TDateTimePicker extends StatefulWidget
    with TInputFieldMixin, TFocusMixin, TTextFieldMixin, TInputValueMixin<DateTime>, TInputValidationMixin<DateTime>, TPopupMixin {
  @override
  final String? label, tag, helperText, placeholder;
  @override
  final bool isRequired, disabled, autoFocus, readOnly;
  @override
  final TTextFieldTheme? theme;
  @override
  final VoidCallback? onTap;
  @override
  final FocusNode? focusNode;
  @override
  final TextEditingController? textController;
  @override
  final DateTime? value;
  @override
  final ValueNotifier<DateTime>? valueNotifier;
  @override
  final ValueChanged<DateTime>? onValueChanged;
  @override
  final List<String? Function(DateTime?)>? rules;
  @override
  final Duration? validationDebounce;
  @override
  final VoidCallback? onShow;
  @override
  final VoidCallback? onHide;

  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateFormat? format;

  const TDateTimePicker({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.placeholder,
    this.isRequired = false,
    this.disabled = false,
    this.autoFocus = false,
    this.readOnly = true,
    this.theme,
    this.onTap,
    this.focusNode,
    this.textController,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.rules,
    this.validationDebounce,
    this.onShow,
    this.onHide,
    this.firstDate,
    this.lastDate,
    this.format,
  });

  @override
  State<TDateTimePicker> createState() => _TDateTimePickerState();
}

class _TDateTimePickerState extends State<TDateTimePicker>
    with
        TInputFieldStateMixin<TDateTimePicker>,
        TFocusStateMixin<TDateTimePicker>,
        TTextFieldStateMixin<TDateTimePicker>,
        TInputValueStateMixin<DateTime, TDateTimePicker>,
        TInputValidationStateMixin<DateTime, TDateTimePicker>,
        TPopupStateMixin<TDateTimePicker> {
  late DateFormat dateFormat;

  int _currentTabIndex = 0;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    dateFormat = widget.format ?? DateFormat('MMM dd, yyyy hh:mm a');
    super.initState();
  }

  @override
  void onExternalValueChanged(DateTime? value) {
    super.onExternalValueChanged(value);
    if (currentValue != null) {
      controller.text = dateFormat.format(currentValue!);
      _selectedDate = DateTime(currentValue!.year, currentValue!.month, currentValue!.day);
      _selectedTime = TimeOfDay.fromDateTime(currentValue!);
    } else {
      controller.text = '';
      _selectedDate = null;
      _selectedTime = null;
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentTabIndex = 1;
      rebuildPopup();
    });

    _composeAndNotifyDateTime();
  }

  void _onTimeSelected(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });

    _composeAndNotifyDateTime();
  }

  void _composeAndNotifyDateTime() {
    if (_selectedDate != null && _selectedTime != null) {
      final DateTime composedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      notifyValueChanged(composedDateTime);
      setState(() {
        controller.text = dateFormat.format(composedDateTime);
      });
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
      rebuildPopup();
    });
  }

  Widget _buildDateTab(ColorScheme colors) {
    return CalendarDatePicker2(
      config: CalendarDatePicker2Config(
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
      ),
      value: [currentValue],
      onValueChanged: (v) {
        _onDateSelected(v.first);
      },
    );
  }

  Widget _buildTimeTab() {
    return TClockTimePicker(
      initialTime: _selectedTime ?? (currentValue ?? DateTime.now()).toTimeOfDay,
      onTimeChanged: _onTimeSelected,
    );
  }

  @override
  double get contentMaxWidth => 425;

  @override
  double get contentMaxHeight => 380;

  @override
  Widget getContentWidget(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TTabs(
          tabPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          borderColor: colors.outline,
          tabs: [
            TTab(icon: Icons.calendar_today, text: 'Date', isActive: _selectedDate != null),
            TTab(icon: Icons.access_time, text: 'Time'),
          ],
          selectedIndex: _currentTabIndex,
          onTabChanged: _onTabChanged,
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: SizedBox(
            height: 300,
            child: IndexedStack(
              index: _currentTabIndex,
              alignment: Alignment.center,
              children: [
                _buildDateTab(colors),
                _buildTimeTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildWithDropdownTarget(
      child: buildContainer(
        preWidget: Icon(Icons.calendar_today_rounded, size: 16, color: colors.onSurfaceVariant),
        child: IgnorePointer(child: buildTextField()),
        onTap: () {
          setState(() {
            _currentTabIndex = 0;
          });

          showPopup(context);
        },
      ),
    );
  }
}
