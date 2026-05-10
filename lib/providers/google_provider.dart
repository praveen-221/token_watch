import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/domain/entities/source_mode.dart';
import 'package:token_watch/domain/engine/provider_registry.dart';
import 'package:token_watch/domain/entities/fetch_context.dart';
import 'package:token_watch/providers/base_provider.dart';

class GoogleProvider extends ProviderAdapter {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com';
  // ignore: unused_field
  final http.Client _client;

  GoogleProvider({http.Client? client}) : _client = client ?? http.Client();

  @override
  ProviderId get id => ProviderId.google;

  @override
  ProviderDescriptor get descriptor => const ProviderDescriptor(
        id: ProviderId.google,
        name: 'google',
        displayName: 'Google',
        icon: Icons.auto_awesome_outlined,
        defaultSource: SourceMode.api,
        availableSources: [SourceMode.api],
        apiUrl: '$_baseUrl/v1beta',
        pricing: {
          'gemini-1.5-pro_input': 0.00035,
          'gemini-1.5-pro_output': 0.00105,
          'gemini-1.5-flash_input': 0.000075,
          'gemini-1.5-flash_output': 0.0003,
          'gemini-2.0-flash_input': 0.0,
          'gemini-2.0-flash_output': 0.0,
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
      throw const GoogleFetchError('API key not configured for Google provider');
    }

    // Google AI Studio / Gemini API does not expose a direct usage/tokens endpoint.
    // Usage tracking is done through Google Cloud Console billing.
    // This provider returns an empty snapshot with default limits.
    // Future implementation could integrate with Cloud Billing API.
    return ProviderSnapshot(
      providerId: ProviderId.google,
      fetchedAt: DateTime.now(),
      sourceUsed: 'api',
      estimatedCost: 0.0,
      sessionUsed: 0,
      sessionLimit: 2000000, // Default: 2M tokens (Gemini 1.5 Pro context window)
      weeklyUsed: 0,
      weeklyLimit: 10000000, // Default: 10M tokens/week
    );
  }

  @override
  Future<double> estimateCost(ProviderSnapshot snapshot) async {
    // Use Gemini 1.5 Pro pricing as default
    final used = (snapshot.sessionUsed ?? 0) + (snapshot.weeklyUsed ?? 0);
    const inputPrice = 0.00035 / 1000;
    const outputPrice = 0.00105 / 1000;
    return (used * 0.5 * inputPrice) + (used * 0.5 * outputPrice);
  }
}

class GoogleFetchError {
  final String message;
  const GoogleFetchError(this.message);
  @override
  String toString() => 'GoogleFetchError: $message';
}
