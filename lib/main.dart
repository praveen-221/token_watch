import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with proper boxes
  await Hive.initFlutter();
  await Hive.openBox('provider_cache');
  await Hive.openBox('usage_history');
  await Hive.openBox('settings');

  registerAllProviders();
  runApp(const ProviderScope(child: TokenWatchApp()));
}
