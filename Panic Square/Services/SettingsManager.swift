//
//  SettingsManager.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 01/08/2025.
//


//
//  SettingsManager.swift
//  BreatheEasy
//
//  Created by [Your Name] on [Date].
//

import Foundation

/// Manages loading and saving user preferences via UserDefaults.
/// This is an ObservableObject so that UI can react to changes in settings.
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Audio Guide Settings
    private let audioGuideOptionKey = "audioGuideOptionKey"
    @Published var audioGuideOption: AudioGuideOption = .voice {
        didSet { 
            saveSettingsDebounced()
        }
    }
    
    // MARK: - Voice Selection
    private let selectedVoiceKey = "selectedVoiceKey"
    @Published var selectedVoice: VoiceOption = .defaultVoice {
        didSet { 
            saveSettingsDebounced()
        }
    }
    
    // MARK: - Background Sound Settings
    private let backgroundSoundKey = "backgroundSoundKey"
    @Published var backgroundSound: BackgroundSoundOption = .calmMusic {
        didSet { 
            saveSettingsDebounced()
        }
    }
    
    // MARK: - Music Enable/Disable (kept for backward compatibility)
    private let isMusicEnabledKey = "isMusicEnabledKey"
    @Published var isMusicEnabled: Bool = true {
        didSet { 
            saveSettingsDebounced()
        }
    }
    
    // MARK: - Breathing Pattern Settings
    private let breathingPatternKey = "breathingPatternKey"
    @Published var breathingPattern: BreathingPattern = .defaultPattern {
        didSet { 
            saveSettingsDebounced()
        }
    }
    
    // MARK: - Session Length Settings
    private let sessionLengthKey = "sessionLengthKey"
    @Published var sessionLength: SessionLength = .infinite {
        didSet { 
            saveSettingsDebounced()
        }
    }
    
    // MARK: - Welcome Screen Settings
    private let hasSeenWelcomeKey = "hasSeenWelcomeKey"
    @Published var hasSeenWelcome: Bool = false {
        didSet { 
            saveSettingsDebounced()
        }
    }
    
    private init() {
        loadSettings()
    }
    
    // MARK: - Debounced saving to prevent excessive writes
    private var saveWorkItem: DispatchWorkItem?
    
    private func saveSettingsDebounced() {
        saveWorkItem?.cancel()
        saveWorkItem = DispatchWorkItem { [weak self] in
            self?.saveSettings()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: saveWorkItem!)
    }
    
    // --- UPDATED: Unified save/load methods ---
    private func saveSettings() {
        print("Saving settings to UserDefaults...")
        
        do {
            let audioData = try JSONEncoder().encode(audioGuideOption)
            userDefaults.set(audioData, forKey: audioGuideOptionKey)
            print("Saved audio guide option: \(audioGuideOption)")
            
            let voiceData = try JSONEncoder().encode(selectedVoice)
            userDefaults.set(voiceData, forKey: selectedVoiceKey)
            print("Saved selected voice: \(selectedVoice)")
            
            let backgroundData = try JSONEncoder().encode(backgroundSound)
            userDefaults.set(backgroundData, forKey: backgroundSoundKey)
            print("Saved background sound: \(backgroundSound)")
            
            let patternData = try JSONEncoder().encode(breathingPattern)
            userDefaults.set(patternData, forKey: breathingPatternKey)
            print("Saved breathing pattern: \(breathingPattern)")
            
            let sessionData = try JSONEncoder().encode(sessionLength)
            userDefaults.set(sessionData, forKey: sessionLengthKey)
            print("Saved session length: \(sessionLength)")
            
            userDefaults.set(isMusicEnabled, forKey: isMusicEnabledKey)
            print("Saved music enabled: \(isMusicEnabled)")
            
            userDefaults.set(hasSeenWelcome, forKey: hasSeenWelcomeKey)
            print("Saved has seen welcome: \(hasSeenWelcome)")
            
            // Force synchronize to ensure data is written to disk
            userDefaults.synchronize()
            print("Settings saved and synchronized to disk.")
            
        } catch {
            print("Failed to save settings: \(error.localizedDescription)")
        }
    }
    
    private func loadSettings() {
        print("Loading settings from UserDefaults...")
        
        // Load audio guide option
        if let audioData = userDefaults.data(forKey: audioGuideOptionKey),
           let option = try? JSONDecoder().decode(AudioGuideOption.self, from: audioData) {
            print("Loaded audio guide option: \(option)")
            self.audioGuideOption = option
        } else {
            print("No saved audio guide option found, using default: \(audioGuideOption)")
        }
        
        // Load selected voice
        if let voiceData = userDefaults.data(forKey: selectedVoiceKey),
           let voice = try? JSONDecoder().decode(VoiceOption.self, from: voiceData) {
            print("Loaded selected voice: \(voice)")
            self.selectedVoice = voice
        } else {
            print("No saved voice found, using default: \(selectedVoice)")
        }
        
        // Load background sound
        if let backgroundData = userDefaults.data(forKey: backgroundSoundKey),
           let sound = try? JSONDecoder().decode(BackgroundSoundOption.self, from: backgroundData) {
            print("Loaded background sound: \(sound)")
            self.backgroundSound = sound
        } else {
            print("No saved background sound found, using default: \(backgroundSound)")
        }
        
        // Load music setting (defaults to true if not found)
        if userDefaults.object(forKey: isMusicEnabledKey) != nil {
            let musicEnabled = userDefaults.bool(forKey: isMusicEnabledKey)
            print("Loaded music enabled: \(musicEnabled)")
            self.isMusicEnabled = musicEnabled
        } else {
            print("No saved music setting found, using default: \(isMusicEnabled)")
        }
        
        // Load breathing pattern
        if let patternData = userDefaults.data(forKey: breathingPatternKey),
           let pattern = try? JSONDecoder().decode(BreathingPattern.self, from: patternData) {
            print("Loaded breathing pattern: \(pattern)")
            self.breathingPattern = pattern
        } else {
            print("No saved breathing pattern found, using default: \(breathingPattern)")
        }
        
        // Load session length
        if let sessionData = userDefaults.data(forKey: sessionLengthKey),
           let session = try? JSONDecoder().decode(SessionLength.self, from: sessionData) {
            print("Loaded session length: \(session)")
            self.sessionLength = session
        } else {
            print("No saved session length found, using default: \(sessionLength)")
        }
        
        // Load welcome screen setting
        if userDefaults.object(forKey: hasSeenWelcomeKey) != nil {
            let seenWelcome = userDefaults.bool(forKey: hasSeenWelcomeKey)
            print("Loaded has seen welcome: \(seenWelcome)")
            self.hasSeenWelcome = seenWelcome
        } else {
            print("No saved welcome setting found, using default: \(hasSeenWelcome)")
        }
        
        print("Settings loading completed.")
    }
    
    // MARK: - Public Methods
    
    /// Force immediate save of settings (useful when app goes to background)
    func forceSave() {
        saveWorkItem?.cancel()
        saveSettings()
    }
    
    /// Debug method to print current settings
    func printCurrentSettings() {
        print("=== Current Settings ===")
        print("Audio Guide: \(audioGuideOption)")
        print("Selected Voice: \(selectedVoice)")
        print("Background Sound: \(backgroundSound)")
        print("Music Enabled: \(isMusicEnabled)")
        print("Breathing Pattern: \(breathingPattern.name)")
        print("Session Length: \(sessionLength)")
        print("Has Seen Welcome: \(hasSeenWelcome)")
        print("========================")
    }
}

