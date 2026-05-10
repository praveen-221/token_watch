import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/usage_level.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/presentation/providers/usage_provider.dart';
import 'package:token_watch/presentation/widgets/common/empty_state.dart';
import 'package:token_watch/presentation/widgets/common/token_glass_card.dart';

class ProviderDetailScreen extends ConsumerWidget {
  final String providerIdString;

  const ProviderDetailScreen({super.key, required this.providerIdString});

  ProviderId get _providerId {
    return ProviderId.values.firstWhere(
      (e) => e.id == providerIdString,
      orElse: () => ProviderId.openai,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(singleProviderSnapshotProvider(_providerId));
    final isRefreshing = ref.watch(isRefreshingProviderProvider(_providerId));

    return Scaffold(
      appBar: AppBar(
        title: Hero(tag: 'provider-card-${_providerId.id}', child: Text(_providerId.displayName)),
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
            ),
          ),
        ),
        actions: [
          if (isRefreshing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
      body: snapshot == null
          ? const TokenEmptyState(
              title: 'No data available',
              subtitle: 'No usage data found for this provider yet.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Large usage display
                _buildLargeUsageDisplay(context, snapshot),
                const SizedBox(height: 12),
                // Detail cards for session/weekly
                _buildDetailUsage(context, snapshot),
                const SizedBox(height: 12),
                if (snapshot.estimatedCost != null)
                  TokenGlassCard(
                    child: Row(
                      children: [
                        const Icon(Icons.payments_outlined),
                        const SizedBox(width: 12),
                        Text(
                          'Estimated Cost: \$${snapshot.estimatedCost!.toStringAsFixed(4)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                if (snapshot.sourceUsed != null)
                  TokenGlassCard(
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_outlined),
                        const SizedBox(width: 12),
                        Text('Source: ${snapshot.sourceUsed}'),
                      ],
                    ),
                  ),
                if (snapshot.fetchedAt != null)
                  Text(
                    'Last updated: ${_formatDateTime(snapshot.fetchedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
                  ),
                const SizedBox(height: 24),
                _buildApiKeySection(context, ref),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.read(usageNotifierProvider.notifier).refreshProvider(_providerId),
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }

  Widget _buildDetailUsage(BuildContext context, ProviderSnapshot snapshot) {
    // Simple per-category cards for Session and Weekly usage inside a glass container
    return Column(
      children: [
        _buildUsageTile(context, 'Session', snapshot.sessionUsed, snapshot.sessionLimit, snapshot.sessionLevel),
        const SizedBox(height: 8),
        _buildUsageTile(context, 'Weekly', snapshot.weeklyUsed, snapshot.weeklyLimit, snapshot.weeklyLevel),
      ],
    );
  }

  Widget _buildUsageTile(BuildContext context, String label, int? used, int? limit, UsageLevel level) {
    final percent = (used != null && limit != null && limit > 0) ? used / limit : 0.0;
    return TokenGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: level.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(level.name, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: level.color)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            color: level.color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(used != null ? '$used' : '—'),
              Text(limit != null ? '/ $limit' : ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeUsageDisplay(BuildContext context, ProviderSnapshot snapshot) {
    final percent = (snapshot.sessionLimit != null && snapshot.sessionLimit! > 0)
        ? (snapshot.sessionUsed ?? 0) / snapshot.sessionLimit!
        : 0.0;
    final level = snapshot.sessionLevel;
    return TokenGlassCard(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                strokeWidth: 14,
                color: level.color,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(percent * 100).toInt()}%',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: level.color,
                      ),
                ),
                Text('Session', style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeySection(BuildContext context, WidgetRef ref) {
    return TokenGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'API Key',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('••••••••••••••••'),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.tonal(
                onPressed: () {},
                child: const Text('Change Key'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: () {}, child: const Text('Remove')),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
