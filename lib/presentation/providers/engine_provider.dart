import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:token_watch/domain/engine/provider_engine.dart';
import 'package:token_watch/domain/engine/provider_registry.dart';
import 'package:token_watch/domain/engine/fetch_orchestrator.dart';

final providerEngineProvider = Provider<ProviderEngine>((ref) {
  final registry = ProviderRegistry();
  return ProviderEngine(
    registry: registry,
    orchestrator: FetchOrchestrator(registry: registry),
  );
});

// Alias for backwards compatibility
final providerEngineProviderAlias = Provider<ProviderEngine>((ref) {
  return ref.watch(providerEngineProvider);
});
