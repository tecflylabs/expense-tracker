//
//  TransactionFilterOptions.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 02.01.26.
//

import Foundation

enum TransactionFilterType: String, CaseIterable, Identifiable {
    case all = "All"
    case income = "Income"
    case expense = "Expense"
    
    var id: String { rawValue }
}

enum SortOption: String, CaseIterable, Identifiable {
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"
    case amountHighest = "Amount (Highest)"
    case amountLowest = "Amount (Lowest)"
    
    var id: String { rawValue }
    
    var sortDescriptor: SortDescriptor<Transaction> {
        switch self {
        case .dateNewest:
            return SortDescriptor(\Transaction.date, order: .reverse)
        case .dateOldest:
            return SortDescriptor(\Transaction.date, order: .forward)
        case .amountHighest:
            return SortDescriptor(\Transaction.amount, order: .reverse)
        case .amountLowest:
            return SortDescriptor(\Transaction.amount, order: .forward)
        }
    }
}
