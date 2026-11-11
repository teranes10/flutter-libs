import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Showcase for [TRollingText]: scoreboard, flip clock and taxi meter.
class RollingTextPage extends StatefulWidget {
  const RollingTextPage({super.key});

  @override
  State<RollingTextPage> createState() => _RollingTextPageState();
}

class _RollingTextPageState extends State<RollingTextPage> {
  static const _players = ['V. Kohli', 'R. Sharma', 'S. Gill', 'K. Rahul', 'H. Pandya'];
  final _rng = Random();

  // Scoreboard
  final _player = ValueNotifier<String>('V. Kohli');
  final _runs = ValueNotifier<int>(0);
  final _wickets = ValueNotifier<int>(0);
  final _overs = ValueNotifier<String>('0.0');
  int _balls = 0;

  // Clock
  final _clock = ValueNotifier<String>('');
  Timer? _clockTimer;

  // Taxi meter
  final _fare = ValueNotifier<double>(0);
  final _distance = ValueNotifier<double>(0);
  Timer? _meterTimer;

  @override
  void initState() {
    super.initState();
    _tickClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tickClock());
  }

  void _tickClock() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    _clock.value = '${two(n.hour)}:${two(n.minute)}:${two(n.second)}';
  }

  void _addRuns(int r) {
    _runs.value += r;
    _ball();
  }

  void _wicket() {
    _wickets.value = min(10, _wickets.value + 1);
    _player.value = _players[_rng.nextInt(_players.length)];
    _ball();
  }

  void _ball() {
    _balls++;
    _overs.value = '${_balls ~/ 6}.${_balls % 6}';
  }

  void _toggleMeter() {
    if (_meterTimer != null) {
      _meterTimer!.cancel();
      setState(() => _meterTimer = null);
      return;
    }
    setState(() {
      _meterTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
        _fare.value = ((_fare.value + 0.10) * 100).round() / 100;
        _distance.value += 0.05;
      });
    });
  }

  void _resetMeter() {
    _meterTimer?.cancel();
    setState(() => _meterTimer = null);
    _distance.value = 0;
    _fare.value = 0;
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _meterTimer?.cancel();
    _player.dispose();
    _runs.dispose();
    _wickets.dispose();
    _overs.dispose();
    _clock.dispose();
    _fare.dispose();
    _distance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const mono = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rolling Text',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Characters change one by one with a mechanical rotation: odometer, slide and flip effects, driven by a ValueNotifier.',
            style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          // 1. Cricket scoreboard
          WidgetDocCard(
            title: 'Cricket Scoreboard',
            description: 'Runs roll like an odometer, the batter name slides character by character',
            icon: HugeIcons.strokeRoundedCricketBat,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TRollingText.listenable(
                        _player,
                        effect: TRollingEffect.slide,
                        style: const TextStyle(fontSize: 18, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TRollingText.listenable(
                            _runs,
                            style: mono.copyWith(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text('/', style: mono.copyWith(fontSize: 40, color: const Color(0xFF64748B))),
                          TRollingText.listenable(
                            _wickets,
                            style: mono.copyWith(fontSize: 40, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
                          ),
                          const SizedBox(width: 20),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Text('Overs ', style: TextStyle(color: Color(0xFF94A3B8))),
                                TRollingText.listenable(
                                  _overs,
                                  effect: TRollingEffect.slide,
                                  style: mono.copyWith(fontSize: 20, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TButton(type: TButtonType.tonal, size: TButtonSize.sm, text: '+1', onTap: () => _addRuns(1)),
                    TButton(type: TButtonType.tonal, size: TButtonSize.sm, text: '+4', onTap: () => _addRuns(4)),
                    TButton(type: TButtonType.tonal, size: TButtonSize.sm, text: '+6', onTap: () => _addRuns(6)),
                    TButton(type: TButtonType.tonal, size: TButtonSize.sm, text: 'Wicket', color: context.theme.danger, onTap: _wicket),
                  ],
                ),
              ],
            ),
            code: '''final runs = ValueNotifier<int>(0);
final player = ValueNotifier<String>('V. Kohli');

TRollingText.listenable(runs, style: TextStyle(fontSize: 56))
TRollingText.listenable(player, effect: TRollingEffect.slide)

runs.value += 4; // only changed digits roll, one after another''',
          ),
          const SizedBox(height: 24),

          // 2. Clock
          WidgetDocCard(
            title: 'Flip Clock',
            description: 'Each digit folds and unfolds on its own tile as the time ticks',
            icon: HugeIcons.strokeRoundedClock01,
            preview: TRollingText.listenable(
              _clock,
              effect: TRollingEffect.flip,
              duration: const Duration(milliseconds: 450),
              stagger: Duration.zero,
              style: mono.copyWith(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white),
              slotPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              slotDecoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(6)),
            ),
            code: '''TRollingText.listenable(
  clock, // ValueNotifier<String> updated every second
  effect: TRollingEffect.flip,
  stagger: Duration.zero,
  slotPadding: EdgeInsets.all(6),
  slotDecoration: BoxDecoration(
    color: Color(0xFF1E293B),
    borderRadius: BorderRadius.circular(6),
  ),
)''',
          ),
          const SizedBox(height: 24),

          // 3. Taxi meter
          WidgetDocCard(
            title: 'Taxi Meter',
            description: 'Fare digits spin like a mechanical meter, last digits first',
            icon: HugeIcons.strokeRoundedTaxi,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FARE', style: TextStyle(color: Color(0xFF22C55E), fontSize: 12, letterSpacing: 2)),
                      TRollingText.listenable(
                        _fare,
                        format: (v) => '\$${(v as double).toStringAsFixed(2)}',
                        reverseStagger: true,
                        duration: const Duration(milliseconds: 700),
                        style: mono.copyWith(fontSize: 52, fontWeight: FontWeight.bold, color: const Color(0xFF22C55E)),
                      ),
                      TRollingText.listenable(
                        _distance,
                        format: (v) => '${(v as double).toStringAsFixed(1)} km',
                        style: mono.copyWith(fontSize: 18, color: const Color(0xFF86EFAC)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    TButton(
                      type: TButtonType.tonal,
                      size: TButtonSize.sm,
                      text: _meterTimer == null ? 'Start trip' : 'Pause',
                      onTap: _toggleMeter,
                    ),
                    TButton(type: TButtonType.outline, size: TButtonSize.sm, text: 'Reset', onTap: _resetMeter),
                  ],
                ),
              ],
            ),
            code: '''final fare = ValueNotifier<double>(0);

TRollingText.listenable(
  fare,
  format: (v) => '\\\$\${(v as double).toStringAsFixed(2)}',
  reverseStagger: true, // rightmost digit starts first
  duration: Duration(milliseconds: 700),
)

fare.value += 0.10; // 10 cents per tick''',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
