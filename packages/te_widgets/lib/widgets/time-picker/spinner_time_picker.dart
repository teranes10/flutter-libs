import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A time picker using scrolling wheels (springs).
///
/// `TSpinnerTimePicker` provides a vertical scrolling interface for selecting
/// hours and minutes, imitating native iOS style pickers.
class TSpinnerTimePicker extends StatefulWidget {
  /// The current time.
  final TimeOfDay time;

  /// Callback fired when time changes.
  final ValueChanged<TimeOfDay> onTimeChanged;

  /// Whether scroll direction matches gesture (true) or is inverted (false).
  final bool reverseScroll;

  /// Creates a spinner time picker.
  const TSpinnerTimePicker({
    super.key,
    required this.time,
    required this.onTimeChanged,
    this.reverseScroll = true,
  });

  @override
  State<TSpinnerTimePicker> createState() => _TSpinnerTimePickerState();
}

class _TSpinnerTimePickerState extends State<TSpinnerTimePicker> {
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.time.hour;
    selectedMinute = widget.time.minute;
    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  void _onHourChanged(int index) {
    setState(() => selectedHour = index);
    widget.onTimeChanged(TimeOfDay(hour: selectedHour, minute: selectedMinute));
  }

  void _onMinuteChanged(int index) {
    setState(() => selectedMinute = index);
    widget.onTimeChanged(TimeOfDay(hour: selectedHour, minute: selectedMinute));
  }

  Widget _buildWheel({
    required String label,
    required int max,
    required int selected,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onChanged,
  }) {
    final colors = context.colors;

    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                final offsetChange = widget.reverseScroll ? -details.delta.dy : details.delta.dy;
                controller.jumpTo(controller.offset + offsetChange);
              },
              child: ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: 40,
                perspective: 0.005,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: onChanged,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: max + 1,
                  builder: (context, index) {
                    final isSelected = index == selected;
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primaryContainer : colors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildWheel(
                label: 'Hour',
                max: 23,
                selected: selectedHour,
                controller: hourController,
                onChanged: _onHourChanged,
              ),
              const SizedBox(
                width: 20,
                child: Text(
                  ':',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              _buildWheel(
                label: 'Minute',
                max: 59,
                selected: selectedMinute,
                controller: minuteController,
                onChanged: _onMinuteChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
