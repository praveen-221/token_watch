import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/domain/entities/source_mode.dart';
import 'package:token_watch/domain/engine/provider_registry.dart';
import 'package:token_watch/domain/entities/fetch_context.dart';
import 'package:token_watch/providers/base_provider.dart';

class CopilotProvider extends ProviderAdapter {
  static const String _baseUrl = 'https://api.github.com';
  // ignore: unused_field
  final http.Client _client;

  CopilotProvider({http.Client? client}) : _client = client ?? http.Client();

  @override
  ProviderId get id => ProviderId.copilot;

  @override
  ProviderDescriptor get descriptor => const ProviderDescriptor(
        id: ProviderId.copilot,
        name: 'copilot',
        displayName: 'Copilot',
        icon: Icons.code_outlined,
        defaultSource: SourceMode.api,
        availableSources: [SourceMode.api],
        apiUrl: '$_baseUrl/copilot_internal',
        pricing: {
          'copilot_chat': 0.0, // Free tier for individual users
          'copilot_business': 0.019, // Per user/month for business
        },
      );

  @override
  SourceMode get defaultSource => SourceMode.api;

  @override
  List<SourceMode> get availableSources => [SourceMode.api];

  @override
  Map<String, double> get pricing => descriptor.pricing;

  @override
  Future<ProviderSnapshot> fetch(FetchContext context) async {
    final token = context.credentials['github_token'];
    if (token == null || token.isEmpty) {
      throw const CopilotFetchError(
          'GitHub token not configured for Copilot provider');
    }

    // GitHub Copilot usage is tracked differently than other providers.
    // The API endpoints available are:
    // - /copilot_internal/user (seat info)
    // - /copilot/usage (enterprise only, requires org admin)
    // For individual users, usage is not directly exposed via API.
    // This provider returns a basic snapshot with default limits.
    final snapshot = ProviderSnapshot(
      providerId: ProviderId.copilot,
      fetchedAt: DateTime.now(),
      sourceUsed: 'api',
      estimatedCost: 0.0,
      sessionUsed: 0,
      sessionLimit: 0, // No hard limit for Copilot (unlimited for paid tier)
      weeklyUsed: 0,
      weeklyLimit: 0,
    );
    final cost = await estimateCost(snapshot);
    return ProviderSnapshot(
      providerId: snapshot.providerId,
      fetchedAt: snapshot.fetchedAt,
      sourceUsed: snapshot.sourceUsed,
      estimatedCost: cost,
      sessionUsed: snapshot.sessionUsed,
      sessionLimit: snapshot.sessionLimit,
      weeklyUsed: snapshot.weeklyUsed,
      weeklyLimit: snapshot.weeklyLimit,
    );
  }

  @override
  Future<double> estimateCost(ProviderSnapshot snapshot) async {
    // Copilot is a subscription service, not per-token pricing
    return 0.0;
  }
}

class CopilotFetchError {
  final String message;
  const CopilotFetchError(this.message);
  @override
  String toString() => 'CopilotFetchError: $message';
}
