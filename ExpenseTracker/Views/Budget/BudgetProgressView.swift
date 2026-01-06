//
//  BudgetProgressView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 04.01.26.
//

import SwiftUI

struct BudgetProgressView: View {
    let budget: BudgetGoal
    let transactions: [Transaction]
    
    private var spent: Double {
        budget.currentSpent(transactions: transactions)
    }
    
    private var remaining: Double {
        budget.remaining(transactions: transactions)
    }
    
    private var progress: Double {
        budget.progress(transactions: transactions)
    }
    
    private var warningLevel: BudgetWarningLevel {
        budget.warningLevel(transactions: transactions)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header - ✨ NOW WITH CATEGORY COLORS
            HStack {
                Image(systemName: budget.category.systemImage)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(budget.category.gradient)
                    )
                
                Text(budget.category.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: warningLevel.icon)
                    .foregroundStyle(warningLevel.color)
                    .imageScale(.small)
            }
            
            // Progress Bar - ✨ Warning color takes priority
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                    
                    // Progress - Warning color overrides category color
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(warningLevel.color),
                                    Color(warningLevel.color).opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                        .animation(.spring(duration: 0.3), value: progress)
                }
            }
            .frame(height: 12)
            
            // Stats
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(spent.asCurrency())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text(warningLevel.message)
                        .font(.caption)
                        .foregroundStyle(warningLevel.color)
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(remaining.asCurrency())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(remaining < 0 ? .red : .primary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    let previewBudget = BudgetGoal(category: .food, monthlyLimit: 500)
    let previewTransactions = [
        Transaction(title: "Groceries", amount: 375, date: Date(), category: .food, type: .expense)
    ]
    
    return VStack(spacing: 16) {
        BudgetProgressView(budget: previewBudget, transactions: previewTransactions)
        
        BudgetProgressView(
            budget: BudgetGoal(category: .transport, monthlyLimit: 200),
            transactions: [Transaction(title: "Uber", amount: 50, date: Date(), category: .transport, type: .expense)]
        )
    }
    .padding()
}
