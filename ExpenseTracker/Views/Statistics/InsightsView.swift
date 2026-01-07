//
//  InsightsView.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 06.01.26.
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    @Query private var transactions: [Transaction]
    @Query private var budgets: [BudgetGoal]
    
    @State private var chartsViewModel = ChartsViewModel()
    @State private var calculator: StatisticsCalculator? = nil
    
    @State private var insights: [Insight] = []
    @State private var allInsights: [Insight] = []
    @State private var isLoadingInsights = false
    @State private var showPaywall = false
    
    private let freeInsightLimit = 3
    
    private var displayedInsights: [Insight] {
        PurchaseManager.shared.hasPro ? allInsights : Array(allInsights.prefix(freeInsightLimit))
    }
    
    private var hasMoreInsights: Bool {
        !PurchaseManager.shared.hasPro && allInsights.count > freeInsightLimit
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if transactions.isEmpty {
                    emptyState
                } else if let calculator {
                    VStack(spacing: 24) {
                        smartInsightsSection
                        statisticsSection(calculator: calculator)
                        chartsSection
                    }
                    .padding()
                } else {
                    ProgressView()
                        .padding()
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: transactions) { _, _ in
                recalcAll()
            }
            .onChange(of: budgets) { _, _ in
                recalcInsights()
            }
            .onAppear {
                recalcAll()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallSheet(feature: "Unlimited Insights")
            }
        }
    }
    
    // MARK: - Recalc
    
    private func recalcAll() {
        let current = transactions
        
        guard !current.isEmpty else {
            chartsViewModel.reset()
            calculator = StatisticsCalculator(transactions: [])
            allInsights = []
            return
        }
        
        chartsViewModel.transactions = current
        
        DispatchQueue.global(qos: .userInitiated).async {
            let calc = StatisticsCalculator(transactions: current)
            DispatchQueue.main.async {
                if current == self.transactions {
                    self.calculator = calc
                }
            }
        }
        
        recalcInsights()
    }
    
    private func recalcInsights() {
        let currentTx = transactions
        let currentBudgets = budgets
        
        guard !currentTx.isEmpty else {
            allInsights = []
            return
        }
        
        isLoadingInsights = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let generator = InsightGenerator(transactions: currentTx, budgets: currentBudgets)
            let all = generator.generate()
            
            DispatchQueue.main.async {
                if currentTx == self.transactions {
                    self.allInsights = all
                }
                self.isLoadingInsights = false
            }
        }
    }
    
    // MARK: - Smart Insights
    
    private var smartInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Smart Insights")
                    .font(.title2.bold())
                Spacer()
                
                if isLoadingInsights {
                    ProgressView()
                        .scaleEffect(0.9)
                }
            }
            
            if displayedInsights.isEmpty, !isLoadingInsights {
                ContentUnavailableView(
                    "No insights yet",
                    systemImage: "sparkles",
                    description: Text("Add more transactions to unlock insights")
                )
                .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 10) {
                    ForEach(displayedInsights) { insight in
                        InsightRowView(insight: insight)
                    }
                    
                    if hasMoreInsights {
                        Button {
                            showPaywall = true
                            HapticManager.shared.impact(style: .medium)
                        } label: {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Unlock \(allInsights.count - freeInsightLimit) more insights")
                                    .fontWeight(.semibold)
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .foregroundStyle(.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Statistics
    
    private func statisticsSection(calculator: StatisticsCalculator) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.title2.bold())
            
            VStack(spacing: 10) {
                StatCard(
                    title: "Balance",
                    value: calculator.balance.asCurrency(currencyCode: currencyCode),
                    icon: "dollarsign.circle.fill",
                    iconColor: calculator.balance >= 0 ? .green : .red,
                    subtitle: "This month"
                )
                
                StatCard(
                    title: "Income",
                    value: calculator.totalIncome.asCurrency(currencyCode: currencyCode),
                    icon: "arrow.down.circle.fill",
                    iconColor: .green,
                    trend: calculator.incomeTrend.map {
                        TrendIndicator(text: "\(String(format: "%.1f", abs($0)))%", isPositive: $0 >= 0)
                    }
                )
                
                StatCard(
                    title: "Expenses",
                    value: calculator.totalExpenses.asCurrency(currencyCode: currencyCode),
                    icon: "arrow.up.circle.fill",
                    iconColor: .red,
                    trend: calculator.expenseTrend.map {
                        TrendIndicator(text: "\(String(format: "%.1f", abs($0)))%", isPositive: $0 < 0)
                    }
                )
                
                StatCard(
                    title: "Daily Average",
                    value: calculator.averageDailySpending.asCurrency(currencyCode: currencyCode),
                    icon: "calendar.circle.fill",
                    iconColor: .blue,
                    subtitle: "Per day"
                )
                
                if let biggest = calculator.biggestExpense {
                    StatCard(
                        title: "Biggest Expense",
                        value: biggest.amount.asCurrency(currencyCode: currencyCode),
                        icon: biggest.category.systemImage,
                        iconColor: biggest.category.color,
                        subtitle: biggest.category.rawValue
                    )
                }
                
                if let mostUsed = calculator.mostUsedCategory {
                    StatCard(
                        title: "Most Used Category",
                        value: mostUsed.category.rawValue,
                        icon: mostUsed.category.systemImage,
                        iconColor: mostUsed.category.color,
                        subtitle: "\(mostUsed.count) transactions"
                    )
                }
                
                StatCard(
                    title: "Total Transactions",
                    value: "\(calculator.transactionCount)",
                    icon: "list.bullet.circle.fill",
                    iconColor: .orange,
                    subtitle: "This month"
                )
                
                StatCard(
                    title: "Spending Streak",
                    value: "\(calculator.spendingStreak) days",
                    icon: "flame.circle.fill",
                    iconColor: .purple,
                    subtitle: "Consecutive days"
                )
            }
        }
    }
    
    // MARK: - Charts
    
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Visual Analytics")
                .font(.title2.bold())
            
            if chartsViewModel.hasData {
                VStack(spacing: 20) {
                    BalanceLineChartView( data: chartsViewModel.balanceOverTimeData)
                    CategoryBarChartView( data: chartsViewModel.categoryChartData)
                    CategoryPieChartView( data: chartsViewModel.categoryChartData)
                    MonthlyComparisonChartView( data: chartsViewModel.monthlyChartData)
                }
            }
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Insights Available",
            systemImage: "chart.line.uptrend.xyaxis",
            description: Text("Add transactions to see statistics and charts")
        )
    }
}

#Preview("InsightsView") {
    InsightsView()
        .modelContainer(previewContainer())
}
