import 'dart:async';

import 'provider_registry.dart';
import 'fetch_orchestrator.dart';
import 'package:token_watch/providers/base_provider.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/domain/entities/settings_config.dart';
import 'package:token_watch/data/datasources/local/hive_datasource.dart';
import 'package:token_watch/data/models/provider_model.dart';

// Facade that ties registry + orchestrator together for domain usage
class ProviderEngine {
  final ProviderRegistry registry;
  final FetchOrchestrator orchestrator;
  final HiveDatasource? _hiveDatasource;
  SettingsConfig _settings;

  final _snapshotController =
      StreamController<Map<ProviderId, ProviderSnapshot>>.broadcast();
  Map<ProviderId, ProviderSnapshot> _snapshot = {};
  final Map<ProviderId, ProviderSnapshot> _cache = {};

  ProviderEngine(
      {required this.registry,
      required this.orchestrator,
      SettingsConfig? initialSettings,
      HiveDatasource? hiveDatasource})
      : _settings = initialSettings ?? SettingsConfig.defaultConfig(),
        _hiveDatasource = hiveDatasource;

  // Load cached snapshots from Hive on initialization
  Future<void> loadFromCache() async {
    if (_hiveDatasource == null) return;
    try {
      for (final id in ProviderId.values) {
        final model = await _hiveDatasource!.getLatestSnapshot(id.id);
        if (model != null) {
          _cache[id] = ProviderSnapshot(
            providerId: id,
            sessionUsed: model.sessionUsed,
            sessionLimit: model.sessionLimit,
            weeklyUsed: model.weeklyUsed,
            weeklyLimit: model.weeklyLimit,
            monthlyUsed: model.monthlyUsed,
            monthlyLimit: model.monthlyLimit,
            fetchedAt: model.lastSync,
            sourceUsed: model.sourceUsed,
            estimatedCost: model.estimatedCost,
          );
        }
      }
    } catch (_) {}
  }

  // Provider creation via registry
  ProviderAdapter? createProvider(ProviderId id) => registry.create(id);

  // Refresh all providers (respecting TTL in orchestrator)
  Future<Map<ProviderId, ProviderSnapshot>> refreshAll({
    List<ProviderId>? providerIds,
    Map<ProviderId, String>? apiKeys,
  }) async {
    final snapshots = await orchestrator.refreshAll(
        providerIds: providerIds, apiKeys: apiKeys);
    _snapshot = snapshots;
    _cache.addAll(snapshots);
    _snapshotController.add(_snapshot);
    return _snapshot;
  }

  Future<Map<ProviderId, ProviderSnapshot>> refreshProvider(
    ProviderId id, {
    Map<ProviderId, String>? apiKeys,
  }) {
    return refreshAll(providerIds: [id], apiKeys: apiKeys);
  }

  ProviderSnapshot? getSnapshot(ProviderId id) => _snapshot[id];

  List<ProviderId> getEnabledProviders() {
    final keys = _settings.enabledProviders.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (keys.isEmpty) return ProviderId.values.toList();
    return keys;
  }

  void updateSettings(SettingsConfig config) {
    _settings = config;
  }

  Stream<Map<ProviderId, ProviderSnapshot>> get snapshotStream =>
      _snapshotController.stream;

  // Cache methods used by presentation layer
  Future<void> persistSnapshot(ProviderId id, ProviderSnapshot snapshot) async {
    _cache[id] = snapshot;
    // Also persist to Hive for app restart persistence
    if (_hiveDatasource != null) {
      try {
        final model = ProviderModel(
          id: id.id,
          name: id.displayName,
          isEnabled: true,
          sessionUsed: snapshot.sessionUsed,
          sessionLimit: snapshot.sessionLimit,
          weeklyUsed: snapshot.weeklyUsed,
          weeklyLimit: snapshot.weeklyLimit,
          monthlyUsed: snapshot.monthlyUsed,
          monthlyLimit: snapshot.monthlyLimit,
          lastSync: snapshot.fetchedAt,
          sourceUsed: snapshot.sourceUsed,
          estimatedCost: snapshot.estimatedCost,
        );
        await _hiveDatasource!.saveSnapshot(model);
      } catch (_) {}
    }
  }

  Future<void> clearCache() async {
    _cache.clear();
    _snapshot.clear();
    if (_hiveDatasource != null) {
      await _hiveDatasource!.clearCache();
    }
  }

  Map<ProviderId, ProviderSnapshot> loadCachedSnapshots() => Map.from(_cache);
}
