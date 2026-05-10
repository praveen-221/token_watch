import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:token_watch/domain/entities/usage_level.dart';
import 'package:token_watch/presentation/providers/usage_provider.dart';

/// Compact status indicator shown in app bars — shows session/weekly usage bars.
class StatusIndicator extends ConsumerWidget {
  const StatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usageStateProvider);
    final refreshState = state.refreshState;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          _buildMiniBar(context, label: 'S', used: state.totalSessionUsed, limit: state.totalSessionLimit),
          const SizedBox(width: 6),
          _buildMiniBar(context, label: 'W', used: state.totalWeeklyUsed, limit: state.totalWeeklyLimit),
          const SizedBox(width: 4),
          if (refreshState == RefreshState.loading)
            SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary))
          else if (refreshState == RefreshState.error)
            Icon(Icons.error_outline, size: 12, color: cs.error),
        ],
      ),
    );
  }

  Widget _buildMiniBar(BuildContext context, {required String label, required int used, required int limit}) {
    final pct = limit > 0 ? used / limit : 0.0;
    final level = UsageLevel.fromPercent(pct * 100);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 32 * pct.clamp(0.0, 1.0),
              decoration: BoxDecoration(color: level.color, borderRadius: BorderRadius.circular(2)),
            ),
          ),
        ),
        const SizedBox(width: 3),
        Text('$label ${(pct * 100).toInt()}%', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9, color: level.color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
