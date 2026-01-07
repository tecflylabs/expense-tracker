//
//  PurchaseManager.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 07.01.26.
//

import StoreKit
import SwiftUI

typealias StoreTransaction = StoreKit.Transaction

@MainActor
@Observable
class PurchaseManager {
    static let shared = PurchaseManager()
    
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    
    let proProductID = "com.pennyflow.lifetime.pro"
    
    var hasPro: Bool {
        purchasedProductIDs.contains(proProductID)
    }
    
    private init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: [proProductID])
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if case .verified(_) = verification {
                await updatePurchasedProducts()
            }
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    
    func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in StoreTransaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchased
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }
}
