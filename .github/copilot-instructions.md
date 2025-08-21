## Quick context

This iOS app (internal name: Breathe Easy / Panic Square) is a SwiftUI + SwiftData app focused on guided box-breathing with optional premium audio. The codebase uses singletons for app-wide services, Swift concurrency (async/await), StoreKit 2 for subscriptions, and resource-based audio assets under `Resources/Sounds/`.

Keep instructions brief and mechanical. Prefer small, safe changes with tests or a smoke-check in Xcode when possible.

## What an agent should know first (big picture)

- App entry: `Application/Panic_SquareApp.swift` — initializes `StoreKitManager` and shows `ContentView()`.
- UI layer: `Views/` contains SwiftUI screens. `ContentView.swift` orchestrates the breathing flow and paywall presentation.
- ViewModels & state: `ViewModel/` (e.g., `BreathingViewModel.swift`) holds session logic and timing. `SettingsManager.swift`, `SubscriptionManager.swift` (in `Services/`) are ObservableObjects used across views.
- Services: `Services/AudioManager.swift` (audio playback/fallback), `StoreKitManager.swift` (product loading & transaction verification), `SubscriptionManager.swift` (feature gating). These are singletons accessed via `.shared`.
- Models & resources: `Model/` contains enums like `VoiceOption`, `BreathingPattern`, and `BreathingPhase`. Audio files live in `Resources/Sounds/` and follow a predictable naming convention (e.g. `female_calm_inhale.wav`).

## Developer workflows (how to build, test, debug)

- Open the Xcode workspace/project at the repo root and run on a simulator or device. The app prefers a dark color scheme by default.
- StoreKit local testing: use `Configuration.storekit` (already in the repo) for testing purchases. Add the `Breathe Easy.entitlements` file and enable In-App Purchase capability in Xcode per `StoreKit_README.md`.
- When modifying subscription logic, run `StoreKitManager.shared.loadProducts()` in the app `task` or call it from a small test target to verify product loading.
- Debug helpers: many views print debug info (e.g., `settingsManager.printCurrentSettings()` and `subscriptionManager.printSubscriptionDebugInfo()` in `ContentView`). Use these for quick runtime checks.

## Project-specific conventions & patterns

- Singletons: managers are singletons (e.g., `StoreKitManager.shared`, `SettingsManager.shared`, `SubscriptionManager.shared`, `AudioManager.shared`). Avoid creating parallel instances.
- Feature gating: check `SubscriptionManager.canUse*` helpers before enabling premium UI or actions. UI often shows paywall when `canUse...` returns false (see `BreathingSettingsView.swift`).
- Audio fallback: `AudioManager` is responsible for falling back to default files when premium assets are missing — modify it only when you understand file naming in `Resources/Sounds/`.
- Swift concurrency: StoreKit and some services use async/await — prefer structured concurrency (Task) and proper `await` handling. Follow existing patterns in `StoreKitManager.swift`.
- Resource naming: voice/background audio files use consistent names like `female_calm_inhale.wav`, `male_deep_exhale.wav`, `calm_music.mp3`. Add new files following this pattern and update corresponding `Model/` enums.

## Integration points & cross-component communication

- Notifications: the app uses NotificationCenter for cross-screen signals (e.g., `.showPaywall`). Search for `.publisher(for: .showPaywall)` to find receivers.
- Settings persistence: `SettingsManager` writes preferences and is expected to be used in views and `BreathingViewModel` for live updates.
- StoreKit <> SubscriptionManager: `StoreKitManager` loads and verifies transactions; `SubscriptionManager` uses that state to expose `hasPremiumAccess` and `canUse...` helpers. Changes to product identifiers belong in `StoreKit_README.md`.

## Files to inspect when making changes

- App lifecycle and product load: `Application/Panic_SquareApp.swift`
- Main UI & orchestration: `Views/ContentView.swift`, `ViewModel/BreathingViewModel.swift`
- Settings and gating: `Services/SettingsManager.swift`, `Services/SubscriptionManager.swift`, `Views/Settings&about/BreathingSettingsView.swift`
- Audio: `Services/AudioManager.swift`, `Model/VoiceOption.swift`, `Resources/Sounds/`
- StoreKit: `Services/StoreKitManager.swift`, `StoreKit_README.md`, `Configuration.storekit`, `Breathe Easy.entitlements`

## Safe change rules (must-follow)

- Do not change the public API of singletons (their `.shared` accessors and primary methods) without updating all usages.
- When adding premium features, update `SubscriptionManager` gating helpers and `PREMIUM_AUDIO_README.md` file to reflect new assets and IDs.
- New audio files must be added to `Resources/Sounds/` and referenced by name in `Model` enums. Verify audio playback in `AudioManager` after adding.
- For StoreKit/product ID changes, update `Configuration.storekit`, `StoreKit_README.md`, and test with the Xcode StoreKit configuration.

## Examples (concrete edit patterns)

- Add new voice: 1) add `female_new_inhale.wav`/`hold`/`exhale` to `Resources/Sounds/`, 2) add a `VoiceOption` case in `Model/VoiceOption.swift` with `isPremium` flag, 3) ensure `AudioManager` selects files by combining `voice` + `phase` names.
- Gate a new session length: add option to `Model/SessionLength.swift`, then add `SubscriptionManager.canUseSessionLength(_:)` logic and UI handling in `BreathingSettingsView.swift` to show paywall.

## Where not to guess

- Do not invent product identifiers, entitlements, or App Store Connect details — follow `StoreKit_README.md` and coordinate with the repository owner.

## If you need more info

- Ask for the App Store Connect product IDs, the preferred team ID for entitlements, or the public SSH key for CI if needed for signing and automated checks.

---
Please review this file and tell me if you want more examples or tighter rules for tests and formatting. I will iterate on feedback.
