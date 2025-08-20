//
//  VoiceOption.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 18/08/2025.
//

import Foundation

/// Defines the available voice options for breathing guidance
enum VoiceOption: String, Codable, CaseIterable {
    case defaultVoice = "default"
    case femaleCalm = "female_calm"
    case maleDeep = "male_deep"
    case femaleWhisper = "female_whisper"
    
    /// User-friendly display name
    var displayName: String {
        switch self {
        case .defaultVoice:
            return "Default"
        case .femaleCalm:
            return "Female (Calm)"
        case .maleDeep:
            return "Male (Deep)"
        case .femaleWhisper:
            return "Female (Whisper)"
        }
    }
    
    /// Whether this voice option requires premium subscription
    var isPremium: Bool {
        switch self {
        case .defaultVoice:
            return false
        case .femaleCalm, .maleDeep, .femaleWhisper:
            return true
        }
    }
    
    /// File prefix for voice audio files
    var filePrefix: String {
        switch self {
        case .defaultVoice:
            return ""
        case .femaleCalm:
            return "female_calm_"
        case .maleDeep:
            return "male_deep_"
        case .femaleWhisper:
            return "female_whisper_"
        }
    }
}
