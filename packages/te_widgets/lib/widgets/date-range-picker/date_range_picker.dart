import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';

/// A date range input with a calendar popup.
///
/// The first tap in the calendar sets the start, the second the end; the popup closes once the range is complete.
/// The value is a [DateTimeRange] (dates at midnight), or null when nothing is selected.
///
/// ```dart
/// TDateRangePicker(
///   label: 'Stay',
///   onValueChanged: (range) => print('${range?.start} – ${range?.end}'),
/// )
/// ```
class TDateRangePicker extends StatefulWidget
    with
        TInputFieldMixin,
        TFocusMixin,
        TTextFieldMixin,
        TInputValueMixin<DateTimeRange>,
        TInputValidationMixin<DateTimeRange>,
        TPopupMixin {
  @override
  final String? label, tag, helperText, placeholder, info;
  @override
  final bool isRequired, disabled, autoFocus, readOnly;
  @override
  final bool clearable;
  @override
  final TTextFieldTheme? theme;
  @override
  final VoidCallback? onTap;
  @override
  final FocusNode? focusNode;
  @override
  final TextEditingController? textController;
  @override
  final DateTimeRange? value;
  @override
  final ValueNotifier<DateTimeRange?>? valueNotifier;
  @override
  final ValueChanged<DateTimeRange?>? onValueChanged;
  @override
  final List<String? Function(DateTimeRange?)>? rules;
  @override
  final Duration? validationDebounce;
  @override
  final VoidCallback? onShow;
  @override
  final VoidCallback? onHide;

  /// The earliest selectable date.
  final DateTime? firstDate;

  /// The latest selectable date.
  final DateTime? lastDate;

  /// Format of each end of the displayed range. Defaults to 'MMM dd, yyyy'.
  final DateFormat? format;

  const TDateRangePicker({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.placeholder,
    this.info,
    this.isRequired = false,
    this.disabled = false,
    this.autoFocus = false,
    this.readOnly = true,
    this.clearable = false,
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
  State<TDateRangePicker> createState() => _TDateRangePickerState();
}

class _TDateRangePickerState extends State<TDateRangePicker>
    with
        TInputFieldStateMixin<TDateRangePicker>,
        TFocusStateMixin<TDateRangePicker>,
        TTextFieldStateMixin<TDateRangePicker>,
        TInputValueStateMixin<DateTimeRange, TDateRangePicker>,
        TInputValidationStateMixin<DateTimeRange, TDateRangePicker>,
        TPopupStateMixin<TDateRangePicker> {
  late DateFormat dateFormat;

  // Range being picked: committed to the field only once both ends are set.
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    dateFormat = widget.format ?? DateFormat('MMM dd, yyyy');
    super.initState();
    _start = currentValue?.start;
    _end = currentValue?.end;
  }

  String _text(DateTimeRange? r) => r == null ? '' : '${dateFormat.format(r.start)} – ${dateFormat.format(r.end)}';

  @override
  void onExternalValueChanged(DateTimeRange? value) {
    super.onExternalValueChanged(value);
    _start = value?.start;
    _end = value?.end;
    textController.text = _text(currentValue);
  }

  void _onRangeChanged(DateTime start, DateTime? end) {
    setState(() {
      _start = start;
      _end = end;
    });
    rebuildPopup();
    if (end == null) return;
    final range = DateTimeRange(start: start, end: end);
    notifyValueChanged(range);
    setState(() => textController.text = _text(range));
    hidePopup();
  }

  void _clear() {
    _start = null;
    _end = null;
    notifyValueChanged(null);
    setState(() => textController.text = '');
  }

  @override
  double get contentMaxWidth => 425;

  @override
  double get contentMaxHeight => 360;

  @override
  Widget getContentWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 16, 6, 6),
      child: TCalendarPicker.range(
        start: _start,
        end: _end,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        onRangeChanged: _onRangeChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildWithDropdownTarget(
      child: buildTextField(
        hasValue: currentValue != null,
        beforePreWidget: TIcon.raw(
          HugeIcons.strokeRoundedCalendar04,
          size: 16,
          color: colors.onSurfaceVariant,
          onTap: widget.disabled ? null : () => showPopup(context),
          semanticLabel: 'Open calendar',
          semanticIdentifier: 'date-range-picker-open',
        ),
        onClear: _clear,
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showPopup(context);
          });
        },
      ),
    );
  }
}
