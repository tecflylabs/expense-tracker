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
    
    @State private var showLockScreen = false
    
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
                
                if showLockScreen && biometricLockEnabled {
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
                
                // Show lock screen on first launch
                if biometricLockEnabled && authManager.isBiometricAvailable {
                    showLockScreen = true
                }
            }
        }
        .modelContainer(sharedModelContainer())
    }
    
    // ✅ NEW: Setup NotificationCenter observers
    private func setupLifecycleObservers() {
        // Observe when app goes to background
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleAppBackground()
        }
        
        // Observe when app comes to foreground
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleAppForeground()
        }
    }
    
    private func handleAppBackground() {
        guard biometricLockEnabled && authManager.isBiometricAvailable else { return }
        
        // Record time when going to background
        authManager.recordBackgroundTime()
        
#if DEBUG
        print("📱 App going to background - recorded time")
#endif
    }
    
    private func handleAppForeground() {
        guard biometricLockEnabled && authManager.isBiometricAvailable else { return }
        
        // Check if we need to re-lock
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
