import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/presentation/providers/api_keys_provider.dart';
import 'package:token_watch/presentation/providers/settings_provider.dart';
import 'package:token_watch/presentation/providers/usage_provider.dart';
import 'package:token_watch/presentation/widgets/common/provider_icon.dart';
import 'package:token_watch/presentation/widgets/common/token_glass_card.dart';

class ApiKeyManagementScreen extends ConsumerStatefulWidget {
  const ApiKeyManagementScreen({super.key});

  @override
  ConsumerState<ApiKeyManagementScreen> createState() => _ApiKeyManagementScreenState();
}

class _ApiKeyManagementScreenState extends ConsumerState<ApiKeyManagementScreen> {
  final Map<ProviderId, TextEditingController> _controllers = {};
  final Map<ProviderId, bool> _obscureText = {};

  @override
  void initState() {
    super.initState();
    for (final provider in ProviderId.values) {
      _controllers[provider] = TextEditingController();
      _obscureText[provider] = true;
    }
    // Load existing keys from secure storage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final provider in ProviderId.values) {
        ref.read(apiKeysNotifierProvider.notifier).loadKey(provider.id);
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKeysState = ref.watch(apiKeysNotifierProvider);

    // Populate text controllers with loaded keys (only once per provider)
    for (final provider in ProviderId.values) {
      final savedKey = apiKeysState.getApiKey(provider.id);
      final controller = _controllers[provider]!;
      if (savedKey != null && controller.text.isEmpty) {
        controller.text = savedKey;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Keys'),
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...ProviderId.values.map(_buildProviderKeyCard),
          const SizedBox(height: 24),
          _securityNotice(context),
        ],
      ),
    );
  }

  Widget _buildProviderKeyCard(ProviderId provider) {
    final controller = _controllers[provider]!;
    final obscured = _obscureText[provider] ?? true;
    final isSaving = ref.watch(apiKeysNotifierProvider.select((s) => s.isSaving(provider.id)));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TokenGlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProviderIcon(providerId: provider, radius: 10),
                const SizedBox(width: 8),
                Text(
                  provider.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: obscured,
              decoration: InputDecoration(
                hintText: 'Enter ${provider.displayName} API key',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: Icon(obscured ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureText[provider] = !obscured),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : FilledButton.icon(
                        onPressed: () {
                          final key = controller.text.trim();
                          if (key.isNotEmpty) {
                            ref.read(apiKeysNotifierProvider.notifier).saveKey(provider.id, key);
                            // Auto-enable the provider when API key is saved
                            ref.read(settingsNotifierProvider.notifier).toggleProvider(provider, true);
                            // Trigger a refresh to fetch usage data
                            ref.read(usageNotifierProvider.notifier).refreshAll();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${provider.displayName} API key saved and enabled')),
                            );
                          }
                        },
                        icon: const Icon(Icons.save, size: 16),
                        label: const Text('Save'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _securityNotice(BuildContext context) {
    return TokenGlassCard(
      child: Row(
        children: const [
          Icon(Icons.shield_outlined),
          SizedBox(width: 8),
          Expanded(child: Text('Your API keys are stored securely. This app uses device-level encryption.')),
        ],
      ),
    );
  }
}
