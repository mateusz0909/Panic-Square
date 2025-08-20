//
//  AudioManager.swift
//  BreatheEasy
//
//  Created by [Your Name] on [Date].
//

import AVFoundation

/// Manages the playback of background music, nature sounds, and voice guidance.
final class AudioManager {
    
    private var backgroundPlayer: AVAudioPlayer?
    private var voicePlayer: AVAudioPlayer?
    private var currentBackgroundSound: BackgroundSoundOption?

    init() {
        setupAudioSession()
    }
    
    // MARK: - Helper Methods
    
    private func findAudioFile(named fileName: String) -> URL? {
        // Try MP3 first, then WAV
        if let mp3URL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            return mp3URL
        } else if let wavURL = Bundle.main.url(forResource: fileName, withExtension: "wav") {
            return wavURL
        }
        return nil
    }
    
    // MARK: - Background Audio Management
    
    func playBackgroundAudio(sound: BackgroundSoundOption, isEnabled: Bool) {
        guard isEnabled else {
            stopBackgroundAudio()
            return
        }
        
        // If we're already playing the same sound, don't restart
        if currentBackgroundSound == sound && backgroundPlayer?.isPlaying == true {
            return
        }
        
        stopBackgroundAudio()
        
        guard let fileName = sound.fileName else {
            // Silence option - just stop any current audio
            return
        }
        
        guard let audioURL = findAudioFile(named: fileName) else {
            print("Could not find \(fileName).mp3 or \(fileName).wav in the bundle.")
            return
        }
        
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: audioURL)
            backgroundPlayer?.numberOfLoops = -1
            backgroundPlayer?.volume = 0
            backgroundPlayer?.prepareToPlay()
            backgroundPlayer?.play()
            backgroundPlayer?.setVolume(0.4, fadeDuration: 2.0)
            currentBackgroundSound = sound
        } catch {
            print("Could not create background audio player: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundAudio() {
        guard let player = backgroundPlayer, player.isPlaying else { return }

        player.setVolume(0, fadeDuration: 1.5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if player.volume < 0.01 {
                player.stop()
            }
        }
        
        currentBackgroundSound = nil
    }
    
    // MARK: - Voice Guidance
    
    func playGuideSound(for phase: BreathingPhase, option: AudioGuideOption, voice: VoiceOption) {
        guard option != .none else { return }
        
        let fileName: String
        
        switch option {
        case .voice:
            fileName = phase.voiceFileName(for: voice)
        case .ping:
            fileName = "ping"
        case .none:
            return
        }
        
        guard let soundURL = findAudioFile(named: fileName) else {
            print("Could not find \(fileName).mp3 or \(fileName).wav in the bundle.")
            // Fallback to default voice if premium voice file is missing
            if voice != .defaultVoice && option == .voice {
                let fallbackFileName = phase.voiceFileName(for: .defaultVoice)
                guard let fallbackURL = findAudioFile(named: fallbackFileName) else {
                    print("Could not find fallback file \(fallbackFileName).mp3 or \(fallbackFileName).wav")
                    return
                }
                playAudioFile(at: fallbackURL)
            }
            return
        }
        
        playAudioFile(at: soundURL)
    }
    
    private func playAudioFile(at url: URL) {
        do {
            voicePlayer = try AVAudioPlayer(contentsOf: url)
            voicePlayer?.volume = 0.8
            voicePlayer?.play()
        } catch {
            print("Could not create voice player: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        do {
            // Using .duckOthers allows the background music to lower its volume
            // when the voice cue plays, making the instruction clearer.
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Legacy Methods (for backward compatibility)
    
    func playMusic(isEnabled: Bool) {
        // Use calm music as default for legacy calls
        playBackgroundAudio(sound: .calmMusic, isEnabled: isEnabled)
    }
    
    func playMusic() {
        playBackgroundAudio(sound: .calmMusic, isEnabled: true)
    }
    
    func stopMusic() {
        stopBackgroundAudio()
    }
}
