//
//  PremiumUpgradeButton.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 19/08/2025.
//

import SwiftUI

struct PremiumUpgradeButton: View {
    let title: String
    let subtitle: String?
    let action: () -> Void
    
    init(title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.caption)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [.yellow.opacity(0.6), .yellow.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color("BackgroundColor")
            .ignoresSafeArea()
        
        VStack(spacing: 16) {
            PremiumUpgradeButton(
                title: "Unlock Premium Features",
                subtitle: "Access all breathing patterns and sounds"
            ) {
                print("Upgrade tapped")
            }
            
            PremiumUpgradeButton(
                title: "Go Premium"
            ) {
                print("Upgrade tapped")
            }
        }
        .padding()
    }
}
