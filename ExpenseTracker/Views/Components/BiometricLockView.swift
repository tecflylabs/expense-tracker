//
//  BiometricLockView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 04.01.26.
//

import SwiftUI

struct BiometricLockView: View {
    @State private var isUnlocking = false
    @State private var showError = false
    @State private var appeared = false
    
    let onUnlock: () -> Void
    
    private let authManager = BiometricAuthManager.shared
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Icon
                Image(systemName: authManager.biometricType.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .opacity(appeared ? 1.0 : 0.0)
                    .animation(.spring(duration: 0.5), value: appeared)
                
                // Title
                VStack(spacing: 8) {
                    Text("ExpenseTracker")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Text("Unlock with \(authManager.biometricType.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .opacity(appeared ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.5).delay(0.2), value: appeared)
                
                Spacer()
                
                // Unlock Button
                Button {
                    authenticateUser()
                } label: {
                    HStack {
                        Image(systemName: authManager.biometricType.icon)
                        Text("Unlock")
                    }
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                .disabled(isUnlocking)
                .opacity(appeared ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.5).delay(0.4), value: appeared)
            }
            .padding()
        }
        .onAppear {
            appeared = true
            // Auto-trigger authentication on appear
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                authenticateUser()
            }
        }
        .alert("Authentication Failed", isPresented: $showError) {
            Button("Try Again") {
                authenticateUser()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please try again or use your device passcode.")
        }
    }
    
    private func authenticateUser() {
        guard !isUnlocking else { return }
        
        isUnlocking = true
        HapticManager.shared.impact(style: .medium)
        
        Task {
            let success = await authManager.authenticate()
            
            await MainActor.run {
                isUnlocking = false
                
                if success {
                    withAnimation(.spring(duration: 0.4)) {
                        onUnlock()
                    }
                } else {
                    showError = true
                }
            }
        }
    }
}

#Preview {
    BiometricLockView {
        print("Unlocked!")
    }
}
