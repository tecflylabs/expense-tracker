//
//  RecurringTransactionManager.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 04.01.26.
//

import SwiftData
import Foundation

@MainActor
class RecurringTransactionManager {
    static let shared = RecurringTransactionManager()
    
    private init() {}
    
    func processRecurringTransactions(context: ModelContext) {
        let descriptor = FetchDescriptor<RecurringTransaction>(
            predicate: #Predicate { $0.isActive == true }
        )
        
        guard let recurringTransactions = try? context.fetch(descriptor) else {
            return
        }
        
        for recurring in recurringTransactions {
            if recurring.isDue {
                generateTransaction(from: recurring, context: context)
            }
        }
        
        try? context.save()
    }
    
    private func generateTransaction(from recurring: RecurringTransaction, context: ModelContext) {
        let transaction = Transaction(
            title: recurring.title,
            amount: recurring.amount,
            date: recurring.nextDueDate,
            category: recurring.category,
            type: recurring.type,
            notes: recurring.notes,
            isRecurring: true
        )
        
        context.insert(transaction)
        recurring.lastGenerated = recurring.nextDueDate
        
        print("✅ Generated recurring transaction: \(recurring.title)")
    }
}
