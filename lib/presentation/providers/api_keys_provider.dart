import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:token_watch/data/datasources/local/secure_storage_datasource.dart';

/// Singleton secure storage instance — safe for all platforms.
final _secureStorage = const FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

/// Data source for reading/writing encrypted API keys.
final secureStorageProvider = Provider<SecureStorageDatasource>((ref) {
  return SecureStorageDatasource(storage: _secureStorage);
});

/// Provider state: maps provider ID (string key) → stored API key (or null).
class ApiKeysState {
  final Map<String, String?> keys;
  final Map<String, bool> saving;

  const ApiKeysState({required this.keys, required this.saving});

  factory ApiKeysState.initial() {
    return ApiKeysState(
      keys: {},
      saving: {},
    );
  }

  ApiKeysState copyWith({Map<String, String?>? keys, Map<String, bool>? saving}) {
    return ApiKeysState(
      keys: keys ?? this.keys,
      saving: saving ?? this.saving,
    );
  }

  String? getApiKey(String providerId) => keys[providerId];
  bool isSaving(String providerId) => saving[providerId] ?? false;
}

final apiKeysNotifierProvider =
    StateNotifierProvider<ApiKeysNotifier, ApiKeysState>((ref) {
  final datasource = ref.watch(secureStorageProvider);
  return ApiKeysNotifier(datasource);
});

class ApiKeysNotifier extends StateNotifier<ApiKeysState> {
  final SecureStorageDatasource _datasource;

  ApiKeysNotifier(this._datasource) : super(ApiKeysState.initial()) {
    _loadAllKeys();
  }

  Future<void> _loadAllKeys() async {
    try {
      final all = await _datasource.getAllApiKeys();
      state = state.copyWith(keys: all);
    } catch (_) {
      // If loading fails, start with empty keys
    }
  }

  Future<void> loadKey(String providerId) async {
    try {
      final key = await _datasource.getApiKey(providerId);
      final updated = Map<String, String?>.from(state.keys);
      updated[providerId] = key;
      state = state.copyWith(keys: updated);
    } catch (_) {}
  }

  Future<void> saveKey(String providerId, String key) async {
    final saving = Map<String, bool>.from(state.saving);
    saving[providerId] = true;
    state = state.copyWith(saving: saving);

    try {
      await _datasource.setApiKey(providerId, key);
      final keys = Map<String, String?>.from(state.keys);
      keys[providerId] = key;
      state = state.copyWith(keys: keys);
    } finally {
      saving[providerId] = false;
      state = state.copyWith(saving: saving);
    }
  }
}
