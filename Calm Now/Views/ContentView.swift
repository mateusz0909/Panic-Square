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
    
    private let squareSize: CGFloat = 350
    
    // Welcome screen logic: show only if user hasn't seen it (first time only)
    private var shouldShowWelcomeScreen: Bool {
        !settingsManager.hasSeenWelcome
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .opacity(viewModel.backgroundOpacity)
                .ignoresSafeArea()
            ShimmerView()
                .opacity(viewModel.isBreathing ? 0.3 : 0.6)
                .animation(.easeInOut(duration: 0.8), value: viewModel.isBreathing)
            
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
    
    // MARK: - Enhanced Visual Properties
    private var breathingSquareOpacity: Double {
        switch viewModel.currentPhase {
        case .inhale:
            return 0.4
        case .holdAfterInhale:
            return 0.45
        case .exhale:
            return 0.35
        case .holdAfterExhale:
            return 0.3
        }
    }
    
    private var breathingBorderOpacity: Double {
        switch viewModel.currentPhase {
        case .inhale:
            return 0.6
        case .holdAfterInhale:
            return 0.7
        case .exhale:
            return 0.5
        case .holdAfterExhale:
            return 0.4
        }
    }
    
    private var shadowColor: Color {
        switch viewModel.currentPhase {
        case .inhale:
            return .black.opacity(0.15)
        case .holdAfterInhale:
            return .black.opacity(0.2)
        case .exhale:
            return .black.opacity(0.1)
        case .holdAfterExhale:
            return .black.opacity(0.08)
        }
    }
    
    private var shadowRadius: CGFloat {
        switch viewModel.currentPhase {
        case .inhale:
            return 8
        case .holdAfterInhale:
            return 12
        case .exhale:
            return 6
        case .holdAfterExhale:
            return 4
        }
    }
    
    private var shadowOffset: CGFloat {
        switch viewModel.currentPhase {
        case .inhale:
            return 6
        case .holdAfterInhale:
            return 8
        case .exhale:
            return 4
        case .holdAfterExhale:
            return 3
        }
    }
    
    /// The main animated square, with optimized smooth animations and visual feedback.
    private var breathingSquare: some View {
        ZStack {
            // Layer 1 (Back): Enhanced Glass Panel with depth
            ZStack {
                // Base color with breathing-based opacity variation
                Color("SquareColor")
                    .opacity(breathingSquareOpacity)
                
                // Multi-layer gradient for more depth
                LinearGradient(
                    colors: [
                        .white.opacity(0.25), 
                        .white.opacity(0.1), 
                        .white.opacity(0.05)
                    ], 
                    startPoint: .topLeading, 
                    endPoint: .bottomTrailing
                )
                
                // Subtle inner glow effect
                RoundedRectangle(cornerRadius: viewModel.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .blur(radius: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: viewModel.cornerRadius))
            .overlay(
                // Enhanced breathing guide overlay
                ZStack {
                    // Subtle static border with breathing pulse
                    RoundedRectangle(cornerRadius: viewModel.cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(breathingBorderOpacity), 
                                    .white.opacity(breathingBorderOpacity * 0.3)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ), 
                            lineWidth: 1.5
                        )
                    
                    // Enhanced traveling guide light
                    
                }
            )
            .frame(width: squareSize, height: squareSize)
            .scaleEffect(viewModel.scale)
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowOffset)
            
            // Layer 2 (Front): Enhanced Text Content
            VStack(spacing: 12) {
                Text(viewModel.currentPhase.instruction)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
                    .minimumScaleFactor(0.5)
                    .id("instruction-\(viewModel.currentPhase.instruction)")
                    .transition(.blurReplace)
                
                Text("\(viewModel.countdown)")
                    .font(.system(size: 64, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
                    .contentTransition(.numericText())
                
                // Enhanced session info
                if viewModel.isBreathing {
                    VStack(spacing: 6) {
                        if let timeRemaining = viewModel.sessionTimeRemaining {
                            Text(formatTime(timeRemaining))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.white.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        
                        if viewModel.totalBreathCycles > 0 {
                            Text("\(viewModel.totalBreathCycles) \(viewModel.totalBreathCycles == 1 ? "cycle" : "cycles")")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }
            .scaleEffect(0.8 + (viewModel.scale * 0.2))
            .frame(width: squareSize * 0.7, height: squareSize * 0.7)
            .animation(.easeInOut(duration: 0.4), value: viewModel.countdown)
        }
        // Consolidated animation for better performance
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.8), value: viewModel.scale)
        .animation(.easeOut(duration: 0.5), value: viewModel.cornerRadius)
        .animation(.easeInOut(duration: 0.4), value: viewModel.currentPhase)
        .animation(.easeInOut(duration: 0.6), value: viewModel.backgroundOpacity)
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
