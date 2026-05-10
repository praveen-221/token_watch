import 'provider_id.dart';
import 'source_mode.dart';

// Context for a fetch operation per provider
class FetchContext {
  final ProviderId providerId;
  final SourceMode sourceMode;
  final Map<String, String> credentials;
  final String? sessionId;

  const FetchContext({
    required this.providerId,
    required this.sourceMode,
    required this.credentials,
    this.sessionId,
  });

  FetchContext copyWith(
      {ProviderId? providerId,
      SourceMode? sourceMode,
      Map<String, String>? credentials,
      String? sessionId}) {
    return FetchContext(
      providerId: providerId ?? this.providerId,
      sourceMode: sourceMode ?? this.sourceMode,
      credentials: credentials ?? this.credentials,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}
