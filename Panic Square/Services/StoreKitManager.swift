//
//  StoreKitManager.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 19/08/2025.
//

import Foundation
import StoreKit
import SwiftUI

// MARK: - Custom StoreKit Errors
enum StoreKitManagerError: Error, LocalizedError {
    case failedVerification
    case purchaseFailed(String)
    case noProductsFound
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Purchase verification failed"
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .noProductsFound:
            return "No products found"
        }
    }
}

/// Production-ready StoreKit 2 manager for handling in-app purchases and subscriptions
@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    // MARK: - Published Properties
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    @Published private(set) var subscriptionStatuses: [Product.SubscriptionInfo.Status] = []
    @Published private(set) var hasActiveSubscription = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Product Identifiers
    private let productIdentifiers: Set<String> = [
        "breatheeasy_premium_monthly",
        "breatheeasy_premium_yearly",
        "breatheeasy_lifetime"
    ]
    
    // MARK: - Transaction Update Task
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        print("🔧 StoreKitManager - Initializing...")
        print("🔧 StoreKitManager - hasActiveSubscription: \(hasActiveSubscription)")
        print("🔧 StoreKitManager - purchasedProductIDs: \(purchasedProductIDs)")
        
        // Start listening for transaction updates
        updateListenerTask = listenForTransactionUpdates()
        
        print("🔧 StoreKitManager - Initialization complete")
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Load products from App Store Connect
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let products = try await Product.products(for: productIdentifiers)
            self.products = products.sorted { product1, product2 in
                // Sort: yearly, monthly, lifetime
                let order1 = sortOrder(for: product1.id)
                let order2 = sortOrder(for: product2.id)
                return order1 < order2
            }
            
            await updateSubscriptionStatus()
        } catch {
            print("Failed to load products: \(error)")
            errorMessage = "Failed to load subscription options. Please try again."
        }
        
        isLoading = false
    }
    
    /// Purchase a product
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // Successful purchase
                    await transaction.finish()
                    await updateSubscriptionStatus()
                    isLoading = false
                    return true
                case .unverified:
                    // Transaction failed verification
                    errorMessage = "Purchase could not be verified. Please try again."
                    isLoading = false
                    return false
                }
            case .userCancelled:
                // User cancelled the purchase
                isLoading = false
                return false
            case .pending:
                // Transaction is pending (e.g., Ask to Buy for child accounts)
                errorMessage = "Purchase is pending approval."
                isLoading = false
                return false
            @unknown default:
                errorMessage = "Unknown purchase result."
                isLoading = false
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            errorMessage = "Purchase failed. Please try again."
            isLoading = false
            return false
        }
    }
    
    /// Restore purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            print("Failed to restore purchases: \(error)")
            errorMessage = "Failed to restore purchases. Please try again."
        }
        
        isLoading = false
    }
    
    /// Check if user has premium access
    var hasPremiumAccess: Bool {
        let hasAccess = hasActiveSubscription || purchasedProductIDs.contains("breatheeasy_lifetime")
        print("🔍 StoreKit Debug - hasActiveSubscription: \(hasActiveSubscription), purchasedProductIDs: \(purchasedProductIDs), hasPremiumAccess: \(hasAccess)")
        return hasAccess
    }
    
    // MARK: - Private Methods
    
    private func sortOrder(for productID: String) -> Int {
        switch productID {
        case "breatheeasy_premium_yearly": return 0
        case "breatheeasy_premium_monthly": return 1
        case "breatheeasy_lifetime": return 2
        default: return 999
        }
    }
    
    private func listenForTransactionUpdates() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    guard let self = self else { return }
                    let transaction = try self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    nonisolated private func updateSubscriptionStatus() async {
        var purchasedProductIDs: Set<String> = []
        var subscriptionStatuses: [Product.SubscriptionInfo.Status] = []
        
        // Check current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedProductIDs.insert(transaction.productID)
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        // Check subscription statuses - need to access products on main actor
        let currentProducts = await MainActor.run { self.products }
        for product in currentProducts {
            if product.type == .autoRenewable {
                if let subscription = product.subscription {
                    let statuses = try? await subscription.status
                    if let statuses = statuses {
                        subscriptionStatuses.append(contentsOf: statuses)
                    }
                }
            }
        }
        
        await MainActor.run {
            self.purchasedProductIDs = purchasedProductIDs
            self.subscriptionStatuses = subscriptionStatuses
            
            // Determine if user has active subscription
            self.hasActiveSubscription = subscriptionStatuses.contains { status in
                switch status.state {
                case .subscribed, .inGracePeriod:
                    return true
                default:
                    return false
                }
            }
        }
    }
    
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitManagerError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
