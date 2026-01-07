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
        insights.append(contentsOf: streakInsights())
        insights.append(contentsOf: savingsOpportunityInsights())
        insights.append(contentsOf: weekendSpendingInsights())
        insights.append(contentsOf: recurringTransactionInsights())
        insights.append(contentsOf: incomeInsights())
        insights.append(contentsOf: dailyAverageInsights())
        insights.append(contentsOf: categoryComparisonInsights())
        insights.append(contentsOf: noSpendDaysInsights())
        
        insights.sort { $0.priority > $1.priority }
        
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

// MARK: - Insight Building Blocks

private extension InsightGenerator {
    
    // MARK: - Budget Insights (existing)
    
    func budgetInsights() -> [Insight] {
        let activeBudgets = budgets.filter { $0.isActive }
        guard !activeBudgets.isEmpty else { return [] }
        
        let sorted = activeBudgets.sorted { a, b in
            a.progress(transactions: transactions) > b.progress(transactions: transactions)
        }
        
        var result: [Insight] = []
        
        for budget in sorted.prefix(2) {
            let progress = budget.progress(transactions: transactions)
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
    
    // MARK: - Month Over Month Insights (existing)
    
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
    
    // MARK: - Category Insights (existing)
    
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
    
    // MARK: - Anomaly Insights (existing)
    
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
    
    // MARK: - 🆕 Streak Insights
    
    func streakInsights() -> [Insight] {
        let calendar = Calendar.current
        let sortedDates = transactions
            .map { calendar.startOfDay(for: $0.date) }
            .sorted()
        
        guard !sortedDates.isEmpty else { return [] }
        
        var streak = 1
        var maxStreak = 1
        
        for i in 1..<sortedDates.count {
            if calendar.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day == 1 {
                streak += 1
                maxStreak = max(maxStreak, streak)
            } else if sortedDates[i] != sortedDates[i-1] {
                streak = 1
            }
        }
        
        if maxStreak >= 7 {
            return [
                Insight(
                    kind: .warning,
                    title: "Long spending streak",
                    message: "You spent money for \(maxStreak) consecutive days. Consider a no-spend day!",
                    systemImage: "flame.fill",
                    priority: 55
                )
            ]
        }
        
        return []
    }
    
    // MARK: - 🆕 Savings Opportunity Insights
    
    func savingsOpportunityInsights() -> [Insight] {
        let calendar = Calendar.current
        let now = Date()
        
        let thisMonth = transactions.filter {
            $0.type == .expense && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
        
        let grouped = Dictionary(grouping: thisMonth, by: { $0.category })
        let smallExpenses = grouped.filter { $0.value.count >= 10 }
        
        guard let category = smallExpenses.max(by: { $0.value.count < $1.value.count }) else { return [] }
        
        let total = category.value.reduce(0) { $0 + $1.amount }
        let count = category.value.count
        
        if total > 50 {
            return [
                Insight(
                    kind: .positive,
                    title: "Savings opportunity",
                    message: "You made \(count) \(category.key.rawValue) purchases totaling \(formatCurrency(total)). Reducing by 20% could save \(formatCurrency(total * 0.2))/month.",
                    systemImage: "lightbulb.fill",
                    priority: 45
                )
            ]
        }
        
        return []
    }
    
    // MARK: - 🆕 Weekend Spending Insights
    
    func weekendSpendingInsights() -> [Insight] {
        let calendar = Calendar.current
        let now = Date()
        
        let thisMonth = transactions.filter {
            $0.type == .expense && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
        
        let weekendExpenses = thisMonth.filter {
            let weekday = calendar.component(.weekday, from: $0.date)
            return weekday == 1 || weekday == 7
        }.reduce(0) { $0 + $1.amount }
        
        let weekdayExpenses = thisMonth.filter {
            let weekday = calendar.component(.weekday, from: $0.date)
            return weekday != 1 && weekday != 7
        }.reduce(0) { $0 + $1.amount }
        
        let total = weekendExpenses + weekdayExpenses
        guard total > 0 else { return [] }
        
        let weekendPct = (weekendExpenses / total) * 100
        
        if weekendPct >= 40 {
            return [
                Insight(
                    kind: .neutral,
                    title: "Weekend spending high",
                    message: "\(weekendPct.rounded1())% of your spending happens on weekends (\(formatCurrency(weekendExpenses))).",
                    systemImage: "calendar.badge.exclamationmark",
                    priority: 40
                )
            ]
        }
        
        return []
    }
    
    // MARK: - 🆕 Recurring Transaction Insights
    
    func recurringTransactionInsights() -> [Insight] {
        let calendar = Calendar.current
        let now = Date()
        
        let monthlyExpenses = transactions.filter {
            $0.type == .expense &&
            $0.isRecurring &&
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
        
        let recurringTotal = monthlyExpenses.reduce(0) { $0 + $1.amount }
        guard recurringTotal > 0 else { return [] }
        
        let totalExpenses = transactions.filter {
            $0.type == .expense && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
        
        let pct = (recurringTotal / totalExpenses) * 100
        
        return [
            Insight(
                kind: .neutral,
                title: "Recurring expenses",
                message: "Subscriptions & recurring costs account for \(pct.rounded1())% of spending (\(formatCurrency(recurringTotal))/month).",
                systemImage: "arrow.clockwise.circle.fill",
                priority: 65
            )
        ]
    }
    
    // MARK: - 🆕 Income Insights
    
    func incomeInsights() -> [Insight] {
        let calendar = Calendar.current
        let now = Date()
        
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return [] }
        
        let thisIncome = transactions.filter {
            $0.type == .income && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
        
        let prevIncome = transactions.filter {
            $0.type == .income && calendar.isDate($0.date, equalTo: lastMonth, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
        
        guard prevIncome > 0 else { return [] }
        
        let diff = thisIncome - prevIncome
        let pct = (diff / prevIncome) * 100
        
        if abs(pct) >= 10 {
            let kind: Insight.Kind = diff > 0 ? .positive : .warning
            let title = diff > 0 ? "Income increased" : "Income decreased"
            
            return [
                Insight(
                    kind: kind,
                    title: title,
                    message: "Your income is \(abs(pct).rounded1())% \(diff > 0 ? "higher" : "lower") than last month (\(formatCurrency(abs(diff)))).",
                    systemImage: diff > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                    priority: 75
                )
            ]
        }
        
        return []
    }
    
    // MARK: - 🆕 Daily Average Insights
    
    func dailyAverageInsights() -> [Insight] {
        let calendar = Calendar.current
        let now = Date()
        
        let thisMonth = transactions.filter {
            $0.type == .expense && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
        
        let total = thisMonth.reduce(0) { $0 + $1.amount }
        let daysInMonth = calendar.range(of: .day, in: .month, for: now)?.count ?? 30
        let dailyAvg = total / Double(daysInMonth)
        
        guard dailyAvg > 0 else { return [] }
        
        if dailyAvg > 50 {
            return [
                Insight(
                    kind: .neutral,
                    title: "Daily spending average",
                    message: "You're spending an average of \(formatCurrency(dailyAvg)) per day this month.",
                    systemImage: "calendar.circle.fill",
                    priority: 35
                )
            ]
        }
        
        return []
    }
    
    // MARK: - 🆕 Category Comparison Insights
    
    func categoryComparisonInsights() -> [Insight] {
        let calendar = Calendar.current
        let now = Date()
        
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return [] }
        
        let thisMonth = transactions.filter {
            $0.type == .expense && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
        
        let prevMonth = transactions.filter {
            $0.type == .expense && calendar.isDate($0.date, equalTo: lastMonth, toGranularity: .month)
        }
        
        let thisGrouped = Dictionary(grouping: thisMonth, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
        
        let prevGrouped = Dictionary(grouping: prevMonth, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
        
        var biggestIncrease: (category: Category, pct: Double, amount: Double)?
        
        for (category, thisAmount) in thisGrouped {
            guard let prevAmount = prevGrouped[category], prevAmount > 0 else { continue }
            
            let diff = thisAmount - prevAmount
            let pct = (diff / prevAmount) * 100
            
            if pct > 30, diff > 20 {
                if biggestIncrease == nil || pct > biggestIncrease!.pct {
                    biggestIncrease = (category, pct, diff)
                }
            }
        }
        
        if let increase = biggestIncrease {
            return [
                Insight(
                    kind: .warning,
                    title: "Category spike",
                    message: "\(increase.category.rawValue) spending increased by \(increase.pct.rounded1())% (\(formatCurrency(increase.amount)) more than last month).",
                    systemImage: "arrow.up.right.circle.fill",
                    priority: 68
                )
            ]
        }
        
        return []
    }
    
    // MARK: - 🆕 No-Spend Days Insights
    
    func noSpendDaysInsights() -> [Insight] {
        let calendar = Calendar.current
        let now = Date()
        
        let thisMonth = transactions.filter {
            $0.type == .expense && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
        
        let spendDays = Set(thisMonth.map { calendar.startOfDay(for: $0.date) })
        let daysInMonth = calendar.range(of: .day, in: .month, for: now)?.count ?? 30
        let currentDay = calendar.component(.day, from: now)
        
        let noSpendDays = currentDay - spendDays.count
        
        if noSpendDays >= 5 {
            return [
                Insight(
                    kind: .positive,
                    title: "Great self-control!",
                    message: "You had \(noSpendDays) no-spend days this month. Keep it up!",
                    systemImage: "star.fill",
                    priority: 30
                )
            ]
        } else if noSpendDays == 0 && currentDay >= 10 {
            return [
                Insight(
                    kind: .warning,
                    title: "No spend-free days",
                    message: "You've spent money every day this month. Try a no-spend day challenge!",
                    systemImage: "calendar.badge.exclamationmark",
                    priority: 42
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

// MARK: - Helpers

private extension Double {
    func rounded1() -> String {
        String(format: "%.1f", self)
    }
}
