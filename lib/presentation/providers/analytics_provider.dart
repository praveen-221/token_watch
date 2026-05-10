import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:token_watch/domain/entities/provider_id.dart';

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

final usageBreakdownProvider =
    Provider<Map<ProviderId, double>>((ref) {
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

class AnalyticsState {
  final DateTimeRange selectedRange;
  final Map<ProviderId, double> usageByProvider;
  final List<UsageDataPoint> trendData;
  final double totalCost;
  final DateTime? peakUsageDate;

  AnalyticsState({
    required this.selectedRange,
    required this.usageByProvider,
    required this.trendData,
    required this.totalCost,
    this.peakUsageDate,
  });

  factory AnalyticsState.initial() {
    final now = DateTime.now();
    return AnalyticsState(
      selectedRange:
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      usageByProvider: const {},
      trendData: const [],
      totalCost: 0.0,
      peakUsageDate: null,
    );
  }

  AnalyticsState copyWith({
    DateTimeRange? selectedRange,
    Map<ProviderId, double>? usageByProvider,
    List<UsageDataPoint>? trendData,
    double? totalCost,
    DateTime? peakUsageDate,
  }) {
    return AnalyticsState(
      selectedRange: selectedRange ?? this.selectedRange,
      usageByProvider: usageByProvider ?? this.usageByProvider,
      trendData: trendData ?? this.trendData,
      totalCost: totalCost ?? this.totalCost,
      peakUsageDate: peakUsageDate ?? this.peakUsageDate,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(AnalyticsState.initial());

  void setDateRange(DateTimeRange range) {
    state = state.copyWith(selectedRange: range);
  }

  Future<void> refreshAnalytics() async {
    // In a real implementation, fetch analytics data from UsageNotifier or engine
    // For now, perform a lightweight no-op to demonstrate the pattern
    // This could populate usageByProvider and trendData based on current state
  }
}
