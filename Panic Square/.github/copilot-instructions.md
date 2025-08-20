# Copilot Instructions for Breathe Easy

## Project Overview
- **Breathe Easy** is a SwiftUI iOS/macOS app focused on guided breathing and relaxation, with audio, haptics, and visually engaging UI components.
- The codebase is organized by feature: `Model/` (data models), `Services/` (audio, haptics, settings), `ViewModel/` (state management), and `Views/` (UI, including reusable components).

## Architecture & Patterns
- **MVVM**: Core logic is separated into `ViewModel/` (e.g., `BreathingViewModel.swift`) and `Views/` (UI). Models in `Model/` define app data and options.
- **Services**: Cross-cutting concerns (audio, haptics, settings) are in `Services/` and are accessed by view models and views.
- **Extensions**: Utility extensions (e.g., color helpers) are in `Extensions/`.
- **Resources**: Assets (colors, icons, sounds) are in `Resources/` and referenced by name in code.

## Key Conventions
- **SwiftUI**: All UI is declarative. Use custom views in `Views/Components/` for reusable UI (e.g., `BreathingGuideView`, `GlassButtonStyle`).
- **Naming**: Files and types are named by feature and role (e.g., `AudioManager`, `BreathingPhase`).
- **Settings & About**: Settings and about screens are in `Views/Settings&about/`.
- **No Storyboards**: All UI is code-driven.

## Developer Workflows
- **Build**: Open the project in Xcode and build/run as a standard SwiftUI app.
- **Assets**: Add new images, colors, or sounds to `Resources/Assets.xcassets` or `Resources/Sounds/` and reference them by name.
- **Testing**: No explicit test directory found; add tests in Xcode as needed.
- **Debugging**: Use Xcode's debugger and SwiftUI previews for UI.

## Integration & Dependencies
- **No external dependencies** detected (no Package.swift, Podfile, or similar found).
- **Audio**: Audio files are in `Resources/Sounds/` and played via `AudioManager`.
- **Haptics**: Managed by `HapticManager` in `Services/`.

## Examples
- To add a new breathing phase: update `Model/BreathingPhase.swift` and ensure `BreathingViewModel.swift` uses it.
- To add a new button style: create a SwiftUI view in `Views/Components/` and apply it in your UI.

## References
- **Entry point**: `Application/Panic_SquareApp.swift`
- **Main UI**: `Views/ContentView.swift`
- **Reusable UI**: `Views/Components/`
- **Services**: `Services/`
- **Models**: `Model/`

---

For questions about project structure or patterns, review the above directories and files for examples before introducing new approaches.
