//
//  BudgetGoal.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 04.01.26.
//



import Foundation
import SwiftData
import SwiftUI

@Model
final class BudgetGoal {
    var category: Category
    var monthlyLimit: Double
    var startDate: Date
    var isActive: Bool
    
    init(category: Category, monthlyLimit: Double, startDate: Date = Date(), isActive: Bool = true) {
        self.category = category
        self.monthlyLimit = monthlyLimit
        self.startDate = startDate
        self.isActive = isActive
    }
    
    // MARK: - Computed Properties
    
    /// Calculate spent amount for current month based on transactions
    func currentSpent(transactions: [Transaction]) -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        return transactions
            .filter { transaction in
                transaction.category == self.category &&
                transaction.type == .expense &&
                calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Remaining budget amount
    func remaining(transactions: [Transaction]) -> Double {
        monthlyLimit - currentSpent(transactions: transactions)
    }
    
    /// Progress percentage (0.0 to 1.0)
    func progress(transactions: [Transaction]) -> Double {
        let spent = currentSpent(transactions: transactions)
        return min(spent / monthlyLimit, 1.0)
    }
    
    /// Warning status for UI
    func warningLevel(transactions: [Transaction]) -> BudgetWarningLevel {
        let progressValue = progress(transactions: transactions)
        
        if progressValue >= 1.0 {
            return .exceeded
        } else if progressValue >= 0.9 {
            return .critical
        } else if progressValue >= 0.75 {
            return .warning
        } else {
            return .safe
        }
    }
}

// MARK: - Warning Level Enum

enum BudgetWarningLevel {
    case safe
    case warning
    case critical
    case exceeded
    
    var color: Color {
        switch self {
        case .safe: return .green
        case .warning: return .orange
        case .critical: return .red
        case .exceeded: return Color(red: 1.0, green: 0.0, blue: 0.302)
        }
    }
    
    var icon: String {
        switch self {
        case .safe: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "exclamationmark.triangle.fill"
        case .exceeded: return "xmark.circle.fill"
        }
    }
    
    var message: String {
        switch self {
        case .safe: return "On track"
        case .warning: return "75% used"
        case .critical: return "90% used!"
        case .exceeded: return "Budget exceeded!"
        }
    }
}
