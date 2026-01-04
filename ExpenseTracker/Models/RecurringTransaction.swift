//
//  RecurringTransaction.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 04.01.26.
//

import Foundation
import SwiftData

@Model
final class RecurringTransaction {
    var title: String
    var amount: Double
    var category: Category
    var type: TransactionType
    var frequency: RecurringFrequency
    var startDate: Date
    var lastGenerated: Date?
    var notes: String?
    var isActive: Bool
    
    init(
        title: String,
        amount: Double,
        category: Category,
        type: TransactionType,
        frequency: RecurringFrequency,
        startDate: Date = Date(),
        notes: String? = nil,
        isActive: Bool = true
    ) {
        self.title = title
        self.amount = amount
        self.category = category
        self.type = type
        self.frequency = frequency
        self.startDate = startDate
        self.notes = notes
        self.isActive = isActive
        self.lastGenerated = nil
    }
    
    var nextDueDate: Date {
        guard let lastGenerated = lastGenerated else {
            return startDate
        }
        return frequency.nextDate(from: lastGenerated)
    }
    
    var isDue: Bool {
        nextDueDate <= Date()
    }
}

// MARK: - Preview Helper

extension RecurringTransaction {
    static var preview: RecurringTransaction {
        RecurringTransaction(
            title: "Netflix Subscription",
            amount: 15.99,
            category: .entertainment,
            type: .expense,
            frequency: .monthly,
            startDate: Date()
        )
    }
}

