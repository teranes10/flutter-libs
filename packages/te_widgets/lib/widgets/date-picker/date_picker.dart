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
    controller.text = currentValue != null ? dateFormat.format(currentValue!) : '';
  }

  void _onDateSelected(DateTime date) {
    notifyValueChanged(date);
    setState(() {
      controller.text = dateFormat.format(date);
    });

    hidePopup();
  }

  @override
  double get contentMaxWidth => 425;

  @override
  double get contentMaxHeight => 360;

  WidgetStateProperty<T> _resolveState<T>(T normal, T selected) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected) || states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
        return selected;
      }
      return normal;
    });
  }

  @override
  Widget getContentWidget(BuildContext context) {
    final colors = context.colors;

    return DatePickerTheme(
      data: DatePickerThemeData(
        backgroundColor: Colors.amber,
        surfaceTintColor: Colors.red,
        todayForegroundColor: _resolveState(colors.onSurface, colors.onPrimaryContainer),
        todayBackgroundColor: _resolveState(colors.surface, colors.primaryContainer),
        yearForegroundColor: _resolveState(colors.onSurface, colors.onPrimaryContainer),
        yearBackgroundColor: _resolveState(colors.surface, colors.primaryContainer),
        dayForegroundColor: _resolveState(colors.onSurface, colors.onPrimaryContainer),
        dayBackgroundColor: _resolveState(colors.onSurface, colors.primaryContainer),
      ),
      child: CalendarDatePicker(
        initialDate: currentValue ?? DateTime.now(),
        currentDate: currentValue,
        firstDate: widget.firstDate ?? DateTime(1950),
        lastDate: widget.lastDate ?? DateTime(2050),
        onDateChanged: (date) {
          _onDateSelected(date);
        },
      ),
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
