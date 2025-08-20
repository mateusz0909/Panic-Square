//
//  SessionLength.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 18/08/2025.
//

import Foundation

/// Defines different session length options
enum SessionLength: String, Codable, CaseIterable, Identifiable {
    case infinite = "infinite"
    case oneMinute = "1min"
    case twoMinutes = "2min"
    case fiveMinutes = "5min"
    case tenMinutes = "10min"
    case fifteenMinutes = "15min"
    case twentyMinutes = "20min"
    case thirtyMinutes = "30min"
    
    var id: String { rawValue }
    
    /// User-friendly display name
    var displayName: String {
        switch self {
        case .infinite:
            return "Infinite"
        case .oneMinute:
            return "1 minute"
        case .twoMinutes:
            return "2 minutes"
        case .fiveMinutes:
            return "5 minutes"
        case .tenMinutes:
            return "10 minutes"
        case .fifteenMinutes:
            return "15 minutes"
        case .twentyMinutes:
            return "20 minutes"
        case .thirtyMinutes:
            return "30 minutes"
        }
    }
    
    /// Duration in seconds (nil for infinite)
    var durationInSeconds: TimeInterval? {
        switch self {
        case .infinite:
            return nil
        case .oneMinute:
            return 60
        case .twoMinutes:
            return 120
        case .fiveMinutes:
            return 300
        case .tenMinutes:
            return 600
        case .fifteenMinutes:
            return 900
        case .twentyMinutes:
            return 1200
        case .thirtyMinutes:
            return 1800
        }
    }
    
    /// Whether this session length requires premium
    var isPremium: Bool {
        switch self {
        case .infinite, .fiveMinutes:
            return false
        case .oneMinute, .twoMinutes, .tenMinutes, .fifteenMinutes, .twentyMinutes, .thirtyMinutes:
            return true
        }
    }
    
    /// System icon for UI
    var iconName: String {
        switch self {
        case .infinite:
            return "infinity"
        case .oneMinute, .twoMinutes:
            return "timer"
        case .fiveMinutes, .tenMinutes:
            return "clock"
        case .fifteenMinutes, .twentyMinutes, .thirtyMinutes:
            return "clock.badge"
        }
    }
}
