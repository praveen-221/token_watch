import '../entities/provider_id.dart';
import '../entities/provider_snapshot.dart';

class AlertService {
  List<ProviderId> checkThresholds(
      Map<ProviderId, ProviderSnapshot> snapshots, double threshold) {
    // threshold is a fraction 0.0-1.0
    final exceeded = <ProviderId>[];
    for (final e in snapshots.entries) {
      final s = e.value;
      final percent = s.sessionPercent;
      if (percent >= threshold) exceeded.add(e.key);
    }
    return exceeded;
  }
}
