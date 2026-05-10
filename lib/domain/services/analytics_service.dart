import '../entities/provider_id.dart';

// Lightweight analytics service interface for domain layer
class AnalyticsService {
  Future<Map<ProviderId, double>> getUsageByProvider(Duration period) async {
    // Placeholder implementation; in domain layer this would query Hive or similar
    return {for (var p in ProviderId.values) p: 0.0};
  }

  Future<List<Map<ProviderId, double>>> getTrendOverTime(
      Duration period) async {
    // Placeholder trend data
    return [];
  }

  Future<double> getTotalCost(Duration period) async {
    return 0.0;
  }

  Future<DateTime?> getPeakUsageDate(Duration period) async {
    return null;
  }
}
