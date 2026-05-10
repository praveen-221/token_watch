import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Trend line chart with glassy card container and gradient line.
class TrendLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final String label;
  final int totalDays;

  const TrendLineChart({
    super.key,
    required this.spots,
    this.label = 'Usage Trend',
    this.totalDays = 7,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return const Center(child: Text('No trend data available'));
    }

    final theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= totalDays)
                        return const SizedBox.shrink();
                      // Show day labels: D1, D2, etc.
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'D${idx + 1}',
                          style:
                              theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: _calculateInterval(),
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatNumber(value.toInt()),
                        style:
                            theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                      );
                    },
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        'Day ${spot.x.toInt() + 1}\n${_formatNumber(spot.y.toInt())} tokens',
                        TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Usage Trend',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }

  double _calculateInterval() {
    if (spots.isEmpty) return 25;
    double maxY = 0;
    for (final spot in spots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    if (maxY == 0) return 25;
    return (maxY / 4).ceilToDouble();
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
