//
//  View+Extensions.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 02.01.26.
//

import SwiftUI

extension View {
    // MARK: - Card Style
    
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Haptic Feedback
    
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            HapticManager.shared.impact(style: style)
        }
    }
    
    // MARK: - Smooth Appear Animation
    
    /// Smoothly animates the view from slight offset & transparent to fully visible.
    /// Uses an internal state wrapper so we don't assign to modifiers directly.
    func smoothAppear(delay: Double = 0) -> some View {
        SmoothAppearView(content: self, delay: delay)
    }
}

// MARK: - Internal Wrapper for smoothAppear

private struct SmoothAppearView<Content: View>: View {
    let content: Content
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Animation Extension

extension Animation {
    static let smooth = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let bouncy = Animation.spring(response: 0.6, dampingFraction: 0.6)
}

