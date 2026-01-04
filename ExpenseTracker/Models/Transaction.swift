//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 30.12.25.
//

import Foundation
import SwiftData

@Model
final class Transaction {
    var title: String
    var amount: Double
    var date: Date
    var category: Category
    var type: TransactionType
    var notes: String?
    var isRecurring: Bool
    
    init(title: String, amount: Double, date: Date, category: Category, type: TransactionType, notes: String? = nil, isRecurring: Bool = false) {
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.type = type
        self.notes = notes
        self.isRecurring = isRecurring
    }
}
