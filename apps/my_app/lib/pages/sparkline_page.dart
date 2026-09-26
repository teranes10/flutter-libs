import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class SparklinePage extends StatefulWidget {
  const SparklinePage({super.key});

  @override
  State<SparklinePage> createState() => _SparklinePageState();
}

class _SparklinePageState extends State<SparklinePage> {
  final List<double> _revenueData = [12.0, 15.2, 14.8, 19.5, 24.0, 22.1, 28.9, 34.5, 42.0];
  final List<double> _latencyData = [45.0, 42.0, 50.0, 38.0, 32.0, 30.0, 24.0, 21.5];
  final List<double> _requestsData = [120, 140, 180, 220, 190, 260, 310, 290, 380, 450];
  final List<double> _errorsData = [8.0, 6.0, 9.0, 12.0, 5.0, 3.0, 2.0, 1.0];

  bool _smooth = true;
  bool _showEndDot = true;
  bool _showMinMaxDots = true;

  void _randomizeData() {
    final rng = math.Random();
    setState(() {
      for (int i = 0; i < _revenueData.length; i++) {
        _revenueData[i] = 10.0 + rng.nextDouble() * 40.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'TSparkline & TTrendIndicator Showcase',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'High-performance inline micro-charts for analytical dashboards and KPI tiles. '
            'Supports cubic bezier curve smoothing, area gradient fills, vertical micro-bars, and trend percentage deltas.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Options Toolbar Card
          TCard(
            title: 'Chart Controls',
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TButton(
                  text: 'Shuffle Revenue Data',
                  icon: Icons.shuffle_rounded,
                  type: TButtonType.outline,
                  size: TSize.sm,
                  onTap: _randomizeData,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _smooth,
                      onChanged: (val) => setState(() => _smooth = val ?? true),
                    ),
                    const Text('Bezier Curve Smoothing', style: TextStyle(fontSize: 13)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _showEndDot,
                      onChanged: (val) => setState(() => _showEndDot = val ?? true),
                    ),
                    const Text('Pulse End Dot', style: TextStyle(fontSize: 13)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _showMinMaxDots,
                      onChanged: (val) => setState(() => _showMinMaxDots = val ?? true),
                    ),
                    const Text('Highlight Min/Max Dots', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Live Analytical KPI Cards with Embedded Sparklines
          Text('Analytical KPI Tiles', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildKpiCard(
                title: 'Monthly Recurring Revenue',
                value: '\$42,850',
                delta: 24.8,
                comparisonLabel: 'vs last month',
                chart: TSparkline(
                  data: _revenueData,
                  type: TSparklineType.area,
                  color: Colors.green.shade600,
                  smooth: _smooth,
                  showEndDot: _showEndDot,
                  showMinMaxDots: _showMinMaxDots,
                  height: 48,
                  width: 140,
                ),
              ),
              _buildKpiCard(
                title: 'P99 Latency',
                value: '21.5 ms',
                delta: -32.4,
                comparisonLabel: 'vs peak hours',
                isPositiveGood: false, // latency drop is good!
                chart: TSparkline(
                  data: _latencyData,
                  type: TSparklineType.line,
                  color: Colors.blue.shade600,
                  smooth: _smooth,
                  showEndDot: _showEndDot,
                  height: 48,
                  width: 140,
                ),
              ),
              _buildKpiCard(
                title: 'Throughput (Req / Sec)',
                value: '450 k/s',
                delta: 18.2,
                comparisonLabel: 'vs baseline',
                chart: TSparkline(
                  data: _requestsData,
                  type: TSparklineType.bar,
                  color: Colors.indigo.shade600,
                  height: 48,
                  width: 140,
                ),
              ),
              _buildKpiCard(
                title: 'Cluster Error Rate',
                value: '0.01%',
                delta: -68.0,
                comparisonLabel: 'vs yesterday',
                isPositiveGood: false,
                chart: TSparkline(
                  data: _errorsData,
                  type: TSparklineType.area,
                  color: Colors.teal.shade600,
                  smooth: _smooth,
                  showEndDot: _showEndDot,
                  height: 48,
                  width: 140,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Trend Indicator Gallery Card
          TCard(
            title: 'TTrendIndicator Gallery',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Versatile directional badges for delta percentages and metric deltas:'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: const [
                    TTrendIndicator(delta: 18.4, comparisonLabel: 'growth'),
                    TTrendIndicator(delta: -4.2, comparisonLabel: 'churn'),
                    TTrendIndicator(delta: -15.8, isPositiveGood: false, comparisonLabel: 'lower latency (Good)'),
                    TTrendIndicator(delta: 0.0, showArrow: false, comparisonLabel: 'unchanged'),
                    TTrendIndicator(delta: 24.5, asPill: false, comparisonLabel: 'raw text style'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required double delta,
    required String comparisonLabel,
    required Widget chart,
    bool isPositiveGood = true,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: 340,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: theme.hintColor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TTrendIndicator(
                      delta: delta,
                      isPositiveGood: isPositiveGood,
                      comparisonLabel: comparisonLabel,
                    ),
                  ],
                ),
              ),
              chart,
            ],
          ),
        ],
      ),
    );
  }
}
