import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/presentation/providers/analytics_provider.dart';
import 'package:token_watch/presentation/providers/settings_provider.dart';
import 'package:token_watch/presentation/providers/usage_provider.dart';
import 'package:token_watch/presentation/widgets/common/token_glass_card.dart';
import 'package:token_watch/presentation/widgets/charts/trend_line_chart.dart';
import 'package:token_watch/presentation/widgets/charts/usage_bar_chart.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.week;

  @override
  void initState() {
    super.initState();
    // Schedule initial computation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAndCompute();
    });
  }

  void _refreshAndCompute() {
    final usageState = ref.read(usageStateProvider);
    ref
        .read(analyticsNotifierProvider.notifier)
        .computeFromSnapshots(usageState.snapshots);
  }

  @override
  Widget build(BuildContext context) {
    final usageState = ref.watch(usageStateProvider);
    final analyticsState = ref.watch(analyticsNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);

    // Filter snapshots by enabled providers
    final filteredSnapshots = Map<ProviderId, ProviderSnapshot>.fromEntries(
      usageState.snapshots.entries
          .where((e) => settings.enabledProviders[e.key] ?? true),
    );

    // Re-compute analytics whenever snapshots change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(analyticsNotifierProvider.notifier)
          .computeFromSnapshots(filteredSnapshots);
    });

    final days = _daysForPeriod(_selectedPeriod);
    final spots = _generateTrendSpots(filteredSnapshots, days);
    final periodLabel = _periodLabel(_selectedPeriod);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        flexibleSpace: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(usageNotifierProvider.notifier).refreshAll(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Period selector: Day, Week
            SegmentedButton<AnalyticsPeriod>(
              segments: const [
                ButtonSegment(
                    value: AnalyticsPeriod.day,
                    label: Text('Day'),
                    icon: Icon(Icons.today)),
                ButtonSegment(
                    value: AnalyticsPeriod.week,
                    label: Text('Week'),
                    icon: Icon(Icons.date_range)),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    periodLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (filteredSnapshots.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No usage data yet',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    )
                  else
                    UsageBarChart(data: _getUsageByProvider(filteredSnapshots)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Usage Trend - only show for week (not for single day)
            if (_selectedPeriod == AnalyticsPeriod.week)
              TokenGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usage Trend — $periodLabel',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TrendLineChart(spots: spots, totalDays: days),
                  ],
                ),
              ),
            if (_selectedPeriod == AnalyticsPeriod.week)
              const SizedBox(height: 16),

            // Summary stats
            TokenGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(context, 'Total Tokens',
                          _formatNumber(analyticsState.totalTokens)),
                      _buildStat(context, 'Est. Cost',
                          '\$${analyticsState.totalCost.toStringAsFixed(4)}'),
                      _buildStat(context, 'Providers',
                          analyticsState.totalProviders.toString()),
                    ],
                  ),
                ],
              ),
            ),
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
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  Map<ProviderId, double> _getUsageByProvider(
      Map<ProviderId, ProviderSnapshot> snapshots) {
    final map = <ProviderId, double>{};
    for (final entry in snapshots.entries) {
      map[entry.key] = entry.value.sessionPercent;
    }
    return map;
  }

  List<FlSpot> _generateTrendSpots(
      Map<ProviderId, ProviderSnapshot> snapshots, int days) {
    if (snapshots.isEmpty) {
      return List.generate(days, (i) => FlSpot(i.toDouble(), 0.0));
    }

    int totalUsed = 0;
    for (final snap in snapshots.values) {
      totalUsed += snap.sessionUsed ?? 0;
    }
    final points = <FlSpot>[];

    for (int i = 0; i < days; i++) {
      final x = i.toDouble();
      final y = totalUsed > 0 ? (totalUsed.toDouble() / days) * (i + 1) : 0.0;
      points.add(FlSpot(x, y));
    }

    return points;
  }

  int _daysForPeriod(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.day:
        return 1;
      case AnalyticsPeriod.week:
        return 7;
    }
  }

  String _periodLabel(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.day:
        return 'Today';
      case AnalyticsPeriod.week:
        return 'This Week';
    }
  }
}
