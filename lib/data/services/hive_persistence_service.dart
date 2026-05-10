import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/domain/entities/settings_config.dart';

class HivePersistenceService {
  static const String _settingsKey = 'app_settings';
  static const String _snapshotBoxName = 'provider_cache';
  static const String _historyBoxName = 'usage_history';

  Box? _settingsBox;
  Box? _snapshotBox;
  Box? _historyBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox(_snapshotBoxName);
    _snapshotBox = await Hive.openBox(_snapshotBoxName);
    _historyBox = await Hive.openBox(_historyBoxName);
  }

  // Settings persistence
  Future<void> saveSettings(SettingsConfig config) async {
    await _settingsBox?.put(_settingsKey, _settingsToJson(config));
  }

  SettingsConfig? loadSettings() {
    final data = _settingsBox?.get(_settingsKey);
    if (data == null) return null;
    return _settingsFromJson(data as String);
  }

  // Snapshot cache
  Future<void> saveSnapshot(ProviderId id, ProviderSnapshot snapshot) async {
    await _snapshotBox?.put(id.id, jsonEncode(snapshot.toJson()));
  }

  ProviderSnapshot? loadSnapshot(ProviderId id) {
    final data = _snapshotBox?.get(id.id);
    if (data == null) return null;
    return ProviderSnapshot.fromJson(jsonDecode(data as String) as Map<String, dynamic>);
  }

  Map<ProviderId, ProviderSnapshot> loadAllSnapshots() {
    final result = <ProviderId, ProviderSnapshot>{};
    for (final key in _snapshotBox?.keys ?? []) {
      final data = _snapshotBox?.get(key);
      if (data != null) {
        try {
          final snapshot = ProviderSnapshot.fromJson(
            jsonDecode(data as String) as Map<String, dynamic>,
          );
          result[snapshot.providerId] = snapshot;
        } catch (_) {}
      }
    }
    return result;
  }

  Future<void> clearCache() async {
    await _snapshotBox?.clear();
    await _historyBox?.clear();
  }

  Future<void> close() async {
    await _settingsBox?.close();
    await _snapshotBox?.close();
    await _historyBox?.close();
  }

  String _settingsToJson(SettingsConfig config) {
    return jsonEncode({
      'enabledProviders': config.enabledProviders.map((k, v) => MapEntry(k.id, v)),
      'refreshIntervalMinutes': config.refreshInterval.inMinutes,
      'ttlMinutes': config.ttl.inMinutes,
      'notificationsEnabled': config.notificationsEnabled,
      'alertThreshold': config.alertThreshold,
      'themeModeIndex': config.themeMode.index,
    });
  }

  SettingsConfig _settingsFromJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final enabledProviders = <ProviderId, bool>{};
    final enabledMap = data['enabledProviders'] as Map<String, dynamic>;
    for (final entry in enabledMap.entries) {
      final providerId = ProviderId.values.firstWhere(
        (e) => e.id == entry.key,
        orElse: () => ProviderId.openai,
      );
      enabledProviders[providerId] = entry.value as bool;
    }

    return SettingsConfig(
      enabledProviders: enabledProviders,
      refreshInterval: Duration(minutes: data['refreshIntervalMinutes'] as int),
      ttl: Duration(minutes: data['ttlMinutes'] as int),
      notificationsEnabled: data['notificationsEnabled'] as bool,
      alertThreshold: (data['alertThreshold'] as num).toDouble(),
      themeMode: ThemeMode.values[data['themeModeIndex'] as int],
    );
  }
}
