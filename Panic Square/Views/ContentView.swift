//
//  ContentView.swift
//  BreatheEasy
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = BreathingViewModel()
    @ObservedObject private var settingsManager = SettingsManager.shared
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @State private var isShowingAboutSheet = false
    @State private var isShowingAudioSettings = false
    @State private var isShowingBreathingSettings = false
    @State private var isShowingPaywall = false
    
    private let squareSize: CGFloat = 300
    
    // Welcome screen logic: show only if user hasn't seen it (first time only)
    private var shouldShowWelcomeScreen: Bool {
        !settingsManager.hasSeenWelcome
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            ShimmerView()
            
            if shouldShowWelcomeScreen && !viewModel.isBreathing {
                // Welcome/Start screen
                WelcomeView {
                    startBreathingSession()
                }
                .ignoresSafeArea()
                .transition(.opacity.combined(with: .scale))
            } else {
                // Main breathing interface
                VStack(spacing: 0) {
                    Spacer()
                    breathingSquare
                    Spacer()
                    
                    // Breathing pattern info - moved above controls
                    if !viewModel.isBreathing {
                        VStack(spacing: 4) {
                            Text(settingsManager.breathingPattern.name)
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                            Text(settingsManager.breathingPattern.timingDisplay)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.bottom, 20)
                    }
                    
                    controls
                        .padding(.bottom, 40)
                }
                .padding()
                .transition(.opacity.combined(with: .scale))
            }
            
            // Info button overlay (only when not showing welcome screen)
            if !shouldShowWelcomeScreen {
                VStack {
                    HStack {
                        Spacer()
                        
                        // Info button in top-right
                        Button(action: { isShowingAboutSheet = true }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.title3)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    Spacer()
                }
            }
        }
        .animation(.easeInOut(duration: 0.6), value: shouldShowWelcomeScreen)
        .animation(.easeInOut(duration: 0.6), value: viewModel.isBreathing)
        .onAppear {
            // Debug: Print settings on app launch
            print("ContentView appeared - checking settings...")
            settingsManager.printCurrentSettings()
            
            #if DEBUG
            // Debug subscription status
            subscriptionManager.printSubscriptionDebugInfo()
            #endif
        }
        .onReceive(NotificationCenter.default.publisher(for: .showPaywall)) { _ in
            print("🎯 ContentView - Received .showPaywall notification")
            print("🎯 ContentView - Setting isShowingPaywall = true")
            isShowingPaywall = true
            print("🎯 ContentView - isShowingPaywall is now: \(isShowingPaywall)")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            // App going to background - disable wake lock if session is not active
            if !viewModel.isBreathing {
                UIApplication.shared.isIdleTimerDisabled = false
                print("🔄 ContentView - App backgrounded: Ensured wake lock is disabled")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // App became active - restore wake lock if session is active
            if viewModel.isBreathing {
                UIApplication.shared.isIdleTimerDisabled = true
                print("🔄 ContentView - App foregrounded: Restored wake lock for active session")
            }
        }
        .sheet(isPresented: $isShowingAboutSheet) {
            AboutSheetView()
        }
        .sheet(isPresented: $isShowingAudioSettings) {
            AudioSettingsView()
        }
        .sheet(isPresented: $isShowingBreathingSettings) {
            BreathingSettingsView()
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView {
                // Refresh subscription status after purchase
                Task {
                    await StoreKitManager.shared.loadProducts()
                }
            }
        }
    }
    
    /// The main animated square, with the definitive guide light solution.
    private var breathingSquare: some View {
        ZStack {
            // Layer 1 (Back): The Glass Panel
            ZStack {
                Color("SquareColor").opacity(0.3)
                LinearGradient(colors: [.white.opacity(0.2), .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
//            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: viewModel.cornerRadius))
            .overlay(
                // --- THE DEFINITIVE FIX: The guide is now an overlay ON TOP of the glass ---
                ZStack {
                    // Layer 1 of Overlay: The faint, static border.
                    RoundedRectangle(cornerRadius: viewModel.cornerRadius)
                        .stroke(LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        ), lineWidth: 1)
                    
                    // Layer 2 of Overlay: The bright, traveling guide light.
                    // This is guaranteed to be visible because it's drawn on top.
                    BreathingGuideView(
                        isAnimating: $viewModel.isGuideAnimating,
                        cornerRadius: viewModel.cornerRadius
                    )
                }
            )
            .frame(width: squareSize, height: squareSize)
            .scaleEffect(viewModel.scale)
            .shadow(color: .black.opacity(0.1), radius: 5, y: 5)
            
            // Layer 2 (Front): The Text Content
            VStack(spacing: 8) {
                Text(viewModel.currentPhase.instruction)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    .minimumScaleFactor(0.5)
                    .id("instruction-\(viewModel.currentPhase.instruction)")
                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                
                Text("\(viewModel.countdown)")
                    .font(.system(size: 64, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    .contentTransition(.numericText())
                
                // Session info
                if viewModel.isBreathing {
                    VStack(spacing: 4) {
                        if let timeRemaining = viewModel.sessionTimeRemaining {
                            Text(formatTime(timeRemaining))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        if viewModel.totalBreathCycles > 0 {
                            Text("\(viewModel.totalBreathCycles) \(viewModel.totalBreathCycles == 1 ? "cycle" : "cycles")")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
            .scaleEffect(0.8 + (viewModel.scale * 0.2))
            .frame(width: squareSize * 0.7, height: squareSize * 0.7)
            .animation(.easeInOut(duration: 0.4), value: viewModel.countdown)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.scale)
    }
    
    /// The bottom control area.
    private var controls: some View {
        VStack(spacing: 30) {
            HStack(spacing: 20) {
                
                // Background sound toggle
                GlassIconButton(
                    systemName: settingsManager.isMusicEnabled ? settingsManager.backgroundSound.iconName : "speaker.slash.fill"
                ) { 
                    settingsManager.isMusicEnabled.toggle() 
                }
                .contentTransition(.symbolEffect(.replace))
                
                // Audio guide toggle
                GlassIconButton(
                    systemName: settingsManager.audioGuideOption.iconName
                ) { 
                    cycleAudioGuideOption()
                }
                .contentTransition(.symbolEffect(.replace))
                
                // Breathing pattern settings
                ZStack {
                    GlassIconButton(systemName: "timer") {
                        isShowingBreathingSettings = true
                    }
                    
                    // Premium badge for breathing patterns
                    if !subscriptionManager.hasPremiumAccess {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .frame(width: 20, height: 20)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(LinearGradient(
                                        colors: [.yellow.opacity(0.6), .yellow.opacity(0.2)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ), lineWidth: 1)
                            )
                            .shadow(color: .yellow.opacity(0.3), radius: 2, x: 0, y: 1)
                            .offset(x: 20, y: -20)
                    }
                }
                
                // Audio settings
                ZStack {
                    GlassIconButton(systemName: "slider.horizontal.3") {
                        isShowingAudioSettings = true
                    }
                    
                    // Premium badge
                    if !subscriptionManager.hasPremiumAccess {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .frame(width: 20, height: 20)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(LinearGradient(
                                        colors: [.yellow.opacity(0.6), .yellow.opacity(0.2)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ), lineWidth: 1)
                            )
                            .shadow(color: .yellow.opacity(0.3), radius: 2, x: 0, y: 1)
                            .offset(x: 20, y: -20)
                    }
                }
            }

            Button(action: {
                if shouldShowWelcomeScreen {
                    startBreathingSession()
                } else {
                    viewModel.toggleBreathing()
                }
            }) { 
                Text(viewModel.isBreathing ? "Stop" : "Start") 
            }
            .buttonStyle(GlassButtonStyle())
            .padding(.horizontal, 40)
        }
        .animation(.easeInOut, value: settingsManager.isMusicEnabled)
        .animation(.easeInOut, value: settingsManager.audioGuideOption)
        .animation(.easeInOut, value: settingsManager.backgroundSound)
        .animation(.easeInOut, value: settingsManager.breathingPattern)
    }
    
    // MARK: - Helper Methods
    
    /// Starts breathing session from welcome screen
    private func startBreathingSession() {
        // Mark that user has seen the welcome screen
        settingsManager.hasSeenWelcome = true
        
        // Start breathing immediately
        viewModel.toggleBreathing()
    }
    
    /// Cycles through audio guide options
    private func cycleAudioGuideOption() {
        let options = AudioGuideOption.allCases
        guard let currentIndex = options.firstIndex(of: settingsManager.audioGuideOption) else { return }
        let nextIndex = (currentIndex + 1) % options.count
        settingsManager.audioGuideOption = options[nextIndex]
    }
    
    /// Formats time remaining in minutes:seconds format
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    ContentView()
}
