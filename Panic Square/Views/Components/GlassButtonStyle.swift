//
//  GlassButtonStyle.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 05/08/2025.
//


//
//  GlassButtonStyle.swift
//  BreatheEasy
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.title3, design: .rounded).bold())
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            // The core glass effect: a blurred, semi-transparent background
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            // Add a subtle border to define the edge of the glass
            .overlay(
                Capsule()
                    .stroke(LinearGradient(
                        colors: [.white.opacity(0.4), .white.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ), lineWidth: 1)
            )
            // Make the button feel interactive by scaling it down when pressed
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: configuration.isPressed)
    }
}