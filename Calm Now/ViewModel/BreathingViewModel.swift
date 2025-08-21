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
    @Published private(set) var countdown: Int = 1
    @Published var isGuideAnimating: Bool = false
    @Published private(set) var sessionTimeRemaining: TimeInterval?
    @Published private(set) var totalBreathCycles: Int = 0
    @Published var backgroundOpacity: Double = 1.0

    
    // MARK: - Private Properties
    private let audioManager = AudioManager.shared
    private let settingsManager = SettingsManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: CFTimeInterval = 0
    private var elapsedTime: TimeInterval = 0
    private var sessionStartTime: Date?
    
    // MARK: - Computed Properties
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
    
    // MARK: - Initialization
    init() {
        setupObservers()
    }
    
    deinit {
        displayLink?.invalidate()
        timer?.cancel()
    }
    
    // MARK: - Setup
    private func setupObservers() {
        // Listen for breathing pattern changes
        settingsManager.$breathingPattern
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                // Only act if a breathing session is currently active
                guard self.isBreathing else { return }
                
                // Reset to the new pattern's initial state
                self.stop()
            }
            .store(in: &cancellables)
        
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
        displayLink?.preferredFramesPerSecond = 30 // Optimize for better performance
        displayLink?.add(to: .main, forMode: .common)
        lastUpdateTime = CACurrentMediaTime()
    }
    
    @objc private func updateWithDisplayLink() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        elapsedTime += deltaTime
        
        // Update session time remaining (only animate this if needed)
        if let remaining = sessionTimeRemaining {
            let newRemaining = max(0, remaining - deltaTime)
            if newRemaining != sessionTimeRemaining {
                sessionTimeRemaining = newRemaining
            }
            
            // Check if session should end
            if sessionTimeRemaining! <= 0 {
                stop()
                return
            }
        }
        
        // Check for phase transitions
        if elapsedTime >= currentPhaseDuration {
            elapsedTime = 0
            let nextPhase = currentPhase.next
            
            // Count completed breath cycles (when returning to inhale)
            if nextPhase == .inhale {
                totalBreathCycles += 1
            }
            
            setPhase(nextPhase)
        }
        
        // Update UI smoothly without excessive animations
        updateUI(for: elapsedTime)
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
        // Smooth transition to new phase
        withAnimation(.easeInOut(duration: 0.6)) {
            self.currentPhase = phase
        }
        
        let phaseDuration = currentPhaseDuration
        
        print("🔄 BreathingViewModel - Setting phase: \(phase), duration: \(phaseDuration)s")
        
        HapticManager.shared.trigger()
        
        // Play guide sound only if phase duration > 0
        if phaseDuration > 0 {
            audioManager.playGuideSound(
                for: phase,
                option: settingsManager.audioGuideOption,
                voice: settingsManager.selectedVoice
            )
            
            // Start voice counting if voice guidance is enabled
            if settingsManager.audioGuideOption == .voice {
                audioManager.startVoiceCountingForPhase(phase, phaseDuration: phaseDuration, voice: settingsManager.selectedVoice)
            }
            
            // Start ping counting if ping guidance is enabled
            if settingsManager.audioGuideOption == .ping {
                audioManager.startPingCountingForPhase(phase, phaseDuration: phaseDuration)
            }
        } else {
            print("🔄 BreathingViewModel - Skipping voice guide for \(phase) with 0 duration")
        }
    }
    
    private func updateUI(for time: TimeInterval) {
        let progress = min(time / currentPhaseDuration, 1.0)
        
        // Use smooth easing functions for more natural breathing feel
        let easedProgress = easeInOutSine(progress)
        
        // Calculate new values
        let newScale: CGFloat
        let newCornerRadius: CGFloat
        let newBackgroundOpacity: Double
        
        switch currentPhase {
        case .inhale:
            newScale = 0.5 + (easedProgress * 0.5)
            newCornerRadius = 80 - (easedProgress * 50)
            newBackgroundOpacity = 1.0 + (easedProgress * 0.1) // Subtle brightening during inhale
        case .holdAfterInhale:
            newScale = 1.0
            newCornerRadius = 30
            newBackgroundOpacity = 1.1 // Slightly brighter during hold
        case .exhale:
            newScale = 1.0 - (easedProgress * 0.5)
            newCornerRadius = 30 + (easedProgress * 50)
            newBackgroundOpacity = 1.1 - (easedProgress * 0.15) // Gentle dimming during exhale
        case .holdAfterExhale:
            newScale = 0.5
            newCornerRadius = 80
            newBackgroundOpacity = 0.95 // Slightly dimmer during rest
        }
        
        // Only update if values have actually changed (reduce unnecessary animations)
        if abs(scale - newScale) > 0.01 {
            scale = newScale
        }
        if abs(cornerRadius - newCornerRadius) > 0.5 {
            cornerRadius = newCornerRadius
        }
        if abs(backgroundOpacity - newBackgroundOpacity) > 0.01 {
            backgroundOpacity = newBackgroundOpacity
        }
        
        // Update countdown more efficiently
        let newCountdown = Int(floor(time)) + 1
        let maxCountdown = Int(currentPhaseDuration)
        let clampedCountdown = min(newCountdown, maxCountdown)
        
        if countdown != clampedCountdown {
            countdown = clampedCountdown
        }
    }
    
    /// Smooth easing function for natural breathing animation
    private func easeInOutSine(_ t: Double) -> Double {
        return -(cos(.pi * t) - 1) / 2
    }
    
    private func stop() {
        isBreathing = false
        isGuideAnimating = false
        audioManager.stopBackgroundAudio()
        audioManager.stopVoiceCounting()
        
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
        cornerRadius = 80.0
        countdown = 1
        backgroundOpacity = 1.0
        elapsedTime = 0
        sessionTimeRemaining = nil
        totalBreathCycles = 0
    }
}
