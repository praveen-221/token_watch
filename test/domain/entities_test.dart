import 'package:flutter_test/flutter_test.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/provider_snapshot.dart';
import 'package:token_watch/domain/entities/usage_level.dart';
import 'package:token_watch/domain/entities/settings_config.dart';

void main() {
  group('ProviderId', () {
    test('should have correct display names', () {
      expect(ProviderId.openai.displayName, 'OpenAI');
      expect(ProviderId.anthropic.displayName, 'Anthropic');
      expect(ProviderId.google.displayName, 'Google');
      expect(ProviderId.copilot.displayName, 'Copilot');
    });

    test('should have correct id values', () {
      expect(ProviderId.openai.id, 'openai');
      expect(ProviderId.anthropic.id, 'anthropic');
    });
  });

  group('ProviderSnapshot', () {
    test('should calculate session percent correctly', () {
      const snapshot = ProviderSnapshot(
        providerId: ProviderId.openai,
        sessionUsed: 500,
        sessionLimit: 1000,
      );
      expect(snapshot.sessionPercent, 0.5);
    });

    test('should return 0 percent when limit is 0', () {
      const snapshot = ProviderSnapshot(
        providerId: ProviderId.openai,
        sessionUsed: 500,
        sessionLimit: 0,
      );
      expect(snapshot.sessionPercent, 0.0);
    });

    test('should clamp percent to 1.0 maximum', () {
      const snapshot = ProviderSnapshot(
        providerId: ProviderId.openai,
        sessionUsed: 1500,
        sessionLimit: 1000,
      );
      expect(snapshot.sessionPercent, 1.0);
    });

    test('should create empty snapshot with correct provider id', () {
      final snapshot = ProviderSnapshot.empty(ProviderId.anthropic);
      expect(snapshot.providerId, ProviderId.anthropic);
      expect(snapshot.hasData, false);
    });

    test('should serialize and deserialize correctly', () {
      final original = ProviderSnapshot(
        providerId: ProviderId.openai,
        sessionUsed: 1000,
        sessionLimit: 5000,
        estimatedCost: 0.25,
        sourceUsed: 'api',
        fetchedAt: DateTime.parse('2024-01-01T00:00:00'),
      );

      final json = original.toJson();
      final restored = ProviderSnapshot.fromJson(json);

      expect(restored.providerId, original.providerId);
      expect(restored.sessionUsed, original.sessionUsed);
      expect(restored.estimatedCost, original.estimatedCost);
      expect(restored.sourceUsed, original.sourceUsed);
    });
  });

  group('UsageLevel', () {
    test('should classify healthy usage', () {
      expect(UsageLevel.fromPercent(0), UsageLevel.healthy);
      expect(UsageLevel.fromPercent(50), UsageLevel.healthy);
      expect(UsageLevel.fromPercent(59.9), UsageLevel.healthy);
    });

    test('should classify approaching usage', () {
      expect(UsageLevel.fromPercent(60), UsageLevel.approaching);
      expect(UsageLevel.fromPercent(80), UsageLevel.approaching);
    });

    test('should classify near limit usage', () {
      expect(UsageLevel.fromPercent(85), UsageLevel.nearLimit);
      expect(UsageLevel.fromPercent(99), UsageLevel.nearLimit);
    });

    test('should classify exceeded usage', () {
      expect(UsageLevel.fromPercent(100), UsageLevel.exceeded);
      expect(UsageLevel.fromPercent(150), UsageLevel.exceeded);
    });
  });

  group('SettingsConfig', () {
    test('should create default config', () {
      final config = SettingsConfig.defaultConfig();
      expect(config.refreshInterval, const Duration(minutes: 5));
      expect(config.notificationsEnabled, false);
      expect(config.alertThreshold, 0.85);
      expect(config.enabledProviders.isNotEmpty, true);
    });

    test('should copy with new values', () {
      final original = SettingsConfig.defaultConfig();
      final updated = original.copyWith(
        notificationsEnabled: true,
        alertThreshold: 0.9,
      );
      expect(updated.notificationsEnabled, true);
      expect(updated.alertThreshold, 0.9);
      expect(updated.refreshInterval, original.refreshInterval);
    });
  });
}
