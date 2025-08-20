//
//  BreathingPhase.swift
//  BreatheEasy
//
//  Created by [Your Name] on [Date].
//

import Foundation

enum BreathingPhase: CaseIterable {
    case inhale
    case holdAfterInhale
    case exhale
    case holdAfterExhale
    
    var instruction: String {
        switch self {
        case .inhale:
            return "Inhale"
        case .holdAfterInhale, .holdAfterExhale:
            return "Hold"
        case .exhale:
            return "Exhale"
        }
    }
    
    // --- NEW: A property to hold the name of the voice file for each phase ---
    /// The filename (without extension) for the voice guidance audio.
    func voiceFileName(for voiceOption: VoiceOption) -> String {
        let baseFileName: String
        switch self {
        case .inhale:
            baseFileName = "inhale"
        case .holdAfterInhale, .holdAfterExhale:
            baseFileName = "hold"
        case .exhale:
            baseFileName = "exhale"
        }
        
        return voiceOption.filePrefix + baseFileName
    }
    
    var isSquareExpanded: Bool {
        switch self {
        case .inhale, .holdAfterInhale:
            return true
        case .exhale, .holdAfterExhale:
            return false
        }
    }
    
    var next: BreathingPhase {
        guard let currentIndex = BreathingPhase.allCases.firstIndex(of: self) else {
            return .inhale
        }
        let nextIndex = (currentIndex + 1) % BreathingPhase.allCases.count
        return BreathingPhase.allCases[nextIndex]
    }
}
