import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/domain/entities/source_mode.dart';
import 'package:token_watch/domain/engine/provider_registry.dart';
import 'package:token_watch/domain/entities/fetch_context.dart';
import 'package:token_watch/providers/base_provider.dart';

class AnthropicProvider extends ProviderAdapter {
  static const String _baseUrl = 'https://api.anthropic.com';
  // ignore: unused_field
  final http.Client _client;

  AnthropicProvider({http.Client? client}) : _client = client ?? http.Client();

  @override
  ProviderId get id => ProviderId.anthropic;

  @override
  ProviderDescriptor get descriptor => const ProviderDescriptor(
        id: ProviderId.anthropic,
        name: 'anthropic',
        displayName: 'Anthropic',
        icon: Icons.psychology_outlined,
        defaultSource: SourceMode.api,
        availableSources: [SourceMode.api],
        apiUrl: '$_baseUrl/v1/messages',
        pricing: {
          'claude-3-5-sonnet_input': 0.003,
          'claude-3-5-sonnet_output': 0.015,
          'claude-3-opus_input': 0.015,
          'claude-3-opus_output': 0.075,
          'claude-3-haiku_input': 0.00025,
          'claude-3-haiku_output': 0.00125,
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
    final apiKey = context.credentials['api_key'];
    if (apiKey == null || apiKey.isEmpty) {
      throw const AnthropicFetchError('API key not configured for Anthropic provider');
    }

    // Anthropic does not expose a direct usage/tokens endpoint.
    // This provider returns an empty snapshot with a note that usage tracking
    // must be done via the Anthropic Console (console.anthropic.com).
    // Future implementation could integrate with Anthropic's billing API
    // if/when they expose usage data programmatically.
    return ProviderSnapshot(
      providerId: ProviderId.anthropic,
      fetchedAt: DateTime.now(),
      sourceUsed: 'api',
      estimatedCost: 0.0,
      sessionUsed: 0,
      sessionLimit: 200000, // Default: 200K tokens (Claude 3.5 Sonnet context)
      weeklyUsed: 0,
      weeklyLimit: 1000000, // Default: 1M tokens/week
    );
  }

  @override
  Future<double> estimateCost(ProviderSnapshot snapshot) async {
    // Use Claude 3.5 Sonnet pricing as default
    final used = (snapshot.sessionUsed ?? 0) + (snapshot.weeklyUsed ?? 0);
    const inputPrice = 0.003 / 1000;
    const outputPrice = 0.015 / 1000;
    return (used * 0.5 * inputPrice) + (used * 0.5 * outputPrice);
  }
}

class AnthropicFetchError {
  final String message;
  const AnthropicFetchError(this.message);
  @override
  String toString() => 'AnthropicFetchError: $message';
}
