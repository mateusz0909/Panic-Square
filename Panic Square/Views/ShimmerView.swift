//
//  ShimmerView.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 01/08/2025.
//


//
//  ShimmerView.swift
//  BreatheEasy
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct ShimmerView: View {
    @State private var animate = false
    
    // The gradient for our light source. It's a soft, slightly off-white that fades to clear.
    private let gradient = Gradient(colors: [
        .white.opacity(0.25),
        .clear,
        .clear
    ])
    
    var body: some View {
        // We use an EllipticalGradient for a more organic, oblong light shape.
        EllipticalGradient(gradient: gradient, center: .center)
            // Scale it up significantly so the edges are far off-screen.
            .scaleEffect(3)
            // Use a large blur to make the light incredibly soft and ethereal.
            .blur(radius: 100)
            // Animate its position by moving it from one corner to the opposite.
            .offset(x: animate ? 400 : -400, y: animate ? 400 : -400)
            .ignoresSafeArea()
            .onAppear {
                // Use a long, smooth animation that repeats and reverses forever.
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    animate.toggle()
                }
            }
    }
}

#Preview {
    ZStack {
        // Preview the shimmer on top of a dark background
        Color(.background).ignoresSafeArea()
        ShimmerView()
    }
}
