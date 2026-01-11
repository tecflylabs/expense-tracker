//
//  BudgetGoalsView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 04.01.26.
//

import SwiftUI
import SwiftData

struct BudgetGoalsView: View {
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    @Environment(\.modelContext) private var modelContext
    @Query private var budgets: [BudgetGoal]
    @Query private var transactions: [Transaction]
    
    @State private var showingAddBudget = false
    
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue
    
    var body: some View {
        NavigationStack {
            Group {
                if budgets.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            
                            overviewCard
                            
                            
                            ForEach(budgets.filter { $0.isActive }) { budget in
                                BudgetProgressView(budget: budget, transactions: transactions)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deleteBudget(budget)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .id(selectedThemeRaw)
            .navigationTitle("Budget Goals")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddBudget = true
                        HapticManager.shared.impact(style: .light)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetGoalView()
            }
        }
    }
    
    // MARK: - Overview Card
    
    private var overviewCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Monthly Budget")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(totalBudget.asCurrency(currencyCode: currencyCode))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Spent")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(totalSpent.asCurrency(currencyCode: currencyCode))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(totalSpent > totalBudget ? .red : .primary)
                }
            }
            
            Divider()
            
            HStack {
                Image(systemName: overallWarningLevel.icon)
                    .foregroundStyle(Color(overallWarningLevel.color))
                
                Text(overallWarningLevel.message)
                    .font(.subheadline)
                    .foregroundStyle(Color(overallWarningLevel.color))
                
                Spacer()
                
                Text("Remaining: \(totalRemaining.asCurrency(currencyCode: currencyCode))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(totalRemaining < 0 ? .red : .secondary)
            }
        }
        .padding()
        .background(Color.brandOrange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Budget Goals",
            systemImage: "target",
            description: Text("Set monthly spending limits to track your expenses better")
        )
    }
    
    // MARK: - Computed Properties
    
    private var totalBudget: Double {
        budgets.filter { $0.isActive }.reduce(0) { $0 + $1.monthlyLimit }
    }
    
    private var totalSpent: Double {
        budgets.filter { $0.isActive }.reduce(0) { $0 + $1.currentSpent(transactions: transactions) }
    }
    
    private var totalRemaining: Double {
        totalBudget - totalSpent
    }
    
    private var overallWarningLevel: BudgetWarningLevel {
        let progress = totalBudget > 0 ? totalSpent / totalBudget : 0
        
        if progress >= 1.0 {
            return .exceeded
        } else if progress >= 0.9 {
            return .critical
        } else if progress >= 0.75 {
            return .warning
        } else {
            return .safe
        }
    }
    
    // MARK: - Actions
    
    private func deleteBudget(_ budget: BudgetGoal) {
        modelContext.delete(budget)
        HapticManager.shared.notification(type: .success)
    }
}

#Preview {
    BudgetGoalsView()
        .modelContainer(for: [BudgetGoal.self, Transaction.self], inMemory: true)
}
