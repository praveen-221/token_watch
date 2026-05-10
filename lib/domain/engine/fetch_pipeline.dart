import 'dart:async';

import '../entities/fetch_context.dart';
import '../entities/provider_snapshot.dart';
import '../strategies/fetch_strategy.dart';

class FetchAttempt {
  final String strategyId;
  final FetchAttemptStatus status;
  final Object? error;
  const FetchAttempt({required this.strategyId, required this.status, this.error});
}

enum FetchAttemptStatus { success, failed, unavailable }

class FetchResult {
  final bool isSuccess;
  final ProviderSnapshot? snapshot;
  final List<FetchAttempt> attempts;
  final Object? error;
  const FetchResult({required this.isSuccess, this.snapshot, required this.attempts, this.error});

  factory FetchResult.success(ProviderSnapshot snapshot, {List<FetchAttempt>? attempts}) {
    return FetchResult(isSuccess: true, snapshot: snapshot, attempts: attempts ?? const [FetchAttempt(strategyId: 'none', status: FetchAttemptStatus.success)], error: null);
  }

  factory FetchResult.failure({List<FetchAttempt>? attempts, Object? error}) {
    return FetchResult(isSuccess: false, snapshot: null, attempts: attempts ?? [], error: error);
  }
}

class FetchPipeline {
  final List<FetchStrategy> strategies;
  FetchPipeline({required this.strategies});

  Future<FetchResult> execute(FetchContext context) async {
    final List<FetchAttempt> history = [];
    for (final strategy in strategies) {
      if (!strategy.isAvailable(context)) {
        history.add(FetchAttempt(strategyId: strategy.id, status: FetchAttemptStatus.unavailable));
        continue;
      }
      try {
        final snapshot = await strategy.fetch(context);
        history.add(FetchAttempt(strategyId: strategy.id, status: FetchAttemptStatus.success));
        return FetchResult.success(snapshot, attempts: history);
      } catch (e) {
        history.add(FetchAttempt(strategyId: strategy.id, status: FetchAttemptStatus.failed, error: e));
        if (!strategy.shouldFallback(e, context)) {
          return FetchResult.failure(attempts: history, error: e);
        }
        // otherwise try next strategy
      }
    }
    return FetchResult.failure(attempts: history, error: 'All strategies failed');
  }
}
