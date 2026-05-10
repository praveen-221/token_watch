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

  IconData get icon => switch (this) {
        openai => Icons.smart_toy_outlined,
        anthropic => Icons.psychology_outlined,
        google => Icons.auto_awesome_outlined,
        copilot => Icons.code_outlined,
        openrouter => Icons.route_outlined,
        deepseek => Icons.search_outlined,
      };
}
