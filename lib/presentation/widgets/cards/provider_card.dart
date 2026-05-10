import 'package:flutter/material.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/domain/entities/usage_level.dart';
import 'package:token_watch/presentation/widgets/common/provider_icon.dart';

class ProviderCard extends StatelessWidget {
  final ProviderId providerId;
  final ProviderSnapshot snapshot;
  final bool isRefreshing;
  final VoidCallback onTap;

  const ProviderCard({
    super.key,
    required this.providerId,
    required this.snapshot,
    this.isRefreshing = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sessionLevel = snapshot.sessionLevel;
    final weeklyLevel = snapshot.weeklyLevel;
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProviderIcon(providerId: providerId, radius: 10),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    providerId.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isRefreshing)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: cs.primary),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _buildUsageBar(
                context, 'Session', snapshot.sessionPercent, sessionLevel),
            const SizedBox(height: 6),
            _buildUsageBar(
                context, 'Weekly', snapshot.weeklyPercent, weeklyLevel),
            if (snapshot.estimatedCost != null) ...[
              const SizedBox(height: 6),
              Text(
                'Est. \$${snapshot.estimatedCost!.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsageBar(
    BuildContext context,
    String label,
    double percent,
    UsageLevel level,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
            Text(
              '${(percent * 100).toInt()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: level.color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 5,
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(level.color),
              minHeight: 5,
            ),
          ),
        ),
      ],
    );
  }
}
