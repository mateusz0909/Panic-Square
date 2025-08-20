//
//  AboutView.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 05/08/2025.
//


// Create this new file: AboutView.swift

import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            // Match the main app background with gradient
            LinearGradient(
                colors: [
                    Color("BackgroundColor"),
                    Color("BackgroundColor").opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    InfoSection(
                        title: "How to Use",
                        content: "Tap 'Start' to begin. The app will guide you through a 4-second cycle: Inhale, hold, exhale, hold. Tap 'Stop' at any time."
                    )
                    
                    InfoSection(
                        title: "Why Box Breathing?",
                        content: "This technique activates your body's relaxation response. It can lower your heart rate, decrease blood pressure, and sharpen your focus by regulating your autonomic nervous system."
                    )
                    
                    InfoSection(
                        title: "When to Use It",
                        content: "Use Breathe Easy to manage anxiety, stress, or panic. It's also a powerful tool for daily mindfulness practice or to calm your mind before a stressful event."
                    )
                }
                .padding(24)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A helper view to create consistently styled sections for informational text.
struct InfoSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(content)
                .font(.body)
                .lineSpacing(4)
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(20)
        .background(
            ZStack {
                // Glass effect background - reduced opacity
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.15)
                
                // Additional glass layer for better effect - reduced opacity
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.05),
                                .white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.15),
                            .white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
