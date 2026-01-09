//
//  OnboardingData.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 06.01.26.
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let imageColor: Color
    let description: String
    let isProPage: Bool  
}

extension OnboardingPage {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Track Every Penny",
            subtitle: "Stay on top of your finances",
            imageName: "chart.line.uptrend.xyaxis",
            imageColor: .blue,
            description: "Easily track your income and expenses with a simple, intuitive interface. Know exactly where your money goes.",
            isProPage: false
        ),
        OnboardingPage(
            title: "Set Budget Goals",
            subtitle: "Achieve your financial targets",
            imageName: "target",
            imageColor: .orange,
            description: "Create custom budget goals for different categories. Get smart warnings when you're approaching your limits.",
            isProPage: false
        ),
        OnboardingPage(
            title: "Secure with Face ID",
            subtitle: "Your data, protected",
            imageName: "faceid",
            imageColor: .green,
            description: "Lock your financial data with Face ID. Your privacy is our priority - all data stays on your device.",
            isProPage: false
        ),
        // Pro Promo Page
        OnboardingPage(
            title: "Unlock Full Potential",
            subtitle: "Get PennyFlow Pro",
            imageName: "star.circle.fill",
            imageColor: .orange,
            description: "One-time purchase, lifetime access to all premium features.",
            isProPage: true
        )
    ]
}
