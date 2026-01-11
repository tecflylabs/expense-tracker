//
//  BiometricAuthManager.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 04.01.26.
//

import LocalAuthentication
import Foundation
internal import UIKit

@Observable
class BiometricAuthManager {
    static let shared = BiometricAuthManager()
    
    var isAuthenticated = false
    var lastBackgroundTime: Date?
    
    private init() {}
    
    // MARK: - Biometric Availability
    
    var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }
    
    var isBiometricAvailable: Bool {
        biometricType != .none
    }
    
    // MARK: - Authentication
    
    func authenticate(reason: String = "Unlock ExpenseTracker") async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            return false
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            if success {
                await MainActor.run {
                    isAuthenticated = true
                    HapticManager.shared.notification(type: .success)
                }
            }
            
            return success
        } catch let error {
            print("Biometric authentication failed: \(error.localizedDescription)")
            await MainActor.run {
                HapticManager.shared.notification(type: .error)
            }
            return false
        }
    }
    
    // MARK: - Background Timeout
    
    func shouldRequireAuthentication(timeoutMinutes: Int) -> Bool {
        guard let lastBackground = lastBackgroundTime else {
            return true 
        }
        
        let timeoutSeconds = TimeInterval(timeoutMinutes * 60)
        let elapsed = Date().timeIntervalSince(lastBackground)
        
        return elapsed >= timeoutSeconds
    }
    
    func recordBackgroundTime() {
        lastBackgroundTime = Date()
    }
}

// MARK: - Biometric Type Enum

enum BiometricType {
    case faceID
    case touchID
    case none
    
    var icon: String {
        switch self {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .none: return "lock.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .none: return "Biometric"
        }
    }
}
