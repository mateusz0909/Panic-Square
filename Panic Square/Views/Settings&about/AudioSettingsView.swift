//
//  AudioSettingsView.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 18/08/2025.
//

import SwiftUI

struct AudioSettingsView: View {
    @ObservedObject private var settingsManager = SettingsManager.shared
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                List {
                    audioGuideSection
                    voiceSelectionSection
                    backgroundSoundSection
                    premiumSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Audio Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView {
                print("🛒 AudioSettingsView - Purchase completed, refreshing subscription status")
                // Refresh subscription status after purchase
                Task {
                    await StoreKitManager.shared.loadProducts()
                    print("🛒 AudioSettingsView - Products reloaded, checking subscription status")
                    print("🛒 AudioSettingsView - hasPremiumAccess after purchase: \(subscriptionManager.hasPremiumAccess)")
                }
            }
        }
    }
    
    // MARK: - Audio Guide Section
    
    private var audioGuideSection: some View {
        Section("Guidance Style") {
            ForEach(AudioGuideOption.allCases, id: \.self) { option in
                HStack {
                    Image(systemName: option.iconName)
                        .foregroundColor(Color("SquareColor"))
                        .frame(width: 24)
                    
                    Text(option.title)
                    
                    Spacer()
                    
                    if settingsManager.audioGuideOption == option {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    settingsManager.audioGuideOption = option
                }
            }
        }
    }
    
    // MARK: - Voice Selection Section
    
    private var voiceSelectionSection: some View {
        Section("Voice Options") {
            ForEach(VoiceOption.allCases, id: \.self) { voice in
                VoiceOptionRow(
                    voice: voice,
                    isSelected: settingsManager.selectedVoice == voice,
                    canUse: subscriptionManager.canUseVoice(voice)
                ) {
                    if subscriptionManager.canUseVoice(voice) {
                        settingsManager.selectedVoice = voice
                    } else {
                        // Show paywall for premium voices
                        showingPaywall = true
                    }
                }
            }
        }
        .disabled(settingsManager.audioGuideOption != .voice)
        .opacity(settingsManager.audioGuideOption != .voice ? 0.5 : 1.0)
    }
    
    // MARK: - Background Sound Section
    
    private var backgroundSoundSection: some View {
        Section("Background Sounds") {
            ForEach(BackgroundSoundOption.allCases, id: \.self) { sound in
                BackgroundSoundRow(
                    sound: sound,
                    isSelected: settingsManager.backgroundSound == sound,
                    canUse: subscriptionManager.canUseBackgroundSound(sound)
                ) {
                    if subscriptionManager.canUseBackgroundSound(sound) {
                        settingsManager.backgroundSound = sound
                    } else {
                        // Show paywall for premium background sounds
                        showingPaywall = true
                    }
                }
            }
        }
    }
    
    // MARK: - Premium Section
    
    private var premiumSection: some View {
        Section {
            if subscriptionManager.hasPremiumAccess {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text("Premium Active")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Test Mode") {
                        subscriptionManager.togglePremiumStatus()
                    }
                    .font(.caption)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundColor(.yellow)
                        Text("Unlock Premium Audio")
                            .font(.headline)
                    }
                    
                    Text("Get access to multiple voices and nature sounds")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Upgrade to Premium") {
                        showingPaywall = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Voice Option Row

struct VoiceOptionRow: View {
    let voice: VoiceOption
    let isSelected: Bool
    let canUse: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(voice.displayName)
                    .foregroundColor(canUse ? .primary : .secondary)
                
                if voice.isPremium && !canUse {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                        Text("Premium")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if isSelected && canUse {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            } else if !canUse {
                Image(systemName: "lock.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
        .opacity(canUse ? 1.0 : 0.6)
    }
}

// MARK: - Background Sound Row

struct BackgroundSoundRow: View {
    let sound: BackgroundSoundOption
    let isSelected: Bool
    let canUse: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: sound.iconName)
                .foregroundColor(Color("SquareColor"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(sound.displayName)
                    .foregroundColor(canUse ? .primary : .secondary)
                
                if sound.isPremium && !canUse {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                        Text("Premium")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if isSelected && canUse {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            } else if !canUse {
                Image(systemName: "lock.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
        .opacity(canUse ? 1.0 : 0.6)
    }
}

#Preview {
    AudioSettingsView()
}
