//
//  Breathe_EasyApp.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 31/07/2025.
//

import SwiftUI
import SwiftData

@main
struct BreatheEasyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // Save settings when app goes to background
                    SettingsManager.shared.forceSave()
                }
                .task {
                    // Initialize StoreKit on app launch
                    await StoreKitManager.shared.loadProducts()
                }
        }
    }
}
