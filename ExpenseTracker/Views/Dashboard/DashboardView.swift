//
//  DashboardView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 02.01.26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var transactions: [Transaction]
    @Query private var budgets: [BudgetGoal]
    
    @State private var showAddSheet = false
    @State private var showAddBudget = false
    @State private var showAllBudgets = false
    
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue
    
    // Computed Properties
    private var totalIncome: Double {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var balance: Double {
        totalIncome - totalExpense
    }
    
    private var expensesByCategory: [(category: Category, amount: Double, percentage: Double)] {
        let categoryTotals = Dictionary(grouping: transactions.filter { $0.type == .expense }) { $0.category }
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
        
        return categoryTotals
            .map { (category: $0.key, amount: $0.value, percentage: totalExpense > 0 ? ($0.value / totalExpense) * 100 : 0) }
            .sorted { $0.amount > $1.amount }
    }
    
    
    private var activeBudgets: [BudgetGoal] {
        budgets.filter { $0.isActive }
    }
    
    var body: some View {
        Group {
            if transactions.isEmpty && budgets.isEmpty {
                emptyState
            } else {
                dashboardContent
            }
        }
        .id(selectedThemeRaw)
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showAddSheet = true
                        HapticManager.shared.impact(style: .light)
                    } label: {
                        Label("Add Transaction", systemImage: "dollarsign.circle")
                    }
                    
                    Button {
                        showAddBudget = true
                        HapticManager.shared.impact(style: .light)
                    } label: {
                        Label("Add Budget Goal", systemImage: "target")
                    }
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .imageScale(.large)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTransactionView()
        }
        .sheet(isPresented: $showAddBudget) {
            AddBudgetGoalView()
        }
        .sheet(isPresented: $showAllBudgets) {
            NavigationStack {
                BudgetGoalsView()
            }
        }
    }
    
    // MARK: - Views
    
    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                statsSection
                
                // Budget Section (appears after stats, before category breakdown)
                if !activeBudgets.isEmpty {
                    budgetSection
                }
                
                categoryBreakdownSection
            }
            .padding()
        }
    }
    
    private var statsSection: some View {
        VStack(spacing: 12) {
            // Income
            StatCardView(
                title: "Total Income",
                value: totalIncome.asCurrency(currencyCode: currencyCode),
                icon: "arrow.down.circle.fill",
                gradientColors: [.green, .green.opacity(0.7)]
            )
            .transition(.scale.combined(with: .opacity))
            
            // Expenses
            StatCardView(
                title: "Total Expenses",
                value: totalExpense.asCurrency(currencyCode: currencyCode),
                icon: "arrow.up.circle.fill",
                gradientColors: [.red, .red.opacity(0.7)]
            )
            .transition(.scale.combined(with: .opacity))
            
            // Balance
            StatCardView(
                title: "Balance",
                value: balance.asCurrency(currencyCode: currencyCode),
                icon: "dollarsign.circle.fill",
                gradientColors: balance >= 0 ? [.blue, .purple] : [.orange, .red]
            )
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    // Budget Section
    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Budget Goals")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    showAllBudgets = true
                    HapticManager.shared.impact(style: .light)
                } label: {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
            }
            
            // Show first 2 budgets only
            ForEach(activeBudgets.prefix(2)) { budget in
                BudgetProgressView(budget: budget, transactions: transactions)
                    .onTapGesture {
                        showAllBudgets = true
                        HapticManager.shared.impact(style: .light)
                    }
            }
            
            // Show count if more budgets exist
            if activeBudgets.count > 2 {
                Button {
                    showAllBudgets = true
                    HapticManager.shared.impact(style: .light)
                } label: {
                    HStack {
                        Text("+\(activeBudgets.count - 2) more \(activeBudgets.count - 2 == 1 ? "budget" : "budgets")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.background)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending by Category")
                .font(.title2)
                .fontWeight(.bold)
            
            if expensesByCategory.isEmpty {
                ContentUnavailableView(
                    "No Expenses Yet",
                    systemImage: "chart.pie",
                    description: Text("Add some expenses to see breakdown")
                )
                .frame(height: 200)
            } else {
                VStack(spacing: 0) {
                    ForEach(expensesByCategory, id: \.category) { item in
                        CategoryRowView(
                            category: item.category,
                            amount: item.amount,
                            percentage: item.percentage
                        )
                        
                        if item.category != expensesByCategory.last?.category {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            ContentUnavailableView(
                "No Data Yet",
                systemImage: "chart.bar.fill",
                description: Text("Add transactions and budget goals to see your financial overview")
            )
            Button {
                showAddSheet = true
                HapticManager.shared.impact(style: .medium)
            } label: {
                Label("Add Transaction", systemImage: "dollarsign.circle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.bottom, 5)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(previewContainer())
}
