import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/domain/entities/usage_level.dart';
import 'package:token_watch/presentation/providers/usage_provider.dart';
import 'package:token_watch/presentation/providers/settings_provider.dart';
import 'package:token_watch/presentation/widgets/common/empty_state.dart';
import 'package:token_watch/presentation/widgets/common/loading_widget.dart';
import 'package:token_watch/presentation/widgets/common/provider_icon.dart';
import 'package:token_watch/presentation/widgets/common/token_glass_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usageStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Watch'),
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
      body: RefreshIndicator(
        onRefresh: () => ref.read(usageNotifierProvider.notifier).refreshAll(),
        child: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, UsageState state) {
    final settings = ref.watch(settingsNotifierProvider);

    // Filter by enabled providers
    final enabledSnapshots = state.snapshots.entries
        .where((e) => settings.enabledProviders[e.key] ?? true)
        .toList();

    // Empty state
    if (!state.hasData && state.refreshState == RefreshState.idle) {
      return const TokenEmptyState(
        title: 'No data yet',
        subtitle: 'Configure API keys in Settings to start tracking.',
      );
    }

    // Loading state
    if (state.refreshState == RefreshState.loading && !state.hasData) {
      return const TokenLoadingWidget(isFullPage: true);
    }

    // Provider list — one container per provider
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child:
              Text('Providers', style: Theme.of(context).textTheme.titleMedium),
        ),
        ...enabledSnapshots.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ProviderTile(
              providerId: entry.key,
              snapshot: entry.value,
              isRefreshing: state.isRefreshing[entry.key] ?? false,
              onTap: () => context.go('/provider/${entry.key.id}'),
            ),
          );
        }),
        if (state.hasErrors) ...[
          const SizedBox(height: 8),
          TokenGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Errors',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 8),
                ...state.errors.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• ${e.key.displayName}: ${e.value}'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Single provider tile showing session + weekly usage. Tappable → detail screen.
class _ProviderTile extends StatelessWidget {
  final ProviderId providerId;
  final ProviderSnapshot snapshot;
  final bool isRefreshing;
  final VoidCallback onTap;

  const _ProviderTile({
    required this.providerId,
    required this.snapshot,
    required this.isRefreshing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sessionLevel = snapshot.sessionLevel;
    final weeklyLevel = snapshot.weeklyLevel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: TokenGlassCard(
          padding: const EdgeInsets.all(14),
          borderRadius: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: icon + name + optional refresh indicator
              Row(
                children: [
                  ProviderIcon(providerId: providerId, radius: 11),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      providerId.displayName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isRefreshing)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: cs.primary),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Session usage
              _UsageBar(
                label: 'Session',
                used: snapshot.sessionUsed,
                limit: snapshot.sessionLimit,
                level: sessionLevel,
              ),
              const SizedBox(height: 8),
              // Weekly usage
              _UsageBar(
                label: 'Weekly',
                used: snapshot.weeklyUsed,
                limit: snapshot.weeklyLimit,
                level: weeklyLevel,
              ),
              if (snapshot.estimatedCost != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Est. cost: \$${snapshot.estimatedCost!.toStringAsFixed(4)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  final String label;
  final int? used;
  final int? limit;
  final UsageLevel level;
  const _UsageBar({
    required this.label,
    required this.used,
    required this.limit,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct =
        (used != null && limit != null && limit! > 0) ? used! / limit! : 0.0;
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
            Text(
              '${(pct * 100).toInt()}%',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: level.color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(level.color),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }
}
