import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TSpinnerTimePicker extends StatefulWidget {
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final bool reverseScroll;

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
    final theme = context.theme;

    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: theme.onSurfaceVariant)),
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
                        color: isSelected ? theme.primaryContainer : theme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.onPrimaryContainer : theme.onSurface,
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
