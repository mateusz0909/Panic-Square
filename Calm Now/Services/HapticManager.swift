//
//  HapticManager.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 01/08/2025.
//

//
//  HapticManager.swift
//  BreatheEasy
//
//  Created by [Your Name] on [Date].
//

import UIKit

/// A manager to provide haptic feedback.
/// Using a singleton pattern here for easy access throughout the app.
class HapticManager {
    static let shared = HapticManager()
    
    private let generator: UIImpactFeedbackGenerator
    
    private init() {
        // Use a .soft impact for a less jarring, more calming feel.
        generator = UIImpactFeedbackGenerator(style: .soft)
        // Preparing the generator in advance reduces latency for the first feedback.
        generator.prepare()
    }
    
    /// Triggers a haptic feedback event.
    func trigger() {
        generator.impactOccurred()
    }
}
