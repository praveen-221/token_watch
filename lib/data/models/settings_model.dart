import 'package:flutter/material.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/settings_config.dart';

class SettingsModel {
  Map<String, bool> enabledProviders;
  int refreshIntervalMinutes;
  int ttlMinutes;
  bool notificationsEnabled;
  double alertThreshold;
  int themeModeIndex;

  SettingsModel({
    required this.enabledProviders,
    required this.refreshIntervalMinutes,
    required this.ttlMinutes,
    required this.notificationsEnabled,
    required this.alertThreshold,
    required this.themeModeIndex,
  });

  SettingsConfig toEntity() {
    final providerMap = <ProviderId, bool>{};
    for (final entry in enabledProviders.entries) {
      final pid = ProviderId.values.firstWhere(
        (e) => e.id == entry.key,
        orElse: () => ProviderId.openai,
      );
      providerMap[pid] = entry.value;
    }
    return SettingsConfig(
      enabledProviders: providerMap,
      refreshInterval: Duration(minutes: refreshIntervalMinutes),
      ttl: Duration(minutes: ttlMinutes),
      notificationsEnabled: notificationsEnabled,
      alertThreshold: alertThreshold,
      themeMode: ThemeMode
          .values[themeModeIndex.clamp(0, ThemeMode.values.length - 1)],
    );
  }

  factory SettingsModel.fromEntity(SettingsConfig config) {
    final stringMap = <String, bool>{};
    for (final entry in config.enabledProviders.entries) {
      stringMap[entry.key.id] = entry.value;
    }
    return SettingsModel(
      enabledProviders: stringMap,
      refreshIntervalMinutes: config.refreshInterval.inMinutes,
      ttlMinutes: config.ttl.inMinutes,
      notificationsEnabled: config.notificationsEnabled,
      alertThreshold: config.alertThreshold,
      themeModeIndex: config.themeMode.index,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabledProviders': enabledProviders,
      'refreshIntervalMinutes': refreshIntervalMinutes,
      'ttlMinutes': ttlMinutes,
      'notificationsEnabled': notificationsEnabled,
      'alertThreshold': alertThreshold,
      'themeModeIndex': themeModeIndex,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      enabledProviders: Map<String, bool>.from(json['enabledProviders'] as Map),
      refreshIntervalMinutes: json['refreshIntervalMinutes'] as int,
      ttlMinutes: json['ttlMinutes'] as int,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      alertThreshold: (json['alertThreshold'] as num).toDouble(),
      themeModeIndex: json['themeModeIndex'] as int,
    );
  }
}
