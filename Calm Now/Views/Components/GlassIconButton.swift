//
//  GlassIconButton.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 05/08/2025.
//


//
//  GlassIconButton.swift
//  BreatheEasy
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct GlassIconButton: View {
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                // The core glass effect
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                // The subtle border
                .overlay(
                    Circle()
                        .stroke(LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        ), lineWidth: 1)
                )
        }
    }
}