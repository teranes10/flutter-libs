import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    this.onShow,
    this.onHide,
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

  @override
  double get contentMaxWidth => 325;

  @override
  double get contentMaxHeight => 360;

  WidgetStateProperty<T> _resolveState<T>(T normal, T selected) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return selected;
      return normal;
    });
  }

  @override
  Widget getContentWidget(BuildContext context) {
    final theme = context.theme;
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
        initialDate: currentValue ?? DateTime.now(),
        firstDate: widget.firstDate ?? DateTime(1900),
        lastDate: widget.lastDate ?? DateTime(2100),
        onDateChanged: (date) {
          _onDateSelected(date);
        },
      ),
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
        onTap: () => showPopup(context),
      ),
    );
  }
}
