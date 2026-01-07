//
//  InsightGenerator.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 07.01.26.
//

import Foundation

struct InsightGenerator {
    let transactions: [Transaction]
    let budgets: [BudgetGoal]
    
    /// Optional: später aus Settings/AppStorage ziehen
    let currencyCode: String
    
    init(transactions: [Transaction], budgets: [BudgetGoal], currencyCode: String = "EUR") {
        self.transactions = transactions
        self.budgets = budgets
        self.currencyCode = currencyCode
    }
    
    func generate(limit: Int? = nil) -> [Insight] {
        guard !transactions.isEmpty else { return [] }
        
        var insights: [Insight] = []
        
        insights.append(contentsOf: budgetInsights())
        insights.append(contentsOf: monthOverMonthInsights())
        insights.append(contentsOf: categoryInsights())
        insights.append(contentsOf: anomalyInsights())
        
        // Sort: important first
        insights.sort { $0.priority > $1.priority }
        
        // Dedupe: kind+title (safer than only title)
        var seen = Set<String>()
        insights = insights.filter { insight in
            let key = "\(insight.kind.rawValue)|\(insight.title)"
            return seen.insert(key).inserted
        }
        
        if let limit {
            return Array(insights.prefix(limit))
        }
        
        return insights
    }
}

// MARK: - Insight building blocks

private extension InsightGenerator {
    func budgetInsights() -> [Insight] {
        let activeBudgets = budgets.filter { $0.isActive }
        guard !activeBudgets.isEmpty else { return [] }
        
        // Highest progress first
        let sorted = activeBudgets.sorted { a, b in
            a.progress(transactions: transactions) > b.progress(transactions: transactions)
        }
        
        var result: [Insight] = []
        
        for budget in sorted.prefix(2) {
            let progress = budget.progress(transactions: transactions) // 0...1 (capped)
            let spent = budget.currentSpent(transactions: transactions)
            let remaining = budget.remaining(transactions: transactions)
            let level = budget.warningLevel(transactions: transactions)
            let categoryName = budget.category.rawValue
            
            switch level {
            case .safe:
                continue
                
            case .warning:
                result.append(
                    Insight(
                        kind: .neutral,
                        title: "Budget getting tight",
                        message: "\(categoryName): \(Int(progress * 100))% used (\(formatCurrency(spent)) spent, \(formatCurrency(remaining)) left).",
                        systemImage: "exclamationmark.triangle.fill",
                        priority: 80
                    )
                )
                
            case .critical:
                result.append(
                    Insight(
                        kind: .warning,
                        title: "Budget almost used",
                        message: "\(categoryName) is at \(Int(progress * 100))% (\(formatCurrency(remaining)) remaining).",
                        systemImage: "exclamationmark.triangle.fill",
                        priority: 90
                    )
                )
                
            case .exceeded:
                result.append(
                    Insight(
                        kind: .warning,
                        title: "Budget exceeded",
                        message: "\(categoryName) is over limit by \(formatCurrency(abs(remaining))).",
                        systemImage: "xmark.circle.fill",
                        priority: 100
                    )
                )
            }
        }
        
        return result
    }
    
    func monthOverMonthInsights() -> [Insight] {
        let calendar = Calendar.current
        let now = Date()
        
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return [] }
        
        let thisMonth = transactions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        let prevMonth = transactions.filter { calendar.isDate($0.date, equalTo: lastMonth, toGranularity: .month) }
        
        let thisExpenses = thisMonth.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        let prevExpenses = prevMonth.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        
        guard prevExpenses > 0 else { return [] }
        
        let diff = thisExpenses - prevExpenses
        let pct = (diff / prevExpenses) * 100
        
        let kind: Insight.Kind = diff <= 0 ? .positive : .warning
        let title = diff <= 0 ? "Spending down" : "Spending up"
        let verb = diff <= 0 ? "less" : "more"
        
        return [
            Insight(
                kind: kind,
                title: title,
                message: "You spent \(abs(pct).rounded1())% \(verb) than last month.",
                systemImage: diff <= 0 ? "arrow.down.right.circle.fill" : "arrow.up.right.circle.fill",
                priority: 70
            )
        ]
    }
    
    func categoryInsights() -> [Insight] {
        let calendar = Calendar.current
        let now = Date()
        
        let thisMonthExpenses = transactions
            .filter { $0.type == .expense && calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        
        let total = thisMonthExpenses.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return [] }
        
        let grouped = Dictionary(grouping: thisMonthExpenses, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
        
        guard let top = grouped.max(by: { $0.value < $1.value }) else { return [] }
        
        let pct = (top.value / total) * 100
        
        return [
            Insight(
                kind: pct >= 50 ? .warning : .neutral,
                title: "Top spending category",
                message: "\(top.key.rawValue) accounts for \(pct.rounded1())% of your expenses (\(formatCurrency(top.value))).",
                systemImage: "chart.pie.fill",
                priority: 60
            )
        ]
    }
    
    func anomalyInsights() -> [Insight] {
        let calendar = Calendar.current
        let now = Date()
        
        let thisMonthExpenses = transactions
            .filter { $0.type == .expense && calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        
        guard thisMonthExpenses.count >= 6 else { return [] }
        
        let amounts = thisMonthExpenses.map(\.amount).sorted()
        let median = amounts[amounts.count / 2]
        
        guard let biggest = thisMonthExpenses.max(by: { $0.amount < $1.amount }) else { return [] }
        
        if median > 0, biggest.amount >= (median * 3) {
            return [
                Insight(
                    kind: .warning,
                    title: "Unusually large expense",
                    message: "\(biggest.title) was \(formatCurrency(biggest.amount)) in \(biggest.category.rawValue).",
                    systemImage: "exclamationmark.bubble.fill",
                    priority: 50
                )
            ]
        }
        
        return []
    }
}

// MARK: - Formatting

private extension InsightGenerator {
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// MARK: - Small helpers

private extension Double {
    func rounded1() -> String {
        String(format: "%.1f", self)
    }
}
