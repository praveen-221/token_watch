import 'package:token_watch/data/datasources/local/hive_datasource.dart';
import 'package:token_watch/data/datasources/local/secure_storage_datasource.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/data/models/provider_model.dart';
import 'package:token_watch/data/models/usage_model.dart';
import 'package:token_watch/data/datasources/remote/api_client.dart';
import 'package:token_watch/data/errors.dart';

typedef ProviderId = String;

class ProviderRepositoryImpl {
  final HiveDatasource hiveDatasource;
  final SecureStorageDatasource secureStorageDatasource;
  final ApiClient apiClient;

  ProviderRepositoryImpl(
      {required this.hiveDatasource,
      required this.secureStorageDatasource,
      required this.apiClient});

  Future<ProviderSnapshot> fetchProviderUsage(ProviderId id,
      {DateTime? context}) async {
    final apiKey = await secureStorageDatasource.getApiKey(id);
    if (apiKey == null) {
      throw AuthError(401, 'Missing API key for provider $id');
    }
    // Provider API URL is provider-specific; this is the bridge layer that delegates to adapters.
    final url = 'https://api.token_watch/providers/$id/usage';
    final data = await apiClient.get(url, headers: {
      'Authorization': 'Bearer $apiKey',
    });

    // Convert response to domain entity (best-effort, relies on domain constructors)
    final snapshot = ProviderSnapshot.fromJson(data);

    // Persist snapshot locally
    final model = ProviderModel.fromEntity(snapshot);
    await hiveDatasource.saveSnapshot(model);

    // Persist usage history if present
    if (data.containsKey('usage')) {
      final List<dynamic> list = data['usage'] as List<dynamic>;
      for (final item in list) {
        final usage = UsageModel(
          providerId: id,
          sessionUsed: item['sessionUsed'] ?? 0,
          sessionLimit: item['sessionLimit'] ?? 0,
          weeklyUsed: item['weeklyUsed'] ?? 0,
          weeklyLimit: item['weeklyLimit'] ?? 0,
          estimatedCost: (item['estimatedCost'] ?? 0).toDouble(),
          timestamp: DateTime.parse(
              item['timestamp'] ?? DateTime.now().toIso8601String()),
          sourceUsed: item['sourceUsed'] ?? '',
        );
        await hiveDatasource.saveUsage(usage);
      }
    }

    return snapshot;
  }

  Future<ProviderSnapshot?> getCachedSnapshot(ProviderId id) async {
    final model = await hiveDatasource.getLatestSnapshot(id);
    return model?.toEntity();
  }

  Future<List<UsageModel>> getUsageHistory(ProviderId id,
      {DateTime? from, DateTime? to}) async {
    return await hiveDatasource.getUsageHistory(id, from: from, to: to);
  }

  Future<void> clearCache() async {
    await hiveDatasource.clearCache();
  }
}
