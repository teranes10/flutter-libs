import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/mixins/popup_mixin.dart';
import 'package:te_widgets/te_widgets.dart';

class TDatePicker extends StatefulWidget
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

  const TDatePicker({
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
  State<TDatePicker> createState() => _TDatePickerState();
}

class _TDatePickerState extends State<TDatePicker>
    with
        TInputFieldStateMixin<TDatePicker>,
        TInputValueStateMixin<DateTime, TDatePicker>,
        TFocusStateMixin<TDatePicker>,
        TInputValidationStateMixin<DateTime, TDatePicker>,
        TPopupStateMixin<TDatePicker> {
  final TextEditingController controller = TextEditingController();
  late DateFormat dateFormat;

  @override
  void initState() {
    super.initState();
    dateFormat = widget.format ?? DateFormat('MMM dd, yyyy');
    if (currentValue != null) {
      controller.text = dateFormat.format(currentValue!);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    notifyValueChanged(date);
    setState(() {
      controller.text = dateFormat.format(date);
    });

    hidePopup();
  }

  // TPopupMixin overrides
  @override
  double getContentWidth() => 325;

  @override
  double getContentHeight() => 300;

  @override
  Widget getContentWidget() {
    return CalendarDatePicker(
      initialDate: currentValue ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      onDateChanged: (date) {
        _onDateSelected(date);
      },
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
        onTap: showPopup,
      ),
    );
  }
}
