import 'dart:async';

import '../entities/provider_id.dart';
import '../entities/fetch_context.dart';
import '../entities/provider_snapshot.dart';
import 'provider_registry.dart';
import '../entities/settings_config.dart';

class FetchOrchestrator {
  final ProviderRegistry registry;
  SettingsConfig? _settings;
  DateTime? _lastRefresh;

  FetchOrchestrator({required this.registry, SettingsConfig? settings}) {
    _settings = settings ?? SettingsConfig.defaultConfig();
  }

  Future<Map<ProviderId, ProviderSnapshot>> refreshAll({List<ProviderId>? providerIds}) async {
    final ids = providerIds ?? ProviderId.values;
    final futures = ids.map((id) async {
      final adapter = registry.create(id);
      if (adapter == null) {
        return MapEntry(id, ProviderSnapshot.empty(id));
      }
      final context = FetchContext(providerId: id, sourceMode: adapter.defaultSource, credentials: <String, String>{}, sessionId: null);
      try {
        final snap = await adapter.fetch(context);
        return MapEntry(id, snap);
      } catch (e) {
        return MapEntry(id, ProviderSnapshot.empty(id));
      }
    }).toList();
    final results = await Future.wait(futures);
    final map = <ProviderId, ProviderSnapshot>{};
    for (var e in results) {
      map[e.key] = e.value;
    }
    _lastRefresh = DateTime.now();
    return map;
  }

  bool shouldRefresh(DateTime? lastRefresh) {
    final ttl = _settings?.refreshInterval ?? const Duration(minutes: 5);
    if (lastRefresh == null) return true;
    return DateTime.now().difference(lastRefresh) > ttl;
  }

  // Exposed for debugging / advanced usage
  DateTime? get lastRefresh => _lastRefresh;
}
