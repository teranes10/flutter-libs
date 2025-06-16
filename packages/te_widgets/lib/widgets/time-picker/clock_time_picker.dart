import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

class TClockTimePicker extends StatefulWidget {
  const TClockTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
    this.width,
    this.height,
  });

  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final double? width;
  final double? height;

  @override
  State<TClockTimePicker> createState() => _TClockTimePickerState();
}

class _TClockTimePickerState extends State<TClockTimePicker> {
  late TimeOfDay _selectedTime;
  _Mode _mode = _Mode.hour;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  void _handleTimeChanged(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });
    widget.onTimeChanged(time);
  }

  void _togglePeriod() {
    final int newHour = _selectedTime.hour < 12 ? _selectedTime.hour + 12 : _selectedTime.hour - 12;
    _handleTimeChanged(_selectedTime.replacing(hour: newHour));
  }

  Widget _buildModeButton(String text, _Mode mode) {
    final bool isSelected = _mode == mode;
    return GestureDetector(
      onTap: () {
        setState(() => _mode = mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.shade400 : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodButton() {
    return GestureDetector(
      onTap: _togglePeriod,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: AppColors.grey.shade100), borderRadius: BorderRadius.circular(8)),
        child: Text(
          _selectedTime.period == DayPeriod.am ? 'AM' : 'PM',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.grey.shade600),
        ),
      ),
    );
  }

  bool _shouldUseLandscapeLayout() {
    // If width and height are provided, use them to determine orientation
    if (widget.width != null && widget.height != null) {
      return widget.width! > widget.height!;
    }

    // Fall back to MediaQuery orientation
    final Size screenSize = MediaQuery.of(context).size;
    return screenSize.width > screenSize.height;
  }

  double _calculateDialSize() {
    final Size screenSize = MediaQuery.of(context).size;
    final bool useLandscapeLayout = _shouldUseLandscapeLayout();

    double availableWidth = widget.width ?? screenSize.width;
    double availableHeight = widget.height ?? screenSize.height;

    double dialSize;

    if (useLandscapeLayout) {
      // In landscape: account for time display width (~200px) + padding
      double timeDisplayWidth = 200;
      double maxDialWidth = availableWidth - timeDisplayWidth - 64; // 64 for padding
      double maxDialHeight = availableHeight - 40; // 40 for top/bottom padding
      dialSize = math.min(maxDialWidth, maxDialHeight);
    } else {
      // In portrait: account for time display height (~60px) + padding
      double timeDisplayHeight = 60;
      double maxDialWidth = availableWidth - 40; // 40 for left/right padding
      double maxDialHeight = availableHeight - timeDisplayHeight - 64; // 64 for padding
      dialSize = math.min(maxDialWidth, maxDialHeight);
    }

    // Ensure reasonable bounds
    dialSize = math.max(dialSize, 180); // Minimum size
    dialSize = math.min(dialSize, 320); // Maximum size

    return dialSize;
  }

  Widget _buildLandscapeTimeDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hour and minute in one row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModeButton(
              _selectedTime.hourOfPeriod.toString().padLeft(2, '0'),
              _Mode.hour,
            ),
            const SizedBox(width: 8),
            const Text(':', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            _buildModeButton(
              _selectedTime.minute.toString().padLeft(2, '0'),
              _Mode.minute,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // AM/PM centered below
        _buildPeriodButton(),
      ],
    );
  }

  Widget _buildPortraitTimeDisplay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth > 0 ? constraints.maxWidth : (widget.width ?? MediaQuery.of(context).size.width);

        // Check if we need to wrap - be more conservative with space
        // Full row needs ~280px, hour:minute needs ~180px
        final bool shouldWrapAll = availableWidth < 280;
        final bool shouldWrapTime = availableWidth < 180;

        if (shouldWrapTime) {
          // Very small screen - stack everything vertically
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModeButton(
                _selectedTime.hourOfPeriod.toString().padLeft(2, '0'),
                _Mode.hour,
              ),
              const SizedBox(height: 8),
              const Text(
                ':',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildModeButton(
                _selectedTime.minute.toString().padLeft(2, '0'),
                _Mode.minute,
              ),
              const SizedBox(height: 12),
              _buildPeriodButton(),
            ],
          );
        } else if (shouldWrapAll) {
          // Medium space - hour:minute together, AM/PM below
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeButton(
                    _selectedTime.hourOfPeriod.toString().padLeft(2, '0'),
                    _Mode.hour,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    ':',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  _buildModeButton(
                    _selectedTime.minute.toString().padLeft(2, '0'),
                    _Mode.minute,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPeriodButton(),
            ],
          );
        } else {
          // Enough space - everything in one row
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModeButton(
                _selectedTime.hourOfPeriod.toString().padLeft(2, '0'),
                _Mode.hour,
              ),
              const SizedBox(width: 8),
              const Text(
                ':',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              _buildModeButton(
                _selectedTime.minute.toString().padLeft(2, '0'),
                _Mode.minute,
              ),
              const SizedBox(width: 8),
              _buildPeriodButton(),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool useLandscapeLayout = _shouldUseLandscapeLayout();
    final double dialSize = _calculateDialSize();

    final Widget timeDisplay = useLandscapeLayout ? _buildLandscapeTimeDisplay() : _buildPortraitTimeDisplay();

    final Widget dial = SizedBox(
      width: dialSize,
      height: dialSize,
      child: _Dial(
        selectedTime: _selectedTime,
        mode: _mode,
        onChanged: _handleTimeChanged,
        onModeChanged: (mode) => setState(() => _mode = mode),
      ),
    );

    if (useLandscapeLayout) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          timeDisplay,
          const SizedBox(width: 32),
          Flexible(child: dial),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          timeDisplay,
          const SizedBox(height: 32),
          Flexible(child: dial),
        ],
      );
    }
  }
}

const double _kTwoPi = 2 * math.pi;
const double _kDialPadding = 28;

enum _Mode { hour, minute }

class _TappableLabel {
  _TappableLabel({
    required this.value,
    required this.painter,
    required this.onTap,
  });

  final int value;
  final TextPainter painter;
  final VoidCallback onTap;
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.labels,
    required this.selectedLabels,
    required this.handColor,
    required this.dotColor,
    required this.theta,
    required this.mode,
    required this.selectedTime,
  });

  final List<_TappableLabel> labels;
  final List<_TappableLabel> selectedLabels;
  final Color handColor;
  final Color dotColor;
  final double theta;
  final _Mode mode;
  final TimeOfDay selectedTime;

  @override
  void paint(Canvas canvas, Size size) {
    final double dialRadius = size.shortestSide / 2;
    final double labelRadius = dialRadius - _kDialPadding;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw background circle
    canvas.drawCircle(center, dialRadius, Paint()..color = Colors.white);

    // Paint labels
    if (labels.isNotEmpty) {
      final double labelThetaIncrement = -_kTwoPi / labels.length;
      double labelTheta = math.pi / 2;

      for (final label in labels) {
        final Offset labelOffset = Offset(-label.painter.width / 2, -label.painter.height / 2);
        final Offset labelPosition = center +
            Offset(
              labelRadius * math.cos(labelTheta),
              -labelRadius * math.sin(labelTheta),
            );
        label.painter.paint(canvas, labelPosition + labelOffset);
        labelTheta += labelThetaIncrement;
      }
    }

    // Draw hand and main dot
    final Paint selectorPaint = Paint()..color = handColor;
    final Offset handEnd = center +
        Offset(
          labelRadius * math.cos(theta),
          -labelRadius * math.sin(theta),
        );

    canvas.drawCircle(center, 6, selectorPaint);
    canvas.drawCircle(handEnd, 16, selectorPaint);
    selectorPaint.strokeWidth = 3;
    canvas.drawLine(center, handEnd, selectorPaint);

    // Draw intermediate dots for minute mode
    if (mode == _Mode.minute) {
      _drawIntermediateDots(canvas, center, labelRadius, selectorPaint);
    }

    // Draw selected labels
    final Rect focusedRect = Rect.fromCircle(center: handEnd, radius: 16);
    canvas.save();
    canvas.clipPath(Path()..addOval(focusedRect));

    if (selectedLabels.isNotEmpty) {
      final double labelThetaIncrement = -_kTwoPi / selectedLabels.length;
      double labelTheta = math.pi / 2;

      for (final label in selectedLabels) {
        final Offset labelOffset = Offset(-label.painter.width / 2, -label.painter.height / 2);
        final Offset labelPosition = center +
            Offset(
              labelRadius * math.cos(labelTheta),
              -labelRadius * math.sin(labelTheta),
            );
        label.painter.paint(canvas, labelPosition + labelOffset);
        labelTheta += labelThetaIncrement;
      }
    }
    canvas.restore();
  }

  void _drawIntermediateDots(Canvas canvas, Offset center, double labelRadius, Paint paint) {
    // Only draw dots for the currently selected minute if it's not on a 5-minute mark
    if (selectedTime.minute % 5 != 0) {
      final Paint dotPaint = Paint()..color = dotColor;
      final double selectedMinuteTheta = math.pi / 2 - (selectedTime.minute / 60) * _kTwoPi;
      final Offset selectedDotPosition = center +
          Offset(
            labelRadius * math.cos(selectedMinuteTheta),
            -labelRadius * math.sin(selectedMinuteTheta),
          );
      canvas.drawCircle(selectedDotPosition, 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_DialPainter oldPainter) {
    return oldPainter.theta != theta || oldPainter.labels != labels || oldPainter.mode != mode || oldPainter.selectedTime != selectedTime;
  }
}

class _Dial extends StatefulWidget {
  const _Dial({
    required this.selectedTime,
    required this.mode,
    required this.onChanged,
    this.onModeChanged,
  });

  final TimeOfDay selectedTime;
  final _Mode mode;
  final ValueChanged<TimeOfDay> onChanged;
  final ValueChanged<_Mode>? onModeChanged;

  @override
  _DialState createState() => _DialState();
}

class _DialState extends State<_Dial> {
  double _getThetaForTime(TimeOfDay time) {
    final double fraction = switch (widget.mode) {
      _Mode.hour => (time.hourOfPeriod / 12) % 1,
      _Mode.minute => (time.minute / 60) % 1,
    };
    return (math.pi / 2 - fraction * _kTwoPi) % _kTwoPi;
  }

  TimeOfDay _getTimeForTheta(double theta, {bool roundMinutes = false}) {
    final double fraction = (0.25 - (theta % _kTwoPi) / _kTwoPi) % 1;
    switch (widget.mode) {
      case _Mode.hour:
        int newHour = (fraction * 12).round() % 12;
        if (newHour == 0) newHour = 12;
        newHour = newHour + (widget.selectedTime.period == DayPeriod.pm ? 12 : 0);
        if (newHour == 24) newHour = 12;
        if (newHour > 12 && widget.selectedTime.period == DayPeriod.am) newHour -= 12;
        return widget.selectedTime.replacing(hour: newHour);
      case _Mode.minute:
        int minute = (fraction * 60).round() % 60;
        if (roundMinutes) {
          minute = ((minute + 2) ~/ 5) * 5 % 60; // Round to nearest 5 minutes
        }
        return widget.selectedTime.replacing(minute: minute);
    }
  }

  void _updateFromPan(Offset position, Size size, {bool roundMinutes = false}) {
    final Offset center = size.center(Offset.zero);
    final Offset offset = position - center;
    final double angle = (math.atan2(offset.dx, offset.dy) - math.pi / 2) % _kTwoPi;

    final TimeOfDay newTime = _getTimeForTheta(angle, roundMinutes: roundMinutes);
    if (newTime != widget.selectedTime) {
      widget.onChanged(newTime);
    }
  }

  void _handlePanStart(DragStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.globalToLocal(details.globalPosition);
    _updateFromPan(position, box.size);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.globalToLocal(details.globalPosition);
    _updateFromPan(position, box.size); // Allow precise dragging during pan
  }

  void _handlePanEnd(DragEndDetails details) {
    // Auto-switch to next mode after selection
    if (widget.mode == _Mode.hour) {
      widget.onModeChanged?.call(_Mode.minute);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.globalToLocal(details.globalPosition);
    _updateFromPan(position, box.size, roundMinutes: true); // Round to nearest increment on tap

    // Auto-switch to next mode after selection
    if (widget.mode == _Mode.hour) {
      widget.onModeChanged?.call(_Mode.minute);
    }
  }

  _TappableLabel _buildLabel(int value, String text, bool selected) {
    return _TappableLabel(
      value: value,
      painter: TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 16,
            color: selected ? Colors.white : AppColors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
      onTap: () {
        TimeOfDay newTime;
        if (widget.mode == _Mode.hour) {
          int hourValue = value;
          if (hourValue == 12) hourValue = 0;
          hourValue += (widget.selectedTime.period == DayPeriod.pm ? 12 : 0);
          if (hourValue == 12 && widget.selectedTime.period == DayPeriod.am) hourValue = 0;
          if (hourValue == 24) hourValue = 12;
          newTime = widget.selectedTime.replacing(hour: hourValue == 0 ? 12 : hourValue);
        } else {
          newTime = widget.selectedTime.replacing(minute: value);
        }
        widget.onChanged(newTime);

        // Auto-switch to next mode after selection
        if (widget.mode == _Mode.hour) {
          widget.onModeChanged?.call(_Mode.minute);
        }
      },
    );
  }

  List<_TappableLabel> _buildHourLabels(bool selected) {
    return List.generate(12, (i) {
      final int hour = i == 0 ? 12 : i;
      return _buildLabel(hour, hour.toString(), selected);
    });
  }

  List<_TappableLabel> _buildMinuteLabels(bool selected) {
    return List.generate(12, (i) {
      final int minute = i * 5;
      return _buildLabel(minute, minute.toString().padLeft(2, '0'), selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<_TappableLabel> labels = widget.mode == _Mode.hour ? _buildHourLabels(false) : _buildMinuteLabels(false);

    final List<_TappableLabel> selectedLabels = widget.mode == _Mode.hour ? _buildHourLabels(true) : _buildMinuteLabels(true);

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapUp: _handleTapUp,
      child: CustomPaint(
        painter: _DialPainter(
          labels: labels,
          selectedLabels: selectedLabels,
          handColor: Theme.of(context).primaryColor,
          dotColor: Colors.white,
          theta: _getThetaForTime(widget.selectedTime),
          mode: widget.mode,
          selectedTime: widget.selectedTime,
        ),
        child: Container(),
      ),
    );
  }
}
