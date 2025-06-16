import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/extensions/date_time_extensions.dart';
import 'package:te_widgets/mixins/popup_mixin.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/time-picker/clock_time_picker.dart';

class TDateTimePicker extends StatefulWidget
    with TInputFieldMixin, TInputValueMixin<DateTime>, TFocusMixin, TInputValidationMixin<DateTime>, TPopupMixin {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool isRequired, disabled;
  @override
  final TInputSize? size;
  @override
  final TInputColor? color;
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
  final double? dropdownMaxHeight;
  @override
  final VoidCallback? onExpanded;
  @override
  final VoidCallback? onCollapsed;
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
    this.dropdownMaxHeight,
    this.onExpanded,
    this.onCollapsed,
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

  Widget _buildDateTab() {
    return CalendarDatePicker(
      initialDate: _selectedDate ?? currentValue ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      onDateChanged: _onDateSelected,
    );
  }

  Widget _buildTimeTab() {
    return TClockTimePicker(
      initialTime: _selectedTime ?? (currentValue ?? DateTime.now()).toTimeOfDay,
      onTimeChanged: _onTimeSelected,
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              index: 0,
              icon: Icons.calendar_today,
              label: 'Date',
              isSelected: _currentTabIndex == 0,
            ),
          ),
          Expanded(
            child: _buildTab(
              index: 1,
              icon: Icons.access_time,
              label: 'Time',
              isSelected: _currentTabIndex == 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    bool isEnabled = true,
  }) {
    final Color color = isEnabled ? (isSelected ? AppColors.primary : AppColors.grey.shade600) : AppColors.grey.shade400;

    return InkWell(
      onTap: isEnabled ? () => _onTabChanged(index) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: isSelected ? Border(bottom: BorderSide(color: AppColors.primary, width: 2)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (index == 0 && _selectedDate != null)
              Container(
                margin: const EdgeInsets.only(left: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  double getContentWidth() => 400;

  @override
  double getContentHeight() => 365;

  @override
  Widget getContentWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTabBar(),
        SizedBox(
          height: 300,
          child: IndexedStack(
            index: _currentTabIndex,
            children: [
              _buildDateTab(),
              _buildTimeTab(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildWithDropdownTarget(
      child: buildContainer(
        preWidget: Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.grey.shade500),
        child: TextField(
          readOnly: true,
          controller: controller,
          focusNode: focusNode,
          enabled: widget.disabled != true,
          textInputAction: TextInputAction.next,
          cursorHeight: widget.fontSize + 2,
          textAlignVertical: TextAlignVertical.center,
          style: widget.textStyle,
          decoration: widget.inputDecoration,
        ),
        onTap: () {
          setState(() {
            _currentTabIndex = 0;
          });
          showPopup();
        },
      ),
    );
  }
}
