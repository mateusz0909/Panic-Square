//
//  PremiumPreviewView.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 18/08/2025.
//

import SwiftUI

struct PremiumPreviewView: View {
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        breathingPatternsSection
                        voicesSection
                        natureSoundsSection
                        benefitsSection
                        ctaSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Premium Audio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Premium Audio Experience")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Elevate your breathing practice with premium voices and nature sounds")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var breathingPatternsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Premium Breathing Patterns", systemImage: "timer")
                .font(.headline)
                .foregroundColor(Color("SquareColor"))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(BreathingPattern.allPatterns.filter(\.isPremium).prefix(4), id: \.id) { pattern in
                    VStack {
                        Image(systemName: "square.dashed")
                            .font(.title2)
                            .foregroundColor(Color("SquareColor"))
                        Text(pattern.name)
                            .font(.caption)
                            .fontWeight(.medium)
                        Text(pattern.timingDisplay)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("SquareColor").opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var voicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Premium Voices", systemImage: "person.wave.2")
                .font(.headline)
                .foregroundColor(Color("SquareColor"))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(VoiceOption.allCases.filter(\.isPremium), id: \.self) { voice in
                    VStack {
                        Image(systemName: "waveform.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color("SquareColor"))
                        Text(voice.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("SquareColor").opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var natureSoundsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Nature Sounds", systemImage: "leaf")
                .font(.headline)
                .foregroundColor(Color("SquareColor"))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(BackgroundSoundOption.allCases.filter(\.isPremium), id: \.self) { sound in
                    VStack {
                        Image(systemName: sound.iconName)
                            .font(.title2)
                            .foregroundColor(Color("SquareColor"))
                        Text(sound.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("SquareColor").opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Premium Benefits", systemImage: "star.fill")
                .font(.headline)
                .foregroundColor(Color("SquareColor"))
            
            VStack(alignment: .leading, spacing: 6) {
                BenefitRow(text: "6 custom breathing patterns (3-3-3-3, 5-5-5-5, 4-7-8, etc.)")
                BenefitRow(text: "Session length customization (1-30 minutes)")
                BenefitRow(text: "3 additional premium voice options")
                BenefitRow(text: "4 immersive nature soundscapes")
                BenefitRow(text: "Enhanced audio quality")
                BenefitRow(text: "Session tracking and progress")
            }
        }
    }
    
    private var ctaSection: some View {
        VStack(spacing: 16) {
            if subscriptionManager.hasPremiumAccess {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                    Text("Premium Active")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Button("Disable Premium (Test)") {
                        subscriptionManager.togglePremiumStatus()
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                VStack(spacing: 12) {
                    Button("Unlock Premium Audio") {
                        subscriptionManager.togglePremiumStatus()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Text("$2.99/month • Cancel anytime")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.top)
    }
}

struct BenefitRow: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            Text(text)
                .font(.caption)
            Spacer()
        }
    }
}

#Preview {
    PremiumPreviewView()
}
