import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/domain/entities/source_mode.dart';
import 'package:token_watch/domain/engine/provider_registry.dart';
import 'package:token_watch/domain/entities/fetch_context.dart';
import 'package:token_watch/providers/base_provider.dart';

class OpenAIProvider extends ProviderAdapter {
  static const String _baseUrl = 'https://api.openai.com';
  final http.Client _client;

  OpenAIProvider({http.Client? client}) : _client = client ?? http.Client();

  @override
  ProviderId get id => ProviderId.openai;

  @override
  ProviderDescriptor get descriptor => const ProviderDescriptor(
        id: ProviderId.openai,
        name: 'openai',
        displayName: 'OpenAI',
        icon: Icons.smart_toy_outlined,
        defaultSource: SourceMode.api,
        availableSources: [SourceMode.api],
        apiUrl: '$_baseUrl/v1/usage',
        pricing: {
          'gpt-4o_input': 0.0025,
          'gpt-4o_output': 0.01,
          'gpt-4_input': 0.03,
          'gpt-4_output': 0.06,
          'gpt-3.5-turbo_input': 0.0005,
          'gpt-3.5-turbo_output': 0.0015,
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
      throw const OpenAIFetchError(
          'API key not configured for OpenAI provider');
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Fetch session (today's) usage
    final sessionSnapshot = await _fetchUsage(
      apiKey,
      date: now,
      context: context.credentials,
    );

    // Fetch weekly usage
    final weeklySnapshot = await _fetchUsage(
      apiKey,
      date: now,
      context: context.credentials,
    );

    return ProviderSnapshot(
      providerId: ProviderId.openai,
      sessionUsed: sessionSnapshot.sessionUsed,
      sessionLimit: sessionSnapshot.sessionLimit,
      weeklyUsed: weeklySnapshot.weeklyUsed,
      weeklyLimit: weeklySnapshot.weeklyLimit,
      lastReset: startOfMonth,
      fetchedAt: DateTime.now(),
      sourceUsed: 'api',
      estimatedCost: _calculateCost(sessionSnapshot, weeklySnapshot),
    );
  }

  Future<ProviderSnapshot> _fetchUsage(
    String apiKey, {
    required DateTime date,
    required Map<String, String> context,
  }) async {
    final uri = Uri.parse('$_baseUrl/v1/usage');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const OpenAIFetchError(
          'Authentication failed. Check your API key.');
    }

    if (response.statusCode == 429) {
      throw const OpenAIFetchError('Rate limited. Please try again later.');
    }

    if (response.statusCode != 200) {
      throw OpenAIFetchError(
          'API returned ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // OpenAI usage API response format
    final totalTokens = data['total_tokens'] as int? ?? 0;

    // Default limits (can be configured)
    const defaultDailyLimit = 100000; // 100K tokens/day
    const defaultWeeklyLimit = 500000; // 500K tokens/week

    return ProviderSnapshot(
      providerId: ProviderId.openai,
      sessionUsed: totalTokens,
      sessionLimit: defaultDailyLimit,
      weeklyUsed: totalTokens * 7, // Approximation
      weeklyLimit: defaultWeeklyLimit,
      fetchedAt: DateTime.now(),
      sourceUsed: 'api',
    );
  }

  double _calculateCost(ProviderSnapshot session, ProviderSnapshot weekly) {
    final used = (session.sessionUsed ?? 0) + (weekly.weeklyUsed ?? 0);
    // Use average pricing as approximation
    final avgInputPrice = 0.0025 / 1000; // per token
    final avgOutputPrice = 0.01 / 1000;
    // Assume 50/50 input/output ratio
    return (used * 0.5 * avgInputPrice) + (used * 0.5 * avgOutputPrice);
  }

  @override
  Future<double> estimateCost(ProviderSnapshot snapshot) async {
    return _calculateCost(snapshot, snapshot);
  }
}

class OpenAIFetchError {
  final String message;
  const OpenAIFetchError(this.message);
  @override
  String toString() => 'OpenAIFetchError: $message';
}
