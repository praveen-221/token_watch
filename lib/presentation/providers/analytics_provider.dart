import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';

final analyticsNotifierProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});

final analyticsStateProvider = Provider<AnalyticsState>((ref) {
  return ref.watch(analyticsNotifierProvider);
});

final usageTrendProvider = Provider<List<UsageDataPoint>>((ref) {
  final state = ref.watch(analyticsNotifierProvider);
  return state.trendData;
});

final usageBreakdownProvider = Provider<Map<ProviderId, double>>((ref) {
  final state = ref.watch(analyticsNotifierProvider);
  return state.usageByProvider;
});

class UsageDataPoint {
  final DateTime date;
  final int tokenCount;
  final double cost;

  const UsageDataPoint({
    required this.date,
    required this.tokenCount,
    required this.cost,
  });
}

enum AnalyticsPeriod { day, week }

class AnalyticsState {
  final AnalyticsPeriod selectedPeriod;
  final Map<ProviderId, double> usageByProvider;
  final List<UsageDataPoint> trendData;
  final double totalCost;
  final DateTime? peakUsageDate;
  final int totalTokens;
  final int totalProviders;

  AnalyticsState({
    required this.selectedPeriod,
    required this.usageByProvider,
    required this.trendData,
    required this.totalCost,
    this.peakUsageDate,
    this.totalTokens = 0,
    this.totalProviders = 0,
  });

  factory AnalyticsState.initial() {
    return AnalyticsState(
      selectedPeriod: AnalyticsPeriod.week,
      usageByProvider: const {},
      trendData: const [],
      totalCost: 0.0,
      peakUsageDate: null,
    );
  }

  AnalyticsState copyWith({
    AnalyticsPeriod? selectedPeriod,
    Map<ProviderId, double>? usageByProvider,
    List<UsageDataPoint>? trendData,
    double? totalCost,
    DateTime? peakUsageDate,
    int? totalTokens,
    int? totalProviders,
  }) {
    return AnalyticsState(
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      usageByProvider: usageByProvider ?? this.usageByProvider,
      trendData: trendData ?? this.trendData,
      totalCost: totalCost ?? this.totalCost,
      peakUsageDate: peakUsageDate ?? this.peakUsageDate,
      totalTokens: totalTokens ?? this.totalTokens,
      totalProviders: totalProviders ?? this.totalProviders,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(AnalyticsState.initial());

  void setDateRange(AnalyticsPeriod period) {
    state = state.copyWith(selectedPeriod: period);
  }

  void computeFromSnapshots(Map<ProviderId, ProviderSnapshot> snapshots) {
    if (snapshots.isEmpty) {
      state = AnalyticsState.initial();
      return;
    }

    // Compute usage by provider: session percent per provider
    final usageByProvider = <ProviderId, double>{};
    for (final entry in snapshots.entries) {
      usageByProvider[entry.key] = entry.value.sessionPercent;
    }

    // Total stats
    final totalTokens =
        snapshots.values.fold(0, (sum, s) => sum + (s.sessionUsed ?? 0));
    final totalCost =
        snapshots.values.fold(0.0, (sum, s) => sum + (s.estimatedCost ?? 0.0));

    // Find peak usage provider
    ProviderId? peakProvider;
    double peakPercent = 0;
    for (final entry in usageByProvider.entries) {
      if (entry.value > peakPercent) {
        peakPercent = entry.value;
        peakProvider = entry.key;
      }
    }

    // Generate trend data based on selected period
    final now = DateTime.now();
    final days = _daysForPeriod(state.selectedPeriod);
    final trendData = <UsageDataPoint>[];

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: days - i - 1));
      // Distribute total usage across period (simple linear model)
      final tokensPerDay = days > 0 ? (totalTokens / days).toInt() : 0;
      final accumulativeTokens = tokensPerDay * (i + 1);
      trendData.add(UsageDataPoint(
        date: date,
        tokenCount: accumulativeTokens,
        cost: totalCost * (i + 1) / days,
      ));
    }

    state = state.copyWith(
      usageByProvider: usageByProvider,
      trendData: trendData,
      totalCost: totalCost,
      totalTokens: totalTokens,
      totalProviders: snapshots.length,
      peakUsageDate: peakProvider != null ? DateTime.now() : null,
    );
  }

  int _daysForPeriod(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.day:
        return 1;
      case AnalyticsPeriod.week:
        return 7;
    }
  }

  String periodLabel(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.day:
        return 'Day';
      case AnalyticsPeriod.week:
        return 'Week';
    }
  }

  String periodShortLabel(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.day:
        return 'D';
      case AnalyticsPeriod.week:
        return 'W';
    }
  }
}
