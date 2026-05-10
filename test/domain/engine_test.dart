import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/source_mode.dart';
import 'package:token_watch/domain/engine/provider_registry.dart';

void main() {
  group('FetchStrategy', () {
    test('strategies should have unique ids', () {
      final ids = <String>{};

      const strategyIds = ['api', 'web', 'fallback'];
      for (final id in strategyIds) {
        expect(ids.contains(id), false, reason: 'Duplicate strategy id: $id');
        ids.add(id);
      }
    });
  });

  group('ProviderRegistry', () {
    tearDown(() {
      ProviderRegistry.clearForTest();
    });

    test('should register and retrieve provider descriptor', () {
      ProviderRegistry.register(
        ProviderId.openai,
        const ProviderDescriptor(
          id: ProviderId.openai,
          name: 'openai',
          displayName: 'OpenAI',
          icon: Icons.star,
          defaultSource: SourceMode.api,
          availableSources: [SourceMode.api],
          pricing: {},
        ),
        () => throw UnimplementedError(),
      );

      final registry = ProviderRegistry();
      final descriptor = registry.getDescriptor(ProviderId.openai);
      expect(descriptor, isNotNull);
      expect(descriptor!.displayName, 'OpenAI');
    });

    test('should return null for unregistered provider', () {
      final registry = ProviderRegistry();
      final descriptor = registry.getDescriptor(ProviderId.copilot);
      expect(descriptor, isNull);
    });

    test('should return all registered descriptors', () {
      ProviderRegistry.register(
        ProviderId.anthropic,
        const ProviderDescriptor(
          id: ProviderId.anthropic,
          name: 'anthropic',
          displayName: 'Anthropic',
          icon: Icons.psychology,
          defaultSource: SourceMode.api,
          availableSources: [SourceMode.api],
          pricing: {},
        ),
        () => throw UnimplementedError(),
      );
      ProviderRegistry.register(
        ProviderId.google,
        const ProviderDescriptor(
          id: ProviderId.google,
          name: 'google',
          displayName: 'Google',
          icon: Icons.auto_awesome,
          defaultSource: SourceMode.api,
          availableSources: [SourceMode.api],
          pricing: {},
        ),
        () => throw UnimplementedError(),
      );

      final registry = ProviderRegistry();
      final descriptors = registry.allDescriptors;
      expect(descriptors.length, 2);
    });
  });
}
