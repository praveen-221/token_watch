import 'package:flutter/material.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/source_mode.dart';
import 'package:token_watch/domain/engine/provider_registry.dart';

import 'openai_provider.dart';
import 'anthropic_provider.dart';
import 'google_provider.dart';
import 'copilot_provider.dart';

void registerAllProviders() {
  ProviderRegistry.register(
    ProviderId.openai,
    const ProviderDescriptor(
      id: ProviderId.openai,
      name: 'openai',
      displayName: 'OpenAI',
      icon: Icons.smart_toy_outlined,
      defaultSource: SourceMode.api,
      availableSources: [SourceMode.api],
      apiUrl: 'https://api.openai.com/v1/usage',
      pricing: {
        'gpt-4o_input': 0.0025,
        'gpt-4o_output': 0.01,
        'gpt-4_input': 0.03,
        'gpt-4_output': 0.06,
        'gpt-3.5-turbo_input': 0.0005,
        'gpt-3.5-turbo_output': 0.0015,
      },
    ),
    () => OpenAIProvider(),
  );

  ProviderRegistry.register(
    ProviderId.anthropic,
    const ProviderDescriptor(
      id: ProviderId.anthropic,
      name: 'anthropic',
      displayName: 'Anthropic',
      icon: Icons.psychology_outlined,
      defaultSource: SourceMode.api,
      availableSources: [SourceMode.api],
      apiUrl: 'https://api.anthropic.com/v1/messages',
      pricing: {
        'claude-3-5-sonnet_input': 0.003,
        'claude-3-5-sonnet_output': 0.015,
        'claude-3-opus_input': 0.015,
        'claude-3-opus_output': 0.075,
        'claude-3-haiku_input': 0.00025,
        'claude-3-haiku_output': 0.00125,
      },
    ),
    () => AnthropicProvider(),
  );

  ProviderRegistry.register(
    ProviderId.google,
    const ProviderDescriptor(
      id: ProviderId.google,
      name: 'google',
      displayName: 'Google',
      icon: Icons.auto_awesome_outlined,
      defaultSource: SourceMode.api,
      availableSources: [SourceMode.api],
      apiUrl: 'https://generativelanguage.googleapis.com/v1beta',
      pricing: {
        'gemini-1.5-pro_input': 0.00035,
        'gemini-1.5-pro_output': 0.00105,
        'gemini-1.5-flash_input': 0.000075,
        'gemini-1.5-flash_output': 0.0003,
      },
    ),
    () => GoogleProvider(),
  );

  ProviderRegistry.register(
    ProviderId.copilot,
    const ProviderDescriptor(
      id: ProviderId.copilot,
      name: 'copilot',
      displayName: 'Copilot',
      icon: Icons.code_outlined,
      defaultSource: SourceMode.api,
      availableSources: [SourceMode.api],
      apiUrl: 'https://api.github.com/copilot_internal',
      pricing: {
        'copilot_chat': 0.0,
        'copilot_business': 0.019,
      },
    ),
    () => CopilotProvider(),
  );
}
