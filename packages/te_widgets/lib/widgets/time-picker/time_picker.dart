import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';

class TTimePicker extends StatefulWidget
    with TInputFieldMixin, TFocusMixin, TTextFieldMixin, TInputValueMixin<TimeOfDay>, TInputValidationMixin<TimeOfDay>, TPopupMixin {
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
  final TimeOfDay? value;
  @override
  final ValueNotifier<TimeOfDay?>? valueNotifier;
  @override
  final ValueChanged<TimeOfDay?>? onValueChanged;
  @override
  final List<String? Function(TimeOfDay?)>? rules;
  @override
  final Duration? validationDebounce;
  @override
  final VoidCallback? onShow;
  @override
  final VoidCallback? onHide;

  final DateFormat? format;

  const TTimePicker({
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
    this.format,
  });

  @override
  State<TTimePicker> createState() => _TTimePickerState();
}

class _TTimePickerState extends State<TTimePicker>
    with
        TInputFieldStateMixin<TTimePicker>,
        TFocusStateMixin<TTimePicker>,
        TTextFieldStateMixin<TTimePicker>,
        TInputValueStateMixin<TimeOfDay, TTimePicker>,
        TInputValidationStateMixin<TimeOfDay, TTimePicker>,
        TPopupStateMixin<TTimePicker> {
  late DateFormat dateFormat;

  @override
  void initState() {
    dateFormat = widget.format ?? DateFormat('hh:mm a');
    super.initState();
  }

  @override
  void onExternalValueChanged(TimeOfDay? value) {
    super.onExternalValueChanged(value);
    textController.text = currentValue != null ? dateFormat.formatTimeOfDay(currentValue!) : '';
  }

  void _onTimeSelected(TimeOfDay time) {
    notifyValueChanged(time);
    setState(() {
      textController.text = dateFormat.formatTimeOfDay(time);
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
