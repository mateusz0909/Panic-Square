//
//  WelcomeView.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 19/08/2025.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject private var settingsManager = SettingsManager.shared
    let onStartTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Welcome header
            VStack(spacing: 12) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.9))
                    .symbolEffect(.pulse.byLayer, options: .speed(0.5).repeat(.continuous))
                
                Text("Welcome to Breathe Easy")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                    .padding(.horizontal, 20)
            }
            
            // Main message
            VStack(spacing: 16) {
                Text("Take a moment to find your calm")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 24)
                
                Text("Breathe Easy guides you through proven breathing techniques that help reduce stress, ease anxiety, and bring peace to your mind.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 32)
            }
            
            // Current pattern info
            VStack(spacing: 12) {
                Text("Ready to begin?")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                // Pattern preview card
                VStack(spacing: 8) {
                    Text(settingsManager.breathingPattern.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(settingsManager.breathingPattern.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                   
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .opacity(0.2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
            }
            .padding(.horizontal, 32)
            
            // Call to action
            VStack(spacing: 12) {
                Button(action: onStartTapped) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.title3)
                        Text("Start Breathing")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.25),
                                .white.opacity(0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.1), value: false)
                
                Text("Tap to begin your journey to inner peace")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            Spacer() // Extra spacer for home indicator area
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ZStack {
        Color("BackgroundColor")
            .ignoresSafeArea()
        
        WelcomeView {
            print("Start tapped")
        }
    }
}
