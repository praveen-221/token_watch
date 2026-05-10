// Immutable domain entity representing a provider snapshot state
import 'package:flutter/material.dart';
import 'provider_id.dart';
import 'dart:core';

import 'usage_level.dart';

@immutable
class ProviderSnapshot {
  final ProviderId providerId;
  final int? sessionUsed;
  final int? sessionLimit;
  final int? weeklyUsed;
  final int? weeklyLimit;
  final int? monthlyUsed;
  final int? monthlyLimit;
  final DateTime? lastReset;
  final DateTime? fetchedAt;
  final String? sourceUsed;
  final double? estimatedCost;

  const ProviderSnapshot({
    required this.providerId,
    this.sessionUsed,
    this.sessionLimit,
    this.weeklyUsed,
    this.weeklyLimit,
    this.monthlyUsed,
    this.monthlyLimit,
    this.lastReset,
    this.fetchedAt,
    this.sourceUsed,
    this.estimatedCost,
  });

  static const ProviderSnapshot emptyProvider =
      ProviderSnapshot(providerId: ProviderId.openai);

  // Percentages as 0.0 - 1.0
  double get sessionPercent {
    if (sessionUsed == null || sessionLimit == null || sessionLimit == 0)
      return 0.0;
    final ratio = sessionUsed! / sessionLimit!;
    return ratio.clamp(0.0, 1.0);
  }

  double get weeklyPercent {
    if (weeklyUsed == null || weeklyLimit == null || weeklyLimit == 0)
      return 0.0;
    final ratio = weeklyUsed! / weeklyLimit!;
    return ratio.clamp(0.0, 1.0);
  }

  double get monthlyPercent {
    if (monthlyUsed == null || monthlyLimit == null || monthlyLimit == 0)
      return 0.0;
    final ratio = monthlyUsed! / monthlyLimit!;
    return ratio.clamp(0.0, 1.0);
  }

  UsageLevel get sessionLevel => UsageLevel.fromPercent(sessionPercent * 100);
  UsageLevel get weeklyLevel => UsageLevel.fromPercent(weeklyPercent * 100);
  UsageLevel get monthlyLevel => UsageLevel.fromPercent(monthlyPercent * 100);

  bool get hasData =>
      sessionUsed != null ||
      sessionLimit != null ||
      weeklyUsed != null ||
      weeklyLimit != null ||
      lastReset != null ||
      fetchedAt != null ||
      sourceUsed != null ||
      estimatedCost != null;

  ProviderSnapshot copyWith({
    ProviderId? providerId,
    int? sessionUsed,
    int? sessionLimit,
    int? weeklyUsed,
    int? weeklyLimit,
    int? monthlyUsed,
    int? monthlyLimit,
    DateTime? lastReset,
    DateTime? fetchedAt,
    String? sourceUsed,
    double? estimatedCost,
  }) {
    return ProviderSnapshot(
      providerId: providerId ?? this.providerId,
      sessionUsed: sessionUsed ?? this.sessionUsed,
      sessionLimit: sessionLimit ?? this.sessionLimit,
      weeklyUsed: weeklyUsed ?? this.weeklyUsed,
      weeklyLimit: weeklyLimit ?? this.weeklyLimit,
      monthlyUsed: monthlyUsed ?? this.monthlyUsed,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      lastReset: lastReset ?? this.lastReset,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      sourceUsed: sourceUsed ?? this.sourceUsed,
      estimatedCost: estimatedCost ?? this.estimatedCost,
    );
  }

  factory ProviderSnapshot.empty(ProviderId id) {
    return ProviderSnapshot(providerId: id);
  }

  factory ProviderSnapshot.fromJson(Map<String, dynamic> json) {
    return ProviderSnapshot(
      providerId: ProviderId.values.firstWhere(
        (e) => e.id == json['providerId'],
        orElse: () => ProviderId.openai,
      ),
      sessionUsed: json['sessionUsed'] as int?,
      sessionLimit: json['sessionLimit'] as int?,
      weeklyUsed: json['weeklyUsed'] as int?,
      weeklyLimit: json['weeklyLimit'] as int?,
      monthlyUsed: json['monthlyUsed'] as int?,
      monthlyLimit: json['monthlyLimit'] as int?,
      lastReset: json['lastReset'] != null
          ? DateTime.parse(json['lastReset'] as String)
          : null,
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.parse(json['fetchedAt'] as String)
          : null,
      sourceUsed: json['sourceUsed'] as String?,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId.id,
      'sessionUsed': sessionUsed,
      'sessionLimit': sessionLimit,
      'weeklyUsed': weeklyUsed,
      'weeklyLimit': weeklyLimit,
      'monthlyUsed': monthlyUsed,
      'monthlyLimit': monthlyLimit,
      'lastReset': lastReset?.toIso8601String(),
      'fetchedAt': fetchedAt?.toIso8601String(),
      'sourceUsed': sourceUsed,
      'estimatedCost': estimatedCost,
    };
  }
}
