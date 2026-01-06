//
//  InsightsView.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 06.01.26.
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query private var transactions: [Transaction]
    @State private var chartsViewModel = ChartsViewModel()
    
    private var calculator: StatisticsCalculator {
        StatisticsCalculator(transactions: transactions)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if !transactions.isEmpty {
                    VStack(spacing: 24) {
                        // Statistics Section
                        statisticsSection
                        
                        // Charts Section
                        chartsSection
                    }
                    .padding()
                } else {
                    emptyState
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: transactions.count) { oldValue, newValue in
                chartsViewModel.transactions = transactions
            }
            .onAppear {
                chartsViewModel.transactions = transactions
            }
        }
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.title2.bold())
            
            VStack(spacing: 10) {
                // Balance
                StatCard(
                    title: "Balance",
                    value: calculator.balance.asCurrency(),
                    icon: "dollarsign.circle.fill",
                    iconColor: calculator.balance >= 0 ? .green : .red,
                    subtitle: "This month"
                )
                
                // Income
                StatCard(
                    title: "Income",
                    value: calculator.totalIncome.asCurrency(),
                    icon: "arrow.down.circle.fill",
                    iconColor: .green,
                    trend: calculator.incomeTrend.map { TrendIndicator(text: "\(String(format: "%.1f", abs($0)))%", isPositive: $0 >= 0) }
                )
                
                // Expenses
                StatCard(
                    title: "Expenses",
                    value: calculator.totalExpenses.asCurrency(),
                    icon: "arrow.up.circle.fill",
                    iconColor: .red,
                    trend: calculator.expenseTrend.map { TrendIndicator(text: "\(String(format: "%.1f", abs($0)))%", isPositive: $0 < 0) }
                )
                
                // Daily Average
                StatCard(
                    title: "Daily Average",
                    value: calculator.averageDailySpending.asCurrency(),
                    icon: "calendar.circle.fill",
                    iconColor: .blue,
                    subtitle: "Per day"
                )
                
                // Biggest Expense
                if let biggest = calculator.biggestExpense {
                    StatCard(
                        title: "Biggest Expense",
                        value: biggest.amount.asCurrency(),
                        icon: biggest.category.systemImage,
                        iconColor: biggest.category.color,
                        subtitle: biggest.category.rawValue
                    )
                }
                
                // Most Used Category
                if let mostUsed = calculator.mostUsedCategory {
                    StatCard(
                        title: "Most Used Category",
                        value: mostUsed.category.rawValue,
                        icon: mostUsed.category.systemImage,
                        iconColor: mostUsed.category.color,
                        subtitle: "\(mostUsed.count) transactions"
                    )
                }
                
                // Transactions Count
                StatCard(
                    title: "Total Transactions",
                    value: "\(calculator.transactionCount)",
                    icon: "list.bullet.circle.fill",
                    iconColor: .orange,
                    subtitle: "This month"
                )
                
                // Spending Streak
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
    
    // MARK: - Charts Section
    
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
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Insights Available",
            systemImage: "chart.line.uptrend.xyaxis",
            description: Text("Add transactions to see statistics and charts")
        )
    }
}

#Preview {
    InsightsView()
        .modelContainer(previewContainer())
}
