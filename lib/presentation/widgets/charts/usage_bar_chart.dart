import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/usage_level.dart';

class UsageBarChart extends StatelessWidget {
  final Map<ProviderId, double> data;

  const UsageBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final List<BarChartGroupData> groups = data.entries.map((e) {
      final level = UsageLevel.fromPercent(e.value * 100);
      final index = data.keys.toList().indexOf(e.key);
      return BarChartGroupData(
        x: index,
        barRods: [BarChartRodData(
          toY: e.value * 100,
          color: level.color,
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        )],
        showingTooltipIndicators: [0],
      );
    }).toList();

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final entryKey = data.keys.elementAt(group.x);
                return BarTooltipItem(
                  '${entryKey.displayName}\n${(rod.toY).toInt()}%',
                  TextStyle(
                    color: rod.color,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) return const SizedBox.shrink();
                  final entry = data.keys.elementAt(index);
                  final name = entry.displayName;
                  final short = name.substring(0, name.length.clamp(0, 4));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(short, style: Theme.of(context).textTheme.labelSmall),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}%', style: Theme.of(context).textTheme.labelSmall);
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
          ),
          barGroups: groups,
        ),
      ),
    );
  }
}
