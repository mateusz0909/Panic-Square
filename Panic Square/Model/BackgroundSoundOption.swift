//
//  BackgroundSoundOption.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 18/08/2025.
//

import Foundation

/// Defines the available background sound options
enum BackgroundSoundOption: String, Codable, CaseIterable {
    case calmMusic = "calm_music"
    case oceanWaves = "ocean_waves"
    case forestSounds = "forest_sounds"
    case rainSounds = "rain_sounds"
    case whitenoise = "white_noise"
    case silence = "silence"
    
    /// User-friendly display name
    var displayName: String {
        switch self {
        case .calmMusic:
            return "Calm Music"
        case .oceanWaves:
            return "Ocean Waves"
        case .forestSounds:
            return "Forest Sounds"
        case .rainSounds:
            return "Rain Sounds"
        case .whitenoise:
            return "White Noise"
        case .silence:
            return "Silence"
        }
    }
    
    /// Whether this background sound requires premium subscription
    var isPremium: Bool {
        switch self {
        case .calmMusic, .silence:
            return false
        case .oceanWaves, .forestSounds, .rainSounds, .whitenoise:
            return true
        }
    }
    
    /// Audio file name (without extension)
    var fileName: String? {
        switch self {
        case .silence:
            return nil
        default:
            return self.rawValue
        }
    }
    
    /// System icon name for UI
    var iconName: String {
        switch self {
        case .calmMusic:
            return "music.note"
        case .oceanWaves:
            return "water.waves"
        case .forestSounds:
            return "tree"
        case .rainSounds:
            return "cloud.rain"
        case .whitenoise:
            return "waveform"
        case .silence:
            return "speaker.slash"
        }
    }
}
