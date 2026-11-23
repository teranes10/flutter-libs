import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

/// Current date and time, refreshed every 30 seconds. Sample for `TLayout.topBarCenter`.
class TopBarClock extends StatefulWidget {
  const TopBarClock({super.key});

  @override
  State<TopBarClock> createState() => _TopBarClockState();
}

class _TopBarClockState extends State<TopBarClock> {
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  late DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    String two(int v) => v.toString().padLeft(2, '0');
    final date = '${_days[_now.weekday - 1]}, ${_now.day} ${_months[_now.month - 1]} ${_now.year}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TIcon.raw(HugeIcons.strokeRoundedCalendar03, size: 12, color: colors.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(date, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
        const SizedBox(width: 12),
        Text(
          '${two(_now.hour)}:${two(_now.minute)}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onSurface),
        ),
      ],
    );
  }
}

/// Light/dark, glass on/off and connection indicators. Sample for `TLayout.topBarTrailing`.
class TopBarStatus extends ConsumerWidget {
  const TopBarStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final glass = ref.watch(themeNotifierProvider.select((s) => s.glass));

    Widget indicator(dynamic icon, String tooltip, {Color? color}) => TTooltip(
      message: tooltip,
      child: TIcon.raw(icon, size: 13, color: color ?? colors.onSurfaceVariant),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator(isDark ? HugeIcons.strokeRoundedMoon02 : HugeIcons.strokeRoundedSun02, isDark ? 'Dark mode' : 'Light mode'),
        const SizedBox(width: 10),
        indicator(HugeIcons.strokeRoundedBlur, glass ? 'Glass mode on' : 'Glass mode off', color: glass ? colors.primary : colors.outline),
        const SizedBox(width: 10),
        indicator(HugeIcons.strokeRoundedSignalFull02, 'Connected', color: context.theme.success),
      ],
    );
  }
}
