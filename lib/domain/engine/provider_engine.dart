import 'dart:async';

import 'provider_registry.dart';
import 'fetch_orchestrator.dart';
import 'package:token_watch/providers/base_provider.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/domain/entities/settings_config.dart';

// Facade that ties registry + orchestrator together for domain usage
class ProviderEngine {
  final ProviderRegistry registry;
  final FetchOrchestrator orchestrator;
  SettingsConfig _settings;

  final _snapshotController = StreamController<Map<ProviderId, ProviderSnapshot>>.broadcast();
  Map<ProviderId, ProviderSnapshot> _snapshot = {};
  final Map<ProviderId, ProviderSnapshot> _cache = {};

  ProviderEngine({required this.registry, required this.orchestrator, SettingsConfig? initialSettings})
      : _settings = initialSettings ?? SettingsConfig.defaultConfig();

  // Provider creation via registry
  ProviderAdapter? createProvider(ProviderId id) => registry.create(id);

  // Refresh all providers (respecting TTL in orchestrator)
  Future<Map<ProviderId, ProviderSnapshot>> refreshAll({List<ProviderId>? providerIds}) async {
    final snapshots = await orchestrator.refreshAll(providerIds: providerIds);
    _snapshot = snapshots;
    _cache.addAll(snapshots);
    _snapshotController.add(_snapshot);
    return _snapshot;
  }

  Future<Map<ProviderId, ProviderSnapshot>> refreshProvider(ProviderId id) {
    return refreshAll(providerIds: [id]);
  }

  ProviderSnapshot? getSnapshot(ProviderId id) => _snapshot[id];

  List<ProviderId> getEnabledProviders() {
    final keys = _settings.enabledProviders.entries.where((e) => e.value).map((e) => e.key).toList();
    if (keys.isEmpty) return ProviderId.values.toList();
    return keys;
  }

  void updateSettings(SettingsConfig config) { _settings = config; }

  Stream<Map<ProviderId, ProviderSnapshot>> get snapshotStream => _snapshotController.stream;

  // Cache methods used by presentation layer
  Future<void> persistSnapshot(ProviderId id, ProviderSnapshot snapshot) async {
    _cache[id] = snapshot;
  }

  Future<void> clearCache() async {
    _cache.clear();
    _snapshot.clear();
  }

  Map<ProviderId, ProviderSnapshot> loadCachedSnapshots() => Map.from(_cache);
}
