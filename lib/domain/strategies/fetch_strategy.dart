import '../entities/fetch_context.dart';
import '../entities/provider_snapshot.dart';
import '../entities/source_mode.dart';

abstract class FetchStrategy {
  String get id;
  SourceMode get mode;
  bool isAvailable(FetchContext context);
  Future<ProviderSnapshot> fetch(FetchContext context);
  bool shouldFallback(Object error, FetchContext context) => true;
}
