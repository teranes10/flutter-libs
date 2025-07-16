import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';

class TTimePicker extends StatefulWidget
    with TInputFieldMixin, TInputValueMixin<TimeOfDay>, TFocusMixin, TInputValidationMixin<TimeOfDay>, TPopupMixin {
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
  final List<String? Function(TimeOfDay?)>? rules;
  @override
  final List<String>? errors;
  @override
  final Duration? validationDebounce;
  @override
  final bool? skipValidation;
  @override
  final TimeOfDay? value;
  @override
  final ValueNotifier<TimeOfDay>? valueNotifier;
  @override
  final ValueChanged<TimeOfDay>? onValueChanged;
  @override
  final FocusNode? focusNode;

  @override
  final VoidCallback? onShow;
  @override
  final VoidCallback? onHide;
  @override
  final VoidCallback? onTap;

  final DateFormat? format;

  const TTimePicker({
    super.key,
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
  State<TTimePicker> createState() => _TTimePickerState();
}

class _TTimePickerState extends State<TTimePicker>
    with
        TInputFieldStateMixin<TTimePicker>,
        TInputValueStateMixin<TimeOfDay, TTimePicker>,
        TFocusStateMixin<TTimePicker>,
        TInputValidationStateMixin<TimeOfDay, TTimePicker>,
        TPopupStateMixin<TTimePicker> {
  final TextEditingController controller = TextEditingController();
  late DateFormat dateFormat;

  @override
  void initState() {
    super.initState();
    dateFormat = widget.format ?? DateFormat('hh:mm a');
    if (currentValue != null) {
      controller.text = dateFormat.formatTimeOfDay(currentValue!);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onTimeSelected(TimeOfDay time) {
    notifyValueChanged(time);
    setState(() {
      controller.text = dateFormat.formatTimeOfDay(time);
    });
  }

  @override
  double get contentMaxWidth => 450;

  @override
  double get contentMaxHeight => 350;

  @override
  Widget getContentWidget(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        child: TClockTimePicker(
          initialTime: DateTime.now().toTimeOfDay,
          onTimeChanged: _onTimeSelected,
        ));
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
