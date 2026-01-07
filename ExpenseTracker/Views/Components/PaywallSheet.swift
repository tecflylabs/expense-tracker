//
//  PaywallSheet.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 07.01.26.
//

import SwiftUI
import StoreKit

struct PaywallSheet: View {
    @Environment(\.dismiss) private var dismiss
    let feature: String
    
    @State private var purchaseManager = PurchaseManager.shared
    @State private var isPurchasing = false
    @State private var isRestoring = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(.yellow.gradient)
                        .shadow(color: .yellow.opacity(0.3), radius: 10)
                    
                    Text("Unlock Pro")
                        .font(.largeTitle.bold())
                    
                    Text(feature)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    PaywallFeatureRow(icon: "photo.fill", title: "Photo Attachments")
                    PaywallFeatureRow(icon: "arrow.clockwise", title: "Recurring Transactions")
                    PaywallFeatureRow(icon: "doc.fill", title: "PDF Export")
                    PaywallFeatureRow(icon: "sparkles", title: "Unlimited Insights")
                    PaywallFeatureRow(icon: "target", title: "Unlimited Budget Goals")
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                if let product = purchaseManager.products.first {
                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text(product.displayPrice)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.orange)
                            
                            Text("Lifetime Access • One-time payment")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Button {
                            Task {
                                isPurchasing = true
                                HapticManager.shared.impact(style: .medium)
                                try? await purchaseManager.purchase(product)
                                isPurchasing = false
                                if purchaseManager.hasPro {
                                    HapticManager.shared.notification(type: .success)
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                    Text("Processing...")
                                } else {
                                    Text("Get Pro")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.orange.gradient)
                            .foregroundStyle(.white)
                            .font(.headline)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(isPurchasing || isRestoring)
                        
                        Button {
                            Task {
                                isRestoring = true
                                HapticManager.shared.impact(style: .light)
                                await purchaseManager.restorePurchases()
                                isRestoring = false
                                if purchaseManager.hasPro {
                                    HapticManager.shared.notification(type: .success)
                                    dismiss()
                                } else {
                                    HapticManager.shared.notification(type: .error)
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                if isRestoring {
                                    ProgressView()
                                        .controlSize(.small)
                                    Text("Restoring...")
                                } else {
                                    Text("Restore Purchases")
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .disabled(isPurchasing || isRestoring)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.orange)
                        Text("Loading products...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 32)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticManager.shared.impact(style: .light)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Paywall Feature Row

private struct PaywallFeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.orange)
                .frame(width: 28)
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.title3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    PaywallSheet(feature: "Unlock all Pro features")
}
