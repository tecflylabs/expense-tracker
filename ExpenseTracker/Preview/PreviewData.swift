//
//  PreviewData.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 30.12.25.
//

import Foundation
import SwiftData

extension Transaction {
    static var preview: Transaction {
        Transaction(
            title: "Grocery Shopping",
            amount: 45.50,
            date: Date(),
            category: .food,
            type: .expense,
            notes: "Weekly groceries"
        )
    }
    
    static var previewSamples: [Transaction] {
        [
            Transaction(
                title: "Salary",
                amount: 3500.00,
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                category: .salary,
                type: .income
            ),
            Transaction(
                title: "Coffee",
                amount: 4.50,
                date: Date(),
                category: .food,
                type: .expense,
                notes: "Morning coffee"
            ),
            Transaction(
                title: "Uber",
                amount: 12.30,
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                category: .transport,
                type: .expense
            ),
            Transaction(
                title: "Netflix",
                amount: 15.99,
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                category: .entertainment,
                type: .expense
            )
        ]
    }
}

@MainActor
func previewContainer() -> ModelContainer {
    let container = try! ModelContainer(
        for: Transaction.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    
    for transaction in Transaction.previewSamples {
        container.mainContext.insert(transaction)
    }
    
    return container
}
