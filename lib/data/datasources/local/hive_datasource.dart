import 'package:hive_flutter/hive_flutter.dart';
import 'package:token_watch/data/models/provider_model.dart';
import 'package:token_watch/data/models/usage_model.dart';
import 'package:token_watch/data/models/settings_model.dart';

class HiveDatasource {
  final Box providerBox;
  final Box usageBox;
  final Box settingsBox;

  HiveDatasource({required this.providerBox, required this.usageBox, required this.settingsBox});

  // Provider snapshot cache
  Future<void> saveSnapshot(ProviderModel model) async {
    await providerBox.put(model.id, model.toJson());
  }

  Future<ProviderModel?> getLatestSnapshot(String providerId) async {
    final items = <ProviderModel>[];
    for (final key in providerBox.keys) {
      final data = providerBox.get(key);
      if (data is Map && data['id'] == providerId) {
        try {
          items.add(ProviderModel.fromJson(Map<String, dynamic>.from(data)));
        } catch (_) {}
      }
    }
    if (items.isEmpty) return null;
    items.sort((a, b) {
      final ad = a.lastSync?.millisecondsSinceEpoch ?? 0;
      final bd = b.lastSync?.millisecondsSinceEpoch ?? 0;
      return ad.compareTo(bd);
    });
    return items.last;
  }

  Future<List<UsageModel>> getUsageHistory(String providerId, {DateTime? from, DateTime? to}) async {
    final all = <UsageModel>[];
    for (final key in usageBox.keys) {
      final data = usageBox.get(key);
      if (data is Map) {
        try {
          final model = UsageModel.fromJson(Map<String, dynamic>.from(data));
          if (model.providerId == providerId) {
            all.add(model);
          }
        } catch (_) {}
      }
    }
    DateTime? f = from;
    DateTime? t = to;
    return all.where((u) {
      final ts = u.timestamp;
      if (f != null && ts.isBefore(f)) return false;
      if (t != null && ts.isAfter(t)) return false;
      return true;
    }).toList();
  }

  Future<void> saveUsage(UsageModel model) async {
    await usageBox.put(model.timestamp.millisecondsSinceEpoch, model.toJson());
  }

  Future<SettingsModel?> getSettings() async {
    final data = settingsBox.get('settings');
    if (data == null) return null;
    try {
      return SettingsModel.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSettings(SettingsModel model) async {
    await settingsBox.put('settings', model.toJson());
  }

  Future<void> clearCache() async {
    await providerBox.clear();
    await usageBox.clear();
    await settingsBox.clear();
  }

  Future<void> close() async {
    await Hive.close();
  }
}
