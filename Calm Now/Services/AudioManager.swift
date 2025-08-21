
import AVFoundation

/// Manages the playback of background music, nature sounds, and voice guidance.
final class AudioManager {
    
    private var backgroundPlayer: AVAudioPlayer?
    private var voicePlayer: AVAudioPlayer?
    private var countingPlayer: AVAudioPlayer?
    private var currentBackgroundSound: BackgroundSoundOption?
    
    // Voice counting management
    private var countingTimer: Timer?
    private var currentPhaseStartTime: Date?
    private var isVoiceCountingEnabled: Bool = false
    
    // Preloaded audio players for smooth playback
    private var preloadedVoicePlayers: [String: AVAudioPlayer] = [:]
    private var preloadedCountingPlayers: [String: AVAudioPlayer] = [:]
    private var preloadedPingPlayers: [String: AVAudioPlayer] = [:]

    init() {
        setupAudioSession()
        preloadAudioFiles()
    }
    
    // MARK: - Helper Methods
    
    private func findAudioFile(named fileName: String) -> URL? {
        // Try MP3 first, then WAV in main directory
        if let mp3URL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            return mp3URL
        } else if let wavURL = Bundle.main.url(forResource: fileName, withExtension: "wav") {
            return wavURL
        }
        
        // Try in subdirectories for premium voices
        let subdirectories = ["Female Calm", "Female Whisper", "Male Deep"]
        for subdirectory in subdirectories {
            if let mp3URL = Bundle.main.url(forResource: fileName, withExtension: "mp3", subdirectory: "Sounds/\(subdirectory)") {
                return mp3URL
            }
            if let wavURL = Bundle.main.url(forResource: fileName, withExtension: "wav", subdirectory: "Sounds/\(subdirectory)") {
                return wavURL
            }
        }
        
        return nil
    }
    
    /// Preloads all voice guidance and counting audio files for smooth playback
    private func preloadAudioFiles() {
        print("🎵 AudioManager - Preloading audio files...")
        
        // Preload basic voice files
        let voiceFiles = ["inhale", "hold", "exhale"]
        for fileName in voiceFiles {
            if let url = findAudioFile(named: fileName) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.volume = 0.8
                    player.prepareToPlay()
                    preloadedVoicePlayers[fileName] = player
                    print("✅ Preloaded voice file: \(fileName)")
                } catch {
                    print("❌ Failed to preload voice file \(fileName): \(error.localizedDescription)")
                }
            }
        }
        
        // Preload premium voice files
        let voicePrefixes = ["female_calm_", "male_deep_", "female_whisper_"]
        let voiceActions = ["inhale", "hold", "exhale"]
        for prefix in voicePrefixes {
            for action in voiceActions {
                let fileName = prefix + action
                if let url = findAudioFile(named: fileName) {
                    do {
                        let player = try AVAudioPlayer(contentsOf: url)
                        player.volume = 0.8
                        player.prepareToPlay()
                        preloadedVoicePlayers[fileName] = player
                        print("✅ Preloaded premium voice file: \(fileName)")
                    } catch {
                        print("❌ Failed to preload premium voice file \(fileName): \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // Preload counting files (default)
        let countingFiles = ["two", "three", "four", "five", "six", "seven", "eight"]
        for fileName in countingFiles {
            if let url = findAudioFile(named: fileName) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.volume = 0.8
                    player.prepareToPlay()
                    preloadedCountingPlayers[fileName] = player
                    print("✅ Preloaded counting file: \(fileName)")
                } catch {
                    print("❌ Failed to preload counting file \(fileName): \(error.localizedDescription)")
                }
            }
        }
        
        // Preload voice-specific counting files for premium voices
        for prefix in voicePrefixes {
            for countFile in countingFiles {
                let fileName = prefix + countFile
                if let url = findAudioFile(named: fileName) {
                    do {
                        let player = try AVAudioPlayer(contentsOf: url)
                        player.volume = 0.8
                        player.prepareToPlay()
                        preloadedCountingPlayers[fileName] = player
                        print("✅ Preloaded premium counting file: \(fileName)")
                    } catch {
                        print("❌ Failed to preload premium counting file \(fileName): \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // Preload ping files for drum guidance
        let pingFiles = ["ping", "ping_between"]
        for fileName in pingFiles {
            if let url = findAudioFile(named: fileName) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.volume = 0.8
                    player.prepareToPlay()
                    preloadedPingPlayers[fileName] = player
                    print("✅ Preloaded ping file: \(fileName)")
                } catch {
                    print("❌ Failed to preload ping file \(fileName): \(error.localizedDescription)")
                }
            }
        }
        
        print("🎵 AudioManager - Audio preloading completed!")
    }
    
    // MARK: - Background Audio Management
    
    func playBackgroundAudio(sound: BackgroundSoundOption, isEnabled: Bool) {
        guard isEnabled else {
            stopBackgroundAudio()
            return
        }
        
        // If we're already playing the same sound, don't restart
        if currentBackgroundSound == sound && backgroundPlayer?.isPlaying == true {
            print("🎵 AudioManager - Background audio already playing: \(sound.fileName ?? "silence")")
            return
        }
        
        stopBackgroundAudio()
        
        guard let fileName = sound.fileName else {
            // Silence option - just stop any current audio
            print("🎵 AudioManager - Selected silence for background")
            return
        }
        
        guard let audioURL = findAudioFile(named: fileName) else {
            print("❌ AudioManager - Could not find background audio \(fileName).mp3 or \(fileName).wav in the bundle.")
            return
        }
        
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: audioURL)
            backgroundPlayer?.numberOfLoops = -1 // Loop infinitely
            backgroundPlayer?.volume = 0
            backgroundPlayer?.prepareToPlay()
            backgroundPlayer?.play()
            
            // Set lower background volume to ensure voice guidance is clear
            backgroundPlayer?.setVolume(0.25, fadeDuration: 2.0) // Reduced from 0.4 to 0.25
            currentBackgroundSound = sound
            print("🎵 AudioManager - Started background audio: \(fileName) with infinite loop")
        } catch {
            print("❌ AudioManager - Could not create background audio player: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundAudio() {
        guard let player = backgroundPlayer, player.isPlaying else { 
            print("🎵 AudioManager - No background audio to stop")
            return 
        }

        print("🎵 AudioManager - Stopping background audio: \(currentBackgroundSound?.fileName ?? "unknown")")
        player.setVolume(0, fadeDuration: 1.5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if player.volume < 0.01 {
                player.stop()
                print("🎵 AudioManager - Background audio stopped")
            }
        }
        
        currentBackgroundSound = nil
        stopVoiceCounting() // Stop voice counting when stopping background audio
    }
    
    // MARK: - Voice Guidance
    
    func playGuideSound(for phase: BreathingPhase, option: AudioGuideOption, voice: VoiceOption) {
        guard option != .none else { return }
        
        let fileName: String
        
        switch option {
        case .voice:
            fileName = phase.voiceFileName(for: voice)
            print("🎵 AudioManager - Playing voice guide: \(fileName) for phase: \(phase) with voice: \(voice.displayName)")
            playPreloadedVoiceFile(named: fileName, fallbackVoice: voice)
        case .ping:
            fileName = "ping"
            print("🥁 AudioManager - Playing ping for phase: \(phase)")
            playPreloadedPingFile(named: fileName)
        case .none:
            return
        }
    }
    
    /// Plays a preloaded voice file with fallback support
    private func playPreloadedVoiceFile(named fileName: String, fallbackVoice: VoiceOption) {
        // Stop current voice player if playing
        voicePlayer?.stop()
        
        // Try to use preloaded player first
        if let preloadedPlayer = preloadedVoicePlayers[fileName] {
            preloadedPlayer.stop()
            preloadedPlayer.currentTime = 0
            preloadedPlayer.play()
            print("🎵 AudioManager - Playing preloaded voice: \(fileName)")
            return
        }
        
        // Fallback to default voice if premium voice file is missing
        if fallbackVoice != .defaultVoice {
            // Extract the phase from the filename (e.g., "inhale" from "female_calm_inhale")
            let components = fileName.components(separatedBy: "_")
            let phase = components.last ?? "inhale"
            let fallbackFileName = phase // Default voice files don't have prefix
            
            if let preloadedFallback = preloadedVoicePlayers[fallbackFileName] {
                preloadedFallback.stop()
                preloadedFallback.currentTime = 0
                preloadedFallback.play()
                print("🔄 AudioManager - Playing preloaded fallback: \(fallbackFileName)")
                return
            }
        }
        
        // Last resort: load from file (shouldn't happen if preloading worked)
        print("⚠️ AudioManager - Preloaded file not found, loading from disk: \(fileName)")
        guard let soundURL = findAudioFile(named: fileName) else {
            print("❌ AudioManager - Could not find \(fileName).mp3 or \(fileName).wav")
            return
        }
        playAudioFile(at: soundURL)
    }
    
    /// Plays a preloaded ping file for drum guidance
    private func playPreloadedPingFile(named fileName: String) {
        // Stop current voice player if playing
        voicePlayer?.stop()
        
        // Try to use preloaded ping player
        if let preloadedPlayer = preloadedPingPlayers[fileName] {
            preloadedPlayer.stop()
            preloadedPlayer.currentTime = 0
            preloadedPlayer.play()
            print("🥁 AudioManager - Playing preloaded ping: \(fileName)")
            return
        }
        
        // Last resort: load from file (shouldn't happen if preloading worked)
        print("⚠️ AudioManager - Preloaded ping file not found, loading from disk: \(fileName)")
        guard let soundURL = findAudioFile(named: fileName) else {
            print("❌ AudioManager - Could not find ping \(fileName).mp3 or \(fileName).wav")
            return
        }
        playAudioFile(at: soundURL)
    }

    /// Starts voice counting for a breathing phase with specified duration
    func startVoiceCountingForPhase(_ phase: BreathingPhase, phaseDuration: Double, voice: VoiceOption) {
        stopVoiceCounting()
        isVoiceCountingEnabled = true
        currentPhaseStartTime = Date()
        
        print("🔢 AudioManager - Starting voice counting for \(phase) with duration \(phaseDuration)s using voice: \(voice.displayName)")
        
        // Skip counting for very short phases (less than 1 second)
        guard phaseDuration >= 1.0 else { 
            print("🔢 AudioManager - Phase too short (\(phaseDuration)s) for counting")
            return 
        }
        
        // For phases that are exactly 1 second, only play the phase instruction
        guard phaseDuration > 1.0 else {
            print("🔢 AudioManager - Phase duration is 1 second, only phase instruction will play")
            return
        }
        
        // Add a tiny delay since we now use preloaded players
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self, self.isVoiceCountingEnabled else { return }
            
            // Schedule counting sounds at 1-second intervals starting immediately
            self.countingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self,
                      let startTime = self.currentPhaseStartTime,
                      self.isVoiceCountingEnabled else {
                    timer.invalidate()
                    return
                }
                
                let elapsed = Date().timeIntervalSince(startTime)
                let secondsElapsed = Int(floor(elapsed))
                let countNumber = secondsElapsed + 1 // Count up: 1, 2, 3, 4, 5, 6, 7, 8
                
                // Play counting sounds for the duration of the phase
                if countNumber <= Int(phaseDuration) {
                    print("🔢 AudioManager - Playing count: \(countNumber) at \(elapsed)s elapsed")
                    self.playCountingSound(for: countNumber, voice: voice)
                }
                
                // Stop counting when phase duration is reached
                if elapsed >= phaseDuration {
                    print("🔢 AudioManager - Phase duration reached, stopping counting")
                    timer.invalidate()
                    self.countingTimer = nil
                }
            }
            
            // Fire the timer immediately for count "1" (but skip since it's the phase instruction)
            self.countingTimer?.fire()
        }
    }
    
    /// Stops voice counting
    func stopVoiceCounting() {
        isVoiceCountingEnabled = false
        countingTimer?.invalidate()
        countingTimer = nil
        currentPhaseStartTime = nil
    }
    
    /// Starts ping counting for a breathing phase with specified duration
    func startPingCountingForPhase(_ phase: BreathingPhase, phaseDuration: Double) {
        stopVoiceCounting()
        isVoiceCountingEnabled = true
        currentPhaseStartTime = Date()
        
        print("🥁 AudioManager - Starting ping counting for \(phase) with duration \(phaseDuration)s")
        
        // Skip counting for very short phases (less than 1 second)
        guard phaseDuration >= 1.0 else { 
            print("🥁 AudioManager - Phase too short (\(phaseDuration)s) for ping counting")
            return 
        }
        
        // For phases that are exactly 1 second, only play the phase instruction
        guard phaseDuration > 1.0 else {
            print("🥁 AudioManager - Phase duration is 1 second, only ping instruction will play")
            return
        }
        
        // Add a tiny delay since we now use preloaded players
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self, self.isVoiceCountingEnabled else { return }
            
            // Schedule ping sounds at 1-second intervals starting immediately
            self.countingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self,
                      let startTime = self.currentPhaseStartTime,
                      self.isVoiceCountingEnabled else {
                    timer.invalidate()
                    return
                }
                
                let elapsed = Date().timeIntervalSince(startTime)
                let secondsElapsed = Int(floor(elapsed))
                let countNumber = secondsElapsed + 1 // Count up: 1, 2, 3, 4, 5, 6, 7, 8
                
                // Play ping_between sounds for the duration of the phase (except for count 1)
                if countNumber > 1 && countNumber <= Int(phaseDuration) {
                    print("🥁 AudioManager - Playing ping_between count: \(countNumber) at \(elapsed)s elapsed")
                    self.playPingBetween()
                }
                
                // Stop counting when phase duration is reached
                if elapsed >= phaseDuration {
                    print("🥁 AudioManager - Phase duration reached, stopping ping counting")
                    timer.invalidate()
                    self.countingTimer = nil
                }
            }
            
            // Fire the timer immediately for count "1" (but skip since it's the phase instruction)
            self.countingTimer?.fire()
        }
    }
    
    /// Plays the ping_between sound for counting
    private func playPingBetween() {
        // Try to use preloaded ping_between player
        if let preloadedPlayer = preloadedPingPlayers["ping_between"] {
            preloadedPlayer.stop()
            preloadedPlayer.currentTime = 0
            preloadedPlayer.play()
            print("🥁 AudioManager - Playing preloaded ping_between")
            return
        }
        
        // Last resort: load from file (shouldn't happen if preloading worked)
        print("⚠️ AudioManager - Preloaded ping_between file not found, loading from disk")
        guard let soundURL = findAudioFile(named: "ping_between") else {
            print("❌ AudioManager - Could not find ping_between.mp3 or ping_between.wav")
            return
        }
        
        do {
            countingPlayer = try AVAudioPlayer(contentsOf: soundURL)
            countingPlayer?.volume = 0.8
            countingPlayer?.play()
        } catch {
            print("❌ AudioManager - Error playing ping_between audio: \(error.localizedDescription)")
        }
    }
    
    /// Plays the counting sound for a specific number using the specified voice
    private func playCountingSound(for number: Int, voice: VoiceOption) {
        guard number > 1 else {
            // For count "1", we don't play anything since the phase instruction already played
            return
        }
        
        let baseCountName: String
        switch number {
        case 2:
            baseCountName = "two"
        case 3:
            baseCountName = "three"
        case 4:
            baseCountName = "four"
        case 5:
            baseCountName = "five"
        case 6:
            baseCountName = "six"
        case 7:
            baseCountName = "seven"
        case 8:
            baseCountName = "eight"
        default:
            // For numbers beyond 8, don't play anything
            return
        }
        
        // Try voice-specific counting file first (for premium voices)
        let voiceSpecificFileName = voice.filePrefix + baseCountName
        if let preloadedPlayer = preloadedCountingPlayers[voiceSpecificFileName] {
            preloadedPlayer.stop()
            preloadedPlayer.currentTime = 0
            preloadedPlayer.play()
            print("🔢 AudioManager - Playing preloaded voice-specific counting sound: \(voiceSpecificFileName)")
            return
        }
        
        // Fallback to default counting file
        if let preloadedPlayer = preloadedCountingPlayers[baseCountName] {
            preloadedPlayer.stop()
            preloadedPlayer.currentTime = 0
            preloadedPlayer.play()
            print("🔢 AudioManager - Playing preloaded default counting sound: \(baseCountName)")
            return
        }
        
        // Last resort: load from file (shouldn't happen if preloading worked)
        print("⚠️ AudioManager - Preloaded counting file not found, loading from disk: \(baseCountName)")
        guard let soundURL = findAudioFile(named: baseCountName) else {
            print("❌ AudioManager - Could not find counting file \(baseCountName).mp3 or \(baseCountName).wav in the bundle.")
            return
        }
        
        playCountingAudioFile(at: soundURL)
    }
    
    private func playCountingAudioFile(at url: URL) {
        do {
            // Stop current counting player if playing
            countingPlayer?.stop()
            
            countingPlayer = try AVAudioPlayer(contentsOf: url)
            countingPlayer?.volume = 0.8
            countingPlayer?.prepareToPlay() // Prepare for smoother playback
            countingPlayer?.play()
        } catch {
            print("❌ AudioManager - Could not create counting player: \(error.localizedDescription)")
        }
    }
    
    private func playAudioFile(at url: URL) {
        do {
            // Stop current voice player if playing
            voicePlayer?.stop()
            
            voicePlayer = try AVAudioPlayer(contentsOf: url)
            voicePlayer?.volume = 0.8
            voicePlayer?.prepareToPlay() // Prepare for smoother playback
            voicePlayer?.play()
            print("🎵 AudioManager - Voice player started for: \(url.lastPathComponent)")
        } catch {
            print("❌ AudioManager - Could not create voice player: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        do {
            // Using .duckOthers allows the background music to automatically lower its volume
            // when the voice cue plays, making the instruction clearer.
            // .mixWithOthers allows background audio to continue playing with other apps
            try AVAudioSession.sharedInstance().setCategory(
                .playback, 
                mode: .default, 
                options: [.duckOthers, .mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            print("🎵 AudioManager - Audio session configured for background mixing and voice ducking")
        } catch {
            print("❌ AudioManager - Failed to set up audio session: \(error.localizedDescription)")
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

extension AudioManager {
    static let shared = AudioManager()
}
