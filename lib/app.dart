import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:token_watch/core/theme/app_theme.dart';
import 'package:token_watch/presentation/router/app_router.dart';
import 'package:token_watch/presentation/providers/settings_provider.dart';

class TokenWatchApp extends ConsumerWidget {
  const TokenWatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch themeMode — avoids full MaterialApp rebuilds when other settings change.
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Token Watch',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
