import 'package:flutter/material.dart';

class TTimePickerSpinner extends StatefulWidget {
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const TTimePickerSpinner({
    super.key,
    required this.time,
    required this.onTimeChanged,
  });

  @override
  State<TTimePickerSpinner> createState() => _TTimePickerSpinnerState();
}

class _TTimePickerSpinnerState extends State<TTimePickerSpinner> {
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
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                controller.jumpTo(controller.offset + details.delta.dy);
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
                        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.black87,
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
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
