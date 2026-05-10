# Token Watch

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

A cross-platform **AI Token Observability** mobile app built with Flutter. Track, visualize, and manage your AI token usage across multiple LLM providers — all from your phone.

> Inspired by [CodexBar](https://github.com/steipete/CodexBar) (macOS) and [Win-CodexBar](https://github.com/Finesssee/Win-CodexBar) (Windows), adapted for mobile with a focus on clean architecture and production-grade quality.

---

## Screenshots

| Dashboard | Analytics | Settings |
|-----------|-----------|----------|
| ![Dashboard](docs/screenshots/dashboard.png) | ![Analytics](docs/screenshots/analytics.png) | ![Settings](docs/screenshots/settings.png) |

---

## Features

- **Multi-Provider Support** — OpenAI, Anthropic, Google Gemini, GitHub Copilot (extensible to 16+ providers)
- **Real-Time Token Tracking** — Session and weekly usage meters per provider
- **Usage Dashboard** — At-a-glance overview with color-coded status indicators
- **Historical Analytics** — Bar charts, trend lines, and cost breakdowns via `fl_chart`
- **Secure API Key Storage** — Platform-native encryption (Keychain / Keystore)
- **Configurable Refresh** — Adjustable intervals (1, 5, 15, 30 min) with TTL caching
- **Usage Alerts** — Threshold-based notifications when approaching limits
- **Dark/Light Theme** — System-aware with manual override
- **Offline Cache** — Hive-based local storage for usage history

---

## Architecture

Token Watch follows **Clean Architecture** with three distinct layers:

```
┌─────────────────────────────────────────────────┐
│              PRESENTATION LAYER                  │
│  Screens, Widgets, Riverpod Providers, Router   │
├─────────────────────────────────────────────────┤
│                DOMAIN LAYER                      │
│  ProviderEngine, FetchPipeline, Entities         │
│  ProviderRegistry, Strategies, Services           │
├─────────────────────────────────────────────────┤
│                 DATA LAYER                       │
│  API Client, Hive Datasource, Secure Storage     │
│  Repository Implementations                      │
└─────────────────────────────────────────────────┘
```

### Design Patterns

| Pattern | Implementation |
|---------|---------------|
| **Clean Architecture** | Strict separation: Presentation → Domain → Data |
| **Strategy Pattern** | `FetchPipeline` with ordered strategy chain (API → Web → Fallback) |
| **Registry Pattern** | `ProviderRegistry` for auto-discovery and factory-based provider creation |
| **Observer Pattern** | Riverpod `StateNotifier` + `StreamController` for reactive state |
| **Repository Pattern** | Abstract interfaces in domain, implementations in data |
| **Facade Pattern** | `ProviderEngine` as unified entry point for all provider operations |

### Tech Stack

| Component | Technology |
|-----------|-----------|
| **State Management** | Riverpod (with code generation) |
| **Navigation** | GoRouter (declarative routing) |
| **Local Storage** | Hive (encrypted, fast NoSQL) |
| **Secure Storage** | `flutter_secure_storage` (Keychain/Keystore) |
| **Charts** | `fl_chart` (bar, line, pie) |
| **HTTP** | `http` package |
| **Linting** | `flutter_lints` with strict rules |

---

## Getting Started

### Prerequisites

- Flutter SDK **3.x** (stable channel)
- Dart SDK **3.x**
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/token_watch.git
cd token_watch

# Install dependencies
flutter pub get

# Run code generation (for Riverpod providers and Hive adapters)
dart run build_runner build --delete-conflicting-outputs

# Run on a connected device or emulator
flutter run
```

### Build Commands

```bash
# Android APK (release)
flutter build apk --release

# Android App Bundle (release, for Play Store)
flutter build appbundle --release

# iOS (release, requires macOS)
flutter build ios --release --no-codesign
```

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # Root widget with theme and routing
│
├── core/                              # Shared utilities
│   ├── theme/app_theme.dart           # Light/dark theme definitions
│   ├── constants/                     # Colors, typography, spacing
│   └── utils/                         # Date formatting, helpers
│
├── domain/                            # Domain Layer (business logic)
│   ├── entities/                      # Pure domain models
│   │   ├── provider_id.dart           # Provider enum with metadata
│   │   ├── provider_snapshot.dart     # Usage snapshot entity
│   │   ├── usage_level.dart           # Usage severity levels
│   │   ├── source_mode.dart           # Fetch strategy enum
│   │   ├── fetch_context.dart         # Fetch operation context
│   │   └── settings_config.dart       # App settings entity
│   ├── engine/                        # Core engine components
│   │   ├── provider_registry.dart     # Provider auto-registration
│   │   ├── fetch_pipeline.dart        # Strategy chain execution
│   │   ├── fetch_orchestrator.dart    # Parallel refresh orchestration
│   │   └── provider_engine.dart       # Facade for all provider ops
│   ├── strategies/                    # Fetch strategy implementations
│   │   ├── fetch_strategy.dart        # Abstract strategy interface
│   │   ├── api_strategy.dart          # API-based fetch
│   │   ├── web_strategy.dart          # Web scraping fetch
│   │   └── fallback_strategy.dart     # Manual/cached fallback
│   └── services/                      # Domain services
│       ├── analytics_service.dart     # Usage analytics computation
│       └── alert_service.dart         # Threshold alert checking
│
├── data/                              # Data Layer (external systems)
│   ├── datasources/
│   │   ├── remote/api_client.dart     # Generic HTTP client
│   │   └── local/                     # Local storage
│   │       ├── hive_datasource.dart   # Hive cache operations
│   │       └── secure_storage_datasource.dart  # Encrypted key storage
│   ├── models/                        # Serialization models
│   │   ├── provider_model.dart        # Hive provider model
│   │   ├── usage_model.dart           # Hive usage history model
│   │   └── settings_model.dart        # Hive settings model
│   ├── repositories/                  # Repository implementations
│   │   ├── provider_repository_impl.dart
│   │   └── settings_repository_impl.dart
│   └── errors.dart                    # Custom error types
│
├── presentation/                      # Presentation Layer (UI)
│   ├── providers/                     # Riverpod state providers
│   │   ├── usage_provider.dart        # Central usage state
│   │   ├── analytics_provider.dart    # Analytics state
│   │   ├── settings_provider.dart     # Settings state
│   │   └── engine_provider.dart       # Engine DI provider
│   ├── screens/                       # App screens
│   │   ├── dashboard/                 # Main overview screen
│   │   ├── analytics/                 # Charts and trends
│   │   ├── settings/                  # Configuration screen
│   │   └── provider_detail/           # Per-provider detail view
│   ├── widgets/                       # Reusable widgets
│   │   ├── common/                    # Status, loading, error, empty
│   │   ├── charts/                    # Bar chart, line chart
│   │   └── cards/                     # Provider card, summary card
│   └── router/                        # GoRouter configuration
│       └── app_router.dart
│
└── providers/                         # Provider Implementations
    ├── providers.dart                 # Registration entry point
    ├── base_provider.dart             # Abstract ProviderAdapter
    ├── openai_provider.dart           # OpenAI API adapter
    ├── anthropic_provider.dart        # Anthropic API adapter
    ├── google_provider.dart           # Google Gemini adapter
    └── copilot_provider.dart          # GitHub Copilot adapter
```

---

## Adding a New Provider

Token Watch's provider system is designed for easy extensibility. Follow these steps:

### 1. Create the Provider Class

```dart
// lib/providers/my_provider.dart
import 'package:token_watch/providers/base_provider.dart';
import 'package:token_watch/domain/entities/provider_id.dart';
import 'package:token_watch/domain/engine/provider_registry.dart';
// ... other imports

class MyProvider extends ProviderAdapter {
  @override
  ProviderId get id => ProviderId.myProvider; // Add to enum first

  @override
  ProviderDescriptor get descriptor => ProviderDescriptor(
    id: ProviderId.myProvider,
    name: 'my_provider',
    displayName: 'My Provider',
    icon: Icons.api,
    defaultSource: SourceMode.api,
    availableSources: [SourceMode.api],
    apiUrl: 'https://api.myprovider.com/v1',
    pricing: const {
      'model_input': 0.001,
      'model_output': 0.005,
    },
  );

  @override
  Future<ProviderSnapshot> fetch(FetchContext context) async {
    final apiKey = context.credentials['api_key'];
    // Implement API call here
    return ProviderSnapshot(
      providerId: id,
      sessionUsed: /* parsed from API */,
      sessionLimit: /* from API or config */,
      fetchedAt: DateTime.now(),
    );
  }

  @override
  Future<double> estimateCost(ProviderSnapshot snapshot) async {
    // Calculate cost based on pricing map
    return 0.0;
  }
}
```

### 2. Register the Provider

Add to `lib/providers/providers.dart`:

```dart
ProviderRegistry.register(
  ProviderId.myProvider,
  ProviderDescriptor(/* ... */),
  () => MyProvider(),
);
```

### 3. Add to the Enum

Add to `lib/domain/entities/provider_id.dart`:

```dart
enum ProviderId {
  // ... existing providers
  myProvider("my_provider", "My Provider");
}
```

---

## Configuration

### API Keys

API keys are stored securely using platform-native encryption:
- **iOS**: Keychain
- **Android**: EncryptedSharedPreferences / Keystore

Keys are never persisted in plain text and are loaded on-demand.

### Settings

| Setting | Default | Description |
|---------|---------|-------------|
| Refresh Interval | 5 minutes | How often to fetch usage data |
| TTL | 5 minutes | Cache validity duration |
| Notifications | Disabled | Usage alert toggle |
| Alert Threshold | 85% | Percentage to trigger alert |
| Theme | System | Light / Dark / System |

---

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/domain/provider_snapshot_test.dart

# Run widget tests
flutter test test/widget/
```

Test structure:
```
test/
├── unit/
│   ├── domain/          # Entity and engine tests
│   └── data/            # Repository and datasource tests
└── widget/
    └── presentation/    # Screen and widget tests
```

---

## CI/CD

This project uses **GitHub Actions** for automated quality checks and builds:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `analyze.yml` | Push / PR | `flutter analyze` + `dart format` |
| `test.yml` | Push / PR | Unit + widget tests with coverage |
| `build-android.yml` | Push / PR / Release | APK + AAB artifacts |
| `build-ios.yml` | Push | iOS archive (requires macOS runner) |

On release creation, Android APK and AAB are automatically uploaded as release assets.

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Ensure tests pass: `flutter test`
5. Format code: `dart format lib/ test/`
6. Run analysis: `flutter analyze`
7. Commit and push: `git commit -m "feat: add my feature"`
8. Open a Pull Request

### Code Style

- Use `dart format` for consistent formatting
- Follow `flutter analyze` rules (strict mode enabled)
- Prefer `const` constructors where possible
- Use Riverpod for all state management (no `setState`)
- Write tests for new domain logic

---

## License

[MIT License](LICENSE) — See LICENSE file for details.

---

## Acknowledgments

- **CodexBar** ([steipete/CodexBar](https://github.com/steipete/CodexBar)) — macOS menu bar app that inspired the provider architecture and usage tracking patterns
- **Win-CodexBar** ([Finesssee/Win-CodexBar](https://github.com/Finesssee/Win-CodexBar)) — Windows port that influenced the strategy-based fetch pipeline and engine/frontend separation
- Both reference projects are licensed under MIT

---

*Token Watch — Keep your AI usage visible, always.*
