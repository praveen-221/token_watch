import '../entities/fetch_context.dart';
import '../entities/provider_snapshot.dart';
import '../entities/source_mode.dart';
import 'fetch_strategy.dart';

class WebStrategy extends FetchStrategy {
  @override
  String get id => 'web';

  @override
  SourceMode get mode => SourceMode.web;

  @override
  bool isAvailable(FetchContext context) {
    // Check for presence of a generic token/cookie indicator in credentials
    return context.credentials.containsKey('cookie') || context.credentials.containsKey('session');
  }

  @override
  Future<ProviderSnapshot> fetch(FetchContext context) async {
    await Future.delayed(const Duration(milliseconds: 20));
    return ProviderSnapshot.empty(context.providerId);
  }
}
