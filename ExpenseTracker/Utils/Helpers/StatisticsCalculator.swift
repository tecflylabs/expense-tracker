//
//  StatisticsCalculator.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 06.01.26.
//

import Foundation

struct StatisticsCalculator {
    let transactions: [Transaction]
    
    // MARK: - Current Month
    
    var currentMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
        }
    }
    
    var totalIncome: Double {
        currentMonthTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        currentMonthTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double {
        totalIncome - totalExpenses
    }
    
    // MARK: - Averages
    
    var averageDailySpending: Double {
        guard !currentMonthTransactions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let daysPassed = calendar.dateComponents([.day], from: startOfMonth, to: now).day! + 1
        
        return totalExpenses / Double(max(daysPassed, 1))
    }
    
    var transactionCount: Int {
        currentMonthTransactions.count
    }
    
    // MARK: - Category Analysis
    
    var biggestExpense: (category: Category, amount: Double)? {
        let expensesByCategory = Dictionary(grouping: currentMonthTransactions.filter { $0.type == .expense }, by: { $0.category })
        
        let categoryTotals = expensesByCategory.mapValues { transactions in
            transactions.reduce(0) { $0 + $1.amount }
        }
        
        guard let maxCategory = categoryTotals.max(by: { $0.value < $1.value }) else {
            return nil
        }
        
        return (category: maxCategory.key, amount: maxCategory.value)
    }
    
    var mostUsedCategory: (category: Category, count: Int)? {
        let expensesByCategory = Dictionary(grouping: currentMonthTransactions.filter { $0.type == .expense }, by: { $0.category })
        
        guard let maxCategory = expensesByCategory.max(by: { $0.value.count < $1.value.count }) else {
            return nil
        }
        
        return (category: maxCategory.key, count: maxCategory.value.count)
    }
    
    // MARK: - Trends (vs Last Month)
    
    var incomeTrend: Double? {
        let lastMonthIncome = lastMonthTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
        
        guard lastMonthIncome > 0 else { return nil }
        
        return ((totalIncome - lastMonthIncome) / lastMonthIncome) * 100
    }
    
    var expenseTrend: Double? {
        let lastMonthExpenses = lastMonthTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
        
        guard lastMonthExpenses > 0 else { return nil }
        
        return ((totalExpenses - lastMonthExpenses) / lastMonthExpenses) * 100
    }
    
    private var lastMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else {
            return []
        }
        
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: lastMonth, toGranularity: .month)
        }
    }
    
    // MARK: - Spending Streak
    
    var spendingStreak: Int {
        let calendar = Calendar.current
        let sortedTransactions = currentMonthTransactions
            .filter { $0.type == .expense }
            .sorted { $0.date > $1.date }
        
        var streak = 0
        var currentDate = Date()
        
        for transaction in sortedTransactions {
            if calendar.isDate(transaction.date, inSameDayAs: currentDate) {
                continue
            } else if calendar.isDate(transaction.date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: currentDate)!) {
                streak += 1
                currentDate = transaction.date
            } else {
                break
            }
        }
        
        return streak
    }
}
