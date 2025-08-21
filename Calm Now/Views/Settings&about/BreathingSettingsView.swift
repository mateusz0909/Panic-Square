//
//  BreathingSettingsView.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 18/08/2025.
//

import SwiftUI

struct BreathingSettingsView: View {
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
                    breathingPatternSection
                    sessionLengthSection
                    premiumSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Breathing Settings")
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
                print("🛒 BreathingSettingsView - Purchase completed, refreshing subscription status")
                // Refresh subscription status after purchase
                Task {
                    await StoreKitManager.shared.loadProducts()
                    print("🛒 BreathingSettingsView - Products reloaded, checking subscription status")
                    print("🛒 BreathingSettingsView - hasPremiumAccess after purchase: \(subscriptionManager.hasPremiumAccess)")
                }
            }
        }
    }
    
    // MARK: - Breathing Pattern Section
    
    private var breathingPatternSection: some View {
        Section("Breathing Patterns") {
            ForEach(BreathingPattern.allPatterns, id: \.id) { pattern in
                BreathingPatternRow(
                    pattern: pattern,
                    isSelected: settingsManager.breathingPattern.id == pattern.id,
                    canUse: subscriptionManager.canUseBreathingPattern(pattern)
                ) {
                    if subscriptionManager.canUseBreathingPattern(pattern) {
                        print("🎯 BreathingSettingsView - User can use pattern: \(pattern.name)")
                        settingsManager.breathingPattern = pattern
                    } else {
                        print("🎯 BreathingSettingsView - Pattern is premium: \(pattern.name)")
                        print("🎯 BreathingSettingsView - Showing local paywall for pattern: \(pattern.name)")
                        // Show paywall for premium patterns
                        showingPaywall = true
                    }
                }
            }
        }
    }
    
    // MARK: - Session Length Section
    
    private var sessionLengthSection: some View {
        Section("Session Length") {
            ForEach(SessionLength.allCases, id: \.id) { length in
                SessionLengthRow(
                    sessionLength: length,
                    isSelected: settingsManager.sessionLength == length,
                    canUse: subscriptionManager.canUseSessionLength(length)
                ) {
                    if subscriptionManager.canUseSessionLength(length) {
                        settingsManager.sessionLength = length
                    } else {
                        // Show paywall for premium session lengths
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
                        Text("Unlock Premium Patterns")
                            .font(.headline)
                    }
                    
                    Text("Get access to custom breathing patterns and session timers")
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

// MARK: - Breathing Pattern Row

struct BreathingPatternRow: View {
    let pattern: BreathingPattern
    let isSelected: Bool
    let canUse: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(pattern.name)
                        .font(.headline)
                        .foregroundColor(canUse ? .primary : .secondary)
                    
                    Text(pattern.timingDisplay)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color("SquareColor").opacity(0.2))
                        .cornerRadius(4)
                }
                
                Text(pattern.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if pattern.isPremium && !canUse {
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
                Image(systemName: "checkmark.circle.fill")
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

// MARK: - Session Length Row

struct SessionLengthRow: View {
    let sessionLength: SessionLength
    let isSelected: Bool
    let canUse: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: sessionLength.iconName)
                .foregroundColor(Color("SquareColor"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(sessionLength.displayName)
                    .foregroundColor(canUse ? .primary : .secondary)
                
                if sessionLength.isPremium && !canUse {
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
    BreathingSettingsView()
}
