//
//  TransactionType.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 30.12.25.
//

import Foundation

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case income = "Income"
    case expense = "Expense"
    var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .income:
            return "arrow.down.circle.fill"
        case .expense:
            return "arrow.up.circle.fill"
        }
    }
    
    var color: String {
        switch self {
            case .income:
            return "green"
        case .expense:
            return "red"
        }
    }
}
