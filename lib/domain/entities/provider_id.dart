// Domain enum for supported provider identifiers with metadata
import 'package:flutter/material.dart';

enum ProviderId {
  openai("openai", "OpenAI"),
  anthropic("anthropic", "Anthropic"),
  google("google", "Google"),
  copilot("copilot", "Copilot"),
  openrouter("openrouter", "OpenRouter"),
  deepseek("deepseek", "DeepSeek");

  final String id;
  final String displayName;
  const ProviderId(this.id, this.displayName);

  @override
  String toString() => id;

  /// Well-known brand colors for each AI provider.
  Color get brandColor => switch (this) {
        openai => const Color(0xFF10A37F), // OpenAI green
        anthropic => const Color(0xFFD4A574), // Anthropic / Claude warm beige
        google => const Color(0xFF4285F4), // Google blue
        copilot => const Color(0xFF6E46B4), // GitHub Copilot purple
        openrouter => const Color(0xFFFF6B35), // OpenRouter orange
        deepseek => const Color(0xFF4F46E5), // DeepSeek indigo
      };

  /// First 1-2 letters to show in avatar when no logo is available.
  String get initial => switch (this) {
        openai => 'O',
        anthropic => 'A',
        google => 'G',
        copilot => 'C',
        openrouter => 'OR',
        deepseek => 'DS',
      };

  IconData get icon => switch (this) {
        openai => Icons.smart_toy_outlined,
        anthropic => Icons.psychology_outlined,
        google => Icons.auto_awesome_outlined,
        copilot => Icons.code_outlined,
        openrouter => Icons.route_outlined,
        deepseek => Icons.search_outlined,
      };
}
