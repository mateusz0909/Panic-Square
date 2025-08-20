//
//  BreathingViewModel.swift
//  BreatheEasy
//
//  Created by [Your Name] on [Date].
//

import Foundation
import Combine
import SwiftUI
import QuartzCore
import UIKit

@MainActor
final class BreathingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var isBreathing: Bool = false
    @Published private(set) var currentPhase: BreathingPhase = .inhale
    @Published private(set) var scale: CGFloat = 0.5
    @Published private(set) var cornerRadius: CGFloat = 80.0
    @Published private(set) var countdown: Int = 4
    @Published var isGuideAnimating: Bool = false
    @Published private(set) var sessionTimeRemaining: TimeInterval?
    @Published private(set) var totalBreathCycles: Int = 0

    
    // MARK: - Private Properties
    private let audioManager = AudioManager()
    private let settingsManager = SettingsManager.shared
    private var timer: AnyCancellable?
    private var displayLink: CADisplayLink?
    // NEW: A property to hold our subscriptions to publishers.
    private var cancellables = Set<AnyCancellable>()
    
    private var lastUpdateTime: CFTimeInterval = 0
    
    private var currentPhaseDuration: TimeInterval {
        let pattern = settingsManager.breathingPattern
        switch currentPhase {
        case .inhale:
            return pattern.inhaleSeconds
        case .holdAfterInhale:
            return pattern.holdAfterInhaleSeconds
        case .exhale:
            return pattern.exhaleSeconds
        case .holdAfterExhale:
            return pattern.holdAfterExhaleSeconds
        }
    }
    
    private var elapsedTime: TimeInterval = 0.0
    private var sessionStartTime: Date?

    // NEW: An initializer to set up our reactive subscriptions.
    init() {
        setupMusicSubscription()
    }
    
    deinit {
        displayLink?.invalidate()
        timer?.cancel()
        // Ensure screen wake lock is disabled when view model is deallocated
        UIApplication.shared.isIdleTimerDisabled = false
        print("🔄 BreathingViewModel - deinit: Screen wake lock disabled")
    }
    
    /// Listens for real-time changes to the music setting.
    private func setupMusicSubscription() {
        // Listen for background sound and music enabled changes
        Publishers.CombineLatest(
            settingsManager.$backgroundSound,
            settingsManager.$isMusicEnabled
        )
        .sink { [weak self] backgroundSound, isEnabled in
            guard let self = self else { return }
            
            // Only act if a breathing session is currently active
            guard self.isBreathing else { return }
            
            // Play the selected background sound
            self.audioManager.playBackgroundAudio(sound: backgroundSound, isEnabled: isEnabled)
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func toggleBreathing() {
        if isBreathing {
            stop()
        } else {
            start()
        }
    }
    
    // MARK: - Private Logic
    private func start() {
        isBreathing = true
        isGuideAnimating = true
        sessionStartTime = Date()
        totalBreathCycles = 0
        
        // Keep screen awake during breathing session
        UIApplication.shared.isIdleTimerDisabled = true
        print("🔄 BreathingViewModel - Screen wake lock enabled")
        
        // Set session time remaining if not infinite
        if let duration = settingsManager.sessionLength.durationInSeconds {
            sessionTimeRemaining = duration
        } else {
            sessionTimeRemaining = nil
        }
        
        // Play the selected background sound
        audioManager.playBackgroundAudio(sound: settingsManager.backgroundSound, isEnabled: settingsManager.isMusicEnabled)
        elapsedTime = 0
        
        setPhase(.inhale)
        
        // Use CADisplayLink for precise timing synchronized with display refresh rate
        displayLink = CADisplayLink(target: self, selector: #selector(updateWithDisplayLink))
        displayLink?.add(to: .main, forMode: .common)
        lastUpdateTime = CACurrentMediaTime()
    }
    
    @objc private func updateWithDisplayLink() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        withAnimation {
            elapsedTime += deltaTime
            
            // Update session time remaining
            if let remaining = sessionTimeRemaining {
                sessionTimeRemaining = max(0, remaining - deltaTime)
                
                // Check if session should end
                if sessionTimeRemaining! <= 0 {
                    stop()
                    return
                }
            }
        }
        
        if elapsedTime >= currentPhaseDuration {
            elapsedTime = 0
            let nextPhase = currentPhase.next
            
            // Count completed breath cycles (when returning to inhale)
            if nextPhase == .inhale {
                totalBreathCycles += 1
            }
            
            setPhase(nextPhase)
        }
        
        withAnimation {
            updateUI(for: elapsedTime)
        }
    }
    
    private func update() {
        let timeIncrement = 1.0/60.0 // Match the timer interval
        
        withAnimation {
            elapsedTime += timeIncrement
            
            // Update session time remaining
            if let remaining = sessionTimeRemaining {
                sessionTimeRemaining = max(0, remaining - timeIncrement)
                
                // Check if session should end
                if sessionTimeRemaining! <= 0 {
                    stop()
                    return
                }
            }
        }
        
        if elapsedTime >= currentPhaseDuration {
            elapsedTime = 0
            let nextPhase = currentPhase.next
            
            // Count completed breath cycles (when returning to inhale)
            if nextPhase == .inhale {
                totalBreathCycles += 1
            }
            
            setPhase(nextPhase)
        }
        
        withAnimation {
            updateUI(for: elapsedTime)
        }
    }
    
    private func setPhase(_ phase: BreathingPhase) {
        self.currentPhase = phase
        HapticManager.shared.trigger()
        audioManager.playGuideSound(
            for: phase,
            option: settingsManager.audioGuideOption,
            voice: settingsManager.selectedVoice
        )
    }
    
    private func updateUI(for time: TimeInterval) {
        let progress = time / currentPhaseDuration
        
        switch currentPhase {
        case .inhale:
            scale = 0.5 + (progress * 0.5)
            cornerRadius = 80 - (progress * 50)
        case .holdAfterInhale:
            scale = 1.0
            cornerRadius = 30
        case .exhale:
            scale = 1.0 - (progress * 0.5)
            cornerRadius = 30 + (progress * 50)
        case .holdAfterExhale:
            scale = 0.5
            cornerRadius = 80
        }
        
        withAnimation {
            countdown = Int(ceil(currentPhaseDuration - time))
            if countdown == 0 { countdown = 1 }
        }
    }
    
    private func stop() {
        isBreathing = false
        isGuideAnimating = false
        audioManager.stopBackgroundAudio()
        
        // Re-enable screen auto-lock
        UIApplication.shared.isIdleTimerDisabled = false
        print("🔄 BreathingViewModel - Screen wake lock disabled")
        
        // Clean up timing mechanisms
        timer?.cancel()
        timer = nil
        displayLink?.invalidate()
        displayLink = nil
        
        resetToInitialState()
    }
    
    private func resetToInitialState() {
        currentPhase = .inhale
        scale = 0.5
        cornerRadius = 80
        countdown = Int(settingsManager.breathingPattern.inhaleSeconds)
        sessionTimeRemaining = nil
        totalBreathCycles = 0
        sessionStartTime = nil
    }
}
