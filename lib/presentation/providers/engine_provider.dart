import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:token_watch/domain/engine/provider_engine.dart';
import 'package:token_watch/domain/engine/provider_registry.dart';
import 'package:token_watch/domain/engine/fetch_orchestrator.dart';
import 'package:token_watch/data/datasources/local/hive_datasource.dart';

final hiveDatasourceProvider = Provider<HiveDatasource>((ref) {
  throw UnimplementedError('HiveDatasource must be overridden in main.dart');
});

final providerEngineProvider = Provider<ProviderEngine>((ref) {
  final registry = ProviderRegistry();
  final hiveDs = ref.watch(hiveDatasourceProvider);
  final engine = ProviderEngine(
    registry: registry,
    orchestrator: FetchOrchestrator(registry: registry),
    hiveDatasource: hiveDs,
  );
  // Load cached data from Hive on startup
  engine.loadFromCache();
  return engine;
});

// Alias for backwards compatibility
final providerEngineProviderAlias = Provider<ProviderEngine>((ref) {
  return ref.watch(providerEngineProvider);
});
