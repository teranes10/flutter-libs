import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';

class TDatePicker extends StatefulWidget
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
  final ValueNotifier<DateTime?>? valueNotifier;
  @override
  final ValueChanged<DateTime?>? onValueChanged;
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

  const TDatePicker({
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
  State<TDatePicker> createState() => _TDatePickerState();
}

class _TDatePickerState extends State<TDatePicker>
    with
        TInputFieldStateMixin<TDatePicker>,
        TFocusStateMixin<TDatePicker>,
        TTextFieldStateMixin<TDatePicker>,
        TInputValueStateMixin<DateTime, TDatePicker>,
        TInputValidationStateMixin<DateTime, TDatePicker>,
        TPopupStateMixin<TDatePicker> {
  late DateFormat dateFormat;

  @override
  void initState() {
    dateFormat = widget.format ?? DateFormat('MMM dd, yyyy');
    super.initState();
  }

  @override
  void onExternalValueChanged(DateTime? value) {
    super.onExternalValueChanged(value);
    textController.text = currentValue != null ? dateFormat.format(currentValue!) : '';
  }

  void _onDateSelected(DateTime date) {
    notifyValueChanged(date);
    setState(() {
      textController.text = dateFormat.format(date);
    });

    hidePopup();
  }

  @override
  double get contentMaxWidth => 425;

  @override
  double get contentMaxHeight => 360;

  @override
  Widget getContentWidget(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return buildWithDropdownTarget(
      child: buildContainer(
        preWidget: Icon(Icons.calendar_today_rounded, size: 16, color: colors.onSurfaceVariant),
        child: IgnorePointer(child: buildTextField()),
        onTap: () {
          showPopup(context);
        },
      ),
    );
  }
}
