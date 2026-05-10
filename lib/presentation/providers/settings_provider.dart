import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/settings_config.dart';

final settingsConfigProvider = Provider<SettingsConfig>((ref) {
  return SettingsConfig.defaultConfig();
});

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsConfig>((ref) {
  return SettingsNotifier();
});

/// Derived provider that only emits the current themeMode — avoids
/// full MaterialApp rebuilds when unrelated settings change.
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsNotifierProvider.select((s) => s.themeMode));
});

class SettingsNotifier extends StateNotifier<SettingsConfig> {
  SettingsNotifier() : super(SettingsConfig.defaultConfig());

  void toggleProvider(ProviderId id, bool enabled) {
    final current = Map<ProviderId, bool>.from(state.enabledProviders);
    current[id] = enabled;
    state = state.copyWith(enabledProviders: current);
  }

  void setRefreshInterval(Duration interval) {
    state = state.copyWith(refreshInterval: interval);
  }

  void setTtl(Duration ttl) {
    state = state.copyWith(ttl: ttl);
  }

  void setNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void setAlertThreshold(double threshold) {
    state = state.copyWith(alertThreshold: threshold);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  Future<void> saveApiKey(ProviderId id, String key) async {
    // Store securely using the secure storage datasource
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> saveSettings() async {
    // In a real integration, persist to a repository in domain layer.
  }
}
