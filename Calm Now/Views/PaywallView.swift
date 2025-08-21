//
//  PaywallView.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 19/08/2025.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var storeKitManager = StoreKitManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    
    let onPurchaseComplete: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        headerSection
                        
                        // Features
                        featuresSection
                        
                        // Products
                        if storeKitManager.isLoading {
                            loadingSection
                        } else {
                            productsSection
                        }
                        
                        // Footer
                        footerSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .preferredColorScheme(.dark)
        }
        .task {
            await storeKitManager.loadProducts()
        }
        .alert("Error", isPresented: .constant(storeKitManager.errorMessage != nil)) {
            Button("OK") {
                storeKitManager.errorMessage = nil
            }
        } message: {
            if let errorMessage = storeKitManager.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .symbolEffect(.pulse, options: .speed(0.5).repeat(.continuous))
            
            Text("Unlock Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Experience the full power of Breathe Easy")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    private var featuresSection: some View {
        VStack(spacing: 20) {
            Text("Premium Features")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                FeatureRow(
                    icon: "waveform.path",
                    title: "Multiple Voice Guides",
                    description: "Choose from different calming voices"
                )
                
                FeatureRow(
                    icon: "music.note",
                    title: "Nature Sounds",
                    description: "Rain, ocean waves, forest sounds & more"
                )
                
                FeatureRow(
                    icon: "timer",
                    title: "Custom Breathing Patterns",
                    description: "Advanced techniques for deeper relaxation"
                )
                
                FeatureRow(
                    icon: "clock",
                    title: "Custom Session Lengths",
                    description: "Personalize your breathing sessions"
                )
                
                FeatureRow(
                    icon: "heart.fill",
                    title: "Ad-Free Experience",
                    description: "Uninterrupted mindfulness sessions"
                )
            }
        }
    }
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.2)
            
            Text("Loading subscription options...")
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(height: 100)
    }
    
    private var productsSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            ForEach(storeKitManager.products, id: \.id) { product in
                ProductCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    onTap: {
                        selectedProduct = product
                    }
                )
            }
            
            // Purchase Button
            if let selectedProduct = selectedProduct {
                Button(action: {
                    Task {
                        print("🛒 PaywallView - Starting purchase for: \(selectedProduct.displayName)")
                        let success = await storeKitManager.purchase(selectedProduct)
                        print("🛒 PaywallView - Purchase result: \(success)")
                        if success {
                            print("🛒 PaywallView - Purchase successful, calling onPurchaseComplete")
                            onPurchaseComplete()
                            
                            // Give StoreKit time to process the subscription status
                            print("🛒 PaywallView - Waiting 2 seconds for StoreKit to update...")
                            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                            
                            print("🛒 PaywallView - Dismissing paywall")
                            dismiss()
                        }
                    }
                }) {
                    HStack {
                        if storeKitManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "crown.fill")
                        }
                        
                        Text("Upgrade to Premium")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [.yellow.opacity(0.8), .orange.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .yellow.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(storeKitManager.isLoading)
            }
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: 16) {
            Button("Restore Purchases") {
                Task {
                    await storeKitManager.restorePurchases()
                }
            }
            .foregroundColor(.white.opacity(0.7))
            .disabled(storeKitManager.isLoading)
            
            VStack(spacing: 8) {
                Text("Subscriptions auto-renew unless cancelled 24 hours before the end of the current period.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    Button("Terms of Service") {
                        // Open terms URL
                    }
                    
                    Button("Privacy Policy") {
                        // Open privacy URL  
                    }
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.yellow)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(productTitle)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(productSubtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(product.displayPrice)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if let subscription = product.subscription {
                            Text("per \(subscription.subscriptionPeriod.localizedDescription)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                if isPopular {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Most Popular")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                        Spacer()
                    }
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? .yellow : .white.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var productTitle: String {
        switch product.id {
        case "breatheeasy_premium_yearly":
            return "Yearly Premium"
        case "breatheeasy_premium_monthly":
            return "Monthly Premium"
        case "breatheeasy_lifetime":
            return "Lifetime Premium"
        default:
            return product.displayName
        }
    }
    
    private var productSubtitle: String {
        switch product.id {
        case "breatheeasy_premium_yearly":
            return "Best value • 2 months free"
        case "breatheeasy_premium_monthly":
            return "Cancel anytime"
        case "breatheeasy_lifetime":
            return "One-time purchase"
        default:
            return product.description
        }
    }
    
    private var isPopular: Bool {
        return product.id == "breatheeasy_premium_yearly"
    }
}

// MARK: - SubscriptionPeriod Extension
extension Product.SubscriptionPeriod {
    var localizedDescription: String {
        switch unit {
        case .day:
            return value == 1 ? "day" : "\(value) days"
        case .week:
            return value == 1 ? "week" : "\(value) weeks"
        case .month:
            return value == 1 ? "month" : "\(value) months"
        case .year:
            return value == 1 ? "year" : "\(value) years"
        @unknown default:
            return "period"
        }
    }
}

#Preview {
    PaywallView {
        print("Purchase completed")
    }
}
