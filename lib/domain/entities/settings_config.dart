import 'package:flutter/material.dart';
import 'provider_id.dart';

// Immutable domain settings for the token watch app
class SettingsConfig {
  final Map<ProviderId, bool> enabledProviders;
  final Duration refreshInterval;
  final Duration ttl;
  final bool notificationsEnabled;
  final double alertThreshold; // 0.0 - 1.0
  final ThemeMode themeMode;

  const SettingsConfig({
    required this.enabledProviders,
    required this.refreshInterval,
    required this.ttl,
    required this.notificationsEnabled,
    required this.alertThreshold,
    required this.themeMode,
  });

  factory SettingsConfig.defaultConfig() {
    final enabled = <ProviderId, bool>{};
    for (var p in ProviderId.values) {
      enabled[p] = true;
    }
    return SettingsConfig(
      enabledProviders: enabled,
      refreshInterval: const Duration(minutes: 5),
      ttl: const Duration(minutes: 5),
      notificationsEnabled: false,
      alertThreshold: 0.85,
      themeMode: ThemeMode.system,
    );
  }

  SettingsConfig copyWith(
      {Map<ProviderId, bool>? enabledProviders,
      Duration? refreshInterval,
      Duration? ttl,
      bool? notificationsEnabled,
      double? alertThreshold,
      ThemeMode? themeMode}) {
    return SettingsConfig(
      enabledProviders: enabledProviders ?? this.enabledProviders,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      ttl: ttl ?? this.ttl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
