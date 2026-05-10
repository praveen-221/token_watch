import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';

class UsageModel {
  String providerId;
  int sessionUsed;
  int sessionLimit;
  int weeklyUsed;
  int weeklyLimit;
  double estimatedCost;
  DateTime timestamp;
  String sourceUsed;

  UsageModel({
    required this.providerId,
    required this.sessionUsed,
    required this.sessionLimit,
    required this.weeklyUsed,
    required this.weeklyLimit,
    required this.estimatedCost,
    required this.timestamp,
    required this.sourceUsed,
  });

  ProviderSnapshot toEntity() {
    final id = ProviderId.values.firstWhere(
      (e) => e.id == providerId,
      orElse: () => ProviderId.openai,
    );
    return ProviderSnapshot(
      providerId: id,
      sessionUsed: sessionUsed,
      sessionLimit: sessionLimit,
      weeklyUsed: weeklyUsed,
      weeklyLimit: weeklyLimit,
      fetchedAt: timestamp,
      sourceUsed: sourceUsed,
      estimatedCost: estimatedCost,
    );
  }

  factory UsageModel.fromEntity(ProviderSnapshot snapshot) {
    return UsageModel(
      providerId: snapshot.providerId.id,
      sessionUsed: snapshot.sessionUsed ?? 0,
      sessionLimit: snapshot.sessionLimit ?? 0,
      weeklyUsed: snapshot.weeklyUsed ?? 0,
      weeklyLimit: snapshot.weeklyLimit ?? 0,
      estimatedCost: snapshot.estimatedCost ?? 0.0,
      timestamp: snapshot.fetchedAt ?? DateTime.now(),
      sourceUsed: snapshot.sourceUsed ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'sessionUsed': sessionUsed,
      'sessionLimit': sessionLimit,
      'weeklyUsed': weeklyUsed,
      'weeklyLimit': weeklyLimit,
      'estimatedCost': estimatedCost,
      'timestamp': timestamp.toIso8601String(),
      'sourceUsed': sourceUsed,
    };
  }

  factory UsageModel.fromJson(Map<String, dynamic> json) {
    return UsageModel(
      providerId: json['providerId'] as String,
      sessionUsed: json['sessionUsed'] as int,
      sessionLimit: json['sessionLimit'] as int,
      weeklyUsed: json['weeklyUsed'] as int,
      weeklyLimit: json['weeklyLimit'] as int,
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      sourceUsed: json['sourceUsed'] as String,
    );
  }
}
