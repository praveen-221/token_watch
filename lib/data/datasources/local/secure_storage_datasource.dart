import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef ProviderId = String;

class SecureStorageDatasource {
  final FlutterSecureStorage storage;
  static const String _prefix = 'token_watch_';
  static const String _apiKeySuffix = '_api_key';

  const SecureStorageDatasource({required this.storage});

  String _keyFor(ProviderId providerId) => '$_prefix$providerId$_apiKeySuffix';

  Future<String?> getApiKey(ProviderId providerId) async {
    final key = _keyFor(providerId);
    return storage.read(key: key);
  }

  Future<void> setApiKey(ProviderId providerId, String key) async {
    final storageKey = _keyFor(providerId);
    await storage.write(key: storageKey, value: key);
  }

  Future<void> deleteApiKey(ProviderId providerId) async {
    final storageKey = _keyFor(providerId);
    await storage.delete(key: storageKey);
  }

  Future<Map<ProviderId, String>> getAllApiKeys() async {
    final all = await storage.readAll();
    final Map<ProviderId, String> result = {};
    for (final entry in all.entries) {
      if (entry.key.startsWith(_prefix)) {
        final key = entry.key.substring(_prefix.length);
        if (key.endsWith(_apiKeySuffix)) {
          final providerId =
              key.substring(0, key.length - _apiKeySuffix.length);
          result[providerId] = entry.value;
        }
      }
    }
    return result;
  }

  Future<void> clearAll() async {
    final all = await storage.readAll();
    final keysToDelete = <String>[];
    for (final entry in all.entries) {
      if (entry.key.startsWith(_prefix)) keysToDelete.add(entry.key);
    }
    for (final key in keysToDelete) {
      await storage.delete(key: key);
    }
  }
}
