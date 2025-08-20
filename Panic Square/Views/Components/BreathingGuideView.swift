//
//  BreathingGuideView.swift
//  BreatheEasy
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct BreathingGuideView: View {
    @Binding var isAnimating: Bool
    let cornerRadius: CGFloat
    
    @State private var rotationAngle: Angle = .zero
    
    // --- THE KEY FIX: A Super-Sharp Gradient for a Circular Glow ---
    // This gradient is almost entirely clear, with just a tiny, sharp point of white.
    // When this point is blurred, it looks like a soft, glowing orb.
    private let guideGradient = AngularGradient(
        gradient: Gradient(stops: [
            .init(color: .clear, location: 0.0),
            .init(color: .clear, location: 0.499), // The end of the transparent section
            .init(color: .white, location: 0.5),   // A single, bright, infinitesimally small point of light
            .init(color: .clear, location: 0.501), // Immediately becomes transparent again
            .init(color: .clear, location: 1.0)
        ]),
        center: .center
    )
    
    var body: some View {
        // We apply this gradient to the stroke of the shape.
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(guideGradient, lineWidth: 8) // A thicker line gives the blur more to work with.
            // A strong blur transforms the sharp point into a soft "sun ball".
            .blur(radius: 20)
            .rotationEffect(rotationAngle)
            .opacity(isAnimating ? 1 : 0)
            .onChange(of: isAnimating) { _, shouldAnimate in
                if shouldAnimate {
                    withAnimation(.linear(duration: 16).repeatForever(autoreverses: false)) {
                        rotationAngle = .degrees(360)
                    }
                } else {
                    withAnimation(.spring()) {
                        rotationAngle = .zero
                    }
                }
            }
    }
}


