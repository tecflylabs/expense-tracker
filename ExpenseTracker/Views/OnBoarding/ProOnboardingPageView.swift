//
//  ProOnboardingPageView.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 06.01.26.
//

import SwiftUI

struct ProOnboardingPageView: View {
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Star Icon
            Image(systemName: "star.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.orange.gradient)
                .symbolEffect(.bounce, value: appeared)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 50)
                .animation(.spring(duration: 0.8, bounce: 0.4).delay(0.2), value: appeared)
            
            // Title
            VStack(spacing: 12) {
                Text("Unlock Full Potential")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)
                    .animation(.spring(duration: 0.8).delay(0.3), value: appeared)
                
                Text("Get PennyFlow Pro")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(duration: 0.8).delay(0.4), value: appeared)
            }
            .padding(.horizontal, 40)
            
            // Features List
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "chart.bar.fill", text: "Unlimited Budget Goals", delay: 0.5)
                FeatureRow(icon: "chart.xyaxis.line", text: "Advanced Charts & Reports", delay: 0.6)
                FeatureRow(icon: "doc.fill", text: "PDF Export", delay: 0.7)
                FeatureRow(icon: "square.grid.3x3.fill", text: "All Widget Sizes", delay: 0.8)
                FeatureRow(icon: "slider.horizontal.3", text: "Advanced Filters", delay: 0.9)
            }
            .padding(.horizontal, 50)
            
            // Price
            VStack(spacing: 8) {
                Text("Just €4.99")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.orange)
                
                Text("One-time payment • Lifetime access")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(duration: 0.8).delay(1.0), value: appeared)
            .padding(.top, 10)
            
            Spacer()
        }
        .onAppear {
            appeared = true
        }
    }
}

// MARK: - Feature Row Component

struct FeatureRow: View {
    let icon: String
    let text: String
    let delay: Double
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .animation(.spring(duration: 0.6).delay(delay), value: appeared)
        .onAppear {
            appeared = true
        }
    }
}

#Preview {
    ProOnboardingPageView()
}
