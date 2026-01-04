import SwiftUI

@Observable
class ChartsViewModel {
    var transactions: [Transaction] = []
    
    // MARK: - Computed Properties
    
    var categoryChartData: [CategoryChartData] {
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
    
    var monthlyChartData: [MonthlyData] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        let grouped = Dictionary(grouping: transactions) { transaction in
            formatter.string(from: transaction.date)
        }
        
        let mapped: [MonthlyData] = grouped.map { month, transactions in
            let income = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let expense = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            
            return MonthlyData(month: month, income: income, expense: expense)
        }
        
        return Array(mapped.sorted { $0.monthDate < $1.monthDate }.suffix(6))
    }
    
    var balanceOverTimeData: [DailyBalanceData] {
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
    
    var hasData: Bool {
        !transactions.isEmpty
    }
}
