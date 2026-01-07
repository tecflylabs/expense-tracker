//
//  ChartsViewModel.swift
//  PennyFlow
//

import SwiftUI

@Observable
class ChartsViewModel {
    // Eingehende Daten
    var transactions: [Transaction] = [] {
        didSet {
            recalc()
        }
    }
    
    // Fertige Chart-Daten (werden von Views gelesen)
    var categoryChartData: [CategoryChartData] = []
    var monthlyChartData: [MonthlyData] = []
    var balanceOverTimeData: [DailyBalanceData] = []
    
    var hasData: Bool {
        !transactions.isEmpty
    }
    
    func reset() {
        transactions = []
        categoryChartData = []
        monthlyChartData = []
        balanceOverTimeData = []
    }
    
    // MARK: - Recalculation
    
    private func recalc() {
        let current = transactions
        
        // Wenn leer, sofort alles leeren
        guard !current.isEmpty else {
            categoryChartData = []
            monthlyChartData = []
            balanceOverTimeData = []
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let category = Self.makeCategoryChartData(from: current)
            let monthly = Self.makeMonthlyChartData(from: current)
            let balance = Self.makeBalanceData(from: current)
            
            DispatchQueue.main.async {
                // Nur anwenden, wenn sich Basisdaten nicht geändert haben
                if current == self.transactions {
                    self.categoryChartData = category
                    self.monthlyChartData = monthly
                    self.balanceOverTimeData = balance
                }
            }
        }
    }
    
    // MARK: - Static builders
    
    private static func makeCategoryChartData(from transactions: [Transaction]) -> [CategoryChartData] {
        let expenses = transactions.filter { $0.type == .expense }
        let totalExpense = expenses.reduce(0) { $0 + $1.amount }
        
        guard totalExpense > 0 else { return [] }
        
        let categoryTotals = Dictionary(grouping: expenses) { $0.category }
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
        
        return categoryTotals.map { category, amount in
            CategoryChartData(
                category: category,
                amount: amount,
                percentage: (amount / totalExpense) * 100
            )
        }
        .sorted { $0.amount > $1.amount }
    }
    
    private static func makeMonthlyChartData(from transactions: [Transaction]) -> [MonthlyData] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        let grouped = Dictionary(grouping: transactions) { transaction in
            formatter.string(from: transaction.date)
        }
        
        let mapped: [MonthlyData] = grouped.map { month, transactions in
            let income = transactions
                .filter { $0.type == .income }
                .reduce(0) { $0 + $1.amount }
            let expense = transactions
                .filter { $0.type == .expense }
                .reduce(0) { $0 + $1.amount }
            
            return MonthlyData(month: month, income: income, expense: expense)
        }
        
        // Nur die letzten 6 Monate
        return Array(mapped.sorted { $0.monthDate < $1.monthDate }.suffix(6))
    }
    
    private static func makeBalanceData(from transactions: [Transaction]) -> [DailyBalanceData] {
        guard !transactions.isEmpty else { return [] }
        
        let sortedTransactions = transactions.sorted { $0.date < $1.date }
        var runningBalance: Double = 0
        var data: [DailyBalanceData] = []
        
        for transaction in sortedTransactions {
            if transaction.type == .income {
                runningBalance += transaction.amount
            } else {
                runningBalance -= transaction.amount
            }
            
            data.append(DailyBalanceData(date: transaction.date, balance: runningBalance))
        }
        
        return data
    }
}
