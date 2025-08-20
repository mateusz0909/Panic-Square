# Premium Audio Implementation

## Overview
This implementation adds premium audio content to the Breathe Easy breathing app, including multiple voice options and nature sounds for background audio.

## Features Added

### 1. Multiple Voice Options
- **Default Voice** (Free): Original voice guidance files
- **Female Calm** (Premium): Soothing female voice option
- **Male Deep** (Premium): Deep, calming male voice
- **Female Whisper** (Premium): Gentle whisper voice option

### 2. Nature Sounds
- **Calm Music** (Free): Original background music
- **Ocean Waves** (Premium): Relaxing ocean sounds
- **Forest Sounds** (Premium): Peaceful forest ambiance
- **Rain Sounds** (Premium): Gentle rainfall
- **White Noise** (Premium): Consistent white noise
- **Silence** (Free): No background sound

### 3. Audio Settings UI
- New audio settings screen accessible from main controls
- Premium feature gating with visual indicators
- Voice and background sound selection
- Premium upgrade prompts

## Technical Implementation

### New Models
- `VoiceOption`: Enumeration of available voices with premium flags
- `BackgroundSoundOption`: Enumeration of background sounds with premium flags
- `SubscriptionManager`: Manages premium status and feature access

### Updated Services
- `AudioManager`: Enhanced to support multiple audio sources and voice options
- `SettingsManager`: Extended to store voice and background sound preferences

### File Structure
```
Resources/Sounds/
├── inhale.wav (default voice)
├── hold.wav (default voice)
├── exhale.wav (default voice)
├── female_calm_inhale.wav (premium)
├── female_calm_hold.wav (premium)
├── female_calm_exhale.wav (premium)
├── male_deep_inhale.wav (premium)
├── male_deep_hold.wav (premium)
├── male_deep_exhale.wav (premium)
├── female_whisper_inhale.wav (premium)
├── female_whisper_hold.wav (premium)
├── female_whisper_exhale.wav (premium)
├── calm_music.mp3 (free)
├── ocean_waves.mp3 (premium)
├── forest_sounds.mp3 (premium)
├── rain_sounds.mp3 (premium)
├── white_noise.mp3 (premium)
└── ping.wav (for ping guidance)
```

## Usage

### For Users
1. Tap the audio settings button (slider icon) in the main controls
2. Browse voice options and background sounds
3. Premium features show a lock icon and crown badge
4. Tap "Upgrade to Premium" to access premium content (currently toggles test mode)

### For Developers
- Premium status is managed through `SubscriptionManager.shared`
- Audio preferences are automatically saved via `SettingsManager`
- The `AudioManager` handles fallback to default voice if premium files are missing
- All UI components automatically update based on subscription status

## Monetization Ready
The implementation is designed to be easily integrated with StoreKit 2 for actual subscription management. Currently uses UserDefaults for testing premium features.

## Testing
- Toggle premium status using the test buttons in various UI screens
- All premium features are functional when premium status is enabled
- Graceful fallback to free features when premium is disabled
