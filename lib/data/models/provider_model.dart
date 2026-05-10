import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';

class ProviderModel {
  String id;
  String name;
  bool isEnabled;
  int? sessionUsed;
  int? sessionLimit;
  int? weeklyUsed;
  int? weeklyLimit;
  int? monthlyUsed;
  int? monthlyLimit;
  DateTime? lastSync;
  String? sourceUsed;
  double? estimatedCost;

  ProviderModel({
    required this.id,
    required this.name,
    required this.isEnabled,
    this.sessionUsed,
    this.sessionLimit,
    this.weeklyUsed,
    this.weeklyLimit,
    this.monthlyUsed,
    this.monthlyLimit,
    this.lastSync,
    this.sourceUsed,
    this.estimatedCost,
  });

  ProviderSnapshot toEntity() {
    final providerId = ProviderId.values.firstWhere(
      (e) => e.id == id,
      orElse: () => ProviderId.openai,
    );
    return ProviderSnapshot(
      providerId: providerId,
      sessionUsed: sessionUsed,
      sessionLimit: sessionLimit,
      weeklyUsed: weeklyUsed,
      weeklyLimit: weeklyLimit,
      monthlyUsed: monthlyUsed,
      monthlyLimit: monthlyLimit,
      lastReset: lastSync,
      fetchedAt: lastSync,
      sourceUsed: sourceUsed,
      estimatedCost: estimatedCost,
    );
  }

  factory ProviderModel.fromEntity(ProviderSnapshot snapshot) {
    return ProviderModel(
      id: snapshot.providerId.id,
      name: snapshot.providerId.displayName,
      isEnabled: true,
      sessionUsed: snapshot.sessionUsed,
      sessionLimit: snapshot.sessionLimit,
      weeklyUsed: snapshot.weeklyUsed,
      weeklyLimit: snapshot.weeklyLimit,
      monthlyUsed: snapshot.monthlyUsed,
      monthlyLimit: snapshot.monthlyLimit,
      lastSync: snapshot.fetchedAt,
      sourceUsed: snapshot.sourceUsed,
      estimatedCost: snapshot.estimatedCost,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isEnabled': isEnabled,
      'sessionUsed': sessionUsed,
      'sessionLimit': sessionLimit,
      'weeklyUsed': weeklyUsed,
      'weeklyLimit': weeklyLimit,
      'monthlyUsed': monthlyUsed,
      'monthlyLimit': monthlyLimit,
      'lastSync': lastSync?.toIso8601String(),
      'sourceUsed': sourceUsed,
      'estimatedCost': estimatedCost,
    };
  }

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      isEnabled: json['isEnabled'] as bool,
      sessionUsed: json['sessionUsed'] as int?,
      sessionLimit: json['sessionLimit'] as int?,
      weeklyUsed: json['weeklyUsed'] as int?,
      weeklyLimit: json['weeklyLimit'] as int?,
      monthlyUsed: json['monthlyUsed'] as int?,
      monthlyLimit: json['monthlyLimit'] as int?,
      lastSync: json['lastSync'] != null
          ? DateTime.parse(json['lastSync'] as String)
          : null,
      sourceUsed: json['sourceUsed'] as String?,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
    );
  }
}
