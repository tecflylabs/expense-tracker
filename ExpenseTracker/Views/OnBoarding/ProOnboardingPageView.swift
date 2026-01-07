//
//  ProOnboardingPageView.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 06.01.26.
//

import SwiftUI
import StoreKit

struct ProOnboardingPageView: View {
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var appeared = false
    @State private var showPaywall = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "crown.fill")
                .font(.system(size: 100))
                .foregroundStyle(.yellow.gradient)
                .symbolEffect(.bounce, value: appeared)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 50)
                .animation(.spring(duration: 0.8, bounce: 0.4).delay(0.2), value: appeared)
            
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
            
            VStack(alignment: .leading, spacing: 16) {
                ProFeatureRowOnboarding(icon: "photo.fill", text: "Photo Attachments", delay: 0.5)
                ProFeatureRowOnboarding(icon: "arrow.clockwise", text: "Recurring Transactions", delay: 0.6)
                ProFeatureRowOnboarding(icon: "doc.fill", text: "PDF Export", delay: 0.7)
                ProFeatureRowOnboarding(icon: "sparkles", text: "Unlimited Insights", delay: 0.8)
                ProFeatureRowOnboarding(icon: "target", text: "Unlimited Budget Goals", delay: 0.9)
            }
            .padding(.horizontal, 50)
            
            VStack(spacing: 8) {
                if let product = purchaseManager.product {
                    Text("Just \(product.displayPrice)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.orange)
                } else {
                    Text("Just €4.99")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.orange)
                        .redacted(reason: .placeholder)
                }
                
                Text("One-time payment • Lifetime access")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(duration: 0.8).delay(1.0), value: appeared)
            .padding(.top, 10)
            
            Button {
                showPaywall = true
                HapticManager.shared.impact(style: .medium)
            } label: {
                Text("Get Pro Now")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(duration: 0.8).delay(1.1), value: appeared)
            
            Spacer()
        }
        .onAppear {
            appeared = true
        }
        .sheet(isPresented: $showPaywall) {
            PaywallSheet(feature: "Unlock all Pro features")
        }
    }
}

private struct ProFeatureRowOnboarding: View {
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
        .environment(PurchaseManager.shared)
}
