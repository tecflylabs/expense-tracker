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
    
    @State private var showAddSheet = false
    
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
    
    var body: some View {
        Group {
            if transactions.isEmpty {
                emptyState
            } else {
                dashboardContent
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTransactionView()
        }
    }
    
    // MARK: - Views
    
    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                statsSection
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
                value: totalIncome.asCurrency(),
                icon: "arrow.down.circle.fill",
                gradientColors: [.green, .green.opacity(0.7)]
            )
            .transition(.scale.combined(with: .opacity))
            
            // Expenses
            StatCardView(
                title: "Total Expenses",
                value: totalExpense.asCurrency(),
                icon: "arrow.up.circle.fill",
                gradientColors: [.red, .red.opacity(0.7)]
            )
            .transition(.scale.combined(with: .opacity))
            
            // Balance
            StatCardView(
                title: "Balance",
                value: balance.asCurrency(),
                icon: "dollarsign.circle.fill",
                gradientColors: balance >= 0 ? [.blue, .purple] : [.orange, .red]
            )
            .transition(.scale.combined(with: .opacity))
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
        ContentUnavailableView(
            "No Data Yet",
            systemImage: "chart.bar.fill",
            description: Text("Add transactions to see your financial overview")
        )
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(previewContainer())
}
