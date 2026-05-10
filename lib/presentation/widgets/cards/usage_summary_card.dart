import 'package:flutter/material.dart';
import 'package:token_watch/domain/entities/usage_level.dart';

class UsageSummaryCard extends StatelessWidget {
  final int totalSessionUsed;
  final int totalSessionLimit;
  final int totalWeeklyUsed;
  final int totalWeeklyLimit;
  final double totalEstimatedCost;

  const UsageSummaryCard({
    super.key,
    required this.totalSessionUsed,
    required this.totalSessionLimit,
    required this.totalWeeklyUsed,
    required this.totalWeeklyLimit,
    required this.totalEstimatedCost,
  });

  @override
  Widget build(BuildContext context) {
    final sessionPercent =
        totalSessionLimit > 0 ? totalSessionUsed / totalSessionLimit : 0.0;
    final level = UsageLevel.fromPercent(sessionPercent * 100);
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                  context, 'Session', totalSessionUsed, totalSessionLimit),
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: sessionPercent.clamp(0.0, 1.0),
                        strokeWidth: 6,
                        backgroundColor:
                            cs.outlineVariant.withValues(alpha: 0.3),
                        color: level.color,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(sessionPercent * 100).toInt()}%',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: level.color,
                                  ),
                        ),
                        Text('Used',
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatColumn(
                  context, 'Weekly', totalWeeklyUsed, totalWeeklyLimit),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payments_outlined, size: 18),
              const SizedBox(width: 4),
              Text('Estimated Cost: ',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '\$${totalEstimatedCost.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
      BuildContext context, String label, int used, int limit) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            _formatNumber(used),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '/ ${_formatNumber(limit)}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
