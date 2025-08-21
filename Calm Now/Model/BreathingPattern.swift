//
//  BreathingPattern.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 18/08/2025.
//

import Foundation

/// Defines different breathing patterns with custom timing
struct BreathingPattern: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let description: String
    let inhaleSeconds: Double
    let holdAfterInhaleSeconds: Double
    let exhaleSeconds: Double
    let holdAfterExhaleSeconds: Double
    let isPremium: Bool
    
    /// Total duration of one complete breathing cycle
    var cycleDuration: Double {
        return inhaleSeconds + holdAfterInhaleSeconds + exhaleSeconds + holdAfterExhaleSeconds
    }
    
    /// User-friendly display of the pattern timing
    var timingDisplay: String {
        if inhaleSeconds == holdAfterInhaleSeconds && 
           holdAfterInhaleSeconds == exhaleSeconds && 
           exhaleSeconds == holdAfterExhaleSeconds {
            return "\(Int(inhaleSeconds))-\(Int(holdAfterInhaleSeconds))-\(Int(exhaleSeconds))-\(Int(holdAfterExhaleSeconds))"
        } else {
            return "\(Int(inhaleSeconds))-\(Int(holdAfterInhaleSeconds))-\(Int(exhaleSeconds))-\(Int(holdAfterExhaleSeconds))"
        }
    }
}

extension BreathingPattern {
    /// Predefined breathing patterns
    static let allPatterns: [BreathingPattern] = [
        BreathingPattern(
            id: "classic_box",
            name: "Classic Box",
            description: "Traditional 4-4-4-4 box breathing",
            inhaleSeconds: 4,
            holdAfterInhaleSeconds: 4,
            exhaleSeconds: 4,
            holdAfterExhaleSeconds: 4,
            isPremium: false
        ),
        BreathingPattern(
            id: "gentle_box",
            name: "Gentle Box",
            description: "Slower 3-3-3-3 pattern for beginners",
            inhaleSeconds: 3,
            holdAfterInhaleSeconds: 3,
            exhaleSeconds: 3,
            holdAfterExhaleSeconds: 3,
            isPremium: true
        ),
        BreathingPattern(
            id: "deep_box",
            name: "Deep Box",
            description: "Extended 5-5-5-5 pattern for deeper relaxation",
            inhaleSeconds: 5,
            holdAfterInhaleSeconds: 5,
            exhaleSeconds: 5,
            holdAfterExhaleSeconds: 5,
            isPremium: true
        ),
        BreathingPattern(
            id: "advanced_box",
            name: "Advanced Box",
            description: "Challenging 6-6-6-6 pattern for experienced users",
            inhaleSeconds: 6,
            holdAfterInhaleSeconds: 6,
            exhaleSeconds: 6,
            holdAfterExhaleSeconds: 6,
            isPremium: true
        ),
        BreathingPattern(
            id: "four_seven_eight",
            name: "4-7-8 Relaxing",
            description: "Popular 4-7-8 technique for sleep and anxiety",
            inhaleSeconds: 4,
            holdAfterInhaleSeconds: 7,
            exhaleSeconds: 8,
            holdAfterExhaleSeconds: 0,
            isPremium: true
        ),
        BreathingPattern(
            id: "coherent_breathing",
            name: "Coherent Breathing",
            description: "5-0-5-0 pattern for heart rate variability",
            inhaleSeconds: 5,
            holdAfterInhaleSeconds: 0,
            exhaleSeconds: 5,
            holdAfterExhaleSeconds: 0,
            isPremium: true
        )
    ]
    
    /// Default free pattern
    static let defaultPattern = allPatterns[0] // Classic Box
}
