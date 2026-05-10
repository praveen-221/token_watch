// Domain enum for how data should be fetched for a provider
enum SourceMode {
  auto,
  api,
  web,
  cli,
  fallback;

  @override
  String toString() => name;
}
