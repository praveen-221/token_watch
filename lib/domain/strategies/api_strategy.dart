import 'dart:async';

import '../entities/fetch_context.dart';
import '../entities/provider_snapshot.dart';
import '../entities/source_mode.dart';
import 'fetch_strategy.dart';

class ApiStrategy extends FetchStrategy {
  @override
  String get id => 'api';

  @override
  SourceMode get mode => SourceMode.api;

  @override
  bool isAvailable(FetchContext context) {
    return context.credentials.containsKey('apiKey') ||
        context.credentials.containsKey('token');
  }

  @override
  Future<ProviderSnapshot> fetch(FetchContext context) async {
    // In domain layer we don't implement real HTTP; return an empty snapshot as a placeholder
    await Future.delayed(const Duration(milliseconds: 10));
    return ProviderSnapshot.empty(context.providerId);
  }

  @override
  bool shouldFallback(Object error, FetchContext context) {
    // If auth error, do not fallback to other strategies
    final msg = error.toString().toLowerCase();
    if (msg.contains('auth') ||
        msg.contains('unauthorized') ||
        msg.contains('forbidden')) {
      return false;
    }
    return true;
  }
}
