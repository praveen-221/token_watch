import 'dart:async';
import 'package:token_watch/domain/entities/fetch_context.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/engine/provider_registry.dart';
import 'package:token_watch/domain/entities/source_mode.dart';

// Abstract base interface for provider adapters
abstract class ProviderAdapter {
  ProviderId get id;
  ProviderDescriptor get descriptor;
  SourceMode get defaultSource;
  List<SourceMode> get availableSources;
  Future<ProviderSnapshot> fetch(FetchContext context);
  Map<String, double> get pricing;
  Future<double> estimateCost(ProviderSnapshot snapshot);
}
