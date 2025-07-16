import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';

class TDateTimePicker extends StatefulWidget
    with TInputFieldMixin, TInputValueMixin<DateTime>, TFocusMixin, TInputValidationMixin<DateTime>, TPopupMixin {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool isRequired, disabled;
  @override
  final TInputSize? size;
  @override
  final Color? color;
  @override
  final BoxDecoration? boxDecoration;
  @override
  final Widget? preWidget, postWidget;
  @override
  final List<String? Function(DateTime?)>? rules;
  @override
  final List<String>? errors;
  @override
  final Duration? validationDebounce;
  @override
  final bool? skipValidation;
  @override
  final DateTime? value;
  @override
  final ValueNotifier<DateTime>? valueNotifier;
  @override
  final ValueChanged<DateTime>? onValueChanged;
  @override
  final FocusNode? focusNode;

  @override
  final VoidCallback? onShow;
  @override
  final VoidCallback? onHide;
  @override
  final VoidCallback? onTap;

  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateFormat? format;

  const TDateTimePicker({
    super.key,
    this.firstDate,
    this.lastDate,
    this.label,
    this.tag,
    this.placeholder,
    this.helperText,
    this.message,
    this.isRequired = false,
    this.disabled = false,
    this.size,
    this.color,
    this.boxDecoration,
    this.preWidget,
    this.postWidget,
    this.rules,
    this.errors,
    this.validationDebounce,
    this.skipValidation,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.focusNode,
    this.format,
    this.onShow,
    this.onHide,
    this.onTap,
  });

  @override
  State<TDateTimePicker> createState() => _TDateTimePickerState();
}

class _TDateTimePickerState extends State<TDateTimePicker>
    with
        TInputFieldStateMixin<TDateTimePicker>,
        TInputValueStateMixin<DateTime, TDateTimePicker>,
        TFocusStateMixin<TDateTimePicker>,
        TInputValidationStateMixin<DateTime, TDateTimePicker>,
        TPopupStateMixin<TDateTimePicker> {
  final TextEditingController controller = TextEditingController();
  late DateFormat dateFormat;

  int _currentTabIndex = 0;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    dateFormat = widget.format ?? DateFormat('MMM dd, yyyy hh:mm a');
    if (currentValue != null) {
      controller.text = dateFormat.format(currentValue!);
      _selectedDate = DateTime(currentValue!.year, currentValue!.month, currentValue!.day);
      _selectedTime = TimeOfDay.fromDateTime(currentValue!);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

  WidgetStateProperty<T> _resolveState<T>(T normal, T selected) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return selected;
      return normal;
    });
  }

  Widget _buildDateTab(ColorScheme theme) {
    return DatePickerTheme(
        data: DatePickerThemeData(
          backgroundColor: theme.surface,
          headerBackgroundColor: theme.surface,
          headerForegroundColor: theme.onSurface,
          dayForegroundColor: _resolveState(theme.onSurface, theme.surface),
          dayBackgroundColor: _resolveState(Colors.transparent, theme.primary),
          todayForegroundColor: _resolveState(theme.onSurface, theme.surface),
          todayBackgroundColor: _resolveState(Colors.transparent, theme.primary),
        ),
        child: CalendarDatePicker(
          initialDate: _selectedDate ?? currentValue ?? DateTime.now(),
          firstDate: widget.firstDate ?? DateTime(1900),
          lastDate: widget.lastDate ?? DateTime(2100),
          onDateChanged: _onDateSelected,
        ));
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
    final theme = context.theme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TTabs(
          tabPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          borderColor: theme.outline,
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
                _buildDateTab(theme),
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
    final theme = context.theme;
    final exTheme = context.exTheme;

    return buildWithDropdownTarget(
      child: buildContainer(
        theme,
        exTheme,
        preWidget: Icon(Icons.calendar_today_rounded, size: 16, color: theme.onSurfaceVariant),
        child: TextField(
          readOnly: true,
          controller: controller,
          focusNode: focusNode,
          enabled: widget.disabled != true,
          textInputAction: TextInputAction.next,
          cursorHeight: widget.fontSize + 2,
          textAlignVertical: TextAlignVertical.center,
          style: getTextStyle(theme),
          decoration: getInputDecoration(theme),
        ),
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
