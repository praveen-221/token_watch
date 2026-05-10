// ignore: unnecessary_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/entities/source_mode.dart';
import 'package:token_watch/providers/base_provider.dart';
// NOTE: This file defines the domain-level provider registry and descriptor types.

class ProviderDescriptor {
  final ProviderId id;
  final String name;
  final String displayName;
  final IconData icon;
  final SourceMode defaultSource;
  final List<SourceMode> availableSources;
  final String? apiUrl;
  final Map<String, double> pricing; // per 1K tokens: {"input": x, "output": y}

  const ProviderDescriptor({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.defaultSource,
    required this.availableSources,
    this.apiUrl,
    required this.pricing,
  });
}

class ProviderRegistry {
  ProviderRegistry();

  static final Map<ProviderId, ProviderDescriptor> _descriptors = {};
  static final Map<ProviderId, ProviderAdapter Function()> _factories = {};

  static void register(ProviderId id, ProviderDescriptor descriptor, ProviderAdapter Function() factory) {
    _descriptors[id] = descriptor;
    _factories[id] = factory;
  }

  ProviderAdapter? create(ProviderId id) {
    final factory = _factories[id];
    return factory?.call();
  }

  List<ProviderDescriptor> get allDescriptors => _descriptors.values.toList();
  ProviderDescriptor? getDescriptor(ProviderId id) => _descriptors[id];

  // Test-only method to clear registry between tests
  @visibleForTesting
  static void clearForTest() {
    _descriptors.clear();
    _factories.clear();
  }
}
