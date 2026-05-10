import '../entities/fetch_context.dart';
import '../entities/provider_snapshot.dart';
import '../entities/source_mode.dart';
import 'fetch_strategy.dart';

class FallbackStrategy extends FetchStrategy {
  @override
  String get id => 'fallback';

  @override
  SourceMode get mode => SourceMode.fallback;

  @override
  bool isAvailable(FetchContext context) => true;

  @override
  Future<ProviderSnapshot> fetch(FetchContext context) async {
    await Future.delayed(const Duration(milliseconds: 5));
    return ProviderSnapshot.empty(context.providerId);
  }
}
