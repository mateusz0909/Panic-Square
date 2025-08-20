//
//  SubscriptionManager.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 18/08/2025.
//

import Foundation

/// Manages subscription status and premium feature access
/// This now integrates with StoreKit for production-ready subscription management
@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var isPremiumUser: Bool = false
    
    private let storeKitManager = StoreKitManager.shared
    
    private init() {
        #if DEBUG
        // Clear ALL potential debug overrides on startup for clean testing
        UserDefaults.standard.removeObject(forKey: "isPremiumUser_debug")
        UserDefaults.standard.removeObject(forKey: "isPremiumUser") // Old key
        UserDefaults.standard.synchronize()
        print("🧹 SubscriptionManager - Cleared ALL debug overrides for clean testing")
        #endif
        
        // Ensure we start with false
        isPremiumUser = false
        print("🔧 SubscriptionManager - Initialized with isPremiumUser: \(isPremiumUser)")
        
        // Update premium status initially
        updatePremiumStatus()
        
        // Set up observation of StoreKit changes
        setupStoreKitObservation()
        
        // Print initial status
        print("🔧 SubscriptionManager - Initial hasPremiumAccess: \(hasPremiumAccess)")
    }
    
    /// Check if user has access to premium features
    var hasPremiumAccess: Bool {
        #if DEBUG
        // In debug mode, allow manual override
        let debugOverride = UserDefaults.standard.bool(forKey: "isPremiumUser_debug")
        if debugOverride {
            print("🎯 SubscriptionManager - Debug override active: premium access granted")
            return true
        }
        #endif
        // Check StoreKit manager for actual subscription status
        let storeKitAccess = storeKitManager.hasPremiumAccess
        print("🎯 SubscriptionManager - StoreKit access: \(storeKitAccess)")
        return storeKitAccess
    }
    
    /// For development/testing - toggle premium status (only in debug builds)
    #if DEBUG
    func togglePremiumStatus() {
        isPremiumUser.toggle()
        UserDefaults.standard.set(isPremiumUser, forKey: "isPremiumUser_debug")
        print("🎯 SubscriptionManager - Debug premium status toggled to: \(isPremiumUser)")
    }
    
    func printSubscriptionDebugInfo() {
        print("=== SUBSCRIPTION DEBUG INFO ===")
        print("isPremiumUser: \(isPremiumUser)")
        print("storeKitManager.hasActiveSubscription: \(storeKitManager.hasActiveSubscription)")
        print("storeKitManager.purchasedProductIDs: \(storeKitManager.purchasedProductIDs)")
        print("hasPremiumAccess: \(hasPremiumAccess)")
        print("Debug override: \(UserDefaults.standard.bool(forKey: "isPremiumUser_debug"))")
        print("==============================")
    }
    #endif
    
    /// Present the paywall for premium upgrade
    func showPaywall() {
        print("🎯 SubscriptionManager - showPaywall() called")
        print("🎯 SubscriptionManager - Posting .showPaywall notification")
        // This will be called from the UI to show the paywall
        NotificationCenter.default.post(name: .showPaywall, object: nil)
        print("🎯 SubscriptionManager - Notification posted successfully")
    }
    
    /// Check if a voice option is available to current user
    func canUseVoice(_ voice: VoiceOption) -> Bool {
        return !voice.isPremium || hasPremiumAccess
    }
    
    /// Check if a background sound is available to current user
    func canUseBackgroundSound(_ sound: BackgroundSoundOption) -> Bool {
        return !sound.isPremium || hasPremiumAccess
    }
    
    /// Check if a breathing pattern is available to current user
    func canUseBreathingPattern(_ pattern: BreathingPattern) -> Bool {
        let canUse = !pattern.isPremium || hasPremiumAccess
        print("🎯 SubscriptionManager - canUseBreathingPattern(\(pattern.name)): isPremium=\(pattern.isPremium), hasPremiumAccess=\(hasPremiumAccess), result=\(canUse)")
        return canUse
    }
    
    /// Check if a session length is available to current user
    func canUseSessionLength(_ length: SessionLength) -> Bool {
        return !length.isPremium || hasPremiumAccess
    }
    
    // MARK: - Private Methods
    
    private func setupStoreKitObservation() {
        // Observe changes to subscription status
        Task { @MainActor in
            for await _ in storeKitManager.$hasActiveSubscription.values {
                updatePremiumStatus()
            }
        }
        
        // Observe changes to purchased products
        Task { @MainActor in
            for await _ in storeKitManager.$purchasedProductIDs.values {
                updatePremiumStatus()
            }
        }
    }
    
    private func updatePremiumStatus() {
        isPremiumUser = storeKitManager.hasPremiumAccess
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let showPaywall = Notification.Name("showPaywall")
}
