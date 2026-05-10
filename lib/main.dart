import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'providers/providers.dart';
import 'package:token_watch/data/datasources/local/hive_datasource.dart';
import 'package:token_watch/presentation/providers/engine_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive before opening boxes
  await Hive.initFlutter();

  // Open Hive boxes for caching
  final providerBox = await Hive.openBox('provider_cache');
  final usageBox = await Hive.openBox('usage_history');
  final settingsBox = await Hive.openBox('settings');

  final hiveDatasource = HiveDatasource(
    providerBox: providerBox,
    usageBox: usageBox,
    settingsBox: settingsBox,
  );

  // Create a container to override the provider before running the app
  final container = ProviderContainer(
    overrides: [
      hiveDatasourceProvider.overrideWithValue(hiveDatasource),
    ],
  );

  registerAllProviders();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TokenWatchApp(),
    ),
  );
}
