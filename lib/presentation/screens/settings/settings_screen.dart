import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/settings_config.dart';
import 'package:token_watch/presentation/providers/settings_provider.dart';
import 'package:token_watch/presentation/providers/usage_provider.dart';
import 'package:token_watch/presentation/widgets/common/token_glass_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        flexibleSpace: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Providers',
            child: Column(
              children: ProviderId.values.map((id) {
                final enabled = settings.enabledProviders[id] ?? true;
                return SwitchListTile(
                  title: Text(id.displayName),
                  hoverColor: Colors.transparent,
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return Theme.of(context).colorScheme.onSurfaceVariant;
                  }),
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  value: enabled,
                  onChanged: (v) => ref
                      .read(settingsNotifierProvider.notifier)
                      .toggleProvider(id, v),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          _SectionCard(
            title: 'Refresh',
            child: ListTile(
              title: const Text('Refresh Interval'),
              subtitle: Text('${settings.refreshInterval.inMinutes} minutes'),
              trailing: const Icon(Icons.chevron_right),
              hoverColor: Colors.transparent,
              onTap: () => _showRefreshIntervalDialog(context, ref, settings),
            ),
          ),
          const Divider(),
          _SectionCard(
            title: 'Notifications',
            child: SwitchListTile(
              title: const Text('Usage Alerts'),
              subtitle: const Text('Notify when approaching limits'),
              hoverColor: Colors.transparent,
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return Theme.of(context).colorScheme.onSurfaceVariant;
              }),
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              value: settings.notificationsEnabled,
              onChanged: (v) => ref
                  .read(settingsNotifierProvider.notifier)
                  .setNotifications(v),
            ),
          ),
          // Use Visibility to prevent layout crashes during state transitions.
          // AnimatedCrossFade with SizedBox.shrink() causes size: MISSING errors.
          Visibility(
            visible: settings.notificationsEnabled,
            child: _SectionCard(
              title: 'Alert Threshold',
              child: ListTile(
                title: const Text('Alert Threshold'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(settings.alertThreshold * 100).toInt()}%'),
                    Slider(
                      value: settings.alertThreshold,
                      min: 0.5,
                      max: 1.0,
                      divisions: 10,
                      label: '${(settings.alertThreshold * 100).toInt()}%',
                      onChanged: (v) => ref
                          .read(settingsNotifierProvider.notifier)
                          .setAlertThreshold(v),
                    ),
                  ],
                ),
                hoverColor: Colors.transparent,
              ),
            ),
          ),
          const Divider(),
          _SectionCard(
            title: 'Appearance',
            child: ListTile(
              title: const Text('Theme'),
              subtitle: Text(settings.themeMode.name),
              trailing: const Icon(Icons.chevron_right),
              hoverColor: Colors.transparent,
              onTap: () => _showThemeDialog(context, ref, settings),
            ),
          ),
          const Divider(),
          _SectionCard(
            title: 'API Keys',
            child: ListTile(
              title: const Text('Manage API Keys'),
              subtitle: const Text('Securely store provider credentials'),
              trailing: const Icon(Icons.chevron_right),
              hoverColor: Colors.transparent,
              onTap: () => context.push('/settings/api-keys'),
            ),
          ),
          const Divider(),
          _SectionCard(
            title: 'Data',
            child: ListTile(
              title: const Text('Clear Cache'),
              subtitle: const Text('Remove all cached usage data'),
              trailing: const Icon(Icons.delete_outline),
              hoverColor: Colors.transparent,
              onTap: () => _showClearCacheDialog(context, ref),
            ),
          ),
          const Divider(),
          const _SectionCard(
            title: 'About',
            child: ListTile(
              title: Text('Token Watch'),
              subtitle: Text('v0.1.0'),
              trailing: Icon(Icons.info_outline),
              hoverColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section card wrapper for settings
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TokenGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

void _showRefreshIntervalDialog(
    BuildContext context, WidgetRef ref, SettingsConfig settings) {
  showDialog(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Refresh Interval'),
      children: [1, 5, 15, 30].map((m) {
        return SimpleDialogOption(
          onPressed: () {
            ref
                .read(settingsNotifierProvider.notifier)
                .setRefreshInterval(Duration(minutes: m));
            Navigator.pop(ctx);
          },
          child: Text('$m minute${m > 1 ? 's' : ''}'),
        );
      }).toList(),
    ),
  );
}

void _showThemeDialog(
    BuildContext context, WidgetRef ref, SettingsConfig settings) {
  showDialog(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Theme'),
      children: [
        SimpleDialogOption(
          onPressed: () {
            ref
                .read(settingsNotifierProvider.notifier)
                .setThemeMode(ThemeMode.system);
            Navigator.pop(ctx);
          },
          child: const Text('System'),
        ),
        SimpleDialogOption(
          onPressed: () {
            ref
                .read(settingsNotifierProvider.notifier)
                .setThemeMode(ThemeMode.light);
            Navigator.pop(ctx);
          },
          child: const Text('Light'),
        ),
        SimpleDialogOption(
          onPressed: () {
            ref
                .read(settingsNotifierProvider.notifier)
                .setThemeMode(ThemeMode.dark);
            Navigator.pop(ctx);
          },
          child: const Text('Dark'),
        ),
      ],
    ),
  );
}

void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Clear Cache'),
      content: const Text('This will remove all cached usage data. Continue?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            ref.read(usageNotifierProvider.notifier).clearCache();
            if (!ctx.mounted) return;
            Navigator.pop(ctx);
            final rootContext = Navigator.of(ctx).context;
            if (rootContext.mounted) {
              ScaffoldMessenger.of(rootContext).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            }
          },
          child: const Text('Clear'),
        ),
      ],
    ),
  );
}
