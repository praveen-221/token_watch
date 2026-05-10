import 'dart:async';
import 'package:token_watch/data/datasources/local/hive_datasource.dart';
import 'package:token_watch/data/datasources/local/secure_storage_datasource.dart';
import 'package:token_watch/data/models/settings_model.dart';
import 'package:token_watch/domain/entities/settings_config.dart';
import 'package:token_watch/data/datasources/remote/api_client.dart'
    as api_client;

typedef ProviderId = String;

class SettingsRepositoryImpl {
  final HiveDatasource hiveDatasource;
  final SecureStorageDatasource secureStorageDatasource;
  final api_client.ApiClient apiClient;
  final StreamController<SettingsConfig> _controller =
      StreamController<SettingsConfig>.broadcast();

  SettingsRepositoryImpl(
      {required this.hiveDatasource,
      required this.secureStorageDatasource,
      required this.apiClient}) {
    _init();
  }

  Future<void> _init() async {
    final model = await hiveDatasource.getSettings();
    _controller.add(model?.toEntity() ?? SettingsConfig.defaultConfig());
  }

  Future<SettingsConfig> getSettings() async {
    final model = await hiveDatasource.getSettings();
    if (model == null) return SettingsConfig.defaultConfig();
    return model.toEntity();
  }

  Future<void> saveSettings(SettingsConfig config) async {
    final model = SettingsModel.fromEntity(config);
    await hiveDatasource.saveSettings(model);
    _controller.add(config);
  }

  Future<String?> getApiKey(ProviderId id) async {
    return await secureStorageDatasource.getApiKey(id);
  }

  Future<void> setApiKey(ProviderId id, String key) async {
    await secureStorageDatasource.setApiKey(id, key);
  }

  Future<void> deleteApiKey(ProviderId id) async {
    await secureStorageDatasource.deleteApiKey(id);
  }

  Stream<SettingsConfig> watchSettings() => _controller.stream;
}
