import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/presentation/providers/usage_provider.dart';
import 'package:token_watch/presentation/widgets/common/token_glass_card.dart';
import 'package:token_watch/presentation/widgets/charts/trend_line_chart.dart';
import 'package:token_watch/presentation/widgets/charts/usage_bar_chart.dart';

enum AnalyticsPeriod { day, week, month }

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.week;

  @override
  Widget build(BuildContext context) {
    final usageState = ref.watch(usageStateProvider);
    final spots = _generateTrendSpots(usageState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(usageNotifierProvider.notifier).refreshAll(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<AnalyticsPeriod>(
              segments: const [
                ButtonSegment(value: AnalyticsPeriod.day, label: Text('Day'), icon: Icon(Icons.today)),
                ButtonSegment(value: AnalyticsPeriod.week, label: Text('Week'), icon: Icon(Icons.date_range)),
                ButtonSegment(value: AnalyticsPeriod.month, label: Text('Month'), icon: Icon(Icons.calendar_month)),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (selected) {
                setState(() => _selectedPeriod = selected.first);
              },
            ),
            const SizedBox(height: 24),
            // Usage by Provider
            TokenGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usage by Provider',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  if (usageState.snapshots.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No usage data yet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    UsageBarChart(data: _getUsageByProvider(usageState)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Trend
            TokenGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usage Trend',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  TrendLineChart(spots: spots),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Summary
            TokenGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(context, 'Total Tokens', usageState.totalSessionUsed.toString()),
                      _buildStat(context, 'Est. Cost', '\$${usageState.totalEstimatedCost.toStringAsFixed(4)}'),
                      _buildStat(context, 'Providers', usageState.snapshots.length.toString()),
                    ],
                  ),
                ],
              ),
            ),
            // Per-provider breakdown
            if (usageState.snapshots.isNotEmpty) ...[
              const SizedBox(height: 16),
              TokenGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Per-Provider Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...usageState.snapshots.entries.map((e) => _ProviderDetailRow(
                          providerId: e.key,
                          snapshot: e.value,
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Map<ProviderId, double> _getUsageByProvider(UsageState state) {
    final map = <ProviderId, double>{};
    for (final entry in state.snapshots.entries) {
      map[entry.key] = entry.value.sessionPercent;
    }
    return map;
  }

  List<FlSpot> _generateTrendSpots(UsageState state) {
    // Derive trend from actual usage snapshots
    if (state.snapshots.isEmpty) {
      // Return flat line if no data
      return List.generate(7, (i) => FlSpot(i.toDouble(), 0.0));
    }

    // Build trend from total session usage across providers
    final days = _selectedPeriod == AnalyticsPeriod.day
        ? 1
        : _selectedPeriod == AnalyticsPeriod.week
            ? 7
            : 30;

    final totalUsed = state.totalSessionUsed;
    final points = <FlSpot>[];

    for (int i = 0; i < days; i++) {
      // Distribute usage proportionally (simple linear model based on available data)
      final x = i.toDouble();
      final y = totalUsed > 0 ? (totalUsed.toDouble() / days) * (i + 1) : 0.0;
      points.add(FlSpot(x, y));
    }

    return points;
  }
}

class _ProviderDetailRow extends StatelessWidget {
  final ProviderId providerId;
  final ProviderSnapshot snapshot;
  const _ProviderDetailRow({required this.providerId, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(providerId.icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              providerId.displayName,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            '${snapshot.sessionUsed ?? 0} / ${snapshot.sessionLimit ?? 0}',
            style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: snapshot.sessionLevel.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(snapshot.sessionPercent * 100).toInt()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: snapshot.sessionLevel.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
