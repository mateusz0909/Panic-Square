//
//  AudioGuideOption.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 01/08/2025.
//

import Foundation

/// Defines the types of audio guidance available to the user.
/// Conforms to String and Codable for easy saving to UserDefaults.
/// Conforms to CaseIterable to easily populate UI pickers.
enum AudioGuideOption: String, Codable, CaseIterable {
    case voice
    case ping
    case none
    
    /// A user-friendly title for display in the UI.
    var title: String {
        switch self {
        case .voice:
            return "Voice"
        case .ping:
            return "Drum"
        case .none:
            return "None"
        }
    }
    
    /// System icon name for UI
    var iconName: String {
        switch self {
        case .voice:
            return "person.wave.2.fill"
        case .ping:
            return "circle.circle"
        case .none:
            return "speaker.slash.fill"
        }
    }
}