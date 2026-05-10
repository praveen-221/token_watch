import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/domain/engine/provider_engine.dart';
import 'package:token_watch/data/datasources/local/secure_storage_datasource.dart' show SecureStorageDatasource;
import 'package:token_watch/presentation/providers/engine_provider.dart';

enum RefreshState { idle, loading, error }

class ProviderUpdateEvent {
  final ProviderId providerId;
  final ProviderSnapshot? snapshot;
  final String? error;
  final DateTime timestamp;

  ProviderUpdateEvent({
    required this.providerId,
    this.snapshot,
    this.error,
    required this.timestamp,
  });
}

class UsageState {
  final Map<ProviderId, ProviderSnapshot> snapshots;
  final Map<ProviderId, String> errors;
  final Map<ProviderId, bool> isRefreshing;
  final RefreshState refreshState;
  final DateTime? lastFullRefresh;

  const UsageState({
    required this.snapshots,
    required this.errors,
    required this.isRefreshing,
    required this.refreshState,
    this.lastFullRefresh,
  });

  factory UsageState.initial() {
    return const UsageState(
      snapshots: <ProviderId, ProviderSnapshot>{},
      errors: <ProviderId, String>{},
      isRefreshing: <ProviderId, bool>{},
      refreshState: RefreshState.idle,
    );
  }

  UsageState copyWith({
    Map<ProviderId, ProviderSnapshot>? snapshots,
    Map<ProviderId, String>? errors,
    Map<ProviderId, bool>? isRefreshing,
    RefreshState? refreshState,
    DateTime? lastFullRefresh,
  }) {
    return UsageState(
      snapshots: snapshots ?? this.snapshots,
      errors: errors ?? this.errors,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshState: refreshState ?? this.refreshState,
      lastFullRefresh: lastFullRefresh ?? this.lastFullRefresh,
    );
  }

  int get totalSessionUsed =>
      snapshots.values.fold(0, (sum, s) => sum + (s.sessionUsed ?? 0));
  int get totalSessionLimit =>
      snapshots.values.fold(0, (sum, s) => sum + (s.sessionLimit ?? 0));
  int get totalWeeklyUsed =>
      snapshots.values.fold(0, (sum, s) => sum + (s.weeklyUsed ?? 0));
  int get totalWeeklyLimit =>
      snapshots.values.fold(0, (sum, s) => sum + (s.weeklyLimit ?? 0));
  double get totalEstimatedCost => snapshots.values.fold(
      0.0, (sum, s) => sum + (s.estimatedCost ?? 0.0));

  bool get hasData => snapshots.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

final usageNotifierProvider = StateNotifierProvider<UsageNotifier, UsageState>(
  (ref) {
    final engine = ref.watch(providerEngineProvider);
    return UsageNotifier(engine);
  },
  name: 'UsageNotifier',
);

final usageStateProvider = Provider<UsageState>((ref) {
  return ref.watch(usageNotifierProvider);
});

final providerUpdateStreamProvider =
    StreamProvider<ProviderUpdateEvent>((ref) {
  return ref.watch(usageNotifierProvider.notifier).eventStream;
});

final providerSnapshotsProvider =
    Provider<Map<ProviderId, ProviderSnapshot>>((ref) {
  return ref.watch(usageNotifierProvider).snapshots;
});

Provider<ProviderSnapshot?> singleProviderSnapshotProvider(
    ProviderId providerId) {
  return Provider<ProviderSnapshot?>((ref) {
    return ref.watch(usageNotifierProvider).snapshots[providerId];
  });
}

Provider<bool> isRefreshingProviderProvider(ProviderId providerId) {
  return Provider<bool>((ref) {
    return ref.watch(usageNotifierProvider).isRefreshing[providerId] ??
        false;
  });
}

final totalUsagePercentProvider = Provider<double>((ref) {
  final state = ref.watch(usageNotifierProvider);
  final cap = state.totalSessionLimit;
  if (cap == 0) return 0.0;
  return state.totalSessionUsed / cap;
});

final totalEstimatedCostProvider = Provider<double>((ref) {
  return ref.watch(usageNotifierProvider).totalEstimatedCost;
});

class UsageNotifier extends StateNotifier<UsageState> {
  final ProviderEngine _engine;
  final StreamController<ProviderUpdateEvent> _eventController =
      StreamController<ProviderUpdateEvent>.broadcast();
  final SecureStorageDatasource _storage;

  UsageNotifier(this._engine, [this._storage = const SecureStorageDatasource(
    storage: const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  )]) : super(UsageState.initial()) {
    _init();
  }

  Future<void> _init() async {
    // First load from Hive cache
    await _loadFromCache();
    
    // If no cached data, trigger a refresh to fetch fresh data
    if (state.snapshots.isEmpty) {
      refreshAll();
    }
  }

  Stream<ProviderUpdateEvent> get eventStream => _eventController.stream;

  /// Reads stored API keys from secure storage and maps them to ProviderId.
  Future<Map<ProviderId, String>> _readApiKeys() async {
    try {
      final allKeys = await _storage.getAllApiKeys();
      return allKeys.map((key, value) {
        final pid = ProviderId.values.firstWhere(
          (p) => p.id == key,
          orElse: () => ProviderId.openai,
        );
        return MapEntry(pid, value ?? '');
      });
    } catch (_) {
      return <ProviderId, String>{};
    }
  }

  Future<void> refreshProvider(ProviderId id) async {
    final apiKeys = await _readApiKeys();
    final nextRefreshing = Map<ProviderId, bool>.from(state.isRefreshing);
    nextRefreshing[id] = true;
    state = state.copyWith(
        isRefreshing: nextRefreshing, refreshState: RefreshState.loading);

    try {
      final result = await _engine.refreshProvider(id, apiKeys: apiKeys);
      final snapshot = result[id];
      if (snapshot != null) {
        final updated = Map<ProviderId, ProviderSnapshot>.from(state.snapshots);
        updated[id] = snapshot;
        state = state.copyWith(
          snapshots: updated,
          refreshState: RefreshState.idle,
          lastFullRefresh: DateTime.now(),
        );
        _eventController.add(ProviderUpdateEvent(
            providerId: id, snapshot: snapshot, timestamp: DateTime.now()));
        await _engine.persistSnapshot(id, snapshot);
      }
    } catch (err) {
      final nextErrors = Map<ProviderId, String>.from(state.errors);
      nextErrors[id] = err.toString();
      state = state.copyWith(
          errors: nextErrors, refreshState: RefreshState.error);
      _eventController.add(ProviderUpdateEvent(
          providerId: id, error: err.toString(), timestamp: DateTime.now()));
    } finally {
      final refreshed = Map<ProviderId, bool>.from(state.isRefreshing);
      refreshed[id] = false;
      state = state.copyWith(isRefreshing: refreshed);
    }
  }

  Future<void> refreshAll() async {
    final apiKeys = await _readApiKeys();
    final ids = _engine.getEnabledProviders();
    if (ids.isEmpty) return;

    state = state.copyWith(refreshState: RefreshState.loading);
    try {
      final result = await _engine.refreshAll(
        providerIds: ids,
        apiKeys: apiKeys,
      );
      final updated =
          Map<ProviderId, ProviderSnapshot>.from(state.snapshots)
            ..addAll(result);
      state = state.copyWith(
        snapshots: updated,
        refreshState: RefreshState.idle,
        lastFullRefresh: DateTime.now(),
      );
      for (final entry in result.entries) {
        _eventController.add(ProviderUpdateEvent(
            providerId: entry.key,
            snapshot: entry.value,
            timestamp: DateTime.now()));
      }
    } catch (err) {
      state = state.copyWith(refreshState: RefreshState.error);
    }
  }

  Future<void> clearCache() async {
    await _engine.clearCache();
    state = UsageState.initial();
  }

  Future<void> _loadFromCache() async {
    try {
      final cached = _engine.loadCachedSnapshots();
      if (cached.isNotEmpty) {
        state = state.copyWith(snapshots: cached);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}