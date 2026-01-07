//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @AppStorage("lockTimeout") private var lockTimeout = 1
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State private var showLockScreen = false
    @State private var showOnboarding = false
    @State private var purchaseManager = PurchaseManager.shared  // ✅ NEW
    
    private let authManager = BiometricAuthManager.shared
    
    private var colorScheme: ColorScheme? {
        let theme = AppTheme(rawValue: selectedThemeRaw) ?? .system
        switch theme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .tint(.brandOrange)
                    .preferredColorScheme(colorScheme)
                    .blur(radius: showLockScreen ? 10 : 0)
                
                // ✅ CHANGED: Only show lock if onboarding completed
                if showLockScreen && biometricLockEnabled && hasCompletedOnboarding {
                    BiometricLockView {
                        withAnimation {
                            showLockScreen = false
                            authManager.isAuthenticated = true
                        }
                    }
                    .transition(.opacity)
                }
            }
            .onAppear {
                setupLifecycleObservers()
                
                // ✅ PRIORITY 1: Check onboarding FIRST
                if !hasCompletedOnboarding {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showOnboarding = true
                    }
                    // ✅ PRIORITY 2: Then check lock (only if onboarding done)
                } else if biometricLockEnabled && authManager.isBiometricAvailable {
                    showLockScreen = true
                }
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView()
                    .environment(purchaseManager)  // ✅ NEW
            }
            // ✅ NEW: When onboarding completes, check if we need lock
            .onChange(of: hasCompletedOnboarding) { oldValue, newValue in
                if newValue && biometricLockEnabled && authManager.isBiometricAvailable {
                    // Onboarding just completed, now show lock
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showLockScreen = true
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer())
        .environment(purchaseManager)  // ✅ NEW - Global injection
    }
    
    // MARK: - Lifecycle Observers
    
    private func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleAppBackground()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleAppForeground()
        }
    }
    
    private func handleAppBackground() {
        // ✅ CHANGED: Only record time if onboarding completed
        guard hasCompletedOnboarding && biometricLockEnabled && authManager.isBiometricAvailable else { return }
        
        authManager.recordBackgroundTime()
        
#if DEBUG
        print("📱 App going to background - recorded time")
#endif
    }
    
    private func handleAppForeground() {
        // ✅ CHANGED: Only check lock if onboarding completed
        guard hasCompletedOnboarding && biometricLockEnabled && authManager.isBiometricAvailable else { return }
        
        if authManager.isAuthenticated {
            if authManager.shouldRequireAuthentication(timeoutMinutes: lockTimeout) {
#if DEBUG
                print("🔒 Timeout passed - showing lock screen")
#endif
                showLockScreen = true
                authManager.isAuthenticated = false
            } else {
#if DEBUG
                print("✅ Still within timeout - staying unlocked")
#endif
            }
        } else {
#if DEBUG
            print("⚠️ Not authenticated - showing lock screen")
#endif
            showLockScreen = true
        }
    }
}
